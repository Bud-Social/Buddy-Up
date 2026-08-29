from uuid import uuid4

from django.db import models
from django.conf import settings

from common.models import TimestampedModel


class ModerationReport(TimestampedModel):
    REPORT_REASONS = [
        ('spam', 'Spam'),
        ('harassment', 'Harassment'),
        ('hate_speech', 'Hate Speech'),
        ('nudity', 'Nudity / Sexual Content'),
        ('adult_ungated', 'Adult Content Outside Mature Category'),
        ('violence', 'Violence'),
        ('misinformation', 'Misinformation'),
        ('impersonation', 'Impersonation'),
        ('other', 'Other'),
    ]
    STATUS_CHOICES = [
        ('open', 'Open'),
        ('investigating', 'Investigating'),
        ('resolved', 'Resolved'),
        ('dismissed', 'Dismissed'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    reporter = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL,
        null=True, blank=True, related_name='reports_made',
    )
    target_user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='reports_received',
    )
    reason = models.CharField(max_length=30, choices=REPORT_REASONS)
    description = models.TextField(blank=True, max_length=1000)
    content_url = models.URLField(blank=True)
    status = models.CharField(max_length=15, choices=STATUS_CHOICES, default='open')
    assigned_to = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL,
        null=True, blank=True, related_name='assigned_reports',
    )
    resolved_at = models.DateTimeField(null=True, blank=True)
    resolution_note = models.TextField(blank=True)

    class Meta:
        db_table = 'moderation_report'
        indexes = [
            models.Index(fields=['status']),
            models.Index(fields=['reason']),
            models.Index(fields=['-created_at']),
        ]
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.reason} — {self.status}'


class ContentFlag(TimestampedModel):
    FLAG_REASONS = [
        ('nsfw', 'NSFW'),
        ('toxic', 'Toxic Language'),
        ('spam', 'Spam'),
        ('misinfo', 'Misinformation'),
        ('medical_claim', 'Medical / Treatment Claim'),
        ('undisclosed_sponsor', 'Undisclosed Sponsorship'),
        ('adult_ungated', 'Adult Content Outside Mature Category'),
        ('custom', 'Custom Rule'),
    ]
    SEVERITY_CHOICES = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('critical', 'Critical'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    flag_reason = models.CharField(max_length=20, choices=FLAG_REASONS)
    severity = models.CharField(max_length=10, choices=SEVERITY_CHOICES, default='medium')
    confidence = models.FloatField(default=0.0)
    source = models.CharField(max_length=50, default='auto')
    content_type = models.CharField(max_length=50)
    content_id = models.CharField(max_length=100)
    content_preview = models.TextField(blank=True, max_length=500)
    is_actioned = models.BooleanField(default=False)
    action_taken = models.CharField(max_length=50, blank=True)

    class Meta:
        db_table = 'moderation_content_flag'
        indexes = [
            models.Index(fields=['content_type', 'content_id']),
            models.Index(fields=['flag_reason']),
            models.Index(fields=['severity']),
            models.Index(fields=['-created_at']),
        ]
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.flag_reason} ({self.severity})'


class ModerationAction(TimestampedModel):
    ACTION_CHOICES = [
        ('warning', 'Warning'),
        ('content_removed', 'Content Removed'),
        ('user_suspended', 'User Suspended'),
        ('user_banned', 'User Banned'),
        ('report_dismissed', 'Report Dismissed'),
        ('action_reversed', 'Action Reversed on Appeal'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    action = models.CharField(max_length=25, choices=ACTION_CHOICES)
    moderator = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL,
        null=True, related_name='moderation_actions',
    )
    report = models.ForeignKey(
        ModerationReport, on_delete=models.CASCADE,
        null=True, blank=True, related_name='actions',
    )
    target_user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='moderation_actions_received',
    )
    reason = models.TextField()
    duration_days = models.IntegerField(null=True, blank=True)

    class Meta:
        db_table = 'moderation_action'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.action} by {self.moderator}'


class ModerationAppeal(TimestampedModel):
    """User appeal against a moderation action, with independent review."""

    STATUS_CHOICES = [
        ('submitted', 'Submitted'),
        ('under_review', 'Under Review'),
        ('approved', 'Approved / Action Reversed'),
        ('denied', 'Denied'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    action = models.ForeignKey(
        ModerationAction, on_delete=models.CASCADE, related_name='appeals',
    )
    appellant = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='moderation_appeals',
    )
    reason = models.TextField(max_length=1500)
    status = models.CharField(max_length=15, choices=STATUS_CHOICES, default='submitted')
    reviewer = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL,
        null=True, blank=True, related_name='moderation_appeal_reviews',
    )
    reviewed_at = models.DateTimeField(null=True, blank=True)
    resolution_note = models.TextField(blank=True, max_length=1500)

    class Meta:
        db_table = 'moderation_appeal'
        ordering = ['-created_at']
        constraints = [
            models.UniqueConstraint(
                fields=['action', 'appellant'], name='uniq_action_appellant_appeal',
            ),
        ]
