from rest_framework import views, permissions
from rest_framework.response import Response
from django.db.models import Q
from django.utils import timezone
from common.pagination import CursorPagination
from .models import Notification, NotificationPreference
from .serializers import NotificationSerializer, NotificationPreferenceSerializer


class NotificationListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = CursorPagination

    def get(self, request):
        notifications = Notification.objects.filter(
            recipient=request.user.profile,
            is_dismissed=False,
        ).filter(Q(expires_at__isnull=True) | Q(expires_at__gt=timezone.now())).order_by('-is_pinned', '-created_at')

        unread_only = request.query_params.get('unread') == 'true'
        if unread_only:
            notifications = notifications.filter(is_read=False)

        paginator = self.pagination_class()
        page = paginator.paginate_queryset(notifications, request)
        serializer = NotificationSerializer(page, many=True)

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': {
                'count': notifications.count(),
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })

    def post(self, request):
        count, _ = Notification.objects.filter(
            recipient=request.user.profile,
            is_read=False,
        ).update(is_read=True)
        return Response({
            'success': True,
            'data': {'marked_read': count},
            'message': f'{count} notifications marked as read.',
            'errors': None,
            'pagination': None,
        })


class NotificationDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def _get(self, request, notification_id):
        from django.shortcuts import get_object_or_404
        return get_object_or_404(
            Notification, id=notification_id, recipient=request.user.profile,
        )

    def post(self, request, notification_id):
        Notification.objects.filter(
            id=notification_id,
            recipient=request.user.profile,
        ).update(is_read=True)
        return Response({
            'success': True,
            'data': None,
            'message': 'Marked as read',
            'errors': None,
            'pagination': None,
        })

    ACTIONS = {
        'read': {'is_read': True},
        'unread': {'is_read': False},
        'pin': {'is_pinned': True},
        'unpin': {'is_pinned': False},
        'dismiss': {'is_dismissed': True},
    }

    def patch(self, request, notification_id):
        """POST /notifications/<id>/read/ stays for compatibility; new client
        actions go through PATCH {action: read|unread|pin|unpin|dismiss}."""
        notification = self._get(request, notification_id)
        action = (request.data.get('action') or '').strip() if isinstance(request.data, dict) else ''
        if action not in self.ACTIONS:
            return Response({
                'success': False, 'data': None,
                'message': "action must be one of: read, unread, pin, unpin, dismiss",
                'errors': None, 'pagination': None,
            }, status=400)
        for field, value in self.ACTIONS[action].items():
            setattr(notification, field, value)
        notification.save(update_fields=list(self.ACTIONS[action].keys()))

        # Dismissing a pinned note unpins it first so the list stays clean.
        if action == 'dismiss' and notification.is_pinned:
            notification.is_pinned = False
            notification.save(update_fields=['is_pinned'])

        return Response({
            'success': True,
            'data': {
                'id': str(notification.id),
                'is_read': notification.is_read,
                'is_pinned': notification.is_pinned,
                'is_dismissed': notification.is_dismissed,
            },
            'message': f'Notification {action}ned.' if action != 'read' and action != 'unread' else f'Marked as {action}.',
            'errors': None, 'pagination': None,
        })


class UnreadCountView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        count = Notification.objects.filter(
            recipient=request.user.profile,
            is_read=False,
        ).count()
        return Response({
            'success': True,
            'data': {'unread_count': count},
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class NotificationPreferencesView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        prefs, _ = NotificationPreference.objects.get_or_create(profile=request.user.profile)
        serializer = NotificationPreferenceSerializer(prefs)
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })

    def put(self, request):
        prefs, _ = NotificationPreference.objects.get_or_create(profile=request.user.profile)
        serializer = NotificationPreferenceSerializer(prefs, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'Preferences updated',
            'errors': None,
            'pagination': None,
        })
