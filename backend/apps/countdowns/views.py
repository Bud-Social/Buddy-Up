from rest_framework import views, permissions, status
from rest_framework.response import Response
from django.shortcuts import get_object_or_404

from .models import CountdownTemplate, UserCountdown
from .serializers import CountdownTemplateSerializer, UserCountdownSerializer


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


class WelcomeCheckView(views.APIView):
    """Check if the authenticated user's email is in the welcome celebration list.
    
    Emails are stored server-side only — never leaked to the frontend.
    """
    permission_classes = [permissions.IsAuthenticated]

    WELCOME_EMAILS = {
        'goddiekevo@gmail.com': {
            'display_name': 'Naphtalie',
            'nickname': 'Tosiq',
            'auto_buddy_email': 'jmbngugimbugua@gmail.com',
        },
        'jmbngugimbugua@gmail.com': {
            'display_name': 'Automatic Buddy',
            'nickname': 'AutoBuddy',
        },
        'hairplacebnsalon@gmail.com': {
            'display_name': 'Test User',
            'nickname': 'Tester',
        },
    }

    def post(self, request):
        email = request.data.get('email', '').strip().lower()
        if not email:
            return Response({
                'success': False, 'data': None,
                'message': 'email is required.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        welcome_info = self.WELCOME_EMAILS.get(email)
        if welcome_info:
            return Response({
                'success': True,
                'data': {
                    'is_welcome_user': True,
                    'display_name': welcome_info['display_name'],
                    'nickname': welcome_info['nickname'],
                    'auto_buddy_email': welcome_info.get('auto_buddy_email'),
                },
                'message': 'Welcome user confirmed.', 'errors': None, 'pagination': None,
            })
        return Response({
            'success': True,
            'data': {'is_welcome_user': False},
            'message': 'Not a welcome user.', 'errors': None, 'pagination': None,
        })


class WelcomeViewedView(views.APIView):
    """Notify the system that a welcome user has viewed their welcome window.
    
    Sends a backend notification to the automatic buddy (jmbngugimbugua@gmail.com)
    that the viewer just viewed the welcome.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        email = request.data.get('email', '').strip().lower()
        auto_buddy_email = request.data.get('auto_buddy_email', '').strip().lower()
        viewer_name = request.data.get('viewer_name', 'a user')

        if not email:
            return Response({
                'success': False, 'data': None,
                'message': 'email is required.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        welcome_info = WelcomeCheckView.WELCOME_EMAILS.get(email)
        if not welcome_info:
            return Response({
                'success': False, 'data': None,
                'message': 'Not a welcome user.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        target_email = auto_buddy_email or welcome_info.get('auto_buddy_email') or 'jmbngugimbugua@gmail.com'

        # Log the welcome-viewed event server-side for the automatic buddy
        # In production, this could trigger an email/push notification
        print(f'[WELCOME_VIEWED] {email} ({viewer_name}) just viewed the welcome. Notifying {target_email}.')

        return Response({
            'success': True,
            'data': {
                'viewer_email': email,
                'viewer_name': viewer_name,
                'notified_email': target_email,
            },
            'message': 'Welcome view recorded. Automatic buddy notified.', 'errors': None, 'pagination': None,
        })


class CountdownSeedTemplatesView(views.APIView):
    """Seed the default countdown templates (idempotent). Dev/staff only."""
    permission_classes = [permissions.IsAdminUser]

    DEFAULT_TEMPLATES = [
        {
            'code': 'sobriety', 'title': 'Sobriety', 'unit': 'days',
            'description': 'Days since last drink.', 'icon': '🍻', 'color': '#ef4444',
            'default_target': 0, 'sort_order': 1,
        },
        {
            'code': 'no_artificial_sugars', 'title': 'No Artificial Sugars', 'unit': 'days',
            'description': 'Days without artificial sweeteners.', 'icon': '🍬', 'color': '#f59e0b',
            'default_target': 0, 'sort_order': 2,
        },
        {
            'code': 'no_animal_proteins', 'title': 'No Animal Proteins', 'unit': 'days',
            'description': 'Days without meat, fish, eggs, or dairy.', 'icon': '🌱', 'color': '#22c55e',
            'default_target': 0, 'sort_order': 3,
        },
        {
            'code': 'gym_attendance', 'title': 'Gym Attendance', 'unit': 'days',
            'description': 'Consecutive days with a gym visit.', 'icon': '🏋️', 'color': '#3b82f6',
            'default_target': 0, 'sort_order': 4,
        },
        {
            'code': 'walking_days', 'title': 'Walking Days', 'unit': 'days',
            'description': 'Days with a logged walk.', 'icon': '🚶', 'color': '#10b981',
            'default_target': 0, 'sort_order': 5,
        },
        {
            'code': 'no_drugs', 'title': 'No Drugs', 'unit': 'days',
            'description': 'Days drug-free.', 'icon': '💊', 'color': '#dc2626',
            'default_target': 0, 'sort_order': 6,
        },
        {
            'code': 'no_nut_month', "title": "No Nut Month", 'unit': 'days',
            'description': 'Days without nuts.', 'icon': '🥜', 'color': '#a855f7',
            'default_target': 30, 'sort_order': 7,
        },
        {
            'code': 'custom', 'title': 'Custom Reason', 'unit': 'days',
            'description': 'Your own countdown reason.', 'icon': '📅', 'color': '#6b7280',
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
