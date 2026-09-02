"""Direct-upload signing for Bud Press media (Cloudinary)."""
import re
import time

from django.conf import settings
from django.utils import timezone
from rest_framework import permissions, status, views
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle

from .media_types import IMAGE_EXTS, VIDEO_EXTS

EAGER_TRANSFORMS = {
    'video': 'vc_h264:q_auto:so_auto,w_1080,c_limit',
    'image': 'f_auto,q_auto:good,w_1440,c_limit',
}


def _sanitized_username(raw: str) -> str:
    cleaned = re.sub(r'[^A-Za-z0-9_-]', '-', raw or '').strip('-')
    return cleaned or 'user'


class CloudinarySignView(views.APIView):
    """POST /api/v1/uploads/sign/ — issue a direct-upload signature.

    Clients upload straight to Cloudinary using the returned params, keeping
    large media off the Django request path. Falls back to 503 when
    Cloudinary credentials are not configured so clients can use the legacy
    media upload path instead.
    """

    permission_classes = [permissions.IsAuthenticated]
    throttle_scope = 'uploads'
    throttle_classes = [ScopedRateThrottle]

    def _credentials(self):
        import cloudinary

        config = cloudinary.config()
        cloud_name = settings.CLOUDINARY_CLOUD_NAME or getattr(config, 'cloud_name', '') or ''
        api_key = settings.CLOUDINARY_API_KEY or getattr(config, 'api_key', '') or ''
        api_secret = settings.CLOUDINARY_API_SECRET or getattr(config, 'api_secret', '') or ''
        return cloud_name, api_key, api_secret

    def post(self, request):
        resource_type = request.data.get('resource_type')
        filename = str(request.data.get('filename') or '')
        if resource_type not in EAGER_TRANSFORMS:
            return Response({
                'success': False, 'data': None,
                'message': 'resource_type must be one of image, video.',
                'errors': {'resource_type': ['resource_type must be one of image, video.']},
                'pagination': None,
            }, status=status.HTTP_422_UNPROCESSABLE_ENTITY)

        ext = filename.rsplit('.', 1)[-1].lower() if '.' in filename else ''
        allowed_exts = IMAGE_EXTS if resource_type == 'image' else VIDEO_EXTS
        if ext not in allowed_exts:
            return Response({
                'success': False, 'data': None,
                'message': f'File extension .{ext} is not allowed for {resource_type} uploads.',
                'errors': {'filename': [f'Allowed extensions: {", ".join(allowed_exts)}.']},
                'pagination': None,
            }, status=status.HTTP_422_UNPROCESSABLE_ENTITY)

        cloud_name, api_key, api_secret = self._credentials()
        if not (cloud_name and api_key and api_secret):
            return Response({
                'success': False, 'data': None,
                'message': 'Direct upload unavailable; use legacy media upload',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        import cloudinary.utils

        username = request.user.profile.username or str(request.user.profile.user_id)
        folder = f"buddyup/posts/{_sanitized_username(username)}/{timezone.now().strftime('%Y%m')}"
        params = {
            'folder': folder,
            'timestamp': int(time.time()),
            'eager': EAGER_TRANSFORMS[resource_type],
        }
        signature = cloudinary.utils.api_sign_request(params, api_secret)
        data = {
            'cloud_name': cloud_name,
            'api_key': api_key,
            'timestamp': params['timestamp'],
            'signature': signature,
            'folder': folder,
            'resource_type': resource_type,
            'eager': params['eager'],
            'upload_url': f'https://api.cloudinary.com/v1_1/{cloud_name}/{resource_type}/upload',
        }
        return Response({
            'success': True, 'data': data,
            'message': 'Upload signature issued.', 'errors': None, 'pagination': None,
        })
