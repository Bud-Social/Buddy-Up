"""Community-side view of gym→community link requests.

The gym asks to link its gym to a community (e.g. a local lifting cohort);
this is how the community's owner/admin reviews and decides. The two sides
keep separate screens on purpose: a gym is managed through the gym console,
a community through its own settings/members view.
"""

from django.db import transaction
from django.http import Http404
from rest_framework import permissions, status, views
from rest_framework.response import Response
from django.shortcuts import get_object_or_404

from .models import GymCommunityLink


def _json_response(data, message='OK', status_code=status.HTTP_200_OK):
    return Response({'success': True, 'data': data, 'message': message,
                     'errors': None, 'pagination': None},
                    status=status_code)


def _error(detail, status_code=status.HTTP_400_BAD_REQUEST):
    return Response({'success': False, 'data': None,
                     'message': detail,
                     'errors': None, 'pagination': None},
                    status=status_code)


def _community_staff(community, profile):
    from apps.messaging.models import ConversationMembership
    return ConversationMembership.objects.filter(
        conversation=community, profile=profile, role__in=['owner', 'admin'],
    ).first()


class GymLinkRequestListView(views.APIView):
    """Pending gym→community link requests for communities I can decide on."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        from apps.messaging.models import ConversationMembership

        community_id = request.query_params.get('community_id')
        viewer_community_ids = list(
            ConversationMembership.objects.filter(
                profile=request.user.profile, role__in=['owner', 'admin'],
                conversation__is_community=True,
            ).values_list('conversation_id', flat=True)
        )
        links = (
            GymCommunityLink.objects.filter(
                status='pending', community_id__in=viewer_community_ids,
            )
            .select_related('gym', 'community', 'requested_by')
            .order_by('created_at')
        )
        if community_id:
            links = links.filter(community_id=community_id)

        rows = [
            {
                'id': link.pk,
                'gym_handle': link.gym.handle,
                'gym_name': link.gym.name,
                'gym_logo_url': link.gym.logo_url,
                'gym_category': link.gym.category,
                'gym_member_count': link.gym.member_count,
                'community_id': str(link.community_id),
                'community_name': link.community.group_name,
                'requested_by': link.requested_by.display_name or link.requested_by.username
                if link.requested_by else '',
                'created_at': link.created_at.isoformat(),
            } for link in links
        ]
        return _json_response({'requests': rows, 'count': len(rows)})


class GymLinkRequestDecideView(views.APIView):
    """Approve or decline a gym→community link request."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, request_id):
        decision = (request.data.get('decision') or '').strip().lower()
        if decision not in ('approved', 'declined'):
            return _error("decision must be 'approved' or 'declined'.", status.HTTP_400_BAD_REQUEST)

        link = get_object_or_404(
            GymCommunityLink.objects.select_related('gym', 'community', 'requested_by'),
            pk=request_id, status='pending',
        )
        membership = _community_staff(link.community, request.user.profile)
        if membership is None:
            raise Http404('No such request.')

        with transaction.atomic():
            # Link states are 'pending' | 'active' | 'declined' — the payload
            # verb is 'approved', the stored state after approval is 'active'.
            link.status = 'active' if decision == 'approved' else 'declined'
            link.decided_by = request.user.profile
            link.save(update_fields=['status', 'decided_by', 'updated_at'])
            if decision == 'approved' and link.is_primary:
                # Primary means the one the gym leads with — demote the rest.
                GymCommunityLink.objects.filter(
                    gym=link.gym, is_primary=True,
                ).exclude(pk=link.pk).update(is_primary=False)

        if link.requested_by_id:
            from apps.notifications.tasks import create_notification
            create_notification.delay(
                recipient_id=str(link.requested_by.user_id),
                notification_type='gym_community_link_decided',
                title=f'{link.community.group_name} {"accepted" if decision == "approved" else "declined"} your request',
                body=(f'{link.gym.name} is now linked with {link.community.group_name}.'
                      if decision == 'approved' else
                      f'{link.community.group_name} did not accept the link from {link.gym.name}.'),
                metadata={
                    'gym_handle': link.gym.handle,
                    'gym_name': link.gym.name,
                    'community_id': str(link.community_id),
                    'community_name': link.community.group_name,
                    'decision': decision,
                },
            )

        return _json_response({
            'id': link.pk,
            'status': link.status,
            'is_primary': link.is_primary,
            'community_id': str(link.community_id),
            'gym_handle': link.gym.handle,
        })
