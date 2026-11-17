"""The gym's contained messaging subservice.

Like buddy chats (``kind='buddy'``), gym chats (``kind='gym'``) live outside
the main inbox — a gym owns a dedicated channel with its members, team and
clients contacting it, with its own inbox in the console. The console never
redirects into the acting staff member's personal DMs.

Model layout (no new tables; reuses ``Conversation`` / ``Message``):

* ``kind='gym'``, ``group_gym=<gym>`` — every gym conversation is scoped
  to one gym via the existing ``group_gym`` FK and tagged with ``sub_channel``:
  ``'member'`` (1:many-staff DM with a member), ``'team'`` (all-gym-staff
  group chat), ``'client'`` (a member-of-the-public reaching out).
* Staff-side visibility: owner/co-owner/moderator see their gym's
  conversations. Regular clients/members see only their own 1:many-staff DM
  with that gym.
* The conversation's participant roster is who can answer — every staff
  member belongs to every current gym conversation for that gym (seeded at
  creation; new staff are added to the team chat but not to closed DMs —
  same rule as buddy chats).
"""

import uuid as _uuid  # noqa: F401  (kept for typing docs)

from django.db import transaction
from django.utils import timezone
from rest_framework import permissions, status, views

from apps.messaging.models import Conversation, ConversationMembership, Message
from apps.gyms.insights_views import _error, _json_response, _partner_staff
from apps.gyms.models import Gym, GymMembership


def _staff_profiles(gym):
    """The profiles with gym-console access (owner/co-owner/moderator)."""
    return list(
        GymMembership.objects.filter(gym=gym, role__in=['owner', 'co_owner', 'moderator'])
        .values_list('member', flat=True)
    )


def _staff_and_trainers(gym):
    return list(
        GymMembership.objects.filter(gym=gym, role__in=['owner', 'co_owner', 'moderator', 'trainer'])
        .values_list('member', flat=True)
    )


def _row_basic(conv, viewer_id, gym_name, staff_ids=()):
    participants = list(
        conv.participants.values('user_id', 'username', 'display_name', 'avatar_url', 'role')
    )
    unread = conv.messages.filter(is_deleted=False, is_read=False).exclude(sender=viewer_id).count()
    staff_set = {str(sid) for sid in staff_ids}
    others = [p for p in participants if str(p['user_id']) not in staff_set]
    audience_member = None
    if conv.sub_channel in ('member', 'client') and len(others) == 1:
        audience_member = {
            'user_id': str(others[0]['user_id']),
            'username': others[0]['username'],
            'display_name': others[0]['display_name'],
            'avatar_url': others[0]['avatar_url'],
        }
    return {
        'id': str(conv.id),
        'kind': 'gym',
        'conversation_kind': conv.sub_channel or 'member',
        'is_group': conv.is_group,
        'group_name': conv.group_name,
        'group_avatar_url': conv.group_avatar_url,
        'group_gym_id': str(conv.group_gym_id) if conv.group_gym_id else None,
        'gym_name': gym_name,
        'member_count': len(participants),
        'participants': [
            {'user_id': str(p['user_id']), 'username': p['username'],
             'display_name': p['display_name'], 'avatar_url': p['avatar_url'], 'role': p['role']}
            for p in participants
        ],
        'audience_member': audience_member,
        'last_message': conv.last_message_text,
        'last_message_at': conv.last_message_at.isoformat() if conv.last_message_at else None,
        'unread_count': unread,
    }


def _find_member_conversation(gym, member):
    staff_ids = _staff_profiles(gym)
    if not staff_ids:
        return None
    candidates = (Conversation.objects.filter(
        kind='gym', group_gym=gym, is_group=False, participants=member,
    ).filter(participants__in=staff_ids).distinct()
        .prefetch_related('participants'))
    for conv in candidates:
        if set(conv.participants.values_list('pk', flat=True)) == set(staff_ids) | {member.pk}:
            return conv
    return next(iter(candidates), None)


def _ensure_member_conversation(gym, member, creator):
    existing = _find_member_conversation(gym, member)
    if existing is not None:
        return existing, False, member
    staff_ids = _staff_profiles(gym)
    with transaction.atomic():
        conv = Conversation.objects.create(
            kind='gym', is_group=False, group_gym=gym,
            origin='direct', created_by=creator,
            sub_channel='member', last_message_at=timezone.now(),
        )
        conv.participants.set([*staff_ids, member.pk])
        ConversationMembership.objects.create(
            conversation=conv, profile=creator, role='member',
        )
        for sid in staff_ids:
            if str(sid) != str(creator.pk):
                ConversationMembership.objects.get_or_create(
                    conversation=conv, profile_id=sid, defaults={'role': 'member'},
                )
        return conv, True, member


def _ensure_team_conversation(gym, creator):
    staff_and_trainers = _staff_and_trainers(gym)
    if not staff_and_trainers:
        staff_and_trainers = _staff_profiles(gym)
    with transaction.atomic():
        conv = (Conversation.objects.filter(
            kind='gym', group_gym=gym, is_group=True, sub_channel='team',
        ).prefetch_related('participants').first())
        if conv is not None:
            current = set(conv.participants.values_list('pk', flat=True))
            missing = [sid for sid in staff_and_trainers if sid not in current]
            if missing:
                conv.participants.add(*missing)
            return conv, False
        conv = Conversation.objects.create(
            kind='gym', is_group=True, group_gym=gym,
            origin='group', created_by=creator,
            sub_channel='team',
            group_name=f'Team · {gym.name}',
            group_avatar_url=gym.logo_url or '',
            last_message_at=timezone.now(),
        )
        conv.participants.set(staff_and_trainers)
        ConversationMembership.objects.bulk_create([
            ConversationMembership(conversation=conv, profile_id=sid, role='member')
            for sid in staff_and_trainers
        ])
        return conv, True


class GymInboxView(views.APIView):
    """The gym's contained inbox: list conversations or open one."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = Gym.objects.filter(handle__iexact=gym_slug).first()
        if gym is None or not _partner_staff(gym, request):
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        viewer = request.user.profile
        gym_name = gym.name
        # Every staff member sees every gym conversation (they all answer it).
        rows = (
            Conversation.objects.filter(kind='gym', group_gym=gym)
            .prefetch_related('participants')
            .order_by('-last_message_at', '-created_at')[:50]
        )
        staff_ids = _staff_profiles(gym)
        items = [_row_basic(c, viewer.pk, gym_name, staff_ids) for c in rows]
        return _json_response({'conversations': items})

    def post(self, request, gym_slug):
        """Open (or create) a gym conversation.

        Staff: ``audience='team'`` (everyone with a console role + trainers) or
        ``audience='member'`` + ``participant_id`` (a member of this gym).
        Members/clients: no role needed — find-or-create their direct line
        with the gym, using ``body`` when given.
        """
        gym = Gym.objects.filter(handle__iexact=gym_slug).first()
        if gym is None:
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        viewer = request.user.profile
        staff = _partner_staff(gym, request)
        audience = (request.data.get('audience') or '').strip().lower()
        body = (request.data.get('body') or '').strip()
        participant_id = request.data.get('participant_id')

        if not audience and not participant_id:
            # Any authenticated caller (member, client — or a staff member fed
            # this page as both) opens their own line with the gym; every
            # current staff member is added as a participant.
            conv, _created, _ = _ensure_member_conversation(gym, viewer, viewer)
            staff_ids = _staff_profiles(gym)
            current = set(conv.participants.values_list('pk', flat=True))
            need = [sid for sid in staff_ids if sid not in current]
            if need:
                conv.participants.add(*need)
            if body:
                Message.objects.create(
                    conversation=conv, sender=viewer, message_type='text', body=body,
                )
                conv.last_message_text = body[:200]
                conv.last_message_at = timezone.now()
                conv.save(update_fields=['last_message_text', 'last_message_at'])
            row = _row_basic(conv, viewer.pk, gym.name, _staff_profiles(gym))
            row['is_staff_view'] = False
            return _json_response(row, status_code=status.HTTP_201_CREATED)

        if not staff:
            return _error('Not found.', status.HTTP_404_NOT_FOUND)

        if audience == 'team':
            conv, created = _ensure_team_conversation(gym, viewer)
            row = _row_basic(conv, viewer.pk, gym.name, _staff_profiles(gym))
            row['is_staff_view'] = True
            return _json_response(row, status_code=status.HTTP_201_CREATED)

        from apps.profiles.models import Profile
        from apps.gyms.insights_views import _coerce_uuid
        member = None
        if participant_id:
            uuid_candidate = _coerce_uuid(participant_id)
            if uuid_candidate is not None:
                member = Profile.objects.filter(user_id=uuid_candidate).first()
            if member is None:
                member = Profile.objects.filter(username__iexact=str(participant_id).strip()).first()
        if member is None:
            return _error('Pick a member of the gym (username or user id).', status.HTTP_400_BAD_REQUEST)
        is_member = GymMembership.objects.filter(gym=gym, member=member).exists()
        if not is_member:
            return _error('That person is not a member of this gym.', status.HTTP_400_BAD_REQUEST)
        conv, created, _m = _ensure_member_conversation(gym, member, viewer)
        if body:
            Message.objects.create(conversation=conv, sender=viewer, message_type='text', body=body)
            conv.last_message_text = body[:200]
            conv.last_message_at = timezone.now()
            conv.save(update_fields=['last_message_text', 'last_message_at'])
        row = _row_basic(conv, viewer.pk, gym.name, _staff_profiles(gym))
        row['is_staff_view'] = True
        return _json_response(row, status_code=status.HTTP_201_CREATED)


class GymInboxMessagesView(views.APIView):
    """Read or send messages inside a gym conversation."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug, conversation_id):
        gym = Gym.objects.filter(handle__iexact=gym_slug).first()
        if gym is None:
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        conv = (Conversation.objects.filter(id=conversation_id, kind='gym', group_gym=gym)
                .prefetch_related('participants', 'messages').first())
        if conv is None:
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        staff = _partner_staff(gym, request)
        if not staff and not conv.participants.filter(pk=request.user.profile.pk).exists():
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        rows = list(conv.messages.filter(is_deleted=False).order_by('created_at')[:100])
        return _json_response({
            'messages': [
                {
                    'id': str(m.id),
                    'conversation': str(conv.id),
                    'sender': str(m.sender_id),
                    'sender_display': m.sender.display_name or m.sender.username,
                    'sender_avatar': m.sender.avatar_url,
                    'sender_username': m.sender.username,
                    'message_type': m.message_type,
                    'body': m.body,
                    'created_at': m.created_at.isoformat(),
                    'is_read': m.is_read,
                    'is_gym': conv.kind == 'gym',
                } for m in rows
            ],
        })

    def post(self, request, gym_slug, conversation_id):
        gym = Gym.objects.filter(handle__iexact=gym_slug).first()
        if gym is None:
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        conv = (Conversation.objects.filter(id=conversation_id, kind='gym', group_gym=gym)
                .first())
        if conv is None:
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        staff = _partner_staff(gym, request)
        if not staff and not conv.participants.filter(pk=request.user.profile.pk).exists():
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        body = (request.data.get('body') or '').strip()
        if not body:
            return _error('body is required.', status.HTTP_400_BAD_REQUEST)
        sender = request.user.profile
        with transaction.atomic():
            message = Message.objects.create(
                conversation=conv, sender=sender, message_type='text', body=body[:2000],
            )
            conv.last_message_text = body[:200]
            conv.last_message_at = timezone.now()
            conv.save(update_fields=['last_message_text', 'last_message_at'])
            # Message the gym's members must not spam each other — mark
            # inbound messages read for the staff answerers when staff send.
            if staff:
                conv.messages.filter(is_deleted=False).update(is_read=True)
        return _json_response({
            'id': str(message.id),
            'conversation': str(conv.id),
            'sender': str(sender.pk),
            'sender_display': sender.display_name or sender.username,
            'sender_avatar': sender.avatar_url,
            'sender_username': sender.username,
            'message_type': 'text',
            'body': message.body,
            'created_at': message.created_at.isoformat(),
            'is_read': message.is_read,
        }, status_code=status.HTTP_201_CREATED)
