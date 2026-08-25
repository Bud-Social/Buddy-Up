"""Tests for the multistep ID + selfie verification wizard."""
import io

from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.verification.models import VerificationDocument, VerificationSubmission
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
        self.base = f'/api/v1/verification/submissions'

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

    def test_manual_backend_short_circuits(self):
        from unittest import mock
        with mock.patch.dict('os.environ', {'FACE_MATCH_BACKEND': 'manual'}):
            result = run_face_match('https://example.com/id.jpg', 'https://example.com/selfie.jpg')
        self.assertEqual(result, ('manual_review', None))
