from django.db import models
from common.models import TimestampedModel
from uuid import uuid4


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

    class Meta:
        db_table = 'wallet_artifact_transaction'
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['transaction_type']),
            models.Index(fields=['status']),
            models.Index(fields=['counterparty']),
        ]
