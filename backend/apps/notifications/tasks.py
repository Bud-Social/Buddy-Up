from celery import shared_task
from django.utils import timezone
from datetime import timedelta


@shared_task
def create_notification(recipient_id: str, notification_type: str, title: str, body: str = '', metadata: dict = None):
    from apps.profiles.models import Profile
    from .models import Notification, NotificationPreference
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

    should_push = prefs.push_enabled
    if prefs.quiet_hours_start and prefs.quiet_hours_end:
        now = timezone.localtime().time()
        h1, h2 = prefs.quiet_hours_start, prefs.quiet_hours_end
        if h1 < h2 and h1 <= now <= h2:
            should_push = False
        elif h1 > h2 and (now >= h1 or now <= h2):
            should_push = False

    if not should_push:
        return

    from asgiref.sync import async_to_sync
    from channels.layers import get_channel_layer
    try:
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            f'user_{recipient_id}',
            {
                'type': 'event_notification',
                'data': {
                    'id': str(notification.id) if hasattr(locals(), 'notification') else '',
                    'type': notification_type,
                    'title': title,
                    'body': body,
                    'metadata': metadata or {},
                },
            },
        )
    except:
        pass


def _deliver_notification(recipient_id: str, notification_type: str, title: str, body: str = '', metadata: dict = None):
    """Create an in-app notification and push it over the websocket channel layer."""
    from apps.profiles.models import Profile
    from .models import Notification
    try:
        profile = Profile.objects.get(user_id=recipient_id)
    except Profile.DoesNotExist:
        return

    notification = Notification.objects.create(
        recipient=profile,
        notification_type=notification_type,
        title=title,
        body=body,
        metadata=metadata or {},
    )

    from asgiref.sync import async_to_sync
    from channels.layers import get_channel_layer
    try:
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            f'user_{recipient_id}',
            {
                'type': 'event_notification',
                'data': {
                    'id': str(notification.id),
                    'type': notification_type,
                    'title': title,
                    'body': body,
                    'metadata': metadata or {},
                    'created_at': notification.created_at.isoformat(),
                },
            },
        )
    except Exception:
        pass



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
        metadata={'from_user_id': str(from_profile.user_id), 'from_username': from_profile.username,
                   'from_display_name': from_profile.display_name, 'from_avatar_url': from_profile.avatar_url},
    )

    try:
        from asgiref.sync import async_to_sync
        from channels.layers import get_channel_layer
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(f'user_{to_profile.user_id}', {
            'type': 'event_notification',
            'data': {'id': str(notification.id), 'type': 'buddy_request', 'title': notification.title,
                      'body': notification.body, 'metadata': notification.metadata, 'created_at': notification.created_at.isoformat()},
        })
    except: pass


@shared_task
def send_buddy_accepted_notification(from_profile_id: str, to_profile_id: str):
    from apps.profiles.models import Profile
    from .models import Notification
    from_profile = Profile.objects.get(user_id=from_profile_id)
    to_profile = Profile.objects.get(user_id=to_profile_id)

    n1 = Notification.objects.create(
        recipient=from_profile, notification_type='buddy_accepted',
        title=f'You and {to_profile.display_name} are now BuddyUp Buddies! 🎉',
        body=f'Start a conversation with @{to_profile.username}.',
        metadata={'from_user_id': str(to_profile.user_id), 'from_username': to_profile.username,
                   'from_display_name': to_profile.display_name, 'from_avatar_url': to_profile.avatar_url},
    )
    n2 = Notification.objects.create(
        recipient=to_profile, notification_type='buddy_accepted',
        title=f'You and {from_profile.display_name} are now BuddyUp Buddies! 🎉',
        body=f'Start a conversation with @{from_profile.username}.',
        metadata={'from_user_id': str(from_profile.user_id), 'from_username': from_profile.username,
                   'from_display_name': from_profile.display_name, 'from_avatar_url': from_profile.avatar_url},
    )
    try:
        from asgiref.sync import async_to_sync; from channels.layers import get_channel_layer
        cl = get_channel_layer()
        for n in [n1, n2]:
            async_to_sync(cl.group_send)(f'user_{n.recipient.user_id}', {
                'type': 'event_notification',
                'data': {'id': str(n.id), 'type': n.notification_type, 'title': n.title,
                          'body': n.body, 'metadata': n.metadata, 'created_at': n.created_at.isoformat()},
            })
    except: pass


@shared_task
def send_follow_notification(follower_id: str, followee_id: str):
    from apps.profiles.models import Profile
    from .models import Notification
    follower = Profile.objects.get(user_id=follower_id)
    followee = Profile.objects.get(user_id=followee_id)
    n = Notification.objects.create(
        recipient=followee, notification_type='new_follower',
        title=f'{follower.display_name} started following you',
        body=f'@{follower.username} is now following you.',
        metadata={'from_user_id': str(follower.user_id), 'from_username': follower.username,
                   'from_display_name': follower.display_name, 'from_avatar_url': follower.avatar_url},
    )
    try:
        from asgiref.sync import async_to_sync; from channels.layers import get_channel_layer
        async_to_sync(get_channel_layer().group_send)(f'user_{followee.user_id}', {
            'type': 'event_notification',
            'data': {'id': str(n.id), 'type': n.notification_type, 'title': n.title,
                      'body': n.body, 'metadata': n.metadata, 'created_at': n.created_at.isoformat()},
        })
    except: pass


@shared_task
def send_login_alert(user_id: str, ip_address: str, device: str, location: str = ''):
    from apps.profiles.models import Profile
    from .models import Notification
    try:
        profile = Profile.objects.get(user_id=user_id)
    except Profile.DoesNotExist:
        return
    n = Notification.objects.create(
        recipient=profile, notification_type='new_device_login',
        title=f'New login detected',
        body=f'New login from {device} ({ip_address})',
        metadata={'ip': ip_address, 'device': device, 'location': location},
    )
    try:
        from asgiref.sync import async_to_sync; from channels.layers import get_channel_layer
        async_to_sync(get_channel_layer().group_send)(f'user_{user_id}', {
            'type': 'event_notification',
            'data': {'id': str(n.id), 'type': n.notification_type, 'title': n.title,
                      'body': n.body, 'metadata': n.metadata, 'created_at': n.created_at.isoformat()},
        })
    except: pass


@shared_task
def send_verification_update(user_id: str, status: str, message: str = ''):
    from .models import Notification
    from apps.profiles.models import Profile
    try:
        profile = Profile.objects.get(user_id=user_id)
    except Profile.DoesNotExist:
        return
    n = Notification.objects.create(
        recipient=profile, notification_type='verification_update',
        title=f'Verification status updated',
        body=message or f'Your verification status is now: {status}.',
        metadata={'status': status},
    )
    try:
        from asgiref.sync import async_to_sync; from channels.layers import get_channel_layer
        async_to_sync(get_channel_layer().group_send)(f'user_{user_id}', {
            'type': 'event_notification',
            'data': {'id': str(n.id), 'type': n.notification_type, 'title': n.title,
                      'body': n.body, 'metadata': n.metadata, 'created_at': n.created_at.isoformat()},
        })
    except: pass


@shared_task
def send_payment_notification(user_id: str, tx_type: str, amount: str):
    from .models import Notification
    from apps.profiles.models import Profile
    try:
        profile = Profile.objects.get(user_id=user_id)
    except Profile.DoesNotExist:
        return
    labels = {'purchase': 'Purchase', 'withdrawal': 'Withdrawal', 'tip_received': 'Tip Received'}
    n = Notification.objects.create(
        recipient=profile, notification_type='payment_received',
        title=f'{labels.get(tx_type, "Payment")}: {amount}',
        body=f'Transaction type: {tx_type}. Amount: {amount}.',
        metadata={'tx_type': tx_type, 'amount': amount},
    )
    try:
        from asgiref.sync import async_to_sync; from channels.layers import get_channel_layer
        async_to_sync(get_channel_layer().group_send)(f'user_{user_id}', {
            'type': 'event_notification',
            'data': {'id': str(n.id), 'type': n.notification_type, 'title': n.title,
                      'body': n.body, 'metadata': n.metadata, 'created_at': n.created_at.isoformat()},
        })
    except: pass


@shared_task
def send_daily_digest():
    from .models import Notification, NotificationPreference
    from apps.profiles.models import Profile
    yesterday = timezone.now() - timedelta(days=1)
    profiles = Profile.objects.all()
    for profile in profiles[:100]:
        try:
            prefs = NotificationPreference.objects.get(profile=profile)
            if not prefs.email_enabled:
                continue
        except NotificationPreference.DoesNotExist:
            continue
        count = Notification.objects.filter(
            recipient=profile, created_at__gte=yesterday, is_read=False,
        ).count()
        if count > 0:
            Notification.objects.create(
                recipient=profile, notification_type='payment_received',
                title=f'You have {count} unread notifications',
                body='Check BuddyUp to see what you missed!',
                metadata={'count': count},
            )


@shared_task
def cleanup_old_notifications():
    from .models import Notification
    cutoff = timezone.now() - timedelta(days=90)
    Notification.objects.filter(created_at__lt=cutoff, is_read=True).delete()


@shared_task
def send_live_started_notification(live_id: str, host_profile_id: str):
    from apps.profiles.models import Profile, BuddyRelationship
    from .models import Notification
    from django.db.models import Q

    try:
        host = Profile.objects.get(user_id=host_profile_id)
    except Profile.DoesNotExist:
        return

    buddies = Profile.objects.filter(
        Q(buddy_sent__to_user=host, buddy_sent__status='confirmed') |
        Q(buddy_received__from_user=host, buddy_received__status='confirmed'),
    ).distinct()

    # Also notify followers so trending lives reach a wider audience.
    followers = Profile.objects.filter(following__followee=host).distinct()

    from asgiref.sync import async_to_sync
    from channels.layers import get_channel_layer
    channel_layer = get_channel_layer()

    seen = set()
    for profile in list(buddies) + list(followers):
        if profile.user_id in seen:
            continue
        seen.add(profile.user_id)
        n = Notification.objects.create(
            recipient=profile,
            notification_type='live_starting',
            title=f'{host.display_name} is live now!',
            body=f'@{host.username} just started "{host.display_name}\'s live" — join the sweat!',
            metadata={
                'live_id': live_id,
                'host_user_id': host_profile_id,
                'host_display_name': host.display_name,
                'host_username': host.username,
                'host_avatar_url': host.avatar_url,
            },
        )
        try:
            async_to_sync(channel_layer.group_send)(
                f'user_{profile.user_id}',
                {
                    'type': 'event_notification',
                    'data': {
                        'id': str(n.id),
                        'type': 'live_starting',
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
def send_cohost_invite_notification(host_profile_id: str, invitee_profile_id: str, live_id: str):
    """Host invites a user to co-host their live — invitee gets a notification."""
    from apps.profiles.models import Profile
    from .models import Notification
    try:
        host = Profile.objects.get(user_id=host_profile_id)
        invitee = Profile.objects.get(user_id=invitee_profile_id)
    except Profile.DoesNotExist:
        return

    n = Notification.objects.create(
        recipient=invitee,
        notification_type='live_starting',
        title=f'{host.display_name} invited you to co-host! 🎙️',
        body=f'Join @{host.username}\'s live as a co-host and take the stage.',
        metadata={
            'live_id': live_id,
            'host_user_id': host_profile_id,
            'host_display_name': host.display_name,
            'host_username': host.username,
            'host_avatar_url': host.avatar_url,
            'action': 'cohost_invite',
        },
    )
    try:
        from asgiref.sync import async_to_sync
        from channels.layers import get_channel_layer
        async_to_sync(get_channel_layer().group_send)(f'user_{invitee_profile_id}', {
            'type': 'event_notification',
            'data': {'id': str(n.id), 'type': n.notification_type, 'title': n.title,
                      'body': n.body, 'metadata': n.metadata, 'created_at': n.created_at.isoformat()},
        })
    except: pass


@shared_task
def send_cohost_request_notification(requesting_profile_id: str, live_id: str):
    """An attendee requests to speak — host gets a notification."""
    from apps.profiles.models import Profile
    from .models import Notification
    from apps.lives.models import BuddyLive
    try:
        requester = Profile.objects.get(user_id=requesting_profile_id)
        live = BuddyLive.objects.select_related('host').get(id=live_id)
    except (Profile.DoesNotExist, BuddyLive.DoesNotExist):
        return

    n = Notification.objects.create(
        recipient=live.host,
        notification_type='live_starting',
        title=f'{requester.display_name} wants to speak 🎤',
        body=f'@{requester.username} requested to co-host "{live.title}". Tap to approve.',
        metadata={
            'live_id': live_id,
            'requesting_user_id': requesting_profile_id,
            'requesting_display_name': requester.display_name,
            'requesting_username': requester.username,
            'action': 'cohost_request',
        },
    )
    try:
        from asgiref.sync import async_to_sync
        from channels.layers import get_channel_layer
        async_to_sync(get_channel_layer().group_send)(f'user_{live.host.user_id}', {
            'type': 'event_notification',
            'data': {'id': str(n.id), 'type': n.notification_type, 'title': n.title,
                      'body': n.body, 'metadata': n.metadata, 'created_at': n.created_at.isoformat()},
        })
    except: pass


@shared_task
def send_post_notification(post_id: str, author_profile_id: str):
    """Notify buddies + followers when a user publishes a new post."""
    from apps.profiles.models import Profile
    from .models import Notification
    from django.db.models import Q
    try:
        author = Profile.objects.get(user_id=author_profile_id)
    except Profile.DoesNotExist:
        return

    from apps.feed.models import Post
    try:
        post = Post.objects.get(id=post_id)
    except Post.DoesNotExist:
        return

    if post.visibility != 'public' or post.moderation_status != 'clean' or post.is_deleted:
        return

    recipients = Profile.objects.filter(
        Q(buddy_sent__to_user=author, buddy_sent__status='confirmed') |
        Q(buddy_received__from_user=author, buddy_received__status='confirmed') |
        Q(following__followee=author),
    ).distinct()

    from asgiref.sync import async_to_sync
    from channels.layers import get_channel_layer
    channel_layer = get_channel_layer()

    preview = (post.body or '')[:200] or (post.media_urls and '📸 Shared a media post') or 'Shared a new post'
    is_video = any(
        str(u).split('?')[0].lower().rsplit('.', 1)[-1] in ('mp4', 'webm', 'mov', 'm4v') for u in (post.media_urls or [])
    )
    if is_video:
        preview = '🎬 Shared a video'

    for recipient in recipients:
        n = Notification.objects.create(
            recipient=recipient,
            notification_type='post_reaction',
            title=f'{author.display_name} posted',
            body=preview,
            metadata={
                'post_id': str(post.id),
                'author_username': author.username,
                'author_display_name': author.display_name,
                'author_avatar_url': author.avatar_url,
                'is_video': is_video,
            },
        )
        try:
            async_to_sync(channel_layer.group_send)(
                f'user_{recipient.user_id}',
                {
                    'type': 'event_notification',
                    'data': {
                        'id': str(n.id),
                        'type': 'post_reaction',
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
def send_repost_notification(repost_author_id: str, original_post_id: str):
    """Notify the original author when someone reposts their post."""
    from apps.profiles.models import Profile
    from .models import Notification
    from apps.feed.models import Post
    try:
        reposter = Profile.objects.get(user_id=repost_author_id)
        original = Post.objects.select_related('author').get(id=original_post_id)
    except (Profile.DoesNotExist, Post.DoesNotExist):
        return

    if original.author == reposter:
        return

    n = Notification.objects.create(
        recipient=original.author,
        notification_type='post_repost',
        title=f'{reposter.display_name} reposted your post',
        body=(original.body or '')[:200] or 'Reposted by ' + reposter.display_name,
        metadata={
            'post_id': str(original.id),
            'repost_author_id': reposter.user_id,
            'repost_username': reposter.username,
            'repost_display_name': reposter.display_name,
            'repost_avatar_url': reposter.avatar_url,
        },
    )
    try:
        from asgiref.sync import async_to_sync
        from channels.layers import get_channel_layer
        async_to_sync(get_channel_layer().group_send)(f'user_{original.author.user_id}', {
            'type': 'event_notification',
            'data': {'id': str(n.id), 'type': n.notification_type, 'title': n.title,
                      'body': n.body, 'metadata': n.metadata, 'created_at': n.created_at.isoformat()},
        })
    except: pass
