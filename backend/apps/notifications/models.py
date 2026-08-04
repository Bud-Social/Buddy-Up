from uuid import uuid4

from django.db import models
from common.models import TimestampedModel


class Notification(TimestampedModel):
    TYPE_CHOICES = [
        ('buddy_request', 'Buddy Request'),
        ('buddy_accepted', 'Buddy Accepted'),
        ('buddy_declined', 'Buddy Declined'),
        ('new_follower', 'New Follower'),
        ('comment', 'Comment'),
        ('comment_reply', 'Comment Reply'),
        ('post_reaction', 'Post Reaction'),
        ('post_repost', 'Post Repost'),
        ('post_quote', 'Post Quote'),
        ('live_starting', 'Live Starting'),
        ('live_reminder', 'Live Reminder'),
        ('gym_invite', 'Gym Invite'),
        ('session_booked', 'Session Booked'),
        ('session_reminder', 'Session Reminder'),
        ('session_cancelled', 'Session Cancelled'),
        ('payment_received', 'Payment Received'),
        ('withdrawal_processed', 'Withdrawal Processed'),
        ('streak_milestone', 'Streak Milestone'),
        ('streak_reminder', 'Streak Reminder'),
        ('verification_update', 'Verification Update'),
        ('accountability_ping', 'Accountability Ping'),
        ('new_device_login', 'New Device Login'),
        # Marketplace / Shop
        ('shop_created', 'Shop Created'),
        ('shop_verified', 'Shop Verified'),
        ('shop_cert_status', 'Shop Certification Status Update'),
        ('programme_reminder', 'Programme Activity Reminder'),
        ('meal_reminder', 'Meal Plan Daily Reminder'),
        ('new_purchase', 'New Purchase'),
        ('shop_invite', 'Shop Invite'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    recipient = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='notifications')
    notification_type = models.CharField(max_length=30, choices=TYPE_CHOICES)
    title = models.CharField(max_length=200)
    body = models.TextField(blank=True)
    metadata = models.JSONField(default=dict)
    is_read = models.BooleanField(default=False)
    is_pushed = models.BooleanField(default=False)

    class Meta:
        db_table = 'notifications_notification'
        indexes = [
            models.Index(fields=['recipient', '-created_at']),
            models.Index(fields=['recipient', 'is_read']),
            models.Index(fields=['notification_type']),
        ]
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.notification_type} for {self.recipient}'


class NotificationPreference(TimestampedModel):
    profile = models.OneToOneField('profiles.Profile', on_delete=models.CASCADE, related_name='notification_preferences')
    push_enabled = models.BooleanField(default=True)
    email_enabled = models.BooleanField(default=True)
    in_app_enabled = models.BooleanField(default=True)
    quiet_hours_start = models.TimeField(null=True, blank=True)
    quiet_hours_end = models.TimeField(null=True, blank=True)

    buddy_request_push = models.BooleanField(default=True)
    buddy_accepted_push = models.BooleanField(default=True)
    new_follower_push = models.BooleanField(default=False)
    comment_push = models.BooleanField(default=False)
    live_starting_push = models.BooleanField(default=True)
    session_reminder_push = models.BooleanField(default=True)
    streak_milestone_push = models.BooleanField(default=True)
    accountability_ping_push = models.BooleanField(default=True)
    # Marketplace push preferences
    programme_reminder_push = models.BooleanField(default=True)
    meal_reminder_push = models.BooleanField(default=True)
    shop_cert_push = models.BooleanField(default=True)
    new_purchase_push = models.BooleanField(default=True)

    class Meta:
        db_table = 'notifications_preference'
