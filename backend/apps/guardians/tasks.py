import logging

from celery import shared_task
from django.conf import settings
from django.core.mail import send_mail

logger = logging.getLogger(__name__)


@shared_task
def send_guardian_invite_existing_email(link_id, guardian_name, invite_email):
    """Invite an existing teen account holder to accept a guardian link."""
    subject = 'BuddyUp Fit family connection request'
    message = (
        f'Hi!\n\n'
        f'{guardian_name} wants to connect as your parental co-owner on BuddyUp Fit.\n\n'
        f'Open BuddyUp Fit, go to Settings > Family, and accept the connection.\n\n'
        f'— The BuddyUp Fit team'
    )
    try:
        send_mail(
            subject=subject,
            message=message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[invite_email],
            fail_silently=False,
        )
        logger.info('guardian invite (existing teen) email sent link=%s', link_id)
    except Exception:  # noqa: BLE001 — mail failure must never break the invite
        logger.exception('guardian invite (existing teen) email failed link=%s', link_id)


@shared_task
def send_guardian_invite_new_email(link_id, guardian_name, invite_email, accept_url):
    """Welcome a newly provisioned teen account with its password-setup link."""
    subject = 'Your BuddyUp Fit teen account is ready'
    message = (
        f'Hi!\n\n'
        f'{guardian_name} created a BuddyUp Fit teen account for you. '
        f'Set your password: {accept_url}\n\n'
        f'The link can be used once.\n\n'
        f'— The BuddyUp Fit team'
    )
    try:
        send_mail(
            subject=subject,
            message=message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[invite_email],
            fail_silently=False,
        )
        logger.info('guardian invite (new teen) email sent link=%s', link_id)
    except Exception:  # noqa: BLE001 — mail failure must never break the invite
        logger.exception('guardian invite (new teen) email failed link=%s', link_id)
