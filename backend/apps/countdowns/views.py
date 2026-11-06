from rest_framework import views, permissions, status
from rest_framework.response import Response
from django.shortcuts import get_object_or_404

from .models import CountdownTemplate, UserCountdown, Routine
from .serializers import CountdownTemplateSerializer, UserCountdownSerializer, RoutineSerializer


class CountdownTemplateListView(views.APIView):
    """List active countdown templates offered to all users."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = CountdownTemplate.objects.filter(is_active=True)
        return Response({
            'success': True,
            'data': CountdownTemplateSerializer(qs, many=True).data,
            'message': 'Templates.', 'errors': None, 'pagination': None,
        })


class UserCountdownListView(views.APIView):
    """List and create the authenticated user's countdowns."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = UserCountdown.objects.filter(user=request.user.profile)
        is_active = request.query_params.get('is_active')
        if is_active is not None:
            qs = qs.filter(is_active=is_active.lower() == 'true')
        return Response({
            'success': True,
            'data': UserCountdownSerializer(qs, many=True).data,
            'message': 'Countdowns.', 'errors': None, 'pagination': {'count': qs.count()},
        })

    def post(self, request):
        serializer = UserCountdownSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        serializer.save(user=request.user.profile)
        return Response({
            'success': True,
            'data': UserCountdownSerializer(serializer.instance).data,
            'message': 'Countdown created.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class UserCountdownDetailView(views.APIView):
    """Retrieve, update, or delete a single user countdown."""
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self, pk):
        return get_object_or_404(UserCountdown, id=pk, user=self.request.user.profile)

    def get(self, request, pk):
        obj = self.get_object(pk)
        return Response({
            'success': True,
            'data': UserCountdownSerializer(obj).data,
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    def patch(self, request, pk):
        obj = self.get_object(pk)
        serializer = UserCountdownSerializer(obj, data=request.data, partial=True, context={'request': request})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({
            'success': True,
            'data': UserCountdownSerializer(serializer.instance).data,
            'message': 'Updated.', 'errors': None, 'pagination': None,
        })

    def delete(self, request, pk):
        obj = self.get_object(pk)
        obj.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Deleted.', 'errors': None, 'pagination': None,
        })


class CountdownCheckInView(views.APIView):
    """Manual check-in: advance a manual countdown by one unit."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        obj = get_object_or_404(UserCountdown, id=pk, user=request.user.profile)
        if obj.countdown_type != 'manual':
            return Response({
                'success': False, 'data': None,
                'message': 'Only manual countdowns can be checked in.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        obj.advance(amount=1)
        return Response({
            'success': True,
            'data': UserCountdownSerializer(obj).data,
            'message': 'Checked in.', 'errors': None, 'pagination': None,
        })


class CountdownResetView(views.APIView):
    """Reset a countdown to zero."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        obj = get_object_or_404(UserCountdown, id=pk, user=request.user.profile)
        obj.reset()
        return Response({
            'success': True,
            'data': UserCountdownSerializer(obj).data,
            'message': 'Reset.', 'errors': None, 'pagination': None,
        })


class CountdownAutoAdvanceView(views.APIView):
    """Server endpoint for automatic signals to advance a countdown.

    Called by activity/gps/workout handlers when an automatic countdown
    should advance (e.g. a logged walk advances the 'walking days' countdown).
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        signal = request.data.get('signal')
        user = request.user.profile
        if not signal:
            return Response({
                'success': False, 'data': None,
                'message': 'signal is required.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        qs = UserCountdown.objects.filter(
            user=user, is_active=True, countdown_type='automatic',
            auto_advance_signal=signal,
        )
        advanced = []
        for obj in qs:
            obj.advance(amount=1, signal=signal)
            advanced.append(obj.id)

        return Response({
            'success': True,
            'data': {'advanced_ids': advanced, 'count': len(advanced)},
            'message': 'Auto-advance processed.', 'errors': None, 'pagination': None,
        })


class CountdownSeedTemplatesView(views.APIView):
    """Seed the default countdown templates (idempotent). Dev/staff only."""
    permission_classes = [permissions.IsAdminUser]

    DEFAULT_TEMPLATES = [
        {
            'code': 'sobriety', 'title': 'Sobriety', 'unit': 'days',
            'description': 'Days since last drink.', 'icon': 'wine', 'color': '#ef4444',
            'default_target': 0, 'sort_order': 1,
        },
        {
            'code': 'no_artificial_sugars', 'title': 'No Artificial Sugars', 'unit': 'days',
            'description': 'Days without artificial sweeteners.', 'icon': 'minus', 'color': '#f59e0b',
            'default_target': 0, 'sort_order': 2,
        },
        {
            'code': 'no_animal_proteins', 'title': 'No Animal Proteins', 'unit': 'days',
            'description': 'Days without meat, fish, eggs, or dairy.', 'icon': 'leaf', 'color': '#22c55e',
            'default_target': 0, 'sort_order': 3,
        },
        {
            'code': 'gym_attendance', 'title': 'Gym Attendance', 'unit': 'days',
            'description': 'Consecutive days with a gym visit.', 'icon': 'dumbbell', 'color': '#3b82f6',
            'default_target': 0, 'sort_order': 4,
        },
        {
            'code': 'walking_days', 'title': 'Walking Days', 'unit': 'days',
            'description': 'Days with a logged walk.', 'icon': 'map-pin', 'color': '#10b981',
            'default_target': 0, 'sort_order': 5,
        },
        {
            'code': 'no_drugs', 'title': 'No Drugs', 'unit': 'days',
            'description': 'Days drug-free.', 'icon': 'alert-circle', 'color': '#dc2626',
            'default_target': 0, 'sort_order': 6,
        },
        {
            'code': 'no_nut_month', "title": "No Nut Month", 'unit': 'days',
            'description': 'Days without nuts.', 'icon': 'leaf', 'color': '#a855f7',
            'default_target': 30, 'sort_order': 7,
        },
        {
            'code': 'custom', 'title': 'Custom Reason', 'unit': 'days',
            'description': 'Your own countdown reason.', 'icon': 'plus', 'color': '#6b7280',
            'default_target': 0, 'sort_order': 99,
        },
    ]

    def post(self, request):
        created = 0
        for data in self.DEFAULT_TEMPLATES:
            obj, was_created = CountdownTemplate.objects.update_or_create(
                code=data['code'], defaults=data,
            )
            if was_created:
                created += 1
        return Response({
            'success': True,
            'data': {'created': created, 'total': CountdownTemplate.objects.count()},
            'message': 'Templates seeded.', 'errors': None, 'pagination': None,
        })


class RoutineListView(views.APIView):
    """List and create the authenticated user's routines."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = Routine.objects.filter(user=request.user.profile, is_active=True)
        return Response({
            'success': True,
            'data': RoutineSerializer(qs, many=True).data,
            'message': 'Routines.', 'errors': None, 'pagination': {'count': qs.count()},
        })

    def post(self, request):
        serializer = RoutineSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        serializer.save(user=request.user.profile)
        return Response({
            'success': True,
            'data': RoutineSerializer(serializer.instance).data,
            'message': 'Routine created.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class RoutineDetailView(views.APIView):
    """Retrieve, update, or delete a single routine."""
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self, pk):
        return get_object_or_404(Routine, id=pk, user=self.request.user.profile)

    def get(self, request, pk):
        obj = self.get_object(pk)
        return Response({
            'success': True,
            'data': RoutineSerializer(obj).data,
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    def patch(self, request, pk):
        obj = self.get_object(pk)
        serializer = RoutineSerializer(obj, data=request.data, partial=True, context={'request': request})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({
            'success': True,
            'data': RoutineSerializer(serializer.instance).data,
            'message': 'Updated.', 'errors': None, 'pagination': None,
        })

    def delete(self, request, pk):
        obj = self.get_object(pk)
        obj.is_active = False
        obj.save(update_fields=['is_active'])
        return Response({
            'success': True, 'data': None,
            'message': 'Deleted.', 'errors': None, 'pagination': None,
        })
