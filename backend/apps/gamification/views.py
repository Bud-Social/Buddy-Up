from rest_framework import permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from . import services


class AchievementsView(APIView):
    """List all achievement definitions with the caller's progress/state.

    Evaluation runs lazily here so achievements unlock without needing a
    signal wired into every write path.
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        period = request.query_params.get('period') or None
        if period not in (None, 'all_time', 'daily', 'weekly', 'monthly', 'quarterly', 'yearly'):
            period = None
        payload = services.profile_achievement_payload(request.user.profile, period=period)
        payload['period'] = period or 'all_time'
        return Response({
            'success': True,
            'data': payload,
            'message': 'OK',
            'errors': None,
            'pagination': {'count': len(payload['items'])},
        })

    def post(self, request):
        """Force re-evaluation; returns newly earned achievements."""
        earned = services.evaluate_profile(request.user.profile)
        from .serializers import UserAchievementSerializer
        return Response({
            'success': True,
            'data': {
                'newly_earned': UserAchievementSerializer(earned, many=True).data,
            },
            'message': 'Evaluated.',
            'errors': None,
            'pagination': None,
        })
