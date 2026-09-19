from django.db import IntegrityError
from django.db.models import Q
from django.shortcuts import get_object_or_404
from rest_framework import mixins, status, viewsets
from rest_framework.decorators import action
from rest_framework.parsers import FormParser, JSONParser, MultiPartParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.notifications.tasks import create_notification
from apps.profiles.models import Profile

from .models import Alarm, AlarmShare, AlarmSound, AlarmSuggestion, are_buddies
from .serializers import (
    AlarmSerializer,
    AlarmShareSerializer,
    AlarmSoundSerializer,
    AlarmSuggestionSerializer,
)


def envelope(data, message='OK', pagination=None, status_code=status.HTTP_200_OK):
    """Repo-standard response wrapper the frontend ApiResponse type expects."""
    return Response(
        {'success': True, 'data': data, 'message': message,
         'errors': None, 'pagination': pagination},
        status=status_code,
    )


class EnvelopeMixin:
    """Wrap viewset CRUD in the {success, data, message, errors, pagination} envelope."""

    def _page_info(self, paginator, queryset):
        return {
            'count': queryset.count(),
            'next': paginator.get_next_link(),
            'previous': paginator.get_previous_link(),
        } if paginator is not None else {
            'count': queryset.count(), 'next': None, 'previous': None,
        }

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())
        page = self.paginate_queryset(queryset)
        if page is not None:
            data = self.get_serializer(page, many=True).data
            return envelope(data, pagination=self._page_info(self.paginator, queryset))
        return envelope(self.get_serializer(queryset, many=True).data)

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        return envelope(response.data, 'Created.',
                        status_code=status.HTTP_201_CREATED)

    def retrieve(self, request, *args, **kwargs):
        return envelope(super().retrieve(request, *args, **kwargs).data)

    def update(self, request, *args, **kwargs):
        return envelope(super().update(request, *args, **kwargs).data)

    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return envelope(None, 'Deleted.')


class AlarmViewSet(EnvelopeMixin, viewsets.ModelViewSet):
    queryset = Alarm.objects.select_related('sound').all()
    serializer_class = AlarmSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = super().get_queryset()
        if not self.request.user.is_staff:
            qs = qs.filter(owner__user=self.request.user)
        return qs

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user.profile)


class AlarmSoundViewSet(EnvelopeMixin, viewsets.ModelViewSet):
    queryset = AlarmSound.objects.all()
    serializer_class = AlarmSoundSerializer
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_queryset(self):
        qs = super().get_queryset()
        if self.request.user.is_staff:
            return qs
        profile = self.request.user.profile
        # Own sounds plus sounds buddies shared with me and I accepted.
        return qs.filter(
            Q(owner=profile)
            | Q(shares__recipient=profile, shares__status='accepted'),
        ).distinct()

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user.profile)

    @action(detail=True, methods=['post'])
    def share(self, request, pk=None):
        """Share my sound with a buddy: {recipient_profile_id}."""
        profile = request.user.profile
        sound = self.get_object()
        if sound.owner_id != profile.pk:
            return Response(
                {'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND,
            )

        recipient_id = request.data.get('recipient_profile_id')
        if not recipient_id:
            return Response(
                {'detail': 'recipient_profile_id is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        recipient = get_object_or_404(Profile, pk=recipient_id)
        if recipient.pk == profile.pk:
            return Response(
                {'detail': 'You cannot share a sound with yourself.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if not are_buddies(profile, recipient):
            return Response(
                {'detail': 'You can only share alarm sounds with buddies.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if AlarmShare.objects.filter(sound=sound, recipient=recipient).exists():
            return Response(
                {'detail': 'Sound already shared with this buddy.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        from django.db import transaction

        try:
            # Savepoint: a lost race on the unique constraint must not
            # poison the outer transaction.
            with transaction.atomic():
                share = AlarmShare.objects.create(
                    sound=sound, sender=profile, recipient=recipient,
                )
        except IntegrityError:
            return Response(
                {'detail': 'Sound already shared with this buddy.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        create_notification.delay(
            str(recipient.user_id),
            'alarm_shared',
            f'{profile.display_name} shared an alarm sound with you 🔊',
            f'@{profile.username} shared "{sound.name}". Tap to accept it.',
            {
                'sound_id': str(sound.id),
                'sound_name': sound.name,
                'share_id': str(share.id),
                'from_user_id': str(profile.user_id),
                'from_username': profile.username,
            },
        )
        return envelope(
            AlarmShareSerializer(share, context={'request': request}).data,
            'Shared.', status_code=status.HTTP_201_CREATED,
        )


class AlarmShareViewSet(
    EnvelopeMixin,
    mixins.ListModelMixin,
    mixins.RetrieveModelMixin,
    viewsets.GenericViewSet,
):
    queryset = AlarmShare.objects.select_related('sound', 'sender', 'recipient').all()
    serializer_class = AlarmShareSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = super().get_queryset()
        if not self.request.user.is_staff:
            profile = self.request.user.profile
            qs = qs.filter(Q(sender=profile) | Q(recipient=profile))
        return qs

    @action(detail=False, methods=['get'])
    def inbox(self, request):
        """Pending shares I received."""
        shares = self.get_queryset().filter(
            recipient=request.user.profile, status='pending',
        )
        page = self.paginate_queryset(shares)
        if page is not None:
            data = AlarmShareSerializer(page, many=True,
                                        context={'request': request}).data
            return envelope(data, pagination=self._page_info(self.paginator, shares))
        return envelope(AlarmShareSerializer(
            shares, many=True, context={'request': request}).data)

    @action(detail=True, methods=['post'])
    def respond(self, request, pk=None):
        """Accept or decline a received share: {accept: bool}."""
        profile = request.user.profile
        share = self.get_object()
        if share.recipient_id != profile.pk:
            return Response(
                {'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND,
            )
        if share.status != 'pending':
            return Response(
                {'detail': f'Share already {share.status}.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if 'accept' not in request.data:
            return Response(
                {'detail': 'accept is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        accepted = request.data.get('accept')
        accepted = accepted is True or (
            isinstance(accepted, str) and accepted.lower() in ('true', '1')
        )
        share.status = 'accepted' if accepted else 'declined'
        share.save(update_fields=['status', 'updated_at'])

        if accepted:
            sender = share.sender
            create_notification.delay(
                str(sender.user_id),
                'alarm_share_accepted',
                f'{profile.display_name} accepted your alarm sound 🎉',
                f'@{profile.username} accepted "{share.sound.name}".',
                {
                    'sound_id': str(share.sound_id),
                    'sound_name': share.sound.name,
                    'share_id': str(share.id),
                    'from_user_id': str(profile.user_id),
                    'from_username': profile.username,
                },
            )
        return envelope(AlarmShareSerializer(
            share, context={'request': request}).data)


class AlarmSuggestionViewSet(
    EnvelopeMixin,
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    queryset = AlarmSuggestion.objects.select_related('sender', 'recipient').all()
    serializer_class = AlarmSuggestionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = super().get_queryset()
        if not self.request.user.is_staff:
            profile = self.request.user.profile
            qs = qs.filter(Q(sender=profile) | Q(recipient=profile))
        return qs

    def perform_create(self, serializer):
        profile = self.request.user.profile
        recipient = serializer.validated_data['recipient']
        if recipient.pk == profile.pk:
            from rest_framework.exceptions import ValidationError

            raise ValidationError('You cannot suggest a sound to yourself.')
        if not are_buddies(profile, recipient):
            from rest_framework.exceptions import ValidationError

            raise ValidationError('You can only send alarm suggestions to buddies.')
        suggestion = serializer.save(sender=profile)
        create_notification.delay(
            str(recipient.user_id),
            'alarm_suggestion',
            f'{profile.display_name} suggested an alarm sound 🎵',
            suggestion.title[:200],
            {
                'suggestion_id': str(suggestion.id),
                'suggestion_title': suggestion.title,
                'from_user_id': str(profile.user_id),
                'from_username': profile.username,
            },
        )

    @action(detail=True, methods=['post'])
    def respond(self, request, pk=None):
        """Respond to a received suggestion: {decision: accepted|declined|dismissed}."""
        profile = request.user.profile
        suggestion = self.get_object()
        if suggestion.recipient_id != profile.pk:
            return Response(
                {'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND,
            )
        decision = request.data.get('decision')
        valid = dict(AlarmSuggestion.STATUS_CHOICES)
        if decision not in valid or decision == 'pending':
            return Response(
                {'detail': 'decision must be one of: accepted, declined, dismissed.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        suggestion.status = decision
        suggestion.save(update_fields=['status', 'updated_at'])
        return envelope(AlarmSuggestionSerializer(
            suggestion, context={'request': request}).data)
