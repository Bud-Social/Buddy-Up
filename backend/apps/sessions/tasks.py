from celery import shared_task
from django.db import models as db_models
from django.utils import timezone
from datetime import timedelta
from .models import BookingSession, TrainerProfile


@shared_task
def send_session_reminders():
    window = timezone.now() + timedelta(hours=1)
    upcoming = BookingSession.objects.filter(
        status='confirmed',
        scheduled_at__lte=window,
        scheduled_at__gte=timezone.now(),
    )
    for booking in upcoming.select_related('client__user', 'trainer__user'):
        for recipient, role_label in [(booking.client, 'client'), (booking.trainer, 'trainer')]:
            from apps.notifications.tasks import create_notification
            create_notification.delay(
                recipient_id=recipient.user_id,
                notification_type='session_reminder',
                title='Upcoming Session Reminder',
                body=f'Your session {"with " + booking.trainer.display_name if role_label == "client" else "with " + booking.client.display_name} starts in less than an hour!',
                metadata={'booking_id': str(booking.id)},
            )


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

    from apps.wallet.utils import release_held_to_party, release_held_refund, platform_cut
    from apps.wallet.models import ArtifactTransaction

    tx_ids = [t for t in booking.escrow_tx_id.split(',') if t]
    for tx_id in tx_ids:
        try:
            tx = ArtifactTransaction.objects.get(id=tx_id, status='held')
        except ArtifactTransaction.DoesNotExist:
            continue

        cut_qty = platform_cut('session_fee', tx.artifact_type, tx.quantity)
        net_qty = tx.quantity - cut_qty

        if net_qty > 0:
            release_held_to_party(
                profile=booking.client,
                recipient=booking.trainer,
                artifact_type=tx.artifact_type,
                quantity=net_qty,
            )
        if cut_qty > 0:
            release_held_refund(booking.client, tx.artifact_type, cut_qty)

        tx.status = 'completed'
        tx.description = f'Escrow released for booking {booking.id}'
        tx.save(update_fields=['status', 'description'])

        if cut_qty > 0:
            ArtifactTransaction.objects.create(
                user=booking.trainer,
                transaction_type='platform_cut',
                artifact_type=tx.artifact_type,
                quantity=cut_qty,
                direction='debit',
                status='completed',
                description=f'Platform fee ({tx.quantity - net_qty}/{tx.quantity}) for session {booking.id}',
            )

    trainer_profile, _ = TrainerProfile.objects.get_or_create(profile=booking.trainer)
    trainer_profile.total_sessions_completed = db_models.F('total_sessions_completed') + 1
    trainer_profile.save(update_fields=['total_sessions_completed'])
