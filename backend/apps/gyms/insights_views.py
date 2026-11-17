"""Sessions, messages, communities and rich analytics for the gym console.

Kept separate from views.py so the already enormous GymDetail file doesn't
absorb four more class definitions. All four are owner/co-owner/moderator
gated via _partner_staff.
"""

import datetime

from django.db.models import Count, Q, Sum
from django.db.models.functions import TruncDate
from django.utils import timezone
from rest_framework import permissions, status, views
from rest_framework.response import Response

from .models import (
    AttendanceRecord,
    Gym,
    GymCommunityLink,
    GymMembership,
    GymOnlineCoach,
    GymRoutinePost,
    GymWalletEntry,
)


def _partner_staff(gym, request):
    return GymMembership.objects.filter(
        gym=gym, member=request.user.profile,
        role__in=['owner', 'co_owner', 'moderator'],
    ).first() is not None


def _gym_inbox_conversations(gym, viewer):
    """The conversations that belong in *this viewer's* gym inbox.

    Deliberately narrow — this is the inbox of the person operating the gym,
    not a surveillance feed of everything other staff do with members:

    1. DMs (not groups, not communities) the viewer personally participates
       in — the messages they exchanged with clients or colleagues.
    2. Communities linked to this gym (gym-formed or adopted).
    3. Group conversations explicitly tagged to the gym.

    A trainer's private DMs with a client never surface to the owner — the
    owner manages the gym, not the coach's personal relationships.
    """
    from apps.messaging.models import Conversation

    my_dms = (
        Conversation.objects.filter(participants=viewer, is_group=False, is_community=False)
    )
    linked = Conversation.objects.filter(
        is_community=True, gym_links__gym=gym, gym_links__status='active',
    )
    tagged = Conversation.objects.filter(group_gym=gym)
    return (my_dms | linked | tagged).distinct()


def _coerce_uuid(value):
    """Return a UUID for ``value`` or None.

    Callers pass client-supplied ids straight into lookups; Django raises
    ``ValidationError`` (uncaught by DRF's default handling) when the literal
    does not parse, so validate here instead of try/except at each site.
    """
    import uuid as _uuid
    try:
        return _uuid.UUID(str(value))
    except (ValueError, TypeError, AttributeError):
        return None


def _gym_staff_profiles(gym):
    return (
        GymMembership.objects.filter(gym=gym, role__in=['owner', 'co_owner', 'moderator'])
        .values_list('member_id', flat=True)
    )


def _json_response(data, message='OK', status_code=status.HTTP_200_OK):
    return Response({'success': True, 'data': data, 'message': message,
                     'errors': None, 'pagination': None},
                    status=status_code)


def _error(detail, status_code=status.HTTP_400_BAD_REQUEST):
    return Response({'success': False, 'data': None,
                     'message': detail,
                     'errors': None, 'pagination': None},
                    status=status_code)


# ---------------------------------------------------------------------------
# Sessions — bookings to gym coaches + check-ins
# ---------------------------------------------------------------------------

class GymSessionsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = Gym.objects.filter(handle__iexact=gym_slug).first()
        if gym is None or not _partner_staff(gym, request):
            return _error('Not found.', status.HTTP_404_NOT_FOUND)

        coach_ids = list(
            GymOnlineCoach.objects.filter(gym=gym, is_available=True)
            .values_list('coach_id', flat=True)
        )
        # Bookings where the trainer attached to the gym (online coach or
        # staff serving in-person sessions).
        bookings_qs = (
            BookingSession_select_related()
            .filter(Q(trainer_id__in=coach_ids) | Q(trainer_id__in=_gym_staff_profiles(gym)))
            .order_by('-scheduled_at')
        )

        now = timezone.now()
        next_30 = now + datetime.timedelta(days=30)
        upcoming_count = bookings_qs.filter(status__in=['pending', 'confirmed'], scheduled_at__gte=now, scheduled_at__lte=next_30).count()
        completed_30d = bookings_qs.filter(status='completed', completed_at__gte=now - datetime.timedelta(days=30)).count()
        cancelled_30d = bookings_qs.filter(status__in=['cancelled_by_client', 'cancelled_by_trainer'], cancelled_at__gte=now - datetime.timedelta(days=30)).count()
        no_show_30d = bookings_qs.filter(status='no_show', scheduled_at__gte=now - datetime.timedelta(days=30)).count()

        bookings = list(bookings_qs[:20])
        rows = [
            {
                'id': str(b.id),
                'client': b.client.username,
                'client_display': b.client.display_name or b.client.username,
                'client_avatar': b.client.avatar_url,
                'trainer': b.trainer.username,
                'trainer_display': b.trainer.display_name or b.trainer.username,
                'trainer_avatar': b.trainer.avatar_url,
                'session_type': b.session_type,
                'status': b.status,
                'scheduled_at': b.scheduled_at.isoformat() if b.scheduled_at else None,
                'completed_at': b.completed_at.isoformat() if b.completed_at else None,
                'duration_minutes': b.duration_minutes,
                'fee': b.artifact_fee,
                'created_at': b.created_at.isoformat(),
            } for b in bookings
        ]

        # Check-ins for the gym — series and total
        window = timezone.now() - datetime.timedelta(days=30)
        check_ins_qs = AttendanceRecord.objects.filter(gym=gym, checked_in_at__gte=window)
        daily_rows = (
            check_ins_qs
            .annotate(day=TruncDate('checked_in_at'))
            .values('day')
            .annotate(count=Count('id'))
            .order_by('day')
        )
        by_day = [{'date': r['day'].isoformat(), 'count': r['count']} for r in daily_rows]

        return _json_response({
            'summary': {
                'sessions_30d': completed_30d,
                'upcoming_30d': upcoming_count,
                'cancelled_30d': cancelled_30d,
                'no_shows_30d': no_show_30d,
                'check_ins_30d': check_ins_qs.count(),
                'unique_attendees_30d': check_ins_qs.values('member').distinct().count(),
            },
            'bookings': rows,
            'check_ins_daily': by_day,
        })


def BookingSession_select_related():
    from apps.sessions.models import BookingSession
    return BookingSession.objects.select_related('client', 'trainer')


# ---------------------------------------------------------------------------
# Messages — gym inbox (community chat + member DMs)
# ---------------------------------------------------------------------------

class GymMessagesView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = Gym.objects.filter(handle__iexact=gym_slug).first()
        if gym is None or not _partner_staff(gym, request):
            return _error('Not found.', status.HTTP_404_NOT_FOUND)

        staff_ids = list(_gym_staff_profiles(gym))

        from apps.messaging.models import Message

        # Gym inbox: this viewer's DMs + gym-linked communities + gym-tagged
        # groups (see _gym_inbox_conversations — other staff's private DMs
        # and communities stay out).
        gym_convs = (
            _gym_inbox_conversations(gym, request.user.profile)
            .prefetch_related('participants')
            .order_by('-last_message_at', '-created_at')[:30]
        )
        conversations = []
        for conv in gym_convs:
            members = list(conv.participants.values_list('username', 'display_name', 'avatar_url', 'role')[:8])
            conversations.append({
                'id': str(conv.id),
                'kind': 'community' if conv.is_community else ('group' if conv.is_group else 'direct'),
                'name': conv.group_name or ('Gym ' + ('community' if conv.is_community else 'chat')),
                'members': [
                    {'username': u, 'display_name': d, 'avatar_url': a, 'role': r}
                    for u, d, a, r in members
                ],
                'last_message_at': conv.last_message_at.isoformat() if conv.last_message_at else None,
                'last_message': conv.last_message_text,
                'is_community': conv.is_community,
            })

        inbox = _gym_inbox_conversations(gym, request.user.profile)
        recent_messages = (
            Message.objects.filter(conversation__in=inbox)
            .distinct()
            .select_related('sender', 'conversation')
            .exclude(sender__in=staff_ids)
            .order_by('-created_at')[:50]
        )
        messages = [
            {
                'id': str(m.id),
                'body': (m.body or '')[:300],
                'sender': m.sender.username,
                'sender_display': m.sender.display_name or m.sender.username,
                'sender_avatar': m.sender.avatar_url,
                'sent_at': m.created_at.isoformat(),
                'conversation': str(m.conversation_id),
            } for m in recent_messages
        ]

        return _json_response({
            'conversations': conversations,
            'recent_inbound': messages,
            'summary': {
                'community_chats': sum(1 for c in conversations if c['is_community']),
                'group_chats': sum(1 for c in conversations if not c['is_community'] and c['kind'] == 'group'),
                'direct_threads': sum(1 for c in conversations if c['kind'] == 'direct'),
                'inbound_7d': Message.objects.filter(
                    conversation__in=_gym_inbox_conversations(gym, request.user.profile),
                    created_at__gte=timezone.now() - datetime.timedelta(days=7),
                ).distinct().exclude(sender__in=staff_ids).count(),
            },
        })


# ---------------------------------------------------------------------------
# Communities — link/unlink and list communities attached to the gym
# ---------------------------------------------------------------------------

class GymCommunitiesView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        """Linked communities + discoverable public ones.

        Communities are ``messaging.Conversation(is_community=True)`` rows —
        the live in-app community feature. Every community created through
        either creation path keeps one of these with a shared id.
        """
        from apps.messaging.models import CommunityPost, Conversation, ConversationMembership

        gym = Gym.objects.filter(handle__iexact=gym_slug).first()
        if gym is None or not _partner_staff(gym, request):
            return _error('Not found.', status.HTTP_404_NOT_FOUND)

        profile = request.user.profile
        links = list(
            GymCommunityLink.objects.filter(gym=gym, status__in=['active', 'pending'])
            .select_related('community')
        )
        conv_ids = [link.community_id for link in links]
        member_counts = {
            row['conversation_id']: row['c'] for row in
            ConversationMembership.objects.filter(conversation_id__in=conv_ids)
            .values('conversation_id').annotate(c=Count('id'))
        }
        post_counts = {
            row['conversation_id']: row['c'] for row in
            CommunityPost.objects.filter(conversation_id__in=conv_ids)
            .values('conversation_id').annotate(c=Count('id'))
        }
        member_conv_ids = set(
            ConversationMembership.objects.filter(conversation_id__in=conv_ids, profile=profile)
            .values_list('conversation_id', flat=True)
        )

        def community_row(c, link=None):
            return {
                'id': str(c.id),
                'name': c.group_name,
                'description': c.description,
                'avatar_url': c.group_avatar_url,
                'cover_url': c.cover_url,
                'member_count': member_counts.get(c.id, 0),
                'post_count': post_counts.get(c.id, 0),
                'is_public': c.is_public,
                'is_primary': bool(link.is_primary) if link is not None else False,
                'is_gym_formed': c.group_gym_id == gym.id,
                'created_at': c.created_at.isoformat(),
                'is_member': c.id in member_conv_ids,
                'status': link.status if link is not None else 'active',
            }

        rows = [community_row(link.community, link) for link in links]

        discover_qs = (
            Conversation.objects.filter(is_community=True, is_public=True)
            .exclude(gym_links__gym=gym, gym_links__status__in=['active', 'pending'])
            .exclude(id__in=conv_ids)
            .order_by('-last_message_at', '-created_at')[:12]
        )
        discover_ids = [c.id for c in discover_qs]
        discover_counts = {
            row['conversation_id']: row['c'] for row in
            ConversationMembership.objects.filter(conversation_id__in=discover_ids)
            .values('conversation_id').annotate(c=Count('id'))
        }
        discover = [
            {
                'id': str(c.id),
                'name': c.group_name,
                'description': c.description,
                'avatar_url': c.group_avatar_url,
                'member_count': discover_counts.get(c.id, 0),
                'created_at': c.created_at.isoformat(),
            } for c in discover_qs
        ]

        return _json_response({
            'linked': rows,
            'discoverable': discover,
            'primary_count': sum(1 for r in rows if r['is_primary']),
        })

    def post(self, request, gym_slug):
        """Create a gym-formed community, or link/join an existing one.

        ``action='create'`` mints a fresh ``Conversation(is_community=True)``
        with ``group_gym=gym``, enrolls the caller as owner and records the
        link as primary. ``action='link'`` (the default) attaches an existing
        platform community by ``community_id``.
        """
        import uuid

        from apps.messaging.models import (
            Conversation,
            ConversationMembership,
            _generate_invite_code,
        )
        from django.db import transaction

        gym = Gym.objects.filter(handle__iexact=gym_slug).first()
        if gym is None:
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        membership = GymMembership.objects.filter(
            gym=gym, member=request.user.profile, role__in=['owner', 'co_owner'],
        ).first()
        if membership is None:
            return _error('Only an owner or co-owner can manage communities.', status.HTTP_403_FORBIDDEN)

        profile = request.user.profile
        action = (request.data.get('action') or 'link').strip().lower()

        if action == 'create':
            name = (request.data.get('name') or '').strip()
            if not name:
                return _error('name is required.', status.HTTP_400_BAD_REQUEST)
            description = (request.data.get('description') or '').strip()
            is_public = bool(request.data.get('is_public', True))
            with transaction.atomic():
                community = Conversation.objects.create(
                    id=uuid.uuid4(),
                    is_group=True,
                    is_community=True,
                    group_name=name[:100],
                    description=description,
                    is_public=is_public,
                    invite_code=_generate_invite_code(),
                    created_by=profile,
                    group_gym=gym,
                    last_message_at=timezone.now(),
                )
                community.participants.add(profile)
                ConversationMembership.objects.create(
                    conversation=community, profile=profile, role='owner',
                )
                link = GymCommunityLink.objects.create(
                    gym=gym, community=community, status='active',
                    is_primary=True, requested_by=profile,
                )
                # Primary means the one the gym leads with — demote the rest.
                GymCommunityLink.objects.filter(
                    gym=gym, is_primary=True,
                ).exclude(pk=link.pk).update(is_primary=False)
            return _json_response({
                'id': str(community.id),
                'community_id': str(community.id),
                'name': community.group_name,
                'description': community.description,
                'is_public': community.is_public,
                'member_count': 1,
                'is_member': True,
                'is_primary': link.is_primary,
                'is_gym_formed': True,
                'created': True,
            }, status_code=status.HTTP_201_CREATED)

        # action == 'link'
        community_uuid = _coerce_uuid(request.data.get('community_id'))
        community = (
            Conversation.objects.filter(id=community_uuid, is_community=True).first()
            if community_uuid else None
        )
        if community is None:
            return _error('Community not found.', status.HTTP_404_NOT_FOUND)

        is_primary = bool(request.data.get('is_primary', False))
        with transaction.atomic():
            link, created = GymCommunityLink.objects.get_or_create(
                gym=gym, community=community,
                defaults={'requested_by': profile, 'status': 'pending', 'is_primary': is_primary},
            )
            if not created:
                # Re-requesting after a decline re-opens the ask; an already
                # pending ask is simply left alone.
                if link.status == 'declined':
                    link.status = 'pending'
                link.requested_by = profile
                link.decided_by = None
                if is_primary:
                    link.is_primary = True
                link.save(update_fields=['status', 'requested_by', 'decided_by', 'is_primary'])

            from apps.messaging.models import ConversationMembership
            from apps.notifications.tasks import create_notification
            owner_ids = list(
                ConversationMembership.objects.filter(
                    conversation=community, role__in=['owner', 'admin'],
                ).values_list('profile__user_id', flat=True)
            )
            for owner_id in owner_ids:
                create_notification.delay(
                    recipient_id=str(owner_id),
                    notification_type='gym_community_link_request',
                    title=f'{gym.name} asked to link with {community.group_name}',
                    body='Review the request in the community settings.',
                    metadata={
                        'gym_handle': gym.handle,
                        'gym_name': gym.name,
                        'community_id': str(community.id),
                        'community_name': community.group_name,
                        'link_id': link.pk,
                    },
                )

            # A gym joining someone else's community enrols its acting owner as
            # a member, if not already one.
            if not community.participants.filter(pk=profile.pk).exists():
                community.participants.add(profile)
                ConversationMembership.objects.get_or_create(
                    conversation=community, profile=profile,
                    defaults={'role': 'member'},
                )

        member_count = ConversationMembership.objects.filter(conversation=community).count()
        return _json_response({
            'id': str(community.id),
            'community_id': str(community.id),
            'name': community.group_name,
            'description': community.description,
            'is_public': community.is_public,
            'member_count': member_count,
            'is_member': True,
            'is_primary': link.is_primary,
            'status': link.status,
            'is_gym_formed': False,
            'created': False,
        })

    def delete(self, request, gym_slug):
        from apps.messaging.models import Conversation

        gym = Gym.objects.filter(handle__iexact=gym_slug).first()
        if gym is None:
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        membership = GymMembership.objects.filter(
            gym=gym, member=request.user.profile, role__in=['owner', 'co_owner'],
        ).first()
        if membership is None:
            return _error('Only an owner or co-owner can unlink a community.', status.HTTP_403_FORBIDDEN)
        community_uuid = _coerce_uuid(request.data.get('community_id'))
        community = (
            Conversation.objects.filter(id=community_uuid, is_community=True).first()
            if community_uuid else None
        )
        if community is None:
            return _error('Community not found.', status.HTTP_404_NOT_FOUND)
        GymCommunityLink.objects.filter(gym=gym, community=community).delete()
        return _json_response({'unlinked': True})


# ---------------------------------------------------------------------------
# Analytics — time-series for the rich dashboard
# ---------------------------------------------------------------------------

def _pct_change(current, previous):
    if previous:
        return round((current - previous) / previous * 100, 1)
    return 100.0 if current else 0.0


def _series_from_counts(days, counts):
    now = timezone.now()
    series = []
    for offset in range(days - 1, -1, -1):
        day = (now - datetime.timedelta(days=offset)).date()
        series.append({'date': day.isoformat(), 'count': int(counts.get(day, 0))})
    return series


def _timeseries(gym, days, predicate, viewer=None):
    """Return {date, count} for the last N days — one GROUP BY query each."""
    now = timezone.now()
    start = timezone.make_aware(datetime.datetime.combine(
        (now - datetime.timedelta(days=days - 1)).date(), datetime.time.min,
    ))
    if predicate == 'check_ins':
        rows = (AttendanceRecord.objects.filter(gym=gym, checked_in_at__gte=start)
                .annotate(d=TruncDate('checked_in_at')).values('d')
                .annotate(c=Count('id')))
    elif predicate == 'new_members':
        rows = (GymMembership.objects.filter(gym=gym, created_at__gte=start)
                .annotate(d=TruncDate('created_at')).values('d')
                .annotate(c=Count('id')))
    elif predicate == 'posts':
        rows = (GymRoutinePost.objects.filter(gym=gym, created_at__gte=start)
                .annotate(d=TruncDate('created_at')).values('d')
                .annotate(c=Count('id')))
    elif predicate == 'revenue':
        rows = (GymWalletEntry.objects.filter(
                    wallet__gym=gym, created_at__gte=start, direction='credit',
                    kind__in=['join_fee', 'subscription_fee', 'event_fee', 'live_fee', 'shop_sale'],
                ).annotate(d=TruncDate('created_at')).values('d')
                .annotate(c=Sum('quantity')))
    elif predicate == 'messages':
        from apps.messaging.models import Message
        rows = (Message.objects.filter(
                    conversation__in=_gym_inbox_conversations(gym, viewer),
                    created_at__gte=start,
                ).annotate(d=TruncDate('created_at')).values('d')
                .annotate(c=Count('id', distinct=True)))
    elif predicate == 'bookings':
        from apps.sessions.models import BookingSession
        coach_ids = list(
            GymOnlineCoach.objects.filter(gym=gym, is_available=True).values_list('coach_id', flat=True)
        ) + list(_gym_staff_profiles(gym))
        rows = (BookingSession.objects.filter(trainer_id__in=coach_ids, created_at__gte=start)
                .annotate(d=TruncDate('created_at')).values('d')
                .annotate(c=Count('id')))
    else:
        rows = []

    counts = {row['d']: row['c'] for row in rows}
    return _series_from_counts(days, counts)

class GymAnalyticsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        from apps.messaging.models import Conversation, Message
        from apps.sessions.models import BookingSession

        gym = Gym.objects.filter(handle__iexact=gym_slug).first()
        if gym is None or not _partner_staff(gym, request):
            return _error('Not found.', status.HTTP_404_NOT_FOUND)

        now = timezone.now()
        since_30d = now - datetime.timedelta(days=30)
        prev_30d = since_30d - datetime.timedelta(days=30)

        revenue_kinds = ['join_fee', 'subscription_fee', 'event_fee', 'live_fee', 'shop_sale']

        active_members = gym.memberships.filter(subscription_active=True).count()
        new_members_30d = gym.memberships.filter(created_at__gte=since_30d).count()
        prev_new_members = gym.memberships.filter(created_at__gte=prev_30d, created_at__lt=since_30d).count()
        churned = gym.memberships.filter(subscription_active=False, updated_at__gte=since_30d).count()
        retention_rate = round(active_members / (active_members + churned) * 100, 1) if (active_members + churned) else 0

        check_ins_qs = AttendanceRecord.objects.filter(gym=gym, checked_in_at__gte=since_30d)
        check_ins = check_ins_qs.count()
        prev_check_ins = AttendanceRecord.objects.filter(gym=gym, checked_in_at__gte=prev_30d, checked_in_at__lt=since_30d).count()
        unique_attendees = check_ins_qs.values('member').distinct().count()

        coach_ids = list(
            GymOnlineCoach.objects.filter(gym=gym, is_available=True).values_list('coach_id', flat=True)
        ) + list(_gym_staff_profiles(gym))
        bookings_30d = BookingSession.objects.filter(trainer_id__in=coach_ids, created_at__gte=since_30d).count()
        completed_bookings_30d = BookingSession.objects.filter(trainer_id__in=coach_ids, status='completed', completed_at__gte=since_30d).count()
        prev_bookings = BookingSession.objects.filter(trainer_id__in=coach_ids, created_at__gte=prev_30d, created_at__lt=since_30d).count()

        staff_ids = list(_gym_staff_profiles(gym))
        inbox = _gym_inbox_conversations(gym, request.user.profile)
        messages_30d = Message.objects.filter(conversation__in=inbox, created_at__gte=since_30d).count()
        prev_messages_30d = Message.objects.filter(conversation__in=inbox, created_at__gte=prev_30d, created_at__lt=since_30d).count()
        inbound_client_messages_30d = Message.objects.filter(conversation__in=inbox, created_at__gte=since_30d).exclude(sender__in=staff_ids).count()
        community_members = (
            Conversation.objects.filter(
                is_community=True, gym_links__gym=gym, gym_links__status='active',
            )
            .annotate(mc=Count('participants', distinct=True))
            .aggregate(total=Sum('mc'))['total'] or 0
        )

        revenue_30d = int(GymWalletEntry.objects.filter(
            wallet__gym=gym, created_at__gte=since_30d,
            direction='credit', kind__in=revenue_kinds,
        ).aggregate(total=Sum('quantity'))['total'] or 0)
        prev_revenue_30d = int(GymWalletEntry.objects.filter(
            wallet__gym=gym, created_at__gte=prev_30d, created_at__lt=since_30d,
            direction='credit', kind__in=revenue_kinds,
        ).aggregate(total=Sum('quantity'))['total'] or 0)
        revenue_all_time = int(GymWalletEntry.objects.filter(
            wallet__gym=gym, direction='credit', kind__in=revenue_kinds,
        ).aggregate(total=Sum('quantity'))['total'] or 0)

        posts_30d = GymRoutinePost.objects.filter(gym=gym, created_at__gte=since_30d).count()
        prev_posts_30d = GymRoutinePost.objects.filter(gym=gym, created_at__gte=prev_30d, created_at__lt=since_30d).count()

        # Join-request conversion: of the requests raised in the window, how
        # many were approved.
        join_total = gym.join_requests.filter(created_at__gte=since_30d).count()
        join_approved = gym.join_requests.filter(created_at__gte=since_30d, status='approved').count()
        join_conversion = round(join_approved / join_total * 100, 1) if join_total else 0.0

        # Contributions from the shop(s) connected to the gym.
        from apps.marketplace.models import MarketplaceEvent, OrderItem, ShopGymLink
        shop_ids = [row[0] for row in
                    ShopGymLink.objects.filter(gym=gym, status='active').values_list('shop_id')]
        events_count = MarketplaceEvent.objects.filter(shop_id__in=shop_ids).count() if shop_ids else 0
        events_30d = MarketplaceEvent.objects.filter(shop_id__in=shop_ids, created_at__gte=since_30d).count() if shop_ids else 0

        def _sold(item_type, fk):
            if not shop_ids:
                return 0, 0
            base = OrderItem.objects.filter(item_type=item_type, order__payment_status='paid')
            all_time = base.filter(**{f'{fk}__shop_id__in': shop_ids}).count()
            last_30 = base.filter(**{f'{fk}__shop_id__in': shop_ids}, order__created_at__gte=since_30d).count()
            return all_time, last_30

        products_count, products_30d = _sold('product', 'product')
        programmes_count, programmes_30d = _sold('programme', 'programme')
        meal_plans_count, meal_plans_30d = _sold('meal_plan', 'meal_plan')
        shop_orders_30d = (
            OrderItem.objects.filter(
                order__payment_status='paid', order__created_at__gte=since_30d,
            ).filter(
                Q(product__shop_id__in=shop_ids) | Q(programme__shop_id__in=shop_ids)
                | Q(meal_plan__shop_id__in=shop_ids) | Q(event__shop_id__in=shop_ids)
            ).values('order').distinct().count()
            if shop_ids else 0
        )

        daily_check_ins = _timeseries(gym, 30, 'check_ins')
        daily_new_members = _timeseries(gym, 30, 'new_members')
        daily_posts = _timeseries(gym, 30, 'posts')
        daily_revenue = _timeseries(gym, 30, 'revenue')
        daily_messages = _timeseries(gym, 30, 'messages', viewer=request.user.profile)
        daily_bookings = _timeseries(gym, 30, 'bookings')

        return _json_response({
            'kpis': {
                'active_members': active_members,
                'new_members_30d': new_members_30d,
                'churned_30d': churned,
                'retention_rate_30d': retention_rate,
                'activation_rate_30d': round(unique_attendees / active_members * 100, 1) if active_members else 0,
                'check_ins_30d': check_ins,
                'avg_check_ins_per_day': round(check_ins / 30, 1),
                'unique_attendees_30d': unique_attendees,
                'visit_rate_30d': round(check_ins / max(active_members, 1), 1),
                'bookings_30d': bookings_30d,
                'completed_bookings_30d': completed_bookings_30d,
                'messages_30d': messages_30d,
                'inbound_client_messages_30d': inbound_client_messages_30d,
                'community_members': community_members,
                'revenue_30d_artifacts': revenue_30d,
                'revenue_lifetime_artifacts': revenue_all_time,
                'posts_30d': posts_30d,
                'join_requests_30d': join_total,
                'join_requests_approved_30d': join_approved,
                'join_conversion_30d': join_conversion,
                'events_hosted': events_count,
                'events_hosted_30d': events_30d,
                'products_sold': products_count,
                'products_sold_30d': products_30d,
                'programmes_sold': programmes_count,
                'programmes_sold_30d': programmes_30d,
                'meal_plans_sold': meal_plans_count,
                'meal_plans_sold_30d': meal_plans_30d,
                'shop_orders_30d': shop_orders_30d,
            },
            'growth': {
                'audience_pct': _pct_change(new_members_30d, prev_new_members),
                'check_ins_pct': _pct_change(check_ins, prev_check_ins),
                'bookings_pct': _pct_change(bookings_30d, prev_bookings),
                'posts_pct': _pct_change(posts_30d, prev_posts_30d),
                'messages_pct': _pct_change(messages_30d, prev_messages_30d),
                'revenue_pct': _pct_change(revenue_30d, prev_revenue_30d),
            },
            'timeseries': {
                'check_ins': daily_check_ins,
                'new_members': daily_new_members,
                'posts': daily_posts,
                'revenue_artifacts': daily_revenue,
                'messages': daily_messages,
                'bookings': daily_bookings,
            },
            'share_card': f'{gym.name} • {active_members} active members • {check_ins} check-ins this month',
        })
