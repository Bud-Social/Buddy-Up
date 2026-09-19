from rest_framework import mixins, status, viewsets
from rest_framework.permissions import AllowAny, IsAdminUser
from rest_framework.response import Response

from .models import WaitlistEntry
from .serializers import WaitlistEntrySerializer


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
        return Response(
            {'success': True, 'data': serializer.data,
             'message': 'You joined the waitlist.', 'errors': None, 'pagination': None},
            status=status.HTTP_201_CREATED,
        )
