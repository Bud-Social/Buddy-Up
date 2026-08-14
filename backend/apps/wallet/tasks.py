import logging
from celery import shared_task
from django.db import transaction as db_transaction
from django.utils import timezone


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
    except Exception as exc:  # noqa: BLE001
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
    from .utils import _get_balance_dict
    from apps.profiles.models import Profile

    held = ArtifactTransaction.objects.filter(
        status='held',
        clearance_at__lte=timezone.now(),
    ).select_related('user', 'counterparty')

    for tx in held:
        with db_transaction.atomic():
            profile_ref = Profile.objects.select_for_update().get(pk=tx.user.pk)
            locked = _get_balance_dict(profile_ref.locked_balance)
            qty = locked.get(tx.artifact_type, 0)
            if qty < tx.quantity:
                tx.status = 'failed'
                tx.description = 'Auto-release failed: insufficient locked balance.'
                tx.save(update_fields=['status', 'description'])
                continue
            locked[tx.artifact_type] = qty - tx.quantity
            profile_ref.locked_balance = locked
            balance = _get_balance_dict(profile_ref.artifact_balance)
            balance[tx.artifact_type] = balance.get(tx.artifact_type, 0) + tx.quantity
            profile_ref.artifact_balance = balance
            profile_ref.save(update_fields=['locked_balance', 'artifact_balance'])
            tx.status = 'completed'
            tx.description = 'Auto-released (clearance_at reached).'
            tx.save(update_fields=['status', 'description'])
