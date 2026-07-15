from django.db import transaction as db_transaction


def _get_balance_dict(balance):
    return balance or {
        'dumbbell': 0, 'barbell': 0, 'burpee': 0,
        'squat': 0, 'sprint': 0, 'pr': 0, 'champion': 0,
    }


def _get_profile_balance(profile):
    return _get_balance_dict(profile.artifact_balance)


def _get_locked_balance(profile):
    return _get_balance_dict(profile.locked_balance)


def deduct_artifacts(profile, artifact_type, quantity):
    from apps.profiles.models import Profile
    with db_transaction.atomic():
        profile_ref = Profile.objects.select_for_update().get(pk=profile.pk)
        balance = _get_balance_dict(profile_ref.artifact_balance)
        if balance.get(artifact_type, 0) < quantity:
            return False
        balance[artifact_type] -= quantity
        profile_ref.artifact_balance = balance
        profile_ref.save(update_fields=['artifact_balance'])
    return True


def credit_artifacts(profile, artifact_type, quantity):
    from apps.profiles.models import Profile
    with db_transaction.atomic():
        profile_ref = Profile.objects.select_for_update().get(pk=profile.pk)
        balance = _get_balance_dict(profile_ref.artifact_balance)
        balance[artifact_type] = balance.get(artifact_type, 0) + quantity
        profile_ref.artifact_balance = balance
        profile_ref.save(update_fields=['artifact_balance'])


def hold_artifacts(profile, artifact_type, quantity, counterparty=None, reference_id=''):
    from apps.profiles.models import Profile as ProfileModel
    from apps.wallet.models import ArtifactTransaction
    with db_transaction.atomic():
        profile_ref = ProfileModel.objects.select_for_update().get(pk=profile.pk)
        balance = _get_balance_dict(profile_ref.artifact_balance)
        if balance.get(artifact_type, 0) < quantity:
            return None
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
        )
    return tx


def release_held_to_party(profile, recipient, artifact_type, quantity):
    from apps.profiles.models import Profile as ProfileModel
    with db_transaction.atomic():
        profile_ref = ProfileModel.objects.select_for_update().get(pk=profile.pk)
        locked = _get_balance_dict(profile_ref.locked_balance)
        if locked.get(artifact_type, 0) < quantity:
            return False
        locked[artifact_type] -= quantity
        profile_ref.locked_balance = locked
        profile_ref.save(update_fields=['locked_balance'])
        recipient_ref = ProfileModel.objects.select_for_update().get(pk=recipient.pk)
        recipient_balance = _get_balance_dict(recipient_ref.artifact_balance)
        recipient_balance[artifact_type] = recipient_balance.get(artifact_type, 0) + quantity
        recipient_ref.artifact_balance = recipient_balance
        recipient_ref.save(update_fields=['artifact_balance'])
    return True


def release_held_refund(profile, artifact_type, quantity):
    from apps.profiles.models import Profile as ProfileModel
    with db_transaction.atomic():
        profile_ref = ProfileModel.objects.select_for_update().get(pk=profile.pk)
        locked = _get_balance_dict(profile_ref.locked_balance)
        if locked.get(artifact_type, 0) < quantity:
            return False
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
