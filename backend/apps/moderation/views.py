from rest_framework import viewsets, mixins, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone

from .models import ModerationReport, ContentFlag, ModerationAction
from .serializers import (
    ModerationReportSerializer, ModerationReportActionSerializer,
    ContentFlagSerializer, ModerationActionSerializer,
)


class ModerationReportViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    queryset = ModerationReport.objects.select_related(
        'reporter', 'target_user', 'assigned_to',
    ).all()
    serializer_class = ModerationReportSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['status', 'reason']
    search_fields = ['description', 'resolution_note']

    def perform_create(self, serializer):
        serializer.save(reporter=self.request.user)

    @action(detail=True, methods=['post'], permission_classes=[IsAdminUser])
    def handle(self, request, pk=None):
        report = self.get_object()
        serializer = ModerationReportActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        action = serializer.validated_data['action']
        now = timezone.now()

        if action == 'investigate':
            report.status = 'investigating'
            report.assigned_to = request.user
        elif action == 'resolve':
            report.status = 'resolved'
            report.resolved_at = now
        elif action == 'dismiss':
            report.status = 'dismissed'
            report.resolved_at = now

        if serializer.validated_data.get('resolution_note'):
            report.resolution_note = serializer.validated_data['resolution_note']

        report.save(update_fields=['status', 'assigned_to', 'resolved_at', 'resolution_note'])
        return Response(ModerationReportSerializer(report).data)


class ContentFlagViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = ContentFlag.objects.all()
    serializer_class = ContentFlagSerializer
    permission_classes = [IsAdminUser]
    filterset_fields = ['flag_reason', 'severity', 'is_actioned']
    search_fields = ['content_preview']


class ModerationActionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = ModerationAction.objects.select_related('moderator', 'target_user').all()
    serializer_class = ModerationActionSerializer
    permission_classes = [IsAdminUser]
    filterset_fields = ['action']
    search_fields = ['reason']
