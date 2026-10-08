import re
from django.db.models.signals import post_save
from django.dispatch import receiver


@receiver(post_save, sender='feed.Post')
def handle_post_created(sender, instance, created, **kwargs):
    if not created or getattr(instance, 'is_deleted', False):
        return

    from apps.notifications.tasks import create_notification

    # 1. Repost notification
    if instance.is_repost and instance.original_post and instance.original_post.author:
        orig_author = instance.original_post.author
        if orig_author.user_id != instance.author.user_id:
            create_notification.delay(
                recipient_id=str(orig_author.user_id),
                notification_type='repost',
                title=f'{instance.author.display_name} reposted your post',
                body=(instance.original_post.body or '')[:200] or 'Your post was reposted',
                metadata={
                    'post_id': str(instance.original_post.id),
                    'repost_post_id': str(instance.id),
                    'repost_author_id': str(instance.author.user_id),
                    'repost_username': instance.author.username,
                    'repost_display_name': instance.author.display_name,
                    'repost_avatar_url': instance.author.avatar_url,
                },
            )

    # 2. Mention notifications in post body
    if instance.body:
        usernames = set(re.findall(r'@(\w+)', instance.body))
        if usernames:
            from apps.profiles.models import Profile
            profiles = Profile.objects.filter(username__in=usernames).exclude(user_id=instance.author.user_id)
            for profile in profiles:
                create_notification.delay(
                    recipient_id=str(profile.user_id),
                    notification_type='mention',
                    title=f'{instance.author.display_name} mentioned you in a post',
                    body=instance.body[:200],
                    metadata={
                        'post_id': str(instance.id),
                        'author_user_id': str(instance.author.user_id),
                        'author_username': instance.author.username,
                        'author_display_name': instance.author.display_name,
                        'author_avatar_url': instance.author.avatar_url,
                    },
                )


@receiver(post_save, sender='feed.Comment')
def handle_comment_created(sender, instance, created, **kwargs):
    if not created or getattr(instance, 'is_deleted', False):
        return

    from apps.notifications.tasks import create_notification

    # Mention notifications in comment body
    if instance.body:
        usernames = set(re.findall(r'@(\w+)', instance.body))
        if usernames:
            from apps.profiles.models import Profile
            profiles = Profile.objects.filter(username__in=usernames).exclude(user_id=instance.author.user_id)
            for profile in profiles:
                create_notification.delay(
                    recipient_id=str(profile.user_id),
                    notification_type='mention',
                    title=f'{instance.author.display_name} mentioned you in a comment',
                    body=instance.body[:200],
                    metadata={
                        'post_id': str(instance.post_id),
                        'comment_id': str(instance.id),
                        'author_user_id': str(instance.author.user_id),
                        'author_username': instance.author.username,
                        'author_display_name': instance.author.display_name,
                        'author_avatar_url': instance.author.avatar_url,
                    },
                )


@receiver(post_save, sender='marketplace.EventTicket')
def handle_event_ticket_created(sender, instance, created, **kwargs):
    if not created:
        return

    from apps.notifications.tasks import create_notification
    event = instance.event
    buyer = instance.holder

    create_notification.delay(
        recipient_id=str(buyer.user_id),
        notification_type='event_ticket_purchased',
        title=f'Ticket confirmed for {event.title} 🎟️',
        body=f'Your ticket (code: {instance.ticket_code}) is confirmed. See you there!',
        metadata={
            'ticket_id': str(instance.id),
            'ticket_code': str(instance.ticket_code),
            'event_id': str(event.id),
            'event_title': event.title,
            'event_category': event.category,
            'start_time': event.start_datetime.isoformat() if event.start_datetime else None,
        },
    )


@receiver(post_save, sender='marketplace.Order')
def handle_order_status_changed(sender, instance, created, **kwargs):
    """Order *creation* only.

    This receiver used to fire on every status change as well, and so did
    ``apps.marketplace.views._notify_order_status_change`` — the buyer ended up
    with two notification rows per seller update, one of them mislabelled
    `new_purchase`. Status changes are now notified from exactly one place (the
    marketplace view, which also tells the sellers), so this receiver must stay
    quiet on them or the duplicate comes straight back.
    """
    from apps.notifications.tasks import create_notification
    buyer = getattr(instance, 'buyer', None) or getattr(instance, 'user', None)
    if not buyer or not created:
        return

    amount = getattr(instance, 'spent_usd', None) or getattr(instance, 'fiat_amount', '0')

    create_notification.delay(
        recipient_id=str(buyer.user_id),
        notification_type='order_status_changed',
        title=f'Order #{instance.order_number} confirmed! 🛒',
        body=f'Your order of ${amount} is being processed.',
        metadata={
            'order_id': str(instance.id),
            'order_number': instance.order_number,
            'status': instance.status,
            'total': str(amount),
        },
        # One row per order even if the order row is re-saved immediately after
        # creation (checkout does), so the buyer is not told twice.
        dedupe_key=f'order:{instance.id}:created',
    )


@receiver(post_save, sender='wallet.ArtifactTransaction')
def handle_wallet_transaction(sender, instance, created, **kwargs):
    if instance.transaction_type in ('withdrawal', 'creator_transfer') and instance.status == 'completed':
        from apps.notifications.tasks import create_notification
        create_notification.delay(
            recipient_id=str(instance.user.user_id),
            notification_type='payout_processed',
            title='Payout processed successfully! 💰',
            body=f'Your payout of {instance.fiat_amount or instance.quantity} {instance.fiat_currency} has been processed.',
            metadata={
                'transaction_id': str(instance.id),
                'amount': str(instance.fiat_amount or instance.quantity),
                'currency': instance.fiat_currency,
                'status': instance.status,
            },
        )


@receiver(post_save, sender='messaging.ConversationMembership')
def handle_community_membership(sender, instance, created, **kwargs):
    if not instance.conversation.is_community:
        return

    from apps.notifications.tasks import create_notification
    comm = instance.conversation

    if created:
        # Notify the user that they joined
        create_notification.delay(
            recipient_id=str(instance.profile.user_id),
            notification_type='community_join_approved',
            title=f"You're now a member of {comm.group_name}! 🏋️",
            body=f'Welcome to the {comm.group_name} community.',
            metadata={
                'community_id': str(comm.id),
                'community_name': comm.group_name,
                'role': instance.role,
            },
        )
