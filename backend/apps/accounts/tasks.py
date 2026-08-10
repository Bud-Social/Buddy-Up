from celery import shared_task
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.conf import settings
from django.utils import timezone
from datetime import timedelta
from django.db.models import Q
import logging

logger = logging.getLogger(__name__)


def sms_delivery_configured() -> bool:
    return bool(
        getattr(settings, 'AFRICASTALKING_USERNAME', '')
        and getattr(settings, 'AFRICASTALKING_API_KEY', '')
    )


@shared_task
def send_otp_email(user_id: str, otp: str, purpose: str = 'registration'):
    from .models import User
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return

    username = user.email.split('@')[0]
    subject = {
        'registration': 'Verify your BuddyUp email',
        'login': 'Your BuddyUp login code',
        'password_reset': 'Reset your BuddyUp password',
    }.get(purpose, 'Your BuddyUp verification code')

    html = render_to_string('emails/otp.html', {
        'username': username,
        'otp': otp,
        'purpose': purpose,
    })
    plain = strip_tags(html)

    send_mail(
        subject=subject,
        message=plain,
        html_message=html,
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[user.email],
        fail_silently=False,
    )


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
                'message': f'Your BuddyUp verification code is {otp}. It expires in 10 minutes.',
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
        subject='Welcome to BuddyUp!',
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
        subject='New login to your BuddyUp account',
        message=plain,
        html_message=html,
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[user.email],
        fail_silently=False,
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


@shared_task
def delete_user_data(user_id: str):
    from .models import User
    from apps.profiles.models import Profile, BuddyRelationship, FollowRelationship, BlockRelationship
    from apps.feed.models import Post, Comment, Reaction
    from apps.messaging.models import Message

    try:
        user = User.objects.get(id=user_id, deleted_at__isnull=False)
        profile = Profile.objects.get(user=user)
    except (User.DoesNotExist, Profile.DoesNotExist):
        return

    Post.objects.filter(author=profile).update(
        body='[Deleted Account]', is_anonymous=True,
        media_urls=[], workout_log_data=None, meal_data=None, progress_data=None,
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

    profile.delete()
    user.delete()


@shared_task
def export_user_data(user_id: str):
    import json
    from django.core.serializers.json import DjangoJSONEncoder
    from .models import User
    from apps.profiles.models import Profile
    from apps.feed.models import Post, Comment
    from apps.messaging.models import Message
    from apps.wallet.models import ArtifactTransaction
    from apps.sessions.models import BookingSession

    try:
        user = User.objects.get(id=user_id)
        profile = Profile.objects.get(user=user)
    except (User.DoesNotExist, Profile.DoesNotExist):
        return

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
    }

    print(f'[DEV] Data export for {user.email}: {json.dumps(data, cls=DjangoJSONEncoder)[:500]}...')
