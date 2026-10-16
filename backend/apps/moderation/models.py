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
    # The model's own account of why it flagged this. Persisted rather than
    # recomputed on read, for two reasons: the checkpoint can be retrained
    # between the flag and the review (so a re-read would silently change the
    # justification under the moderator), and a flag with no stated reason is
    # one a reviewer cannot act on without re-deriving it by hand.
    ai_explanation = models.TextField(blank=True, default='')
    # Which model produced the decision. Reviewers need to know whether they
    # are reading a classifier's reasoning or a keyword rule's.
    ai_method = models.CharField(max_length=50, blank=True, default='')
    # False when no bias model was deployed. Distinct from "no bias found",
    # which is what a reviewer would otherwise assume from an empty field.
    bias_assessed = models.BooleanField(default=False)
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
    #: ``escalated`` is an *internal* routing decision, not something the user is
    #: told about. It exists because a flag being sent to a second reviewer is
    #: not a warning, and recording it as one notified the flagged user that
    #: staff had looked at their content and told them nothing — the single most
    #: alarming thing a platform can do by accident.
    ACTION_CHOICES = [
        ('warning', 'Warning'),
        ('content_removed', 'Content Removed'),
        ('user_suspended', 'User Suspended'),
        ('user_banned', 'User Banned'),
        ('report_dismissed', 'Report Dismissed'),
        ('escalated', 'Escalated for Second Review'),
        ('action_reversed', 'Action Reversed on Appeal'),
    ]

    #: Actions that change (or undo) a user's access. They are never applied by
    #: one person: ``apps.moderation.services.request_standing_action`` routes
    #: them through a two-person approval instead.
    STANDING_ACTIONS = ('user_suspended', 'user_banned')

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
    #: What this action acted on. Written for ``content_removed`` so the removal
    #: can be reversed later: without the pointer on the audit row, "un-remove
    #: this" has nothing to resolve ``content_id`` against.
    content_type = models.CharField(max_length=50, blank=True)
    content_id = models.CharField(max_length=100, blank=True)
    #: Set when this action has been undone. Null ``reversed_by`` means the
    #: action still stands; a populated row is the record of who undid it and
    #: why, which is what an appeal panel reads.
    reversed_by = models.ForeignKey(
        'self', on_delete=models.SET_NULL,
        null=True, blank=True, related_name='reversals',
    )
    reversed_at = models.DateTimeField(null=True, blank=True)
    reversal_reason = models.TextField(blank=True)

    class Meta:
        db_table = 'moderation_action'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.action} by {self.moderator}'

    @property
    def is_reversed(self):
        return self.reversed_at is not None


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

    def __str__(self):
        return f'Appeal against {self.action_id} ({self.status})'


class Commendation(TimestampedModel):
    """A staff-recorded "you did good" for a user.

    The positive half of moderation. Every other model in this app records what
    somebody did wrong; a queue that only ever subtracts trains moderators to
    think in negatives and gives users no way to be told they were valued. This
    is the row that says so, permanently, in the user's own notification feed.

    ``visible_to_recipient=False`` is a revoke, not a delete: the row stays so
    an operator cannot erase the fact that they issued a commendation, and the
    recipient simply stops seeing it.
    """

    CATEGORY_CHOICES = [
        ('excellent_service', 'Excellent Service'),
        ('helpful', 'Helpful'),
        ('reliable', 'Reliable'),
        ('community_builder', 'Community Builder'),
        ('above_and_beyond', 'Above and Beyond'),
        ('resolved_issue', 'Resolved Issue'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    recipient = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE, related_name='commendations',
    )
    issued_by = models.ForeignKey(
        'profiles.Profile', on_delete=models.SET_NULL,
        null=True, blank=True, related_name='commendations_issued',
    )
    category = models.CharField(max_length=32, choices=CATEGORY_CHOICES, default='helpful')
    message = models.TextField(max_length=500)
    visible_to_recipient = models.BooleanField(default=True)

    class Meta:
        db_table = 'moderation_commendation'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['recipient', '-created_at']),
            models.Index(fields=['category']),
        ]

    def __str__(self):
        return f'{self.get_category_display()} for {self.recipient_id}'
