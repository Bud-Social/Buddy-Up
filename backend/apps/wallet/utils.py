from django.db import transaction as db_transaction
from django.core.exceptions import ValidationError
from uuid import uuid4


def _get_balance_dict(balance):
    return balance or {
        'dumbbell': 0, 'barbell': 0, 'burpee': 0,
        'squat': 0, 'sprint': 0, 'pr': 0, 'champion': 0,
    }


def _get_profile_balance(profile):
    return _get_balance_dict(profile.artifact_balance)


def _get_creator_balance(profile):
    return _get_balance_dict(profile.creator_balance)


def _get_total_balance(profile):
    regular = _get_profile_balance(profile)
    creator = _get_creator_balance(profile)
    total = {}
    for k in set(list(regular.keys()) + list(creator.keys())):
        total[k] = regular.get(k, 0) + creator.get(k, 0)
    return total


def _get_locked_balance(profile):
    return _get_balance_dict(profile.locked_balance)


def _ledger_account_type(wallet_bucket):
    return 'seller' if wallet_bucket == 'creator' else 'buyer'


def _post_balance_shadow(*, operation, owner, artifact_type, quantity, direction,
                         wallet_bucket, idempotency_key=None, reference_id=''):
    """Mirror a legacy JSON balance mutation in a balanced ledger entry."""
    from .ledger import PostingLine, post_entry

    key = idempotency_key or f'legacy:{uuid4().hex}'
    if direction == 'debit':
        lines = [
            PostingLine(_ledger_account_type(wallet_bucket), artifact_type, 'debit', quantity, owner, wallet_bucket),
            PostingLine('platform', artifact_type, 'credit', quantity),
        ]
    else:
        lines = [
            PostingLine('platform', artifact_type, 'debit', quantity),
            PostingLine(_ledger_account_type(wallet_bucket), artifact_type, 'credit', quantity, owner, wallet_bucket),
        ]
    return post_entry(
        operation=operation, owner=owner, idempotency_key=key,
        payload={'artifact_type': artifact_type, 'quantity': quantity, 'direction': direction,
                 'wallet_bucket': wallet_bucket, 'reference_id': reference_id},
        lines=lines,
    )


def deduct_artifacts(profile, artifact_type, quantity, *, idempotency_key=None, reference_id=''):
    from apps.profiles.models import Profile
    with db_transaction.atomic():
        profile_ref = Profile.objects.select_for_update().get(pk=profile.pk)
        balance = _get_balance_dict(profile_ref.artifact_balance)
        if balance.get(artifact_type, 0) < quantity:
            return False
        balance[artifact_type] -= quantity
        profile_ref.artifact_balance = balance
        profile_ref.save(update_fields=['artifact_balance'])
        _post_balance_shadow(
            operation='balance_debit', owner=profile_ref, artifact_type=artifact_type,
            quantity=quantity, direction='debit', wallet_bucket='regular',
            idempotency_key=idempotency_key, reference_id=reference_id,
        )
    return True


def credit_artifacts(profile, artifact_type, quantity, *, idempotency_key=None, reference_id=''):
    from apps.profiles.models import Profile
    with db_transaction.atomic():
        profile_ref = Profile.objects.select_for_update().get(pk=profile.pk)
        balance = _get_balance_dict(profile_ref.artifact_balance)
        balance[artifact_type] = balance.get(artifact_type, 0) + quantity
        profile_ref.artifact_balance = balance
        profile_ref.save(update_fields=['artifact_balance'])
        _post_balance_shadow(
            operation='balance_credit', owner=profile_ref, artifact_type=artifact_type,
            quantity=quantity, direction='credit', wallet_bucket='regular',
            idempotency_key=idempotency_key, reference_id=reference_id,
        )


def credit_creator_artifacts(profile, artifact_type, quantity, *, idempotency_key=None, reference_id=''):
    from apps.profiles.models import Profile
    with db_transaction.atomic():
        profile_ref = Profile.objects.select_for_update().get(pk=profile.pk)
        balance = _get_balance_dict(profile_ref.creator_balance)
        balance[artifact_type] = balance.get(artifact_type, 0) + quantity
        profile_ref.creator_balance = balance
        profile_ref.save(update_fields=['creator_balance'])
        _post_balance_shadow(
            operation='creator_balance_credit', owner=profile_ref, artifact_type=artifact_type,
            quantity=quantity, direction='credit', wallet_bucket='creator',
            idempotency_key=idempotency_key, reference_id=reference_id,
        )


def deduct_creator_artifacts(profile, artifact_type, quantity, *, idempotency_key=None, reference_id=''):
    from apps.profiles.models import Profile
    with db_transaction.atomic():
        profile_ref = Profile.objects.select_for_update().get(pk=profile.pk)
        balance = _get_balance_dict(profile_ref.creator_balance)
        if balance.get(artifact_type, 0) < quantity:
            return False
        balance[artifact_type] -= quantity
        profile_ref.creator_balance = balance
        profile_ref.save(update_fields=['creator_balance'])
        _post_balance_shadow(
            operation='creator_balance_debit', owner=profile_ref, artifact_type=artifact_type,
            quantity=quantity, direction='debit', wallet_bucket='creator',
            idempotency_key=idempotency_key, reference_id=reference_id,
        )
    return True


def reserve_withdrawal(
    profile,
    *,
    source,
    artifact_type,
    quantity,
    fiat_amount,
    fiat_currency,
    method,
    phone_number='',
    bank_account='',
    tx_ref='', idempotency_key=None,
):
    """Deduct value and create its payout ledger row in one transaction.

    Returning ``None`` means insufficient balance; no partial mutation is
    committed. Provider calls happen only after this reservation commits.
    """
    from apps.profiles.models import Profile
    from apps.wallet.models import ArtifactTransaction

    with db_transaction.atomic():
        locked = Profile.objects.select_for_update().get(pk=profile.pk)
        field = 'creator_balance' if source == 'creator' else 'artifact_balance'
        balance = _get_balance_dict(getattr(locked, field))
        if balance.get(artifact_type, 0) < quantity:
            return None
        from .ledger import PostingLine, post_entry
        entry, created = post_entry(
            operation='withdrawal_reservation', owner=locked,
            idempotency_key=idempotency_key or tx_ref,
            payload={'artifact_type': artifact_type, 'quantity': quantity, 'source': source, 'tx_ref': tx_ref},
            lines=[
                PostingLine(_ledger_account_type('creator' if source == 'creator' else 'regular'), artifact_type, 'debit', quantity, locked, 'creator' if source == 'creator' else 'regular'),
                PostingLine('escrow', artifact_type, 'credit', quantity),
            ], description='Withdrawal reserved pending provider settlement',
        )
        if not created:
            return ArtifactTransaction.objects.get(journal_entry=entry)
        balance[artifact_type] -= quantity
        setattr(locked, field, balance)
        locked.save(update_fields=[field])
        tx, _ = ArtifactTransaction.objects.get_or_create(
            tx_ref=tx_ref,
            defaults={
                'user': locked,
                'transaction_type': 'withdrawal',
                'artifact_type': artifact_type,
                'quantity': quantity,
                'direction': 'debit',
                'status': 'pending',
                'fiat_amount': fiat_amount,
                'fiat_currency': fiat_currency,
                'payment_provider': 'flutterwave',
                'phone_number': phone_number,
                'bank_account': bank_account,
                'description': f'Withdrawal from {source} wallet via {method}; awaiting provider confirmation',
                'flutterwave_response': {'wallet_source': source},
                'journal_entry': entry,
            },
        )
        return tx


def transfer_artifacts(sender, recipient, artifact_type, quantity, *, source='regular',
                       recipient_bucket='regular', operation='transfer', idempotency_key='',
                       reference_id='', platform_fee=0):
    """Atomically move artifacts and post one balanced settlement entry."""
    from apps.profiles.models import Profile
    from .ledger import PostingLine, post_entry

    if quantity <= 0 or platform_fee < 0 or platform_fee > quantity:
        raise ValidationError('Invalid transfer quantity or platform fee.')
    with db_transaction.atomic():
        first, second = sorted([sender.pk, recipient.pk], key=str)
        profiles = {
            p.pk: p for p in Profile.objects.select_for_update().filter(pk__in=[first, second])
        }
        sender_ref, recipient_ref = profiles[sender.pk], profiles[recipient.pk]
        source_field = 'creator_balance' if source == 'creator' else 'artifact_balance'
        balance = _get_balance_dict(getattr(sender_ref, source_field))
        if balance.get(artifact_type, 0) < quantity:
            return None
        lines = [PostingLine(_ledger_account_type(source), artifact_type, 'debit', quantity, sender_ref, source)]
        if quantity - platform_fee:
            lines.append(PostingLine(_ledger_account_type(recipient_bucket), artifact_type, 'credit', quantity - platform_fee, recipient_ref, recipient_bucket))
        if platform_fee:
            lines.append(PostingLine('platform', artifact_type, 'credit', platform_fee))
        entry, created = post_entry(
            operation=operation, owner=sender_ref, idempotency_key=idempotency_key or reference_id,
            payload={'sender': str(sender_ref.pk), 'recipient': str(recipient_ref.pk), 'artifact_type': artifact_type, 'quantity': quantity, 'source': source, 'fee': platform_fee, 'reference_id': reference_id},
            lines=lines, description=operation,
        )
        if not created:
            return entry, False
        balance[artifact_type] -= quantity
        setattr(sender_ref, source_field, balance)
        recipient_balance = _get_balance_dict(recipient_ref.artifact_balance)
        recipient_balance[artifact_type] = recipient_balance.get(artifact_type, 0) + quantity - platform_fee
        recipient_ref.artifact_balance = recipient_balance
        sender_ref.save(update_fields=[source_field])
        recipient_ref.save(update_fields=['artifact_balance'])
        return entry, created


def hold_artifacts(profile, artifact_type, quantity, counterparty=None, reference_id=''):
    from apps.profiles.models import Profile as ProfileModel
    from apps.wallet.models import ArtifactTransaction, JournalEntry
    with db_transaction.atomic():
        profile_ref = ProfileModel.objects.select_for_update().get(pk=profile.pk)
        key = f'{reference_id}:{artifact_type}' if reference_id else None
        if key:
            existing = JournalEntry.objects.select_for_update().filter(
                idempotency_key=f'escrow_hold:{profile_ref.pk}:{key}',
            ).first()
            if existing:
                return ArtifactTransaction.objects.get(journal_entry=existing)
        balance = _get_balance_dict(profile_ref.artifact_balance)
        if balance.get(artifact_type, 0) < quantity:
            return None
        from .ledger import PostingLine, post_entry
        entry, created = post_entry(
            operation='escrow_hold', owner=profile_ref,
            idempotency_key=key or f'hold:{uuid4().hex}',
            payload={'artifact_type': artifact_type, 'quantity': quantity, 'reference_id': reference_id},
            lines=[PostingLine('buyer', artifact_type, 'debit', quantity, profile_ref, 'regular'), PostingLine('escrow', artifact_type, 'credit', quantity)],
        )
        if not created:
            return ArtifactTransaction.objects.get(journal_entry=entry)
        balance[artifact_type] -= quantity
        profile_ref.artifact_balance = balance
        locked = _get_balance_dict(profile_ref.locked_balance)
        locked[artifact_type] = locked.get(artifact_type, 0) + quantity
        profile_ref.locked_balance = locked
        profile_ref.save(update_fields=['artifact_balance', 'locked_balance'])
        tx = ArtifactTransaction.objects.create(
            user=profile,
            transaction_type='session_fee',
            artifact_type=artifact_type,
            quantity=quantity,
            direction='debit',
            counterparty=counterparty,
            reference_id=reference_id,
            status='held',
            journal_entry=entry,
        )
    return tx


def release_held_to_party(profile, recipient, artifact_type, quantity, reference_id=''):
    from apps.profiles.models import Profile as ProfileModel
    from apps.wallet.models import JournalEntry
    with db_transaction.atomic():
        profile_ref = ProfileModel.objects.select_for_update().get(pk=profile.pk)
        key = reference_id or f'{profile_ref.pk}:{recipient.pk}:{artifact_type}:{quantity}'
        existing = JournalEntry.objects.select_for_update().filter(
            idempotency_key=f'escrow_release:{profile_ref.pk}:{key}',
        ).first()
        if existing:
            return True
        locked = _get_balance_dict(profile_ref.locked_balance)
        if locked.get(artifact_type, 0) < quantity:
            return False
        from .ledger import PostingLine, post_entry
        entry, created = post_entry(
            operation='escrow_release', owner=profile_ref,
            idempotency_key=key,
            payload={'recipient': str(recipient.pk), 'artifact_type': artifact_type, 'quantity': quantity},
            lines=[PostingLine('escrow', artifact_type, 'debit', quantity), PostingLine('seller', artifact_type, 'credit', quantity, recipient, 'regular')],
        )
        if not created:
            return True
        locked[artifact_type] -= quantity
        profile_ref.locked_balance = locked
        profile_ref.save(update_fields=['locked_balance'])
        recipient_ref = ProfileModel.objects.select_for_update().get(pk=recipient.pk)
        recipient_balance = _get_balance_dict(recipient_ref.artifact_balance)
        recipient_balance[artifact_type] = recipient_balance.get(artifact_type, 0) + quantity
        recipient_ref.artifact_balance = recipient_balance
        recipient_ref.save(update_fields=['artifact_balance'])
    return True


def release_held_refund(profile, artifact_type, quantity, reference_id=''):
    from apps.profiles.models import Profile as ProfileModel
    from apps.wallet.models import JournalEntry
    with db_transaction.atomic():
        profile_ref = ProfileModel.objects.select_for_update().get(pk=profile.pk)
        key = reference_id or f'{profile_ref.pk}:{artifact_type}:{quantity}'
        existing = JournalEntry.objects.select_for_update().filter(
            idempotency_key=f'escrow_refund:{profile_ref.pk}:{key}',
        ).first()
        if existing:
            return True
        locked = _get_balance_dict(profile_ref.locked_balance)
        if locked.get(artifact_type, 0) < quantity:
            return False
        from .ledger import PostingLine, post_entry
        entry, created = post_entry(
            operation='escrow_refund', owner=profile_ref,
            idempotency_key=key,
            payload={'artifact_type': artifact_type, 'quantity': quantity},
            lines=[PostingLine('escrow', artifact_type, 'debit', quantity), PostingLine('buyer', artifact_type, 'credit', quantity, profile_ref, 'regular')],
        )
        if not created:
            return True
        locked[artifact_type] -= quantity
        profile_ref.locked_balance = locked
        balance = _get_balance_dict(profile_ref.artifact_balance)
        balance[artifact_type] = balance.get(artifact_type, 0) + quantity
        profile_ref.artifact_balance = balance
        profile_ref.save(update_fields=['locked_balance', 'artifact_balance'])
    return True


def platform_cut(transaction_type, artifact_type, quantity):
    from apps.wallet.serializers import PLATFORM_CUTS
    rate = PLATFORM_CUTS.get(transaction_type, 0.15)
    cut_qty = max(1, int(quantity * rate))
    return cut_qty


def calculate_fiat(balance_dict, currency='USD'):
    from apps.wallet.serializers import ARTIFACT_VALUES
    total = sum(ARTIFACT_VALUES.get(k, 0) * v for k, v in balance_dict.items())
    return {
        'amount': round(total, 2),
        'currency': currency,
        'display': f'{currency} {total:,.2f}',
    }
