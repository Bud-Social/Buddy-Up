import logging
from celery import shared_task
from django.db import transaction as db_transaction
from django.utils import timezone


logger = logging.getLogger(__name__)


def _complete_withdrawal(tx, provider_data):
    from .ledger import PostingLine, post_entry
    from .models import ArtifactTransaction

    with db_transaction.atomic():
        locked = ArtifactTransaction.objects.select_for_update().get(pk=tx.pk)
        if locked.status != 'pending':
            return False
        entry, _ = post_entry(
            operation='withdrawal_settlement', owner=locked.user,
            idempotency_key=f'{locked.id}:settlement',
            payload={'artifact_type': locked.artifact_type, 'quantity': locked.quantity},
            lines=[
                PostingLine('escrow', locked.artifact_type, 'debit', locked.quantity),
                PostingLine('platform', locked.artifact_type, 'credit', locked.quantity),
            ],
        )
        locked.status = 'completed'
        locked.description = 'Withdrawal confirmed by provider'
        locked.flutterwave_response = provider_data
        locked.journal_entry = entry
        locked.save(update_fields=['status', 'description', 'flutterwave_response', 'journal_entry'])
        return True


@shared_task
def refresh_exchange_rates():
    # TODO: Fetch live exchange rates from an API
    pass


@shared_task(bind=True, max_retries=3, default_retry_delay=300)
def process_withdrawal(self, withdrawal_id: str):
    from .models import ArtifactTransaction
    from .flutterwave import FlutterwaveClient
    try:
        with db_transaction.atomic():
            tx = ArtifactTransaction.objects.select_for_update().get(
                id=withdrawal_id,
                transaction_type='withdrawal',
                status='pending',
            )
    except ArtifactTransaction.DoesNotExist:
        return

    method = 'unknown'
    if tx.phone_number:
        method = 'M-Pesa'
        logger.info('Processing withdrawal %s via M-Pesa to %s', withdrawal_id,
                      ('***' + tx.phone_number[-3:]) if tx.phone_number else '***')
    elif tx.bank_account:
        method = 'Bank Transfer'
        logger.info('Processing withdrawal %s via Bank Transfer to %s', withdrawal_id, tx.bank_account)
    else:
        method = 'unsupported'

    try:
        if method != 'Bank Transfer':
            # There is no implemented outbound M-Pesa/PayPal transfer call.
            # Never represent an unexecuted payout as completed.
            tx.description = f'Withdrawal via {method} awaiting manual/provider integration'
            tx.save(update_fields=['description'])
            logger.warning('Withdrawal %s left pending: provider path unavailable (%s)', withdrawal_id, method)
            return

        # Bank transfers are initiated synchronously by WithdrawView. This task
        # reconciles the provider state only after a provider id exists.
        if not tx.flutterwave_id:
            tx.description = 'Bank transfer pending provider reference'
            tx.save(update_fields=['description'])
            return

        result = FlutterwaveClient().verify_transfer(tx.flutterwave_id)
        provider_status = str((result.data or {}).get('status', '')).upper()
        tx.flutterwave_response = result.data
        if result.success and provider_status in {'SUCCESSFUL', 'SUCCESS'}:
            _complete_withdrawal(tx, result.data)
        elif provider_status in {'FAILED', 'CANCELLED', 'REVERSED'}:
            _refund_failed_withdrawal(tx, reason=f'provider status {provider_status}')
        else:
            tx.description = f'Withdrawal via {method} pending provider confirmation'
            tx.save(update_fields=['description', 'flutterwave_response'])
    except Exception as exc:  # noqa: BLE001
        raise self.retry(exc=exc)


def _refund_failed_withdrawal(tx, reason='provider failure'):
    """Atomically refund a failed debit once; safe under webhook/task replay."""
    from .models import ArtifactTransaction
    from .ledger import PostingLine, post_entry
    from apps.profiles.models import Profile

    with db_transaction.atomic():
        locked = ArtifactTransaction.objects.select_for_update().get(pk=tx.pk)
        if locked.status != 'pending':
            return False
        source = (locked.flutterwave_response or {}).get('wallet_source', 'regular')
        profile = Profile.objects.select_for_update().get(pk=locked.user_id)
        field = 'creator_balance' if source == 'creator' else 'artifact_balance'
        balance = dict(getattr(profile, field) or {})
        balance[locked.artifact_type] = balance.get(locked.artifact_type, 0) + locked.quantity
        entry, _ = post_entry(
            operation='withdrawal_refund', owner=profile,
            idempotency_key=f'{locked.id}:refund',
            payload={'artifact_type': locked.artifact_type, 'quantity': locked.quantity},
            lines=[
                PostingLine('escrow', locked.artifact_type, 'debit', locked.quantity),
                PostingLine('seller' if source == 'creator' else 'buyer', locked.artifact_type, 'credit', locked.quantity, profile, source if source == 'creator' else 'regular'),
            ],
        )
        setattr(profile, field, balance)
        profile.save(update_fields=[field])
        locked.status = 'failed'
        locked.description = f'Withdrawal failed; artifacts returned ({reason})'
        locked.save(update_fields=['status', 'description'])
        ArtifactTransaction.objects.get_or_create(
            user=locked.user,
            transaction_type='refund',
            artifact_type=locked.artifact_type,
            quantity=locked.quantity,
            direction='credit',
            reference_id=f'withdrawal_refund:{locked.id}',
            defaults={
                'status': 'completed',
                'fiat_amount': locked.fiat_amount,
                'fiat_currency': locked.fiat_currency,
                'description': f'Automatic refund for failed withdrawal {locked.tx_ref}',
                'journal_entry': entry,
            },
        )
        return True


@shared_task
def process_pending_withdrawals():
    from .models import ArtifactTransaction
    pending = ArtifactTransaction.objects.filter(
        transaction_type='withdrawal', status='pending',
    )[:50]
    for tx in pending:
        process_withdrawal.delay(str(tx.id))


@shared_task
def reconcile_flutterwave_transactions():
    """Daily provider/internal-ledger reconciliation summary.

    Returns serialisable counts for Celery results and emits an ERROR log for
    actionable mismatches; no balance mutation occurs here.
    """
    from .models import ArtifactTransaction
    from .flutterwave import FlutterwaveClient

    cutoff = timezone.now() - timezone.timedelta(days=30)
    qs = ArtifactTransaction.objects.filter(
        payment_provider='flutterwave',
        created_at__gte=cutoff,
    ).exclude(flutterwave_id='')[:500]
    summary = {'checked': 0, 'matched': 0, 'pending': 0, 'mismatched': 0, 'errors': 0}
    client = FlutterwaveClient()
    for tx in qs:
        summary['checked'] += 1
        try:
            result = (
                client.verify_transfer(tx.flutterwave_id)
                if tx.transaction_type == 'withdrawal'
                else client.verify_transaction(tx.flutterwave_id)
            )
            status_name = str((result.data or {}).get('status', '')).lower()
            if status_name in ('pending', 'new', ''):
                summary['pending'] += 1
            elif (tx.status == 'completed') == (status_name in ('successful', 'success')):
                summary['matched'] += 1
            else:
                summary['mismatched'] += 1
                logger.error(
                    'reconciliation_mismatch tx_id=%s tx_ref=%s internal=%s provider=%s',
                    tx.id, tx.tx_ref, tx.status, status_name,
                )
        except Exception:  # noqa: BLE001
            summary['errors'] += 1
            logger.exception('reconciliation_error tx_id=%s tx_ref=%s', tx.id, tx.tx_ref)
    logger.info('flutterwave_reconciliation summary=%s', summary)
    return summary


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
            from .ledger import PostingLine, post_entry
            entry, _ = post_entry(
                operation='escrow_clearance_refund', owner=profile_ref,
                idempotency_key=f'{tx.id}:clearance',
                payload={'artifact_type': tx.artifact_type, 'quantity': tx.quantity},
                lines=[
                    PostingLine('escrow', tx.artifact_type, 'debit', tx.quantity),
                    PostingLine('buyer', tx.artifact_type, 'credit', tx.quantity, profile_ref, 'regular'),
                ],
            )
            ArtifactTransaction.objects.create(
                user=profile_ref,
                transaction_type='refund',
                artifact_type=tx.artifact_type,
                quantity=tx.quantity,
                direction='credit',
                status='completed',
                reference_id=f'{tx.id}:clearance',
                journal_entry=entry,
                description='Automatic escrow clearance refund.',
            )
            tx.status = 'completed'
            tx.description = 'Auto-released (clearance_at reached).'
            tx.save(update_fields=['status', 'description'])
