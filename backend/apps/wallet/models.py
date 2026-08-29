from django.db import models
from common.models import TimestampedModel
from uuid import uuid4


class LedgerAccount(TimestampedModel):
    ACCOUNT_TYPES = [
        ('platform', 'Platform'),
        ('buyer', 'Buyer'),
        ('seller', 'Seller'),
        ('escrow', 'Escrow'),
    ]
    WALLET_BUCKETS = [
        ('system', 'System'),
        ('regular', 'Regular wallet'),
        ('creator', 'Creator wallet'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    account_type = models.CharField(max_length=10, choices=ACCOUNT_TYPES)
    profile = models.ForeignKey(
        'profiles.Profile', null=True, blank=True, on_delete=models.PROTECT,
        related_name='ledger_accounts',
    )
    wallet_bucket = models.CharField(max_length=10, choices=WALLET_BUCKETS)
    artifact_type = models.CharField(max_length=30)
    name = models.CharField(max_length=120)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'wallet_ledger_account'
        constraints = [
            models.UniqueConstraint(
                fields=['account_type', 'profile', 'wallet_bucket', 'artifact_type'],
                name='wallet_unique_profile_ledger_account',
            ),
            models.UniqueConstraint(
                fields=['account_type', 'wallet_bucket', 'artifact_type'],
                condition=models.Q(profile__isnull=True),
                name='wallet_unique_system_ledger_account',
            ),
        ]
        indexes = [models.Index(fields=['profile', 'artifact_type'], name='wallet_ledg_profile_b87592_idx')]

    def __str__(self):
        return f'{self.name} [{self.artifact_type}]'


class JournalEntry(TimestampedModel):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    operation = models.CharField(max_length=40, db_index=True)
    idempotency_key = models.CharField(max_length=180, unique=True)
    request_hash = models.CharField(max_length=64)
    description = models.CharField(max_length=255, blank=True)
    metadata = models.JSONField(default=dict, blank=True)
    posted_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'wallet_journal_entry'
        verbose_name_plural = 'journal entries'
        ordering = ['-posted_at']

    def __str__(self):
        return f'{self.operation}:{self.idempotency_key}'


class JournalLine(models.Model):
    DIRECTIONS = [('debit', 'Debit'), ('credit', 'Credit')]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    journal_entry = models.ForeignKey(
        JournalEntry, on_delete=models.PROTECT, related_name='lines',
    )
    account = models.ForeignKey(
        LedgerAccount, on_delete=models.PROTECT, related_name='journal_lines',
    )
    direction = models.CharField(max_length=6, choices=DIRECTIONS)
    amount = models.PositiveBigIntegerField()

    class Meta:
        db_table = 'wallet_journal_line'
        constraints = [
            models.CheckConstraint(condition=models.Q(amount__gt=0), name='wallet_line_amount_gt_zero'),
        ]
        indexes = [
            models.Index(fields=['account', 'direction'], name='wallet_jour_account_9c51ce_idx'),
            models.Index(fields=['journal_entry', 'direction'], name='wallet_jour_journal_5606f1_idx'),
        ]

    def __str__(self):
        return f'{self.direction} {self.amount} {self.account.artifact_type}'


class ArtifactTransaction(TimestampedModel):
    TRANSACTION_TYPES = [
        ('purchase', 'Purchase'),
        ('tip_sent', 'Tip Sent'),
        ('tip_received', 'Tip Received'),
        ('gift_sent', 'Gift Sent'),
        ('gift_received', 'Gift Received'),
        ('live_fee', 'Live Fee'),
        ('gym_subscription', 'Gym Subscription'),
        ('session_fee', 'Session Fee'),
        ('marketplace', 'Marketplace'),
        ('withdrawal', 'Withdrawal'),
        ('platform_cut', 'Platform Cut'),
        ('refund', 'Refund'),
        ('bonus', 'Bonus'),
        ('creator_transfer', 'Creator Wallet Transfer'),
    ]
    DIRECTION_CHOICES = [
        ('credit', 'Credit'),
        ('debit', 'Debit'),
    ]
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
        ('refunded', 'Refunded'),
        ('held', 'Held (Escrow)'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    user = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='transactions')
    transaction_type = models.CharField(max_length=20, choices=TRANSACTION_TYPES)
    artifact_type = models.CharField(max_length=30)
    quantity = models.IntegerField()
    direction = models.CharField(max_length=10, choices=DIRECTION_CHOICES)
    counterparty = models.ForeignKey('profiles.Profile', null=True, blank=True, on_delete=models.SET_NULL, related_name='counterparty_transactions')
    reference_id = models.CharField(max_length=100, blank=True)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    fiat_amount = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    fiat_currency = models.CharField(max_length=5, default='KES')
    payment_provider = models.CharField(max_length=30, blank=True)
    clearance_at = models.DateTimeField(null=True, blank=True)
    phone_number = models.CharField(max_length=20, blank=True)
    bank_account = models.CharField(max_length=100, blank=True)
    tx_ref = models.CharField(max_length=100, blank=True, db_index=True)
    flutterwave_id = models.CharField(max_length=100, blank=True)
    flutterwave_response = models.JSONField(null=True, blank=True)
    description = models.CharField(max_length=255, blank=True)
    journal_entry = models.ForeignKey(
        JournalEntry, null=True, blank=True, on_delete=models.PROTECT,
        related_name='artifact_transactions',
    )

    class Meta:
        db_table = 'wallet_artifact_transaction'
        constraints = [
            models.UniqueConstraint(
                fields=['tx_ref'],
                condition=~models.Q(tx_ref=''),
                name='wallet_unique_nonblank_tx_ref',
            ),
        ]
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['transaction_type']),
            models.Index(fields=['status']),
            models.Index(fields=['counterparty']),
        ]

    def __str__(self):
        return f'{self.transaction_type}:{self.tx_ref or self.id} ({self.status})'
