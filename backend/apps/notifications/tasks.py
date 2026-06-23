from celery import shared_task
from django.utils import timezone
from .models import Notification, NotificationPreference


@shared_task
def create_notification(recipient_id: str, notification_type: str, title: str, body: str = '', metadata: dict = None):
    from apps.profiles.models import Profile
    try:
        profile = Profile.objects.get(user_id=recipient_id)
    except Profile.DoesNotExist:
        return

    Notification.objects.create(
        recipient=profile,
        notification_type=notification_type,
        title=title,
        body=body,
        metadata=metadata or {},
    )

    try:
        prefs = NotificationPreference.objects.get(profile=profile)
    except NotificationPreference.DoesNotExist:
        return

    should_push = True
    if prefs.quiet_hours_start and prefs.quiet_hours_end:
        now = timezone.localtime().time()
        if prefs.quiet_hours_start < prefs.quiet_hours_end:
            if prefs.quiet_hours_start <= now <= prefs.quiet_hours_end:
                should_push = False
        else:
            if now >= prefs.quiet_hours_start or now <= prefs.quiet_hours_end:
                should_push = False

    if not should_push:
        return

    # TODO: Send push via FCM, email via SendGrid
    print(f"[DEV] Notification for {profile.username}: {title} - {body}")


@shared_task
def send_buddy_request_notification(from_profile_id: str, to_profile_id: str):
    from apps.profiles.models import Profile
    from .models import Notification
    from_profile = Profile.objects.get(user_id=from_profile_id)
    to_profile = Profile.objects.get(user_id=to_profile_id)

    notification = Notification.objects.create(
        recipient=to_profile,
        notification_type='buddy_request',
        title=f'{from_profile.display_name} wants to be your BuddyUp buddy! 💪',
        body=f'@{from_profile.username} sent you a buddy request.',
        metadata={
            'from_user_id': str(from_profile.user_id),
            'from_username': from_profile.username,
            'from_display_name': from_profile.display_name,
            'from_avatar_url': from_profile.avatar_url,
        },
    )

    try:
        from asgiref.sync import async_to_sync
        from channels.layers import get_channel_layer
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            f'user_{to_profile.user_id}',
            {
                'type': 'event_notification',
                'data': {
                    'id': str(notification.id),
                    'type': 'buddy_request',
                    'title': notification.title,
                    'body': notification.body,
                    'metadata': notification.metadata,
                    'created_at': notification.created_at.isoformat(),
                },
            },
        )
    except:
        pass


@shared_task
def send_buddy_accepted_notification(from_profile_id: str, to_profile_id: str):
    from apps.profiles.models import Profile
    from .models import Notification
    from_profile = Profile.objects.get(user_id=from_profile_id)
    to_profile = Profile.objects.get(user_id=to_profile_id)

    notification = Notification.objects.create(
        recipient=from_profile,
        notification_type='buddy_accepted',
        title=f'You and {to_profile.display_name} are now BuddyUp Buddies! 🎉',
        body=f'Start a conversation with @{to_profile.username}.',
        metadata={
            'from_user_id': str(to_profile.user_id),
            'from_username': to_profile.username,
            'from_display_name': to_profile.display_name,
            'from_avatar_url': to_profile.avatar_url,
        },
    )

    notification2 = Notification.objects.create(
        recipient=to_profile,
        notification_type='buddy_accepted',
        title=f'You and {from_profile.display_name} are now BuddyUp Buddies! 🎉',
        body=f'Start a conversation with @{from_profile.username}.',
        metadata={
            'from_user_id': str(from_profile.user_id),
            'from_username': from_profile.username,
            'from_display_name': from_profile.display_name,
            'from_avatar_url': from_profile.avatar_url,
        },
    )

    try:
        from asgiref.sync import async_to_sync
        from channels.layers import get_channel_layer
        channel_layer = get_channel_layer()
        for n in [notification, notification2]:
            async_to_sync(channel_layer.group_send)(
                f'user_{n.recipient.user_id}',
                {
                    'type': 'event_notification',
                    'data': {
                        'id': str(n.id),
                        'type': n.notification_type,
                        'title': n.title,
                        'body': n.body,
                        'metadata': n.metadata,
                        'created_at': n.created_at.isoformat(),
                    },
                },
            )
    except:
        pass


@shared_task
def send_follow_notification(follower_profile_id: str, followee_profile_id: str):
    from apps.profiles.models import Profile
    from .models import Notification
    follower = Profile.objects.get(user_id=follower_profile_id)
    followee = Profile.objects.get(user_id=followee_profile_id)

    notification = Notification.objects.create(
        recipient=followee,
        notification_type='new_follower',
        title=f'{follower.display_name} started following you',
        body=f'@{follower.username} is now following you.',
        metadata={
            'from_user_id': str(follower.user_id),
            'from_username': follower.username,
            'from_display_name': follower.display_name,
            'from_avatar_url': follower.avatar_url,
        },
    )
