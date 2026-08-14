from rest_framework import views, permissions
from rest_framework.response import Response
from common.pagination import CursorPagination
from .models import Notification, NotificationPreference
from .serializers import NotificationSerializer, NotificationPreferenceSerializer


class NotificationListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = CursorPagination

    def get(self, request):
        notifications = Notification.objects.filter(
            recipient=request.user.profile,
        ).order_by('-created_at')

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
