import logging

from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError as DjangoValidationError
from django.db import models as db_models
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import mixins, status, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import PermissionDenied, ValidationError
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.response import Response

from . import services
from .models import Commendation, ContentFlag, ModerationAction, ModerationAppeal, ModerationReport
from .serializers import (
    CommendationCreateSerializer, CommendationRevokeSerializer, CommendationSerializer,
    ContentFlagActionSerializer, ContentFlagSerializer,
    ModerationActionCreateSerializer, ModerationActionReverseSerializer,
    ModerationActionSerializer, ModerationAppealReviewSerializer,
    ModerationAppealSerializer, ModerationReportActionSerializer,
    ModerationReportAssignSerializer, ModerationReportSerializer,
)
from .takedown import ContentTakedownError, UnsupportedContentType, describe_registry
from .tasks import extend_for_appeal
from .visibility import tombstone_payload

logger = logging.getLogger(__name__)

User = get_user_model()

_TRUE = ('true', '1', 'yes')
_FALSE = ('false', '0', 'no')


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

    def get_queryset(self):
        """Reports are private to their reporter; only staff see the queue.

        Without this, `queryset = ...all()` leaks every report (reporter
        identity, target user, resolution notes) to any authenticated user.

        `assigned_to` was write-only before: `handle` set it and nothing ever
        read it back, so an assignment could not be filtered on, listed or
        handed to a moderator as "yours". These three query parameters are the
        read side, and they only apply to the staff queue — for a non-staff user
        the queryset is already their own reports and an `assigned_to` filter
        would just be noise.
        """
        queryset = ModerationReport.objects.select_related(
            'reporter', 'target_user', 'assigned_to',
        ).all()
        user = self.request.user
        if not (user.is_staff or user.is_superuser):
            return queryset.filter(reporter=user)

        queryset = self._apply_assignment_filters(queryset)
        return queryset

    def _apply_assignment_filters(self, queryset):
        params = self.request.query_params
        errors = {}

        assigned_to = (params.get('assigned_to') or '').strip()
        if assigned_to:
            if assigned_to == 'me':
                queryset = queryset.filter(assigned_to=self.request.user)
            else:
                try:
                    queryset = queryset.filter(assigned_to_id=assigned_to)
                except (ValueError, TypeError, DjangoValidationError):
                    errors['assigned_to'] = ['Must be a user id, or "me".']

        unassigned = (params.get('unassigned') or '').strip().lower()
        if unassigned in _TRUE:
            queryset = queryset.filter(assigned_to__isnull=True)
        elif unassigned in _FALSE:
            queryset = queryset.filter(assigned_to__isnull=False)
        elif unassigned:
            errors['unassigned'] = ['Must be true or false.']

        if errors:
            raise ValidationError(errors)
        return queryset

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

    @action(detail=True, methods=['post'], permission_classes=[IsAdminUser])
    def assign(self, request, pk=None):
        """Assign a report to a staff member, or unassign it.

        Separate from ``handle`` on purpose: ``handle``'s ``investigate`` branch
        assigns to *the caller* as a side effect of a status change, which is not
        a queue-management operation and cannot express handing a report to
        someone else or taking it back.
        """
        report = self.get_object()
        serializer = ModerationReportAssignSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        assignee_id = serializer.validated_data['assigned_to']
        if assignee_id is None:
            report.assigned_to = None
        else:
            assignee = User.objects.filter(pk=assignee_id).first()
            if assignee is None:
                return Response({
                    'success': False, 'data': None,
                    'message': f'No user with id {assignee_id}.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_404_NOT_FOUND)
            if not (assignee.is_staff or assignee.is_superuser):
                return Response({
                    'success': False, 'data': None,
                    'message': 'Reports can only be assigned to a staff member.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            report.assigned_to = assignee

        report.save(update_fields=['assigned_to', 'updated_at'])
        report.refresh_from_db()
        return Response({
            'success': True,
            'data': ModerationReportSerializer(report).data,
            'message': 'Report unassigned.' if assignee_id is None else 'Report assigned.',
            'errors': None,
            'pagination': None,
        })


class ContentFlagViewSet(viewsets.ReadOnlyModelViewSet):
    """HITL moderation queue for AI-flagged content (Sprint B3)."""

    queryset = ContentFlag.objects.all()
    serializer_class = ContentFlagSerializer
    permission_classes = [IsAdminUser]
    # content_type is filterable because without it a moderator cannot answer
    # "what have we flagged in communities this week" -- it was a free-text
    # column on a list endpoint that returned every type at once.
    filterset_fields = ['flag_reason', 'severity', 'is_actioned', 'content_type']
    search_fields = ['content_preview', 'content_id']

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
        # Accepts a repeated param or a comma-separated list, so the console can
        # send either `?content_type=a&content_type=b` or `?content_type=a,b`.
        # Both shapes are accepted: `?content_type=a&content_type=b` and
        # `?content_type=a,b`. The console sends the second.
        raw = list(request.query_params.getlist('content_type'))
        raw += request.query_params.get('content_types', '').split(',')
        content_types = []
        for value in raw:
            content_types.extend(t.strip() for t in value.split(',') if t.strip())
        if content_types:
            qs = qs.filter(content_type__in=content_types)

        serializer = ContentFlagSerializer(qs[:100], many=True)
        return Response({
            'success': True,
            'data': serializer.data,
            'count': qs.count(),
            'message': 'OK',
            'errors': None,
            'pagination': None,
            'supported_content_types': describe_registry(),
        })

    @action(detail=True, methods=['get'], url_path='explanation')
    def explanation(self, request, pk=None):
        """Return the human-readable explanation for why content was flagged.

        Any authenticated user can request this — it surfaces the AI's own
        account of why a piece of content was flagged, so viewers understand
        the moderation decision instead of seeing a silent removal.
        """
        flag = self.get_object()
        return Response({
            'success': True,
            'data': {
                'flag_id': str(flag.id),
                'flag_reason': flag.flag_reason,
                'severity': flag.severity,
                'confidence': flag.confidence,
                'ai_explanation': flag.ai_explanation,
                'ai_method': flag.ai_method,
                'content_preview': flag.content_preview,
                'content_type': flag.content_type,
                'content_id': flag.content_id,
                'is_actioned': flag.is_actioned,
                'created_at': flag.created_at.isoformat(),
            },
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })

    @action(detail=False, methods=['get'], url_path='resolve')
    def resolve(self, request):
        """Resolve a `content_type`/`content_id` pair into something viewable.

        The queue used to show moderators a truncated id and a 500-character
        preview and then leave them to guess what they were looking at. This
        returns the live object behind a flag or a report, plus the in-app route
        that opens it, so "go and look at it" is one click.

        Staff-only, and deliberately returns the content in full: this is the
        surface where a moderator has to see what they are about to act on.
        """
        content_type = (request.query_params.get('content_type') or '').strip()
        content_id = (request.query_params.get('content_id') or '').strip()
        if not content_type or not content_id:
            return Response({
                'success': False, 'data': None,
                'message': 'content_type and content_id are both required.',
                'errors': {'content_type': ['required'], 'content_id': ['required']},
                'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        from .takedown import active_takedown_for
        from .resolve import resolve_content

        try:
            resolved = resolve_content(content_type, content_id)
        except Exception as exc:  # noqa: BLE001
            logger.warning('Could not resolve %s %s: %s', content_type, content_id, exc)
            return Response({
                'success': False, 'data': None,
                'message': f'Could not resolve {content_type} {content_id}: {exc}',
                'errors': {'content_id': [str(exc)]},
                'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        takedown = active_takedown_for(content_type, content_id)
        payload = dict(resolved)
        payload['takedown'] = tombstone_payload(takedown)
        return Response({
            'success': True,
            'data': payload,
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
        for reason in ('nsfw', 'toxic', 'spam', 'misinfo', 'medical_claim', 'undisclosed_sponsor', 'adult_ungated', 'custom'):
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

    @action(detail=False, methods=['get'], url_path='pending-approvals')
    def pending_approvals(self, request):
        """Ban/suspension requests waiting for their second approver.

        A moderator raising a ban does not get a ban — they get a row in
        ``apps.governance`` and a queue entry that stays pending until somebody
        else says yes. If that wait is invisible from the moderation side, the
        moderator's natural assumption is that the ban failed, and the obvious
        "fix" is to try again. So the pending state is surfaced here, next to the
        flags, with the target and how long it has been waiting.
        """
        from apps.governance.models import AccountActionRequest

        queryset = AccountActionRequest.objects.filter(
            status='pending', action__in=('ban', 'suspension'),
        ).select_related('target_user', 'requested_by').order_by('created_at')

        now = timezone.now()
        data = [
            {
                'id': str(row.id),
                'governance_action': row.action,
                'target_user': str(row.target_user_id),
                'requested_by': str(row.requested_by_id) if row.requested_by_id else None,
                'requested_by_profile': row.requested_by_profile,
                'reason': (row.payload or {}).get('reason', ''),
                'duration_days': (row.payload or {}).get('duration_days'),
                'requires_second': row.requires_second,
                'waiting_seconds': int((now - row.created_at).total_seconds()),
                'created_at': row.created_at.isoformat(),
                'moderation_action_id': (row.payload or {}).get('moderation_action_id'),
            }
            for row in queryset[:100]
        ]
        return Response({
            'success': True,
            'data': data,
            'count': queryset.count(),
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })

    @action(detail=True, methods=['post'], url_path='act')
    def act_on_flag(self, request, pk=None):
        """Moderator decision on a flagged item.

        Body: {"action": "approve"|"remove"|"escalate", "note": "..."}

        - approve: clear the content's flag marker, keep content visible
        - remove: remove the underlying content, notify its author
        - escalate: keep the flag unactioned and recorded as escalated

        ``remove`` is ordered content-first, flag-second. The previous
        implementation set ``is_actioned=True`` *before* attempting the removal
        and swallowed every exception, so a takedown that failed still left the
        queue saying "handled" while the content stayed live. A takedown that
        cannot be completed now returns 4xx and leaves the flag open.
        """
        flag = self.get_object()
        serializer = ContentFlagActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        action_name = serializer.validated_data['action']
        note = serializer.validated_data.get('note', '')

        moderator = request.user
        effect = None
        # Bound up front so the shared response tail can read it on any branch.
        # Previously it was only assigned inside `remove`, so approve/escalate
        # raised UnboundLocalError at the response instead of returning.
        takedown = None

        if action_name == 'approve':
            try:
                effect = services.clear_flag_marker(flag)
            except ContentTakedownError as exc:
                logger.warning('Approve of flag %s could not clear its marker: %s', flag.id, exc)
                effect = str(exc)
            flag.is_actioned = True
            flag.action_taken = 'approved'
            flag.save(update_fields=['is_actioned', 'action_taken', 'updated_at'])
            ModerationAction.objects.create(
                action='report_dismissed',
                moderator=moderator,
                report=None,
                target_user=services.resolve_author(flag) or moderator,
                reason=f'Approved flag #{flag.id}: {note}'.strip(),
            )

        elif action_name == 'remove':
            try:
                action_row, takedown, effect = services.remove_flagged_content(
                    flag=flag, moderator=moderator, note=note,
                    public_note=note,
                )
            except ContentTakedownError as exc:
                # The decisive bit: `is_actioned` stays False, no
                # ModerationAction row exists, and the moderator is told why.
                logger.exception('Takedown of flag %s failed; flag left unactioned', flag.id)
                return Response({
                    'success': False,
                    'data': {
                        'flag_id': str(flag.id),
                        'content_type': flag.content_type,
                        'content_id': flag.content_id,
                        'is_actioned': False,
                        'takedown_performed': False,
                    },
                    'message': f'Content was NOT removed: {exc}',
                    'errors': {'content': [str(exc)]},
                    'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            except Exception as exc:  # noqa: BLE001
                logger.exception('Unexpected takedown failure for flag %s', flag.id)
                return Response({
                    'success': False,
                    'data': {'flag_id': str(flag.id), 'is_actioned': False,
                             'takedown_performed': False},
                    'message': f'Content was NOT removed: {exc}',
                    'errors': {'content': [str(exc)]},
                    'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

        elif action_name == 'escalate':
            # NOT a warning. Escalating is an internal routing decision — "send
            # this to somebody senior" — and it previously wrote a
            # `ModerationAction(action='warning')`, which told the flagged user
            # they had been warned while staff had in fact done nothing to them
            # and told them nothing.
            moderator_label = getattr(moderator, 'username', None) or getattr(moderator, 'email', str(moderator.id))
            flag.action_taken = f'escalated by {moderator_label}'
            flag.save(update_fields=['action_taken', 'updated_at'])
            ModerationAction.objects.create(
                action='escalated',
                moderator=moderator,
                report=None,
                target_user=services.resolve_author(flag) or moderator,
                reason=f'Escalated flag #{flag.id} for second review: {note}'.strip(),
            )
            effect = 'flag left unactioned and marked for second review; the author was not notified'

        else:
            return Response({
                'success': False, 'data': None,
                'message': f'Unknown action: {action_name}',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        # `takedown` is only bound on the remove branch. Surfacing it lets the
        # console tell the moderator this is reversible and until when, which is
        # the difference between "hidden" and "gone" in their head.
        response_data = {'flag': ContentFlagSerializer(flag).data, 'effect': effect}
        if takedown is not None:
            from .visibility import tombstone_payload

            response_data['takedown'] = tombstone_payload(takedown)
            response_data['takedown_id'] = str(takedown.id)

        return Response({
            'success': True,
            'data': response_data,
            'message': f'Flag {action_name}d successfully.',
            'errors': None,
            'pagination': None,
        })


class ModerationActionViewSet(
    mixins.CreateModelMixin,
    mixins.ListModelMixin,
    mixins.RetrieveModelMixin,
    viewsets.GenericViewSet,
):
    """The moderation ledger, and the staff endpoint that writes to it.

    ``warning`` applies immediately — it carries no access consequence and
    blocking it behind a second approver would train staff to batch warnings.
    ``user_suspended`` and ``user_banned`` never apply here: they create a
    pending ``apps.governance.AccountActionRequest`` and return 202. One person
    may ask for a ban. One person may not grant one.
    """

    queryset = ModerationAction.objects.select_related(
        'moderator', 'target_user', 'reversed_by',
    ).all()
    serializer_class = ModerationActionSerializer
    permission_classes = [IsAdminUser]
    filterset_fields = ['action']
    search_fields = ['reason']

    def get_serializer_class(self):
        if self.action == 'create':
            return ModerationActionCreateSerializer
        if self.action == 'reverse':
            return ModerationActionReverseSerializer
        return ModerationActionSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['user_model'] = User
        return context

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        target = data['_target']
        report = None
        if data.get('report'):
            report = get_object_or_404(ModerationReport, pk=data['report'])

        if data['action'] == 'warning':
            action_row = services.issue_warning(
                target_user=target,
                reason=data['reason'],
                moderator=request.user,
                report=report,
            )
            return Response({
                'success': True,
                'data': ModerationActionSerializer(action_row).data,
                'message': 'Warning issued and the user has been notified.',
                'errors': None,
                'pagination': None,
            }, status=status.HTTP_201_CREATED)

        try:
            action_row, approval = services.request_standing_action(
                action=data['action'],
                target_user=target,
                reason=data['reason'],
                duration_days=data.get('duration_days'),
                moderator=request.user,
                report=report,
            )
        except PermissionError as exc:
            return Response({
                'success': False, 'data': None,
                'message': str(exc),
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)
        except ValueError as exc:
            return Response({
                'success': False, 'data': None,
                'message': str(exc),
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        return Response({
            'success': True,
            'data': {
                'moderation_action': ModerationActionSerializer(action_row).data,
                'approval': {
                    'id': str(approval.id),
                    'action': approval.action,
                    'status': approval.status,
                    'requires_second': True,
                    'requested_by': str(approval.requested_by_id) if approval.requested_by_id else None,
                },
                'applied': False,
            },
            'message': (
                f'{data["action"]} requires a second approver. The request has been '
                'raised in the governance queue and nothing has been applied yet.'
            ),
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_202_ACCEPTED)

    @action(detail=True, methods=['post'])
    def reverse(self, request, pk=None):
        """Undo an action: restore removed content, or lift a suspension/ban.

        Stamps ``reversed_by`` / ``reversed_at`` / ``reversal_reason`` on the
        original row and writes a linked ``action_reversed`` row, so "what
        happened and who undid it" is answerable from either direction.
        """
        action_row = self.get_object()
        serializer = ModerationActionReverseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            reversal, effect = services.reverse_action(
                action_row=action_row,
                actor=request.user,
                reason=serializer.validated_data['reason'],
            )
        except ContentTakedownError as exc:
            logger.warning('Reversal of action %s refused: %s', action_row.id, exc)
            return Response({
                'success': False,
                'data': None,
                'message': str(exc),
                'errors': None,
                'pagination': None,
            }, status=status.HTTP_409_CONFLICT)
        except UnsupportedContentType as exc:
            return Response({
                'success': False, 'data': None,
                'message': str(exc),
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        action_row.refresh_from_db()
        return Response({
            'success': True,
            'data': {
                'reversed_action': ModerationActionSerializer(action_row).data,
                'reversal': ModerationActionSerializer(reversal).data,
                'effect': effect,
            },
            'message': f'Reversed: {effect}',
            'errors': None,
            'pagination': None,
        })


class ModerationAppealViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    queryset = ModerationAppeal.objects.select_related(
        'action', 'appellant', 'reviewer',
    )
    serializer_class = ModerationAppealSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['status']

    def get_queryset(self):
        qs = super().get_queryset()
        return qs if self.request.user.is_staff else qs.filter(appellant=self.request.user)

    def perform_create(self, serializer):
        action = serializer.validated_data['action']
        if action.target_user_id != self.request.user.id:
            raise PermissionDenied('You may only appeal actions applied to your account.')
        serializer.save(appellant=self.request.user)

        # Filing an appeal postpones deletion. The content is deleted once the
        # appeal window closes unappealed, so without this the purge could remove
        # the exact evidence the appeal is being argued from.
        for takedown in action.takedowns.filter(lifted_at__isnull=True, purged_at__isnull=True):
            extend_for_appeal(takedown)

    @action(detail=True, methods=['post'], permission_classes=[IsAdminUser])
    def review(self, request, pk=None):
        appeal = self.get_object()
        serializer = ModerationAppealReviewSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        decision = serializer.validated_data['decision']
        appeal.status = {
            'approve': 'approved', 'deny': 'denied', 'review': 'under_review',
        }[decision]
        appeal.reviewer = request.user
        appeal.reviewed_at = timezone.now()
        appeal.resolution_note = serializer.validated_data['resolution_note']
        appeal.save(update_fields=['status', 'reviewer', 'reviewed_at', 'resolution_note'])

        if decision == 'approve':
            # Same reversal path the reverse endpoint uses. The old code set
            # `target_user.is_active = True` directly, which reactivated the
            # login while leaving the AccountStanding row still reading
            # "suspended" — so `get_standing_object` re-suspended the account the
            # instant it was read back, and the appeal fixed nothing.
            try:
                services.reverse_action(
                    action_row=appeal.action,
                    actor=request.user,
                    reason=f'Appeal approved: {appeal.resolution_note}'.strip(),
                )
            except ContentTakedownError as exc:
                logger.warning('Appeal %s approved but reversal refused: %s',
                               appeal.id, exc)
                return Response({
                    'success': False, 'data': None,
                    'message': str(exc),
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_409_CONFLICT)
        return Response(ModerationAppealSerializer(appeal).data)


class CommendationViewSet(
    mixins.CreateModelMixin,
    mixins.ListModelMixin,
    mixins.RetrieveModelMixin,
    mixins.DestroyModelMixin,
    viewsets.GenericViewSet,
):
    """Staff-recorded commendations.

    Read access is deliberately narrow: a user sees commendations addressed to
    them, plus the ones they issued. A commendation is a judgement about
    somebody, written by staff, and making it browsable platform-wide would turn
    it into a popularity scoreboard.
    """

    queryset = Commendation.objects.select_related('recipient', 'issued_by')
    serializer_class = CommendationSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['category']

    def get_queryset(self):
        user = self.request.user
        queryset = Commendation.objects.select_related('recipient', 'issued_by')
        if user.is_staff or user.is_superuser:
            return queryset
        return queryset.filter(
            db_models.Q(recipient__user_id=user.pk) | db_models.Q(issued_by__user_id=user.pk),
        ).filter(visible_to_recipient=True)

    def get_serializer_class(self):
        if self.action == 'create':
            return CommendationCreateSerializer
        if self.action == 'revoke':
            return CommendationRevokeSerializer
        return CommendationSerializer

    def create(self, request, *args, **kwargs):
        if not (request.user.is_staff or request.user.is_superuser):
            raise PermissionDenied('Only staff may issue commendations.')
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        # A superuser created via `createsuperuser` has no Profile row. That is a
        # legitimate issuer of a commendation, so it records NULL rather than
        # 500 — the recipient's notification does not need an issuer name.
        issuer = getattr(request.user, 'profile', None)
        commendation = serializer.save(issued_by=issuer)
        services.notify_commendation(commendation)
        return Response({
            'success': True,
            'data': CommendationSerializer(commendation).data,
            'message': 'Commendation issued and the recipient has been notified.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)

    def destroy(self, request, *args, **kwargs):
        """The recipient may delete their own; staff may delete any.

        Hard delete, unlike ``revoke``: the recipient is removing something from
        their own feed, and keeping a row they cannot see would be pointless.
        The issuing staff member's record of having sent it is the appeal log,
        not this table.
        """
        commendation = self.get_object()
        is_recipient = commendation.recipient_id == request.user.pk
        if not (is_recipient or request.user.is_staff or request.user.is_superuser):
            raise PermissionDenied('You can only remove your own commendation.')
        commendation.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

    @action(detail=True, methods=['post'], permission_classes=[IsAdminUser])
    def revoke(self, request, pk=None):
        """Staff withdraw a commendation without erasing the row.

        ``visible_to_recipient=False`` keeps the audit trail — an operator must
        not be able to quietly un-send a commendation they regret — while
        removing it from the recipient's view.
        """
        commendation = self.get_object()
        serializer = CommendationRevokeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        if not commendation.visible_to_recipient:
            return Response({
                'success': False, 'data': None,
                'message': 'This commendation was already revoked.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_409_CONFLICT)

        commendation.visible_to_recipient = False
        commendation.save(update_fields=['visible_to_recipient', 'updated_at'])
        return Response({
            'success': True,
            'data': CommendationSerializer(commendation).data,
            'message': 'Commendation revoked. The record is kept; the recipient '
                       'no longer sees it.',
            'errors': None,
            'pagination': None,
        })