import logging
from celery import shared_task
from django.utils import timezone
from datetime import timedelta


@shared_task
def refresh_exchange_rates():
    # TODO: Fetch live exchange rates from an API
    pass


@shared_task(bind=True, max_retries=3, default_retry_delay=300)
def process_withdrawal(self, withdrawal_id: str):
    from .models import ArtifactTransaction
    try:
        tx = ArtifactTransaction.objects.get(id=withdrawal_id, transaction_type='withdrawal', status='pending')
    except ArtifactTransaction.DoesNotExist:
        return

    method = 'unknown'
    if tx.phone_number:
        method = 'M-Pesa'
        logger = logging.getLogger(__name__)
        logger.info('Processing withdrawal %s via M-Pesa to %s', withdrawal_id, tx.phone_number)
    elif tx.bank_account:
        method = 'Bank Transfer'
        logger = logging.getLogger(__name__)
        logger.info('Processing withdrawal %s via Bank Transfer to %s', withdrawal_id, tx.bank_account)
    else:
        method = 'PayPal'

    try:
        # TODO: Call actual payout API (M-Pesa, Flutterwave, PayPal)
        # For now, structured logging and mark as completed
        tx.status = 'completed'
        tx.description = f'Withdrawal via {method} — completed'
        tx.save(update_fields=['status', 'description'])
    except Exception as exc:
        raise self.retry(exc=exc)


@shared_task
def process_pending_withdrawals():
    from .models import ArtifactTransaction
    pending = ArtifactTransaction.objects.filter(
        transaction_type='withdrawal', status='pending',
    )[:50]
    for tx in pending:
        process_withdrawal.delay(str(tx.id))


@shared_task
def clear_locked_balance():
    from .models import ArtifactTransaction
    ArtifactTransaction.objects.filter(
        status='held',
        clearance_at__lte=timezone.now(),
    ).update(status='completed')
