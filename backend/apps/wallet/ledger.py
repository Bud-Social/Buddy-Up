import hashlib
import json
from dataclasses import dataclass

from django.core.exceptions import ValidationError
from django.db import IntegrityError, transaction

from .models import JournalEntry, JournalLine, LedgerAccount


class IdempotencyConflict(ValidationError):
    pass


@dataclass(frozen=True)
class PostingLine:
    account_type: str
    artifact_type: str
    direction: str
    amount: int
    profile: object = None
    wallet_bucket: str = 'system'


def request_fingerprint(payload):
    encoded = json.dumps(payload, sort_keys=True, separators=(',', ':'), default=str).encode()
    return hashlib.sha256(encoded).hexdigest()


def scoped_idempotency_key(operation, owner, key):
    owner_id = getattr(owner, 'pk', owner) or 'system'
    return f'{operation}:{owner_id}:{key}'


def _account_for(line):
    profile = line.profile
    name = f'{line.account_type}:{getattr(profile, "username", "system")}:{line.wallet_bucket}'
    lookup = {
        'account_type': line.account_type,
        'profile': profile,
        'wallet_bucket': line.wallet_bucket,
        'artifact_type': line.artifact_type,
    }
    try:
        return LedgerAccount.objects.get(**lookup)
    except LedgerAccount.DoesNotExist:
        try:
            return LedgerAccount.objects.create(name=name, **lookup)
        except IntegrityError:
            return LedgerAccount.objects.get(**lookup)


def post_entry(*, operation, owner, idempotency_key, payload, lines, description='', metadata=None):
    """Post an immutable balanced entry, returning ``(entry, created)``.

    The caller should include this in the same ``transaction.atomic`` block as
    any legacy JSON balance mutation. A replay with changed inputs is rejected.
    """
    lines = list(lines)
    if not idempotency_key:
        raise ValidationError('An idempotency key is required for ledger posting.')
    if len(lines) < 2:
        raise ValidationError('A journal entry requires at least two lines.')
    if any(line.direction not in {'debit', 'credit'} or line.amount <= 0 for line in lines):
        raise ValidationError('Journal lines require a valid direction and positive amount.')

    artifacts = {line.artifact_type for line in lines}
    for artifact_type in artifacts:
        debit = sum(line.amount for line in lines if line.artifact_type == artifact_type and line.direction == 'debit')
        credit = sum(line.amount for line in lines if line.artifact_type == artifact_type and line.direction == 'credit')
        if debit != credit:
            raise ValidationError(f'Unbalanced journal entry for {artifact_type}: {debit} != {credit}.')

    key = scoped_idempotency_key(operation, owner, idempotency_key)
    fingerprint = request_fingerprint(payload)
    with transaction.atomic():
        existing = JournalEntry.objects.select_for_update().filter(idempotency_key=key).first()
        if existing:
            if existing.request_hash != fingerprint:
                raise IdempotencyConflict('Idempotency key was already used with different inputs.')
            return existing, False

        entry = JournalEntry.objects.create(
            operation=operation,
            idempotency_key=key,
            request_hash=fingerprint,
            description=description,
            metadata=metadata or {},
        )
        JournalLine.objects.bulk_create([
            JournalLine(
                journal_entry=entry,
                account=_account_for(line),
                direction=line.direction,
                amount=line.amount,
            )
            for line in lines
        ])
        return entry, True


def account_balance(account):
    from django.db.models import Q, Sum

    totals = account.journal_lines.aggregate(
        credits=Sum('amount', filter=Q(direction='credit')),
        debits=Sum('amount', filter=Q(direction='debit')),
    )
    return (totals['credits'] or 0) - (totals['debits'] or 0)
