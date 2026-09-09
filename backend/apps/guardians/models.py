from django.conf import settings
from django.db import models

from common.models import TimestampedModel


def default_permissions():
    """Fresh links start fully permissive; guardians tighten per family."""
    return {'allow_direct_messages': True, 'allow_spends': True}


class GuardianLink(TimestampedModel):
    """Parental co-owner <-> teen connection with per-family permissions."""

    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('active', 'Active'),
        ('revoked', 'Revoked'),
    ]

    guardian = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='guardian_links_sent',
    )
    teen = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='guardian_links_received',
    )
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    invite_email = models.EmailField()
    # sha256 hex of the one-time raw invite token; the raw token is never stored.
    invite_token_hash = models.CharField(max_length=64, blank=True, db_index=True)
    permissions = models.JSONField(default=default_permissions)
    accepted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'guardians_guardian_link'
        constraints = [
            models.UniqueConstraint(
                fields=['guardian', 'teen'], name='guardians_guardian_teen_unique'
            ),
        ]
        indexes = [
            models.Index(fields=['status']),
            models.Index(fields=['teen']),
        ]

    def __str__(self):
        return f'{self.guardian} -> {self.teen} ({self.status})'
