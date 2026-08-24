from django.db import models as db_models
from rest_framework import viewsets, mixins, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone

from .models import ModerationReport, ContentFlag, ModerationAction
from .serializers import (
    ModerationReportSerializer, ModerationReportActionSerializer,
    ContentFlagSerializer, ContentFlagActionSerializer,
    ModerationActionSerializer,
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
        from datetime import timedelta
        report = serializer.save(reporter=self.request.user)

        # Auto-flag threshold: if >= 3 reports for the same target user in 15 minutes, auto-flag
        recent_cutoff = timezone.now() - timedelta(minutes=15)
        recent_count = ModerationReport.objects.filter(
            target_user=report.target_user,
            created_at__gte=recent_cutoff,
        ).count()

        if recent_count >= 3:
            ContentFlag.objects.get_or_create(
                flag_reason='toxic',
                content_type='user.profile',
                content_id=str(report.target_user.id),
                defaults={
                    'severity': 'high',
                    'confidence': 0.95,
                    'source': 'auto_report_threshold',
                    'content_preview': f'Multiple user reports ({recent_count}) received within 15 minutes.',
                    'is_actioned': False,
                },
            )

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
    """HITL moderation queue for AI-flagged content (Sprint B3)."""
    queryset = ContentFlag.objects.all()
    serializer_class = ContentFlagSerializer
    permission_classes = [IsAdminUser]
    filterset_fields = ['flag_reason', 'severity', 'is_actioned']
    search_fields = ['content_preview']

    @action(detail=False, methods=['get'], url_path='queue')
    def queue(self, request):
        """List un-actioned flags for the HITL review queue.

        Ordered by severity (critical → high → medium → low), then by confidence
        descending so the highest-confidence flags surface first.
        """
        severity_order = db_models.Case(
            db_models.When(severity='critical', then=db_models.Value(0)),
            db_models.When(severity='high', then=db_models.Value(1)),
            db_models.When(severity='medium', then=db_models.Value(2)),
            db_models.When(severity='low', then=db_models.Value(3)),
            default=db_models.Value(4),
            output_field=db_models.IntegerField(),
        )
        qs = ContentFlag.objects.filter(is_actioned=False).annotate(
            _sev_order=severity_order,
        ).order_by('_sev_order', '-confidence', '-created_at')

        flag_reason = request.query_params.get('flag_reason')
        if flag_reason:
            qs = qs.filter(flag_reason=flag_reason)
        severity = request.query_params.get('severity')
        if severity:
            qs = qs.filter(severity=severity)

        serializer = ContentFlagSerializer(qs[:100], many=True)
        return Response({
            'success': True,
            'data': serializer.data,
            'count': qs.count(),
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })

    @action(detail=False, methods=['get'], url_path='stats')
    def stats(self, request):
        """Aggregate stats for the HITL dashboard header."""
        qs = ContentFlag.objects.all()
        total = qs.count()
        unactioned = qs.filter(is_actioned=False).count()
        actioned = qs.filter(is_actioned=True).count()

        by_severity = {}
        for sev in ('critical', 'high', 'medium', 'low'):
            by_severity[sev] = qs.filter(severity=sev, is_actioned=False).count()

        by_reason = {}
        for reason in ('nsfw', 'toxic', 'spam', 'misinfo', 'medical_claim', 'undisclosed_sponsor', 'custom'):
            by_reason[reason] = qs.filter(flag_reason=reason, is_actioned=False).count()

        return Response({
            'success': True,
            'data': {
                'total': total,
                'unactioned': unactioned,
                'actioned': actioned,
                'by_severity': by_severity,
                'by_reason': by_reason,
            },
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })

    @action(detail=True, methods=['post'], url_path='act')
    def act_on_flag(self, request, pk=None):
        """Moderator decision on a flagged item.

        Body: {"action": "approve"|"remove"|"escalate", "note": "..."}

        - approve: mark flag actioned, keep content visible
        - remove: mark flag actioned, remove underlying content
        - escalate: keep flag unactioned, assigned_to = current moderator
        """
        flag = self.get_object()
        serializer = ContentFlagActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        action_name = serializer.validated_data['action']
        note = serializer.validated_data.get('note', '')

        moderator = request.user
        content_author = self._get_content_author(flag) or moderator

        if action_name == 'approve':
            flag.is_actioned = True
            flag.action_taken = 'approved'
            flag.save(update_fields=['is_actioned', 'action_taken', 'updated_at'])
            self._unflag_content(flag)
            ModerationAction.objects.create(
                action='report_dismissed',
                moderator=moderator,
                report=None,
                target_user=content_author,
                reason=f'Approved flag #{flag.id}: {note}'.strip(),
            )
        elif action_name == 'remove':
            flag.is_actioned = True
            flag.action_taken = 'content_removed'
            flag.save(update_fields=['is_actioned', 'action_taken', 'updated_at'])
            self._remove_content(flag)
            ModerationAction.objects.create(
                action='content_removed',
                moderator=moderator,
                report=None,
                target_user=content_author,
                reason=f'Removed flag #{flag.id}: {note}'.strip(),
            )
        elif action_name == 'escalate':
            moderator_label = getattr(moderator, 'username', None) or getattr(moderator, 'email', str(moderator.id))
            flag.action_taken = f'escalated by {moderator_label}'
            flag.save(update_fields=['action_taken', 'updated_at'])
            ModerationAction.objects.create(
                action='warning',
                moderator=moderator,
                report=None,
                target_user=content_author,
                reason=f'Escalated flag #{flag.id}: {note}'.strip(),
            )
        else:
            return Response({
                'success': False, 'data': None,
                'message': f'Unknown action: {action_name}',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        return Response({
            'success': True,
            'data': ContentFlagSerializer(flag).data,
            'message': f'Flag {action_name}d successfully.',
            'errors': None, 'pagination': None,
        })

    def _remove_content(self, flag: ContentFlag) -> None:
        """Mark the underlying content as removed based on flag.content_type/id."""
        ct = flag.content_type
        cid = flag.content_id
        try:
            if ct == 'feed.post':
                from apps.feed.models import Post
                Post.objects.filter(id=cid).update(moderation_status='removed')
        except Exception:  # noqa: BLE001
            pass

    def _unflag_content(self, flag: ContentFlag) -> None:
        """Clear a flagged status from the underlying content (approve path)."""
        ct = flag.content_type
        cid = flag.content_id
        try:
            if ct == 'feed.post':
                from apps.feed.models import Post
                Post.objects.filter(id=cid, moderation_status='flagged').update(
                    moderation_status='clean',
                )
        except Exception:  # noqa: BLE001
            pass

    def _get_content_author(self, flag: ContentFlag):
        """Resolve the author profile of the flagged content, or None."""
        ct = flag.content_type
        cid = flag.content_id
        try:
            if ct == 'feed.post':
                from apps.feed.models import Post
                post = Post.objects.filter(id=cid).select_related('author').first()
                if post:
                    return post.author
        except Exception:  # noqa: BLE001
            pass
        return None


class ModerationActionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = ModerationAction.objects.select_related('moderator', 'target_user').all()
    serializer_class = ModerationActionSerializer
    permission_classes = [IsAdminUser]
    filterset_fields = ['action']
    search_fields = ['reason']
