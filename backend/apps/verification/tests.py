"""Tests for the multistep ID + selfie verification wizard."""

from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase, override_settings
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.verification.models import VerificationDocument, VerificationDocumentAccess
from apps.verification.tasks import purge_expired_verification_documents
from .services import run_face_match


def _make_user(email):
    user = User.objects.create_user(email=email, password='TestPass123!')
    user.dob_hash = 'x' * 64
    user.is_adult = True
    user.email_verified = True
    user.save()
    return Profile.objects.create(user=user, username=email.split('@')[0], display_name='Tester')


def _jpeg(name='test.jpg'):
    # Minimal valid-ish JPEG bytes (Pillow not needed — storage only).
    return SimpleUploadedFile(name, b'\xff\xd8\xff\xe0FAKEJPEGDATA', content_type='image/jpeg')


class IdWizardFlowTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.profile = _make_user('wizard@test.com')
        refresh = RefreshToken.for_user(self.profile.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        self.base = '/api/v1/verification/submissions'

    def _create_draft(self):
        res = self.client.post(f'{self.base}/', {'verification_type': 'id'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        # ViewSet responses are unwrapped (no {success, data} envelope).
        return res.json()

    def test_create_starts_at_id_document_step(self):
        data = self._create_draft()
        self.assertEqual(data['current_step'], 'id_document')
        self.assertEqual(data['completed_steps'], [])
        self.assertEqual(data['face_match_status'], 'pending')

    def test_full_multistep_flow(self):
        data = self._create_draft()
        sid = data['id']

        # Step 1: ID document
        res = self.client.post(
            f'{self.base}/{sid}/upload_step/',
            {'step': 'id_document', 'document_type': 'passport', 'file': _jpeg()},
            format='multipart',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        body = res.json()
        self.assertEqual(body['current_step'], 'selfie_liveness')
        self.assertIn('id_document', body['completed_steps'])

        # Out-of-order step rejected while on selfie step
        res = self.client.post(
            f'{self.base}/{sid}/upload_step/',
            {'step': 'id_document', 'file': _jpeg()}, format='multipart',
        )
        self.assertEqual(res.status_code, status.HTTP_409_CONFLICT)

        # Step 2: selfie (face match falls back to manual_review without AWS creds)
        res = self.client.post(
            f'{self.base}/{sid}/upload_step/',
            {'step': 'selfie_liveness', 'file': _jpeg('selfie.jpg')},
            format='multipart',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        body = res.json()
        self.assertEqual(body['current_step'], 'review')
        self.assertIn('selfie_liveness', body['completed_steps'])
        self.assertIn('face_match', body['completed_steps'])
        self.assertEqual(
            VerificationDocument.objects.filter(profile=self.profile).count(), 2,
        )

        # Submit succeeds with all required steps complete
        res = self.client.post(f'{self.base}/{sid}/submit/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        body = res.json()
        self.assertEqual(body['status'], 'submitted')
        self.assertEqual(body['current_step'], 'done')

    def test_submit_blocked_without_required_steps(self):
        data = self._create_draft()
        sid = data['id']
        res = self.client.post(
            f'{self.base}/{sid}/upload_step/',
            {'step': 'id_document', 'file': _jpeg()}, format='multipart',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        res = self.client.post(f'{self.base}/{sid}/submit/')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('missing steps', res.json()['detail'])

    def test_start_resets_wizard_state(self):
        data = self._create_draft()
        sid = data['id']
        self.client.post(
            f'{self.base}/{sid}/upload_step/',
            {'step': 'id_document', 'file': _jpeg()}, format='multipart',
        )
        res = self.client.post(f'{self.base}/{sid}/start/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        body = res.json()
        self.assertEqual(body['current_step'], 'id_document')
        self.assertEqual(body['completed_steps'], [])

    def test_non_id_type_has_no_wizard(self):
        res = self.client.post(f'{self.base}/', {'verification_type': 'trainer'}, format='json')
        data = res.json()
        self.assertEqual(data['current_step'], '')
        res = self.client.post(f'{self.base}/{data["id"]}/start/')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class FaceMatchServiceTests(TestCase):
    def test_manual_fallback_when_no_aws(self):
        from unittest import mock
        with mock.patch.dict('os.environ', {
            'FACE_MATCH_BACKEND': 'auto',
            'AWS_ACCESS_KEY_ID': '',
            'AWS_SECRET_ACCESS_KEY': '',
        }):
            result = run_face_match('https://example.com/id.jpg', 'https://example.com/selfie.jpg')
        self.assertEqual(result, ('manual_review', None))


class VerificationRetentionTests(TestCase):
    def setUp(self):
        self.profile = _make_user('retention@test.com')
        self.client = APIClient()
        self.client.force_authenticate(self.profile.user)

    def test_document_retrieve_is_audited(self):
        doc = VerificationDocument.objects.create(
            profile=self.profile,
            document_type='id_card',
            file_url='https://example.com/id.jpg',
        )
        response = self.client.get(
            f'/api/v1/verification/documents/{doc.id}/?purpose=verify+identity',
            HTTP_X_REQUEST_ID='audit-request-1',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        event = VerificationDocumentAccess.objects.get(document=doc)
        self.assertEqual(event.actor, self.profile.user)
        self.assertEqual(event.purpose, 'verify identity')
        self.assertEqual(event.request_id, 'audit-request-1')

    def test_signed_document_access_is_short_lived_and_audited(self):
        doc = VerificationDocument.objects.create(
            profile=self.profile, document_type='id_card', file_url='https://example.com/private/id.jpg',
        )
        grant = self.client.post(f'/api/v1/verification/documents/{doc.id}/access/')
        self.assertEqual(grant.status_code, status.HTTP_200_OK)
        access = self.client.get(f'/api/v1/verification/documents/{doc.id}/access/?token={grant.data["token"]}')
        self.assertEqual(access.status_code, status.HTTP_200_OK)
        self.assertEqual(access.data['file_url'], doc.file_url)
        self.assertEqual(VerificationDocumentAccess.objects.filter(document=doc).count(), 1)

    @override_settings(DEFAULT_FILE_STORAGE='django.core.files.storage.FileSystemStorage')
    def test_expired_document_file_is_purged_but_metadata_remains(self):
        doc = VerificationDocument.objects.create(
            profile=self.profile,
            document_type='selfie',
            file_url='https://cdn.example.com/private/selfie.jpg',
            purge_after=timezone.now() - timezone.timedelta(minutes=1),
        )
        count = purge_expired_verification_documents.run()
        self.assertEqual(count, 1)
        doc.refresh_from_db()
        self.assertEqual(doc.file_url, '')
        self.assertIsNotNone(doc.purged_at)

    def test_manual_backend_short_circuits(self):
        from unittest import mock
        with mock.patch.dict('os.environ', {'FACE_MATCH_BACKEND': 'manual'}):
            result = run_face_match('https://example.com/id.jpg', 'https://example.com/selfie.jpg')
        self.assertEqual(result, ('manual_review', None))


class VerificationDocumentDeliveryTests(TestCase):
    """KYC uploads are stored under server-generated names and served only
    through the access-audited retrieve endpoint."""

    def setUp(self):
        self.profile = _make_user('delivery@test.com')
        self.client = APIClient()
        refresh = RefreshToken.for_user(self.profile.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        self.base = '/api/v1/verification/submissions'

    def _create_draft(self):
        res = self.client.post(f'{self.base}/', {'verification_type': 'id'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        return res.json()['id']

    def test_upload_uses_server_generated_filename(self):
        sid = self._create_draft()
        upload = SimpleUploadedFile(
            'my passport scan FINAL v2.JPG', b'\xff\xd8\xff\xe0FAKEJPEGDATA', content_type='image/jpeg',
        )
        res = self.client.post(
            f'{self.base}/{sid}/upload_step/',
            {'step': 'id_document', 'document_type': 'passport', 'file': upload},
            format='multipart',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)

        doc = VerificationDocument.objects.get(profile=self.profile)
        self.assertFalse(doc.file_url.startswith(('http://', 'https://')))
        stored_name = doc.file_url.rsplit('/', 1)[-1]
        self.assertRegex(stored_name, r'^[0-9a-f]{32}\.jpg$')
        self.assertNotIn('my passport', doc.file_url)

        # The serializer must not expose a directly fetchable URL — point at
        # the audited endpoint instead.
        self.assertEqual(
            res.json()['uploaded_document']['file_url'],
            f'/api/v1/verification/documents/{doc.id}/',
        )

    def test_retrieve_streams_internal_file_and_records_access(self):
        from django.core.files.base import ContentFile
        from django.core.files.storage import default_storage
        saved = default_storage.save(
            f'verification/stream-test/{__import__("uuid").uuid4().hex}.jpg',
            ContentFile(b'SECRET-ID-BYTES'),
        )
        doc = VerificationDocument.objects.create(
            profile=self.profile, document_type='id_card', file_url=saved,
        )
        response = self.client.get(
            f'/api/v1/verification/documents/{doc.id}/?purpose=review',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(
            b'SECRET-ID-BYTES' in b''.join(response.streaming_content),
        )
        self.assertTrue(
            VerificationDocumentAccess.objects.filter(document=doc, actor=self.profile.user).exists(),
        )

    def test_retrieve_requires_authentication(self):
        doc = VerificationDocument.objects.create(
            profile=self.profile, document_type='id_card', file_url='verification/x.jpg',
        )
        anonymous = APIClient()
        response = anonymous.get(f'/api/v1/verification/documents/{doc.id}/')
        self.assertIn(response.status_code, (
            status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN,
        ))

    def test_legacy_external_url_still_returned(self):
        doc = VerificationDocument.objects.create(
            profile=self.profile, document_type='id_card',
            file_url='https://legacy-cdn.example.com/id.jpg',
        )
        response = self.client.get(f'/api/v1/verification/documents/{doc.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['file_url'], 'https://legacy-cdn.example.com/id.jpg')
