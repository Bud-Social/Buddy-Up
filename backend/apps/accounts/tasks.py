from celery import shared_task
from django.utils import timezone
from datetime import timedelta


@shared_task
def send_otp_email(user_id: str, otp: str):
    # TODO: Implement SendGrid OTP email sending
    pass


@shared_task
def send_otp_sms(user_id: str, otp: str):
    # TODO: Implement Africa's Talking SMS sending
    pass


@shared_task
def send_welcome_email(user_id: str):
    # TODO: Send welcome email
    pass


@shared_task
def send_login_alert_email(user_id: str, ip_address: str, device: str):
    # TODO: Send new device login alert
    pass


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
