import logging
import json
import requests
from celery import shared_task
from django.conf import settings
from django.utils import timezone

from apps.ai.audit import audit_ai_call

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
            resp = requests.post(
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
        resp = requests.post(
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

    # Find the activity in the schedule by key
    activity_info = None
    for entry in (programme.schedule or []):
        key = f"w{entry.get('week')}_d{entry.get('day')}_{entry.get('time_of_day', 'any')}"
        if key == activity_key or entry.get('activity_key') == activity_key:
            activity_info = entry
            break

    activity_name = 'your next activity'
    if activity_info and isinstance(activity_info.get('activity'), dict):
        activity_name = activity_info['activity'].get('name', activity_name)

    title = f'⏰ Starting in {minutes_before} min: {activity_name}'
    body = f'Your "{programme.title}" activity is about to start. Get ready!'

    # Check subscriber notification config
    subscriber_config = purchase.notification_config or {}
    programme_config = programme.notification_config or {}

    remind_key = 'remind_30min' if minutes_before == 30 else 'remind_15min'
    should_remind = subscriber_config.get(remind_key, programme_config.get(remind_key, True))

    if not should_remind:
        return

    # In-app notification
    notification = Notification.objects.create(
        recipient=buyer,
        notification_type='programme_reminder',
        title=title,
        body=body,
        metadata={
            'programme_id': str(programme.id),
            'purchase_id': str(purchase.id),
            'activity_key': activity_key,
            'minutes_before': minutes_before,
        },
    )

    # Push to all buyer's devices
    _push_notification_to_profile(
        buyer, title, body,
        {'type': 'programme_reminder', 'programme_id': str(programme.id), 'activity_key': activity_key},
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

    # Merge default notification config from programme into purchase
    programme_config = purchase.programme.notification_config or {}
    if not purchase.notification_config:
        purchase.notification_config = {
            'remind_30min': programme_config.get('remind_30min', True),
            'remind_15min': programme_config.get('remind_15min', True),
            'custom_msg': programme_config.get('custom_msg', ''),
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

    # Map time_of_day labels to rough hour ranges
    TIME_RANGES = {
        'morning': (6, 9),
        'midday': (11, 13),
        'afternoon': (14, 17),
        'evening': (18, 21),
    }

    for purchase in MealPlanPurchase.objects.select_related('meal_plan', 'buyer').filter(
        meal_plan__is_published=True
    ):
        # Get subscriber settings, fall back to plan defaults
        sub_config = purchase.reminder_settings or {}
        plan_config = purchase.meal_plan.reminder_settings or {}
        merged = {**plan_config, **sub_config}

        if not merged.get('enabled', False):
            continue

        time_of_day = merged.get('time_of_day', 'morning')
        hour_range = TIME_RANGES.get(time_of_day, (6, 9))

        if not (hour_range[0] <= current_hour < hour_range[1]):
            continue

        plan = purchase.meal_plan
        buyer = purchase.buyer
        custom_msg = merged.get('message_template', f'Time for your meal plan: "{plan.title}"! 🥗')

        title = f'🥗 Meal Reminder: {plan.title}'
        body = custom_msg

        # In-app
        Notification.objects.create(
            recipient=buyer,
            notification_type='meal_reminder',
            title=title,
            body=body,
            metadata={'meal_plan_id': str(plan.id), 'purchase_id': str(purchase.id)},
        )

        # Push
        _push_notification_to_profile(
            buyer, title, body,
            {'type': 'meal_reminder', 'meal_plan_id': str(plan.id)},
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
    from .models import EventTicket, MarketplaceEvent
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
