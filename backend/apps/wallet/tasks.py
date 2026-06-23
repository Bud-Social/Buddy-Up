from celery import shared_task
from django.utils import timezone
from datetime import timedelta


@shared_task
def refresh_exchange_rates():
    # TODO: Fetch live exchange rates from an API
    pass


@shared_task
def process_withdrawal(withdrawal_id: str):
    from .models import ArtifactTransaction
    try:
        tx = ArtifactTransaction.objects.get(id=withdrawal_id, transaction_type='withdrawal', status='pending')
    except ArtifactTransaction.DoesNotExist:
        return

    # TODO: Call M-Pesa, Flutterwave, or PayPal payout API
    tx.status = 'completed'
    tx.save(update_fields=['status'])


@shared_task
def clear_locked_balance():
    from .models import ArtifactTransaction
    cutoff = timezone.now() - timedelta(days=7)
    ArtifactTransaction.objects.filter(
        status='held',
        clearance_at__lte=timezone.now(),
    ).update(status='completed')
