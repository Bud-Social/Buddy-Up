from apps.notifications.tasks import (
    send_buddy_request_notification,
    send_buddy_accepted_notification,
    send_follow_notification,
)


def notify_buddy_request(from_profile_id, to_profile_id):
    send_buddy_request_notification.delay(from_profile_id, to_profile_id)


def notify_buddy_accepted(from_profile_id, to_profile_id):
    send_buddy_accepted_notification.delay(from_profile_id, to_profile_id)


def notify_follow(follower_profile_id, followee_profile_id):
    send_follow_notification.delay(follower_profile_id, followee_profile_id)
