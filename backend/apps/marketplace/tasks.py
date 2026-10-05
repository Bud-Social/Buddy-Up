import logging
import json
import requests
from celery import shared_task
from django.conf import settings
from django.utils import timezone

from apps.ai.audit import audit_ai_call
from apps.ai.client import ai_post

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Utility: send push to a single device token
# ---------------------------------------------------------------------------

def _send_push_to_device(platform: str, token: str, title: str, body: str, data: dict = None):
    """Dispatch push notification to a single device token (FCM / Web Push)."""
    data = data or {}

    if platform == 'fcm':
        # Use FCM HTTP v1 API via a simple REST call
        fcm_key = getattr(settings, 'FCM_SERVER_KEY', '')
        if not fcm_key:
            return
        try:
            payload = {
                'to': token,
                'notification': {'title': title, 'body': body},
                'data': data,
                'priority': 'high',
            }
            resp = ai_post(
                'https://fcm.googleapis.com/fcm/send',
                headers={'Authorization': f'key={fcm_key}', 'Content-Type': 'application/json'},
                json=payload,
                timeout=10,
            )
            resp.raise_for_status()
        except Exception as exc:  # noqa: BLE001
            logger.warning('FCM push failed for token %s: %s', token[:20], exc)

    elif platform == 'web':
        # Web Push via pywebpush
        vapid_private = getattr(settings, 'VAPID_PRIVATE_KEY', '')
        vapid_email = getattr(settings, 'VAPID_CLAIM_EMAIL', 'admin@buddyup.app')
        if not vapid_private:
            return
        try:
            from pywebpush import webpush
            subscription_info = json.loads(token)
            webpush(
                subscription_info=subscription_info,
                data=json.dumps({'title': title, 'body': body, 'data': data}),
                vapid_private_key=vapid_private,
                vapid_claims={'sub': f'mailto:{vapid_email}'},
            )
        except Exception as exc:  # noqa: BLE001
            logger.warning('Web Push failed: %s', exc)


def _push_notification_to_profile(profile, title: str, body: str, data: dict = None):
    """Push to all active devices of a profile."""
    from apps.marketplace.models import PushDevice
    devices = PushDevice.objects.filter(profile=profile, is_active=True)
    for device in devices:
        _send_push_to_device(device.platform, device.token, title, body, data)


# ---------------------------------------------------------------------------
# Existing task: personalise_meal_plan
# ---------------------------------------------------------------------------

@shared_task(bind=True, max_retries=3, default_retry_delay=30)
def personalise_meal_plan(self, purchase_id: str, profile_id: str):
    from .models import MealPlanPurchase
    from apps.profiles.models import Profile

    try:
        purchase = MealPlanPurchase.objects.select_related('meal_plan', 'buyer').get(id=purchase_id)
        profile = Profile.objects.get(user_id=profile_id)
    except (MealPlanPurchase.DoesNotExist, Profile.DoesNotExist):
        return

    plan = purchase.meal_plan
    user_prefs = profile.user.preferences or {}

    payload = {
        'profile_summary': f'Age: {profile.user.date_of_birth}, Goals: {user_prefs.get("goals", "")}, Activity: {user_prefs.get("activity_level", "")}',
        'goals': user_prefs.get('goals', ''),
        'dietary_preferences': plan.diet_type.split(',') if plan.diet_type else [],
        'allergies': user_prefs.get('allergies', []),
        'calorie_target': user_prefs.get('calorie_target'),
        'plan_template': {
            'title': plan.title,
            'description': plan.description,
            'duration_weeks': plan.duration_weeks,
            'calorie_range': plan.calorie_range,
            'full_plan': plan.full_plan,
            'shopping_list': plan.shopping_list,
        },
    }

    try:
        resp = ai_post(
            f'{settings.AI_SERVICE_URL}/api/v1/meal-plans/personalise',
            json=payload,
            timeout=30,
        )
        resp.raise_for_status()
        ai_result = resp.json()
        audit_ai_call('meal_plan_personalise', input_data=payload, output_data=ai_result)
        personalised = {
            'adjusted_portions': ai_result.get('adjusted_portions', True),
            'substitutions': ai_result.get('substitutions', []),
            'macro_summary': ai_result.get('macro_summary', {}),
            'shopping_list': ai_result.get('shopping_list', plan.shopping_list),
            'notes': ai_result.get('notes', ''),
            'generated_at': timezone.now().isoformat(),
        }
    except requests.RequestException as exc:
        logger.warning('AI service unavailable for purchase %s: %s', purchase_id, exc)
        try:
            self.retry(exc=exc)
        except self.MaxRetriesExceededError:
            personalised = {
                'adjusted_portions': True,
                'substitutions': [],
                'macro_summary': {},
                'shopping_list': plan.shopping_list,
                'notes': 'Personalisation is temporarily unavailable. Your meal plan has been applied with default settings.',
                'generated_at': timezone.now().isoformat(),
            }

    purchase.is_personalised = True
    purchase.personalised_data = personalised
    purchase.save(update_fields=['is_personalised', 'personalised_data'])

    from apps.notifications.models import Notification
    notification = Notification.objects.create(
        recipient=purchase.buyer,
        notification_type='payment_received',
        title='Your personalised meal plan is ready!',
        body=f'"{plan.title}" has been personalised based on your goals and preferences.',
        metadata={'meal_plan_id': str(plan.id), 'purchase_id': str(purchase.id)},
    )
    _push_notification_to_profile(
        purchase.buyer,
        notification.title, notification.body,
        {'type': 'meal_plan_ready', 'meal_plan_id': str(plan.id)},
    )


# ---------------------------------------------------------------------------
# Unified reminder helpers: per-block `timing` enum
# (morning/midday/afternoon/evening/anytime) + global frequency (15m/30m/1h).
# Programme blocks carry `timing`; meal blocks carry `timing` (or legacy
# `time_of_day` label / HH:MM string). Global configs carry `frequency`
# alongside legacy keys for backwards compatibility.
# ---------------------------------------------------------------------------

TIMING_HOUR_RANGES = {
    'morning': (5, 11),
    'midday': (11, 14),
    'afternoon': (14, 18),
    'evening': (18, 23),
    'anytime': (5, 23),
}

FREQUENCY_MINUTES = {'15m': 15, '30m': 30, '1h': 60}


def _normalize_timing(value, default='anytime'):
    """Normalize a per-block timing value to the shared enum."""
    if not isinstance(value, str):
        return default
    v = value.strip().lower()
    if v in TIMING_HOUR_RANGES:
        return v
    # Legacy web label "mid-day" etc.
    if v in ('mid-day', 'mid_day'):
        return 'midday'
    return default


def _timing_matches_hour(timing, hour):
    """Check whether a timing enum covers the given wall-clock hour."""
    start, end = TIMING_HOUR_RANGES.get(_normalize_timing(timing), (5, 23))
    return start <= hour < end


def _frequency_to_minutes(config, fallback=30):
    """Read global frequency ('15m'/'30m'/'1h' or int minutes) from a config dict."""
    if not isinstance(config, dict):
        return fallback
    freq = config.get('frequency', config.get('reminder_frequency'))
    if isinstance(freq, str):
        freq = freq.strip().lower()
        if freq in FREQUENCY_MINUTES:
            return FREQUENCY_MINUTES[freq]
        try:
            return int(freq)
        except (TypeError, ValueError):
            pass
    if isinstance(freq, (int, float)):
        return int(freq)
    return fallback


def _iter_programme_blocks(schedule):
    """Yield normalized activity blocks from list- or dict-shaped schedules.

    New web shape: {week_N: {day_M: [{title, duration_mins, timing, ...}]}}.
    Legacy shape: [{week, day, time_of_day/timing, activity: {name}}].
    """
    if isinstance(schedule, dict):
        for week_key, days in schedule.items():
            try:
                week = int(str(week_key).replace('week_', ''))
            except (TypeError, ValueError):
                week = 1
            if not isinstance(days, dict):
                continue
            for day_key, activities in days.items():
                try:
                    day = int(str(day_key).replace('day_', ''))
                except (TypeError, ValueError):
                    day = 1
                for idx, a in enumerate(activities or []):
                    if not isinstance(a, dict):
                        continue
                    yield {
                        'week': week,
                        'day': day,
                        'index': idx,
                        'timing': _normalize_timing(a.get('timing', a.get('time_of_day', 'anytime'))),
                        'title': a.get('title') or (a.get('activity') or {}).get('name', ''),
                        'activity_key': a.get('activity_key') or f'w{week}_d{day}_{_normalize_timing(a.get("timing", "anytime"))}_{idx}',
                        'raw': a,
                    }
    elif isinstance(schedule, list):
        for idx, entry in enumerate(schedule):
            if not isinstance(entry, dict):
                continue
            activity = entry.get('activity') if isinstance(entry.get('activity'), dict) else {}
            yield {
                'week': entry.get('week', 1),
                'day': entry.get('day', 1),
                'index': idx,
                'timing': _normalize_timing(entry.get('timing', entry.get('time_of_day', 'anytime'))),
                'title': entry.get('title') or activity.get('name', ''),
                'activity_key': entry.get('activity_key') or (
                    f"w{entry.get('week')}_d{entry.get('day')}_{entry.get('time_of_day', 'any')}"
                ),
                'raw': entry,
            }


def _iter_meal_blocks(full_plan):
    """Yield normalized meal blocks from the full_plan dict.

    New web shape: {week_N: {day_M: [{slot, title, timing, ...}]}}.
    """
    if not isinstance(full_plan, dict):
        return
    for week_key, days in full_plan.items():
        try:
            week = int(str(week_key).replace('week_', ''))
        except (TypeError, ValueError):
            week = 1
        if not isinstance(days, dict):
            continue
        for day_key, meals in days.items():
            try:
                day = int(str(day_key).replace('day_', ''))
            except (TypeError, ValueError):
                day = 1
            for idx, m in enumerate(meals or []):
                if not isinstance(m, dict):
                    continue
                yield {
                    'week': week,
                    'day': day,
                    'index': idx,
                    'timing': _normalize_timing(m.get('timing', m.get('time_of_day', 'anytime'))),
                    'title': m.get('title', ''),
                    'raw': m,
                }


def _parse_global_meal_hour(time_of_day, default_hour=8):
    """Accept HH:MM ('08:00') or a timing-enum label; return an hour int."""
    if isinstance(time_of_day, str) and ':' in time_of_day:
        try:
            return int(time_of_day.split(':')[0]) % 24
        except (TypeError, ValueError):
            return default_hour
    start, _ = TIMING_HOUR_RANGES.get(_normalize_timing(time_of_day, 'morning'), (6, 9))
    return start


# ---------------------------------------------------------------------------
# NEW: Programme activity reminders (30-min and 15-min)
# ---------------------------------------------------------------------------

@shared_task
def send_programme_activity_reminder(purchase_id: str, activity_key: str, minutes_before: int = 30):
    """
    Send a reminder push + in-app notification to a subscriber about an upcoming activity.
    Called by Celery beat or a scheduled task set at purchase time.
    """
    from .models import TrainingProgrammePurchase
    from apps.notifications.models import Notification

    try:
        purchase = TrainingProgrammePurchase.objects.select_related(
            'buyer', 'programme'
        ).get(id=purchase_id)
    except TrainingProgrammePurchase.DoesNotExist:
        return

    programme = purchase.programme
    buyer = purchase.buyer

    # Find the activity in the schedule by key (supports list + dict shapes)
    activity_info = None
    for block in _iter_programme_blocks(programme.schedule or []):
        if block['activity_key'] == activity_key:
            activity_info = block
            break

    activity_name = 'your next activity'
    activity_timing = 'anytime'
    if activity_info:
        activity_name = activity_info.get('title') or activity_name
        activity_timing = activity_info.get('timing', 'anytime')

    # Check subscriber notification config (unified: enabled + frequency,
    # with legacy remind_30min/remind_15min fallback)
    subscriber_config = purchase.notification_config or {}
    programme_config = programme.notification_config or {}
    merged_config = {**programme_config, **subscriber_config}

    if not merged_config.get('enabled', True):
        return

    configured_minutes = _frequency_to_minutes(merged_config, fallback=minutes_before)
    effective_minutes = minutes_before or configured_minutes
    # Legacy per-window opt-outs still respected when present.
    remind_key = 'remind_30min' if effective_minutes == 30 else 'remind_15min'
    if remind_key in merged_config and not merged_config.get(remind_key, True):
        return

    custom_message = merged_config.get('custom_message') or merged_config.get('custom_msg', '')
    title = f'⏰ Starting in {effective_minutes} min: {activity_name}'
    body = custom_message or f'Your "{programme.title}" activity is about to start. Get ready!'
    metadata = {
        'programme_id': str(programme.id),
        'purchase_id': str(purchase.id),
        'activity_key': activity_key,
        'minutes_before': effective_minutes,
        'timing': activity_timing,
        'frequency': merged_config.get('frequency', f'{effective_minutes}m'),
    }

    # In-app notification
    notification = Notification.objects.create(
        recipient=buyer,
        notification_type='programme_reminder',
        title=title,
        body=body,
        metadata=metadata,
    )

    # Push to all buyer's devices
    _push_notification_to_profile(
        buyer, title, body,
        {'type': 'programme_reminder', 'programme_id': str(programme.id), 'activity_key': activity_key,
         'timing': activity_timing},
    )

    # WebSocket real-time notification
    try:
        from asgiref.sync import async_to_sync
        from channels.layers import get_channel_layer
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            f'user_{buyer.user_id}',
            {
                'type': 'event_notification',
                'data': {
                    'id': str(notification.id),
                    'type': 'programme_reminder',
                    'title': title,
                    'body': body,
                    'metadata': notification.metadata,
                },
            },
        )
    except Exception:  # noqa: BLE001
        pass


@shared_task
def schedule_programme_reminders_for_purchase(purchase_id: str):
    """
    After a programme is purchased, compute scheduled datetimes for each activity
    and enqueue 30-min and 15-min reminder tasks accordingly.
    Placeholder: in production, use Celery Beat or a cron approach
    because we don't know exact datetimes of future workouts.
    This task instead registers the subscriber's preference so reminders
    can be dispatched when the subscriber marks an activity as 'in_progress'.
    """
    from .models import TrainingProgrammePurchase
    try:
        purchase = TrainingProgrammePurchase.objects.select_related('programme').get(id=purchase_id)
    except TrainingProgrammePurchase.DoesNotExist:
        return

    # Merge default notification config from programme into purchase.
    # Unified shape: {enabled, frequency ('15m'/'30m'/'1h'), timing default,
    # custom_message} with legacy remind_30min/remind_15min/custom_msg kept.
    programme_config = purchase.programme.notification_config or {}
    if not purchase.notification_config:
        purchase.notification_config = {
            'enabled': programme_config.get('enabled', True),
            'frequency': programme_config.get('frequency', '30m'),
            'timing': _normalize_timing(programme_config.get('timing', 'anytime')),
            'custom_message': programme_config.get('custom_message', programme_config.get('custom_msg', '')),
            'remind_30min': programme_config.get('remind_30min', True),
            'remind_15min': programme_config.get('remind_15min', True),
            'custom_msg': programme_config.get('custom_msg', programme_config.get('custom_message', '')),
        }
        purchase.save(update_fields=['notification_config'])


# ---------------------------------------------------------------------------
# NEW: Meal plan daily reminders
# ---------------------------------------------------------------------------

@shared_task
def send_meal_plan_daily_reminders():
    """
    Celery Beat periodic task (run daily). Sends meal plan reminders to all
    subscribers whose reminder_settings are enabled and time_of_day matches now.
    """
    from .models import MealPlanPurchase
    from apps.notifications.models import Notification

    now = timezone.localtime()
    current_hour = now.hour

    for purchase in MealPlanPurchase.objects.select_related('meal_plan', 'buyer').filter(
        meal_plan__is_published=True
    ):
        # Get subscriber settings, fall back to plan defaults.
        # Unified shape: {enabled, frequency, time_of_day (HH:MM legacy or
        # timing-enum label), timing default, message_template}.
        sub_config = purchase.reminder_settings or {}
        plan_config = purchase.meal_plan.reminder_settings or {}
        merged = {**plan_config, **sub_config}

        if not merged.get('enabled', False):
            continue

        # Per-block timing wins when the plan has structured blocks;
        # otherwise fall back to the global time_of_day (HH:MM or enum).
        blocks = list(_iter_meal_blocks(purchase.meal_plan.full_plan or {}))
        if blocks:
            if not any(_timing_matches_hour(b['timing'], current_hour) for b in blocks):
                continue
            matched_timings = sorted({b['timing'] for b in blocks if _timing_matches_hour(b['timing'], current_hour)})
        else:
            global_hour = _parse_global_meal_hour(merged.get('time_of_day', 'morning'))
            if current_hour != global_hour:
                continue
            matched_timings = [_normalize_timing(merged.get('timing', merged.get('time_of_day', 'morning')))]

        plan = purchase.meal_plan
        buyer = purchase.buyer
        custom_msg = merged.get('message_template', f'Time for your meal plan: "{plan.title}"! 🥗')
        frequency = merged.get('frequency', '1h')

        title = f'🥗 Meal Reminder: {plan.title}'
        body = custom_msg

        # In-app
        Notification.objects.create(
            recipient=buyer,
            notification_type='meal_reminder',
            title=title,
            body=body,
            metadata={'meal_plan_id': str(plan.id), 'purchase_id': str(purchase.id),
                      'timings': matched_timings, 'frequency': frequency},
        )

        # Push
        _push_notification_to_profile(
            buyer, title, body,
            {'type': 'meal_reminder', 'meal_plan_id': str(plan.id),
             'timings': matched_timings, 'frequency': frequency},
        )


# ---------------------------------------------------------------------------
# NEW: Event ticket confirmation (in-app + push + email with QR)
# ---------------------------------------------------------------------------

@shared_task
def send_ticket_confirmation(ticket_id: str):
    """
    After a ticket is purchased, notify the holder (in-app + push) and email
    them the ticket with a scannable QR code. Email delivery falls back to the
    console backend in development when no SMTP credentials are configured.
    """
    import base64
    import qrcode
    from io import BytesIO
    from django.core.mail import send_mail
    from django.template.loader import render_to_string
    from django.utils.html import strip_tags
    from .models import EventTicket
    from apps.notifications.models import Notification

    try:
        ticket = EventTicket.objects.select_related('event', 'holder').get(id=ticket_id)
    except EventTicket.DoesNotExist:
        return

    event = ticket.event
    holder = ticket.holder
    start = timezone.localtime(event.start_datetime)

    qr_data_uri = None
    try:
        qr = qrcode.QRCode(box_size=10, border=4)
        qr.add_data(str(ticket.ticket_code))
        qr.make(fit=True)
        img = qr.make_image(fill='black', back_color='white')
        buf = BytesIO()
        img.save(buf, format='PNG')
        qr_data_uri = 'data:image/png;base64,' + base64.b64encode(buf.getvalue()).decode()
    except Exception:  # noqa: BLE001
        pass

    # In-app notification
    notification = Notification.objects.create(
        recipient=holder,
        notification_type='ticket_confirmed',
        title=f'🎟️ Ticket confirmed: {event.title}',
        body=f'{start.strftime("%a, %b %d at %I:%M %p")} · {event.location or "Online event"}',
        metadata={'event_id': str(event.id), 'ticket_id': str(ticket.id)},
    )

    # Push
    _push_notification_to_profile(
        holder, notification.title, notification.body,
        {'type': 'ticket_confirmed', 'event_id': str(event.id), 'ticket_id': str(ticket.id)},
    )

    # WebSocket real-time notification
    try:
        from asgiref.sync import async_to_sync
        from channels.layers import get_channel_layer
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            f'user_{holder.user_id}',
            {
                'type': 'event_notification',
                'data': {
                    'id': str(notification.id),
                    'type': 'ticket_confirmed',
                    'title': notification.title,
                    'body': notification.body,
                    'metadata': notification.metadata,
                },
            },
        )
    except Exception:  # noqa: BLE001
        pass

    # Email with QR
    if holder.user.email:
        try:
            html = render_to_string('emails/ticket.html', {
                'username': holder.user.email.split('@')[0],
                'display_name': holder.display_name,
                'event': event,
                'ticket': ticket,
                'start_datetime': start,
                'qr_data_uri': qr_data_uri,
                'ticket_code': ticket.ticket_code,
            })
            plain = strip_tags(html)
            send_mail(
                subject=f'Your ticket for {event.title} 🎟️',
                message=plain,
                html_message=html,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[holder.user.email],
                fail_silently=False,
            )
        except Exception as exc:  # noqa: BLE001
            logger.warning('Ticket email failed for %s: %s', holder.user_id, exc)


# ---------------------------------------------------------------------------
# NEW: Event-day ticket reminders (Celery Beat, every 15 min)
# ---------------------------------------------------------------------------

@shared_task
def send_event_ticket_reminders():
    """
    Periodic task: remind ticket holders whose event starts within the next
    24 hours (once per event per holder). Skips events that are cancelled or
    already started, and avoids duplicate reminders via a matching Notification.
    """
    from datetime import timedelta
    from .models import MarketplaceEvent
    from apps.notifications.models import Notification

    now = timezone.now()
    window_start = now + timedelta(hours=23, minutes=45)
    window_end = now + timedelta(hours=24, minutes=15)

    events = MarketplaceEvent.objects.filter(
        is_cancelled=False,
        start_datetime__gte=window_start,
        start_datetime__lte=window_end,
    )

    for event in events:
        for ticket in event.tickets.select_related('holder').filter(status='active'):
            if Notification.objects.filter(
                recipient=ticket.holder,
                notification_type='event_reminder',
                metadata__event_id=str(event.id),
            ).exists():
                continue

            start = timezone.localtime(event.start_datetime)
            title = f'⏰ Tomorrow: {event.title}'
            body = (f'{start.strftime("%a, %b %d at %I:%M %p")} · '
                    f'{event.location or "Online event"} — see you there!')

            Notification.objects.create(
                recipient=ticket.holder,
                notification_type='event_reminder',
                title=title,
                body=body,
                metadata={'event_id': str(event.id), 'ticket_id': str(ticket.id)},
            )

            _push_notification_to_profile(
                ticket.holder, title, body,
                {'type': 'event_reminder', 'event_id': str(event.id), 'ticket_id': str(ticket.id)},
            )
