"""FoodRecognizeView hardening.

The recognize endpoint forwards an authenticated user's upload straight to the
AI service, so it is the one marketplace surface where a request userid can
turn the serving parser into a public ingress. It must therefore pass the same
gate the messaging attachment uploads already do:

  * size ceiling before any bytes are read forward,
  * a narrow image extension allowlist,
  * magic-byte verification so the declared extension cannot be a costume,

and every rejection must happen *before* ``ai_post`` is called — no oversized
or mis-typed body ever leaves the backend container.
"""

from io import BytesIO
from unittest import mock

from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.profiles.models import Profile


PNG_BYTES = (
    b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01'
    b'\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\rIDATx\x9cc\xfc\xff\xff'
    b'?0\x03\x00\x05\xfe\x02\xfe\xf2\x0c:\xe3\x00\x00\x00\x00IEND\xaeB`\x82'
)


def make_profile(username):
    user = User.objects.create_user(email=f'{username}@example.com', password='TestPass123!')
    return Profile.objects.create(
        user=user, username=username, display_name=username.title(),
    )


class FoodRecognizeGateTests(TestCase):
    def setUp(self):
        self.profile = make_profile('food-user')
        self.client = APIClient()
        refresh = RefreshToken.for_user(self.profile.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        self.url = '/api/v1/marketplace/food-recognize/'

    def _post_file(self, name, content, content_type):
        self._forwarded = None

        def _stub_ai_post(url, *args, **kwargs):
            self._forwarded = {'url': url, 'kwargs': kwargs}
            stub = mock.MagicMock()
            stub.status_code = 200
            stub.json.return_value = {'items': []}
            stub.raise_for_status.return_value = None
            return stub

        with mock.patch('apps.marketplace.views.ai_post', side_effect=_stub_ai_post):
            uploaded = SimpleUploadedFile(name, content, content_type=content_type)
            return self.client.post(self.url, {'file': uploaded}, format='multipart')

    def test_valid_png_is_forwarded(self):
        resp = self._post_file('meal.png', PNG_BYTES, 'image/png')
        self.assertEqual(resp.status_code, 200)
        self.assertTrue(self._forwarded['url'].endswith('/api/v1/food/recognize'))
        forwarded_name, forwarded_bytes = self._forwarded['kwargs']['files']['file'][:2]
        self.assertEqual(forwarded_name, 'meal.png')
        self.assertEqual(BytesIO(forwarded_bytes).read(), PNG_BYTES)

    def test_oversized_image_is_rejected_before_forward(self):
        big = PNG_BYTES + b'\x00' * (16 * 1024 * 1024)
        resp = self._post_file('big.png', big, 'image/png')
        self.assertEqual(resp.status_code, 400)
        self.assertIsNone(self._forwarded)

    def test_non_image_content_type_is_rejected_before_forward(self):
        resp = self._post_file('notes.pdf', PNG_BYTES, 'application/pdf')
        self.assertEqual(resp.status_code, 400)
        self.assertIsNone(self._forwarded)

    def test_disallowed_extension_is_rejected(self):
        resp = self._post_file('photo.tiff', PNG_BYTES, 'image/tiff')
        self.assertEqual(resp.status_code, 400)
        self.assertIsNone(self._forwarded)

    def test_magic_byte_mismatch_is_rejected(self):
        fake = b'GIF89a' + b'\x00' * 64
        resp = self._post_file('meal.png', fake, 'image/png')
        self.assertEqual(resp.status_code, 400)
        self.assertIsNone(self._forwarded)
