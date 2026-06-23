from celery import shared_task
from django.utils import timezone
from datetime import timedelta
from .models import BookingSession, Review


@shared_task
def send_session_reminders():
    window = timezone.now() + timedelta(hours=1)
    upcoming = BookingSession.objects.filter(
        status='confirmed',
        scheduled_at__lte=window,
        scheduled_at__gte=timezone.now(),
    )
    for booking in upcoming.select_related('client', 'trainer'):
        # TODO: Send push notification
        print(f'[DEV] Reminder: {booking.client.username} session with {booking.trainer.username} at {booking.scheduled_at}')


@shared_task
def clear_expired_sessions():
    expired = BookingSession.objects.filter(
        status='confirmed',
        scheduled_at__lt=timezone.now() - timedelta(hours=4),
    ).exclude(status='completed')
    for booking in expired:
        booking.status = 'no_show'
        booking.save(update_fields=['status'])


@shared_task
def process_escrow_release(booking_id: str):
    try:
        booking = BookingSession.objects.get(id=booking_id, status='completed')
    except BookingSession.DoesNotExist:
        return
    # TODO: Release held artifacts to trainer
    print(f'[DEV] Escrow released for booking {booking.id}')
