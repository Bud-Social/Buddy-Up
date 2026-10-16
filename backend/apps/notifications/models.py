from uuid import uuid4

from django.db import models
from common.models import TimestampedModel


class Notification(TimestampedModel):
    PRIORITY_CHOICES = [('low', 'Low'), ('normal', 'Normal'), ('high', 'High'), ('critical', 'Critical')]
    DELIVERY_CHOICES = [('pending', 'Pending'), ('delivered', 'Delivered'), ('failed', 'Failed'), ('skipped', 'Skipped')]
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
        # Authority changes. A user has to be told when their access changes --
        # otherwise a demotion is silent and an elevation is a surprise they
        # discover by seeing a screen they could not see before.
        ('gym_role_changed', 'Gym Role Changed'),
        ('gym_removed', 'Gym Membership Removed'),
        ('gym_joined', 'Gym Membership Approved'),
        ('staff_role_granted', 'Staff Role Granted'),
        ('staff_role_revoked', 'Staff Role Revoked'),
        ('session_booked', 'Session Booked'),
        ('session_reminder', 'Session Reminder'),
        ('session_cancelled', 'Session Cancelled'),
        ('payment_received', 'Payment Received'),
        ('withdrawal_processed', 'Withdrawal Processed'),
        ('streak_milestone', 'Streak Milestone'),
        ('streak_reminder', 'Streak Reminder'),
        ('verification_update', 'Verification Update'),
        ('accountability_ping', 'Accountability Ping'),
        ('buddy_nearby_available', 'Buddies Nearby Available'),
        ('new_device_login', 'New Device Login'),
        # Marketplace / Shop
        ('shop_created', 'Shop Created'),
        ('shop_verified', 'Shop Verified'),
        ('shop_cert_status', 'Shop Certification Status Update'),
        ('programme_reminder', 'Programme Activity Reminder'),
        ('meal_reminder', 'Meal Plan Daily Reminder'),
        ('new_purchase', 'New Purchase'),
        ('shop_invite', 'Shop Invite'),
        # Communities
        ('community_invite', 'Community Invite'),
        ('community_member', 'New Community Member'),
        ('community_post', 'Community Post'),
        ('community_comment', 'Community Comment'),
        ('community_reaction', 'Community Reaction'),
        ('community_join_request', 'Community Join Request'),
        ('community_join_approved', 'Community Join Approved'),
        # Events & Commerce & Social
        ('repost', 'Post Repost'),
        ('mention', 'Mention'),
        ('event_ticket_purchased', 'Event Ticket Purchased'),
        ('order_status_changed', 'Order Status Changed'),
        ('payout_processed', 'Payout Processed'),
        ('alarm_shared', 'Alarm Shared'),
        ('alarm_share_accepted', 'Alarm Share Accepted'),
        ('alarm_suggestion', 'Alarm Suggestion'),
        # Moderation & commendations
        #
        # Every type below has a matching ``NotificationPreference`` push column.
        # That is not tidiness: ``create_notification`` resolves per-type opt-out
        # with ``getattr(prefs, f'{notification_type}_push', None)`` and a
        # MISSING column returns None, which the ``category_pref is not False``
        # check reads as "push". A type without a column is therefore silently
        # un-disableable — it would reach every user on the platform with no way
        # to turn it off. Adding the type and the column is one change, not two.
        ('moderation_warning', 'Moderation Warning'),
        ('moderation_content_removed', 'Content Removed'),
        ('moderation_suspension', 'Account Suspended'),
        ('moderation_ban', 'Account Banned'),
        ('moderation_action_reversed', 'Moderation Action Reversed'),
        ('commendation_received', 'Commendation Received'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    recipient = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='notifications')
    notification_type = models.CharField(max_length=30, choices=TYPE_CHOICES)
    title = models.CharField(max_length=200)
    body = models.TextField(blank=True)
    metadata = models.JSONField(default=dict)
    is_read = models.BooleanField(default=False)
    is_pushed = models.BooleanField(default=False)
    # Pinned notifications float to the top of the list; dismissed ones are
    # hidden (soft-delete) so accidental swipes are recoverable.
    is_pinned = models.BooleanField(default=False)
    is_dismissed = models.BooleanField(default=False)
    priority = models.CharField(max_length=10, choices=PRIORITY_CHOICES, default='normal')
    dedupe_key = models.CharField(max_length=200, blank=True)
    aggregation_count = models.PositiveIntegerField(default=1)
    expires_at = models.DateTimeField(null=True, blank=True)
    delivery_status = models.CharField(max_length=10, choices=DELIVERY_CHOICES, default='pending')
    delivered_at = models.DateTimeField(null=True, blank=True)

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
    timezone = models.CharField(max_length=60, default='UTC')
    category_frequency = models.JSONField(default=dict, blank=True)

    buddy_request_push = models.BooleanField(default=True)
    buddy_accepted_push = models.BooleanField(default=True)
    new_follower_push = models.BooleanField(default=False)
    comment_push = models.BooleanField(default=False)
    live_starting_push = models.BooleanField(default=True)
    session_reminder_push = models.BooleanField(default=True)
    streak_milestone_push = models.BooleanField(default=True)
    accountability_ping_push = models.BooleanField(default=True)
    buddy_nearby_push = models.BooleanField(default=True)
    # Marketplace push preferences
    programme_reminder_push = models.BooleanField(default=True)
    meal_reminder_push = models.BooleanField(default=True)
    shop_cert_push = models.BooleanField(default=True)
    new_purchase_push = models.BooleanField(default=True)
    # Order status changes now reach sellers as well as the buyer, and that push
    # is no longer incidental. Without this column the lookup in
    # ``create_notification`` (``getattr(prefs, f'{type}_push', None)``) returns
    # None and the notification is pushed whether or not the user opted out.
    order_status_changed_push = models.BooleanField(default=True)
    # Moderation push preferences. See the note on TYPE_CHOICES: each of these
    # types MUST have a column here or the notification is pushed to every
    # recipient with no opt-out.
    moderation_warning_push = models.BooleanField(default=True)
    moderation_content_removed_push = models.BooleanField(default=True)
    moderation_suspension_push = models.BooleanField(default=True)
    moderation_ban_push = models.BooleanField(default=True)
    moderation_action_reversed_push = models.BooleanField(default=True)
    commendation_received_push = models.BooleanField(default=True)

    class Meta:
        db_table = 'notifications_preference'
