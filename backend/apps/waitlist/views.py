from rest_framework import mixins, status, viewsets
from rest_framework.permissions import AllowAny, IsAdminUser
from rest_framework.response import Response

from .models import ContactInquiry, FeatureSuggestion, WaitlistEntry
from .serializers import (
    ContactInquirySerializer,
    FeatureSuggestionSerializer,
    WaitlistEntrySerializer,
)
from .sheets import mirror_to_sheets_later


class WaitlistViewSet(
    mixins.CreateModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    queryset = WaitlistEntry.objects.all()
    serializer_class = WaitlistEntrySerializer

    def get_permissions(self):
        # Public signup; only staff may list entries.
        if self.action == 'create':
            return [AllowAny()]
        return [IsAdminUser()]

    def create(self, request, *args, **kwargs):
        email = (request.data.get('email') or '').strip().lower()
        existing = WaitlistEntry.objects.filter(email__iexact=email).first() if email else None
        if existing:
            # Idempotent: re-submits don't leak or error, just confirm.
            return Response(
                {'success': True, 'data': WaitlistEntrySerializer(existing).data,
                 'message': 'You are already on the waitlist.', 'errors': None,
                 'pagination': None},
            )
        serializer = self.get_serializer(data={
            **request.data, 'email': email, 'source': request.data.get('source') or 'landing',
        })
        serializer.is_valid(raise_exception=True)
        serializer.save()
        # Mirror the new signup to the Google Sheet. Server-side so the
        # webhook URL is never exposed to the browser; fire-and-forget.
        entry = serializer.instance
        mirror_to_sheets_later(entry.email, entry.name, entry.country,
                               entry.source, entry.interest, entry.metadata)
        return Response(
            {'success': True, 'data': serializer.data,
             'message': 'You joined the waitlist.', 'errors': None, 'pagination': None},
            status=status.HTTP_201_CREATED,
        )


class PublicIntakeViewSet(
    mixins.CreateModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    """Shared behaviour for public suggestion/contact intake.

    Anyone may submit; only staff may list. Throttled by DRF defaults.
    """

    def get_permissions(self):
        if self.action == 'create':
            return [AllowAny()]
        return [IsAdminUser()]

    def _created_response(self, serializer, message):
        return Response(
            {'success': True, 'data': serializer.data,
             'message': message, 'errors': None, 'pagination': None},
            status=status.HTTP_201_CREATED,
        )


class FeatureSuggestionViewSet(PublicIntakeViewSet):
    queryset = FeatureSuggestion.objects.all()
    serializer_class = FeatureSuggestionSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return self._created_response(serializer, 'Thanks — your suggestion is in.')


class ContactInquiryViewSet(PublicIntakeViewSet):
    queryset = ContactInquiry.objects.all()
    serializer_class = ContactInquirySerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        inquiry = serializer.save()
        self._notify_staff(inquiry)
        return self._created_response(
            serializer, 'Message received — we reply within two business days.',
        )

    def _notify_staff(self, inquiry):
        import logging
        import os
        logger = logging.getLogger(__name__)
        destination = os.environ.get(
            'CONTACT_INBOX_EMAIL', 'support@buddyupfit.com',
        )
        try:
            from django.core.mail import send_mail
            send_mail(
                subject=f'[BuddyUp contact] {inquiry.topic}: {inquiry.subject or inquiry.name}',
                message=f'From: {inquiry.name} <{inquiry.email}>\n\n{inquiry.message}',
                from_email=None,
                recipient_list=[destination],
                fail_silently=True,
            )
        except Exception:  # noqa: BLE001 — intake must never fail on email
            logger.warning('Contact inquiry staff notification failed', exc_info=True)
