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
    buyer = instance.user

    create_notification.delay(
        recipient_id=str(buyer.user_id),
        notification_type='event_ticket_purchased',
        title=f'Ticket confirmed for {event.title} 🎟️',
        body=f'Your ticket (code: {instance.ticket_code}) is confirmed. See you there!',
        metadata={
            'ticket_id': str(instance.id),
            'ticket_code': instance.ticket_code,
            'event_id': str(event.id),
            'event_title': event.title,
            'event_category': event.category,
            'start_time': event.start_time.isoformat() if event.start_time else None,
        },
    )


@receiver(post_save, sender='marketplace.Order')
def handle_order_status_changed(sender, instance, created, **kwargs):
    from apps.notifications.tasks import create_notification
    buyer = getattr(instance, 'buyer', None) or getattr(instance, 'user', None)
    if not buyer:
        return

    amount = getattr(instance, 'spent_usd', None) or getattr(instance, 'fiat_amount', '0')

    if created:
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
        )
    else:
        create_notification.delay(
            recipient_id=str(buyer.user_id),
            notification_type='order_status_changed',
            title=f'Order #{instance.order_number} is now {instance.status.replace("_", " ").title()}',
            body=f'Your order status has been updated to: {instance.status}.',
            metadata={
                'order_id': str(instance.id),
                'order_number': instance.order_number,
                'status': instance.status,
                'total': str(amount),
            },
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
