from celery import shared_task
from django.core.mail import send_mail, get_connection
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.conf import settings
from django.utils import timezone
from datetime import timedelta
from django.db.models import Q
import logging
import smtplib

logger = logging.getLogger(__name__)


def _send_mail_with_fallback(subject, message, html_message, from_email, recipient_list):
    """Send email using primary SMTP password; fall back to EMAIL_HOST_PASSWORD_FALLBACK
    on authentication errors (e.g. after password rotation)."""
    fallback_pw = getattr(settings, 'EMAIL_HOST_PASSWORD_FALLBACK', '')
    if not fallback_pw:
        # No fallback configured — just send normally.
        send_mail(
            subject=subject, message=message, html_message=html_message,
            from_email=from_email, recipient_list=recipient_list,
            fail_silently=False,
        )
        return

    conn = get_connection()
    try:
        conn.open()
        send_mail(
            subject=subject, message=message, html_message=html_message,
            from_email=from_email, recipient_list=recipient_list,
            connection=conn,
        )
        conn.close()
    except (smtplib.SMTPAuthenticationError, smtplib.SMTPNotSupportedError):
        logger.warning(
            'Primary SMTP password failed for %s, retrying with fallback password',
            from_email,
        )
        conn.close()
        # Re-open with the fallback password — Django's email backend
        # accepts password as a constructor kwarg via get_connection().
        conn = get_connection(password=fallback_pw)
        conn.open()
        send_mail(
            subject=subject, message=message, html_message=html_message,
            from_email=from_email, recipient_list=recipient_list,
            connection=conn,
        )
        conn.close()
    except Exception:
        conn.close()
        raise


def sms_delivery_configured() -> bool:
    return bool(
        getattr(settings, 'AFRICASTALKING_USERNAME', '')
        and getattr(settings, 'AFRICASTALKING_API_KEY', '')
    )


@shared_task(bind=True, max_retries=3, default_retry_delay=10)
def send_otp_email(self, user_id: str, otp: str, purpose: str = 'registration'):
    import logging
    logger = logging.getLogger(__name__)

    # Log initialisation with env-variable fetch status
    logger.info(
        'send_otp_email INIT user_id=%s purpose=%s '
        'email_host=%s email_port=%s email_user=%s '
        'has_password=%s has_fallback=%s '
        'backend=%s',
        user_id, purpose,
        getattr(settings, 'EMAIL_HOST', ''),
        getattr(settings, 'EMAIL_PORT', ''),
        getattr(settings, 'EMAIL_HOST_USER', ''),
        bool(getattr(settings, 'EMAIL_HOST_PASSWORD', '')),
        bool(getattr(settings, 'EMAIL_HOST_PASSWORD_FALLBACK', '')),
        getattr(settings, 'EMAIL_BACKEND', ''),
    )

    from .models import User
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        logger.warning('send_otp_email ABORT - user not found user_id=%s', user_id)
        return

    username = user.email.split('@')[0]
    subject = {
        'registration': 'Verify your BuddyUp Fit email',
        'login': 'Your BuddyUp Fit login code',
        'password_reset': 'Reset your BuddyUp Fit password',
    }.get(purpose, 'Your BuddyUp Fit verification code')

    logo_url = getattr(settings, 'EMAIL_LOGO_URL', '') or (
        f"{getattr(settings, 'PUBLIC_FRONTEND_URL', 'https://buddyup.app').rstrip('/')}"
        "/icons/icon-512.png"
    )

    html = render_to_string('emails/otp.html', {
        'username': username,
        'otp': otp,
        'otp_digits': list(otp),
        'purpose': purpose,
        'logo_url': logo_url,
    })
    plain = strip_tags(html)

    try:
        _send_mail_with_fallback(
            subject=subject,
            message=plain,
            html_message=html,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
        )
        logger.info(
            'send_otp_email SUCCESS user=%s purpose=%s to=%s provider=zoho',
            user.id, purpose, user.email,
        )
        # Developers running locally without a real mail backend must still
        # be able to complete the flow — surface the code in the worker log.
        if settings.DEBUG and 'console' in settings.EMAIL_BACKEND:
            logger.warning(
                'DEV OTP (console email backend) user=%s purpose=%s code=%s',
                user.id, purpose, otp,
            )
    except Exception as exc:  # noqa: BLE001 — retry transient SMTP/provider errors
        logger.exception(
            'send_otp_email FAILED user=%s purpose=%s to=%s provider=zoho error=%s',
            user.id, purpose, user.email, str(exc)[:200],
        )
        raise self.retry(exc=exc)


@shared_task(bind=True, max_retries=3, default_retry_delay=10)
def send_activation_email(self, user_id: str, activation_token: str):
    """Send account activation link via email."""
    import logging
    logger = logging.getLogger(__name__)

    logger.info(
        'send_activation_email INIT user_id=%s '
        'email_host=%s email_port=%s email_user=%s '
        'has_password=%s has_fallback=%s '
        'backend=%s',
        user_id,
        getattr(settings, 'EMAIL_HOST', ''),
        getattr(settings, 'EMAIL_PORT', ''),
        getattr(settings, 'EMAIL_HOST_USER', ''),
        bool(getattr(settings, 'EMAIL_HOST_PASSWORD', '')),
        bool(getattr(settings, 'EMAIL_HOST_PASSWORD_FALLBACK', '')),
        getattr(settings, 'EMAIL_BACKEND', ''),
    )

    from .models import User
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        logger.warning('send_activation_email ABORT - user not found user_id=%s', user_id)
        return

    username = user.email.split('@')[0]
    subject = 'Activate your BuddyUp Fit account'

    # Build the activation link
    frontend_url = getattr(settings, 'PUBLIC_FRONTEND_URL', 'https://buddyup.app').rstrip('/')
    activation_link = f"{frontend_url}/activate?token={activation_token}"

    logo_url = getattr(settings, 'EMAIL_LOGO_URL', '') or (
        f"{getattr(settings, 'PUBLIC_FRONTEND_URL', 'https://buddyup.app').rstrip('/')}"
        "/icons/icon-512.png"
    )

    html = render_to_string('emails/activation.html', {
        'username': username,
        'activation_link': activation_link,
        'logo_url': logo_url,
    })
    plain = strip_tags(html)

    try:
        _send_mail_with_fallback(
            subject='Activate your BuddyUp Fit account',
            message=plain,
            html_message=html,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
        )
        logger.info(
            'send_activation_email SUCCESS user=%s to=%s provider=zoho',
            user.id, user.email,
        )
        if settings.DEBUG and 'console' in settings.EMAIL_BACKEND:
            logger.warning(
                'DEV ACTIVATION LINK (console email backend) user=%s link=%s',
                user.id, activation_link,
            )
    except Exception as exc:  # noqa: BLE001
        logger.exception(
            'send_activation_email FAILED user=%s to=%s provider=zoho error=%s',
            user.id, user.email, str(exc)[:200],
        )
        raise self.retry(exc=exc)


@shared_task
def send_otp_sms(user_id: str, otp: str):
    """Send an OTP through Africa's Talking without exposing it in logs."""
    from .models import User
    import requests

    if not sms_delivery_configured():
        logger.error('SMS delivery requested but Africa\'s Talking is not configured')
        return False
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return False
    if not user.phone:
        logger.warning('SMS delivery requested for a user without a phone number')
        return False

    endpoint = getattr(
        settings, 'AFRICASTALKING_SMS_URL',
        'https://api.africastalking.com/version1/messaging',
    )
    try:
        response = requests.post(
            endpoint,
            headers={
                'apiKey': settings.AFRICASTALKING_API_KEY,
                'Accept': 'application/json',
            },
            data={
                'username': settings.AFRICASTALKING_USERNAME,
                'to': user.phone,
                'message': f'Your BuddyUp Fit verification code is {otp}. It expires in 10 minutes.',
            },
            timeout=(3.05, 10),
        )
        response.raise_for_status()
        return True
    except requests.RequestException:
        logger.exception('SMS delivery failed for user_id=%s', user_id)
        return False


@shared_task
def send_welcome_email(user_id: str):
    from .models import User
    from apps.profiles.models import Profile
    try:
        user = User.objects.get(id=user_id)
        profile = Profile.objects.get(user=user)
    except (User.DoesNotExist, Profile.DoesNotExist):
        return

    html = render_to_string('emails/welcome.html', {
        'username': profile.display_name or user.email.split('@')[0],
    })
    plain = strip_tags(html)

    send_mail(
        subject='Welcome to BuddyUp Fit!',
        message=plain,
        html_message=html,
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[user.email],
        fail_silently=False,
    )


@shared_task
def send_login_alert_email(user_id: str, ip_address: str, device: str):
    from .models import User
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return

    settings_url = 'https://buddyup.app/settings'

    html = render_to_string('emails/login_alert.html', {
        'username': user.email.split('@')[0],
        'ip_address': ip_address,
        'device': device,
        'settings_url': settings_url,
    })
    plain = strip_tags(html)

    send_mail(
        subject='New login to your BuddyUp Fit account',
        message=plain,
        html_message=html,
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[user.email],
        fail_silently=False,
    )


@shared_task
def send_security_notification_email(user_id: str, action: str, ip_address: str = ''):
    from .models import User
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return
    detail = f' from IP address {ip_address}' if ip_address else ''
    send_mail(
        subject=f'BuddyUp Fit security alert: {action}',
        message=(f'{action} was made to your BuddyUp Fit account{detail}. '
                 'If you did not make this change, sign in and secure your account immediately.'),
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[user.email],
        fail_silently=True,
    )


@shared_task
def cleanup_expired_otps():
    from .models import OTPToken
    OTPToken.objects.filter(
        expires_at__lt=timezone.now(),
        is_used=False,
    ).delete()


@shared_task
def cleanup_expired_sessions():
    from .models import DeviceSession
    DeviceSession.objects.filter(
        last_active__lt=timezone.now() - timedelta(days=90),
    ).update(is_active=False)


def _hard_delete_user(user):
    """Irreversibly remove an already-deleted account and its data.

    Shared by the scheduled ETA task (login-initiated deletion countdown) and
    the daily sweep. The caller must have verified deleted_at is set.
    """
    from apps.profiles.models import Profile, BuddyRelationship, FollowRelationship, BlockRelationship
    from apps.feed.models import Post, Comment
    from apps.messaging.models import Message

    profile = Profile.objects.filter(user=user).first()
    if profile is not None:
        Post.objects.filter(author=profile).update(
            body='[Deleted Account]', is_anonymous=True,
            media_urls=[], workout_log_data=None,
        )
        Comment.objects.filter(author=profile).update(
            body='[Deleted Account]', is_anonymous=True,
        )

        BuddyRelationship.objects.filter(
            Q(from_user=profile) | Q(to_user=profile),
        ).delete()
        FollowRelationship.objects.filter(
            Q(follower=profile) | Q(followee=profile),
        ).delete()
        BlockRelationship.objects.filter(
            Q(blocker=profile) | Q(blocked=profile),
        ).delete()

        Message.objects.filter(sender=profile).delete()

        # AnalyticsEvent.actor is SET_NULL, so deleting the profile would
        # orphan every behavioural event this person ever generated — leaving
        # their anonymous_id, session_id and properties intact. Retention is
        # not erasure, so this has to be an explicit delete.
        from apps.analytics.models import AnalyticsEvent as _AnalyticsEvent

        _AnalyticsEvent.objects.filter(actor=profile).delete()

        profile.delete()

    user.delete()


@shared_task
def delete_user_data(user_id: str):
    from .models import User

    try:
        user = User.objects.get(id=user_id, deleted_at__isnull=False)
    except User.DoesNotExist:
        return

    _hard_delete_user(user)


@shared_task
def sweep_scheduled_deletions():
    """Hard-delete accounts whose scheduled deletion date has passed.

    Safety net for the ETA task: catches deletions whose Celery countdown was
    lost (worker restarts, missed ETAs) and any rows with hard_delete_at set
    but no task enqueued. Active accounts are never touched.
    """
    from .models import User

    now = timezone.now()
    due = User.objects.filter(
        deleted_at__isnull=False,
        hard_delete_at__lte=now,
    )
    removed = 0
    for user in due.iterator():
        try:
            _hard_delete_user(user)
            removed += 1
        except Exception:  # noqa: BLE001 — one bad row must not stop the sweep
            logger.exception('scheduled hard delete failed user=%s', user.id)
    if removed:
        logger.info('sweep_scheduled_deletions removed=%s', removed)
    return removed


@shared_task
def export_user_data(user_id: str):
    import json
    from django.core.serializers.json import DjangoJSONEncoder
    from .models import User, AccountEvent, DeviceSession
    from apps.profiles.models import Profile
    from apps.feed.models import Post, Comment
    from apps.messaging.models import Message
    from apps.wallet.models import ArtifactTransaction
    from apps.sessions.models import BookingSession
    from apps.notifications.models import Notification, NotificationPreference
    from apps.analytics.models import AnalyticsEvent, ActivityRecord, WorkoutLog, BodyMetric
    from apps.gamification.models import UserAchievement

    try:
        user = User.objects.get(id=user_id)
        profile = Profile.objects.get(user=user)
    except (User.DoesNotExist, Profile.DoesNotExist):
        return

    try:
        notification_prefs = list(NotificationPreference.objects.filter(profile=profile).values())

        data = {
            'exported_at': timezone.now().isoformat(),
            'user': {
                'id': str(user.id),
                'email': user.email,
                'phone': user.phone,
                'created_at': user.created_at.isoformat(),
            },
            'profile': {
                'username': profile.username,
                'display_name': profile.display_name,
                'bio': profile.bio,
                'role': profile.role,
                'verification_status': profile.verification_status,
            },
            'posts': list(Post.objects.filter(author=profile).values()),
            'comments': list(Comment.objects.filter(author=profile).values()),
            'messages': list(Message.objects.filter(sender=profile).values()),
            'transactions': list(ArtifactTransaction.objects.filter(user=profile).values()),
            'sessions': list(BookingSession.objects.filter(
                Q(client=profile) | Q(trainer=profile),
            ).values()),
            # Notifications: current preferences + the 500 most recent rows.
            'notifications': {
                'preferences': notification_prefs,
                'recent': list(Notification.objects.filter(
                    recipient=profile,
                ).order_by('-created_at')[:500].values()),
            },
            'activity_events': list(AccountEvent.objects.filter(user=user).values()),
            # Device metadata only — never token material.
            'device_sessions': list(DeviceSession.objects.filter(user=user).values(
                'device_name', 'device_id', 'ip_address', 'location',
                'is_active', 'last_active', 'created_at',
            )),
            'analytics': {
                'activity_records': list(ActivityRecord.objects.filter(user=profile).values()),
                'workout_logs': list(WorkoutLog.objects.filter(user=profile).values()),
                'body_metrics': list(BodyMetric.objects.filter(user=profile).values()),
                # Behavioural telemetry is personal data under the same export
                # request as everything else. `id`, `consent` and `actor_id` are
                # omitted — they are not the person's data to receive back.
                'behavioral_events': list(AnalyticsEvent.objects.filter(actor=profile)
                                          .order_by('-received_at')
                                          .values('event_name', 'event_version',
                                                  'occurred_at', 'received_at',
                                                  'platform', 'surface',
                                                  'object_type', 'object_id',
                                                  'anonymous_id', 'session_id',
                                                  'properties')),
            },
            'achievements': list(UserAchievement.objects.filter(profile=profile).values(
                'progress', 'earned_at',
                'definition__code', 'definition__title', 'definition__tier',
            )),
        }

        from django.core.files.base import ContentFile
        from django.core.files.storage import default_storage
        from django.utils import timezone as tz

        payload = json.dumps(data, cls=DjangoJSONEncoder, indent=2)
        filename = f'exports/{profile.username}/{tz.now():%Y%m%d-%H%M%S}-data-export.json'
        saved = default_storage.save(filename, ContentFile(payload.encode('utf-8')))
        download_url = default_storage.url(saved)

        send_mail(
            'Your BuddyUp Fit data export is ready',
            f'Your data export is ready. Download it here (valid while your account is active):\n\n{download_url}\n\nIf the link does not work, request a new export from Settings.',
            getattr(settings, 'DEFAULT_FROM_EMAIL', None) or 'noreply@buddyup.app',
            [user.email],
            fail_silently=False,
        )
        logger.info('data_export_delivered user=%s file=%s', user.id, filename)
    except Exception:  # noqa: BLE001
        logger.exception('data_export_delivery_failed user=%s', user.id)
        # Best-effort failure notice — the user asked for an export and must
        # not be left waiting on a silent worker failure.
        try:
            send_mail(
                'Your BuddyUp Fit data export failed',
                'We could not generate your data export. Please request a new one '
                'from Settings; if this keeps happening, contact support.',
                getattr(settings, 'DEFAULT_FROM_EMAIL', None) or 'noreply@buddyup.app',
                [user.email],
                fail_silently=True,
            )
        except Exception:  # noqa: BLE001
            logger.exception('data_export_failure_notice_failed user=%s', user.id)
