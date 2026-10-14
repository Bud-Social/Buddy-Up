"""Tests for the multistep ID + selfie verification wizard."""

from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase, override_settings
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.verification.models import (
    VerificationDocument, VerificationDocumentAccess, VerificationSubmission,
)
from apps.verification.tasks import purge_expired_verification_documents
from .services import run_face_match


def _make_user(email):
    user = User.objects.create_user(email=email, password='TestPass123!')
    user.dob_hash = 'x' * 64
    user.is_adult = True
    user.email_verified = True
    user.save()
    return Profile.objects.create(user=user, username=email.split('@')[0], display_name='Tester')


def _make_staff(email, scopes=None):
    """A staff member with an authenticated API client.

    ``scopes=None`` means no ``StaffRole`` row, which
    ``apps.governance.services.effective_scopes`` treats as holding every scope
    (the documented back-compat branch). That mirrors the live deployment's one
    staff account, and keeps these tests about separation of duties rather than
    about scope configuration.

    Pass ``scopes`` to create a *narrow* role, for the tests that need an
    approver who lacks ``shops.certifications``.
    """
    from apps.governance.models import StaffRole

    user = User.objects.create_user(email=email, password='TestPass123!')
    user.dob_hash = 'x' * 64
    user.is_adult = True
    user.is_staff = True
    user.save()
    if scopes is not None:
        StaffRole.objects.create(user=user, role='support', scopes=list(scopes))
    client = APIClient()
    refresh = RefreshToken.for_user(user)
    client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
    return client


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


class GymVerificationLinkTests(TestCase):
    """A gym is only verified once a *second* member of staff has approved."""

    def setUp(self):
        from apps.gyms.models import Gym
        self.gym = Gym.objects.create(
            name='Linked Gym', handle='linked-gym', category='fitness',
            access_type='public',
        )
        self.profile = _make_user('gymfounder@test.com')
        self.client = APIClient()
        refresh = RefreshToken.for_user(self.profile.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

        staff_user = User.objects.create_user(email='staff@test.com', password='TestPass123!')
        staff_user.is_staff = True
        staff_user.save()
        self.staff = APIClient()
        staff_refresh = RefreshToken.for_user(staff_user)
        self.staff.credentials(HTTP_AUTHORIZATION=f'Bearer {staff_refresh.access_token}')
        self.base = '/api/v1/verification/submissions'

    def _create_gym_submission(self):
        res = self.client.post(self.base + '/', {
            'verification_type': 'gym',
            'gym_handle': 'linked-gym',
            'credential_title': 'Business Registration',
            'credential_issuer': 'BRS Kenya',
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        sid = res.json()['id']
        # The viewset creates drafts; a decision can only be requested on a
        # submitted application.
        self.assertEqual(
            self.client.post(f'{self.base}/{sid}/submit/').status_code, status.HTTP_200_OK,
        )
        return sid

    def test_gym_is_verified_only_after_a_second_approver(self):
        sid = self._create_gym_submission()

        # First approver only raises the request; nothing is verified yet.
        res = self.staff.post(f'{self.base}/{sid}/review/', {'action': 'approve'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_202_ACCEPTED)
        self.gym.refresh_from_db()
        self.profile.refresh_from_db()
        self.assertFalse(self.gym.is_verified)
        self.assertEqual(self.profile.verification_status, 'none')

        # A second, different member of staff settles it.
        second = _make_staff('staff2@test.com')
        res = second.post(f'{self.base}/{sid}/decide/', {'action': 'approve'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.json())

        self.gym.refresh_from_db()
        self.profile.refresh_from_db()
        self.assertTrue(self.gym.is_verified)
        self.assertEqual(self.profile.verification_status, 'gym')

    def test_unknown_gym_handle_rejected(self):
        res = self.client.post(self.base + '/', {
            'verification_type': 'gym',
            'gym_handle': 'no-such-gym',
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


# ---------------------------------------------------------------------------
# Self-declared role / corrected permissions
# ---------------------------------------------------------------------------

class SelfDeclaredRoleRegistrationTests(TestCase):
    """Registration cannot grant a professional role."""

    def setUp(self):
        self.client = APIClient()
        self.url = '/api/v1/auth/register/'

    def _payload(self, **overrides):
        return {
            'email': 'newbie@example.com',
            'password': 'TestPass123!',
            'dob': '2000-06-15',
            'username': 'newbie',
            'display_name': 'New Bie',
            'accepted_terms': True,
            'accepted_privacy': True,
            'accepted_guidelines': True,
            'is_16_plus': True,
            **overrides,
        }

    def test_registering_with_elevated_role_is_rejected(self):
        for role in ('trainer', 'practitioner'):
            with self.subTest(role=role):
                response = self.client.post(
                    self.url, self._payload(email=f'{role}@example.com', role=role), format='json',
                )
                self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertIn('role', response.data['errors'])
                # The message must name the real path, not just refuse.
                self.assertIn(
                    '/api/v1/verification/category-applications/',
                    str(response.data['errors']['role']),
                )

    def test_rejected_registration_creates_no_profile_and_stays_user(self):
        response = self.client.post(
            self.url, self._payload(role='trainer'), format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(User.objects.filter(email='newbie@example.com').exists())
        self.assertFalse(Profile.objects.filter(username='newbie').exists())

    def test_omitted_and_explicit_user_roles_are_accepted(self):
        for overrides in ({}, {'role': 'user'}):
            with self.subTest(overrides=overrides):
                email = f"ok{len(overrides)}@example.com"
                payload = self._payload(email=email, username=f"ok{len(overrides)}", **overrides)
                response = self.client.post(self.url, payload, format='json')
                self.assertEqual(response.status_code, status.HTTP_201_CREATED)
                profile = Profile.objects.get(username=payload['username'])
                self.assertEqual(profile.role, 'user')
                self.assertFalse(profile.is_verified_role())


class CorrectedPermissionTests(TestCase):
    """``common.permissions`` checked role only; these check both halves."""

    def setUp(self):
        from apps.verification.permissions import IsVerifiedPractitioner, IsVerifiedTrainer
        self.trainer_perm = IsVerifiedTrainer
        self.practitioner_perm = IsVerifiedPractitioner
        self.profile = _make_user('permcheck@test.com')

    def _allows(self, permission_class, user):
        request = type('R', (), {'user': user})()
        return permission_class().has_permission(request, None)

    def test_unverified_trainer_is_refused(self):
        # role claimed, verification never granted — the exact hole.
        self.profile.role = 'trainer'
        self.profile.verification_status = 'none'
        self.profile.save()
        self.assertFalse(self.profile.is_verified_role())
        self.assertFalse(self._allows(self.trainer_perm, self.profile.user))

    def test_verified_trainer_is_allowed(self):
        self.profile.role = 'trainer'
        self.profile.verification_status = 'trainer'
        self.profile.save()
        self.assertTrue(self.profile.is_verified_role())
        self.assertTrue(self._allows(self.trainer_perm, self.profile.user))

    def test_verification_alone_without_role_is_not_enough(self):
        self.profile.role = 'user'
        self.profile.verification_status = 'trainer'
        self.profile.save()
        self.assertFalse(self.profile.is_verified_role())
        self.assertFalse(self._allows(self.trainer_perm, self.profile.user))

    def test_practitioner_permission_needs_practitioner_verification(self):
        self.profile.role = 'practitioner'
        self.profile.verification_status = 'trainer'
        self.profile.save()
        self.assertFalse(self._allows(self.practitioner_perm, self.profile.user))

        self.profile.verification_status = 'practitioner'
        self.profile.save()
        self.assertTrue(self._allows(self.practitioner_perm, self.profile.user))

    def test_anonymous_and_profileless_users_are_refused_not_crashed(self):
        from django.contrib.auth.models import AnonymousUser

        self.assertFalse(self._allows(self.trainer_perm, AnonymousUser()))

        # createsuperuser has no Profile row; the descriptor raises.
        superuser = User.objects.create_superuser(
            email='root@example.com', password='TestPass123!',
        )
        self.assertFalse(self._allows(self.trainer_perm, superuser))

    def test_legacy_common_permission_classes_would_have_allowed_these(self):
        """Pins *why* the corrected classes exist."""
        from common.permissions import IsVerifiedTrainer as LegacyTrainer

        self.profile.role = 'trainer'
        self.profile.verification_status = 'none'
        self.profile.save()

        request = type('R', (), {'user': self.profile.user})()
        self.assertTrue(LegacyTrainer().has_permission(request, None))
        self.assertFalse(self._allows(self.trainer_perm, self.profile.user))


# ---------------------------------------------------------------------------
# Category applications
# ---------------------------------------------------------------------------

class CategoryApplicationTests(TestCase):
    """Applying for an elevated role: validate up front, produce a submission."""

    def setUp(self):
        from apps.gyms.models import Gym

        self.gym = Gym.objects.create(
            name='Apply Gym', handle='apply-gym', category='fitness', access_type='public',
        )
        self.profile = _make_user('applicant@test.com')
        self.client = APIClient()
        self.client.force_authenticate(self.profile.user)
        self.url = '/api/v1/verification/category-applications/'
        self.document = VerificationDocument.objects.create(
            profile=self.profile, document_type='certification',
            file_url='verification/cert.jpg',
        )

    def _payload(self, **overrides):
        return {
            'category': 'trainer',
            'credential_title': 'NASM CPT',
            'credential_issuer': 'National Academy of Sports Medicine',
            'credential_id': 'CPT-12345',
            'issued_date': '2023-04-01',
            'scope_of_practice': 'general_fitness',
            'document_ids': [str(self.document.id)],
            **overrides,
        }

    def test_new_categories_are_offered(self):
        for category in ('trainer', 'practitioner', 'shop_owner', 'delivery_partner'):
            with self.subTest(category=category):
                response = self.client.post(self.url, self._payload(category=category), format='json')
                self.assertEqual(response.status_code, status.HTTP_201_CREATED, response.data)

        # gym_owner is offered too, but additionally has to name its gym.
        response = self.client.post(
            self.url, self._payload(category='gym_owner', gym_handle='apply-gym'), format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED, response.data)

    def test_application_is_created_submitted_with_no_reviewer(self):
        response = self.client.post(self.url, self._payload(), format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED, response.data)

        submission = VerificationSubmission.objects.get(pk=response.data['id'])
        self.assertEqual(submission.status, 'submitted')
        self.assertEqual(submission.verification_type, 'trainer')
        self.assertIsNotNone(submission.submitted_at)
        # Applying grants nothing on its own.
        self.assertIsNone(submission.reviewed_by)
        self.profile.refresh_from_db()
        self.assertEqual(self.profile.role, 'user')
        self.assertEqual(self.profile.verification_status, 'none')

    def test_incomplete_application_is_rejected_up_front(self):
        response = self.client.post(self.url, {
            'category': 'trainer',
            'credential_title': 'NASM CPT',
            # credential_id, issued_date, scope_of_practice all missing
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        errors = response.data['errors']
        self.assertIn('credential_id', errors)
        self.assertIn('issued_date', errors)
        self.assertIn('scope_of_practice', errors)
        self.assertFalse(VerificationSubmission.objects.exists())

    def test_application_without_evidence_is_rejected(self):
        response = self.client.post(
            self.url, self._payload(document_ids=[]), format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('document_ids', response.data['errors'])

    def test_cannot_cite_another_persons_document(self):
        other = _make_user('other@test.com')
        foreign = VerificationDocument.objects.create(
            profile=other, document_type='certification', file_url='verification/other.jpg',
        )
        response = self.client.post(
            self.url, self._payload(document_ids=[str(foreign.id)]), format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('document_ids', response.data['errors'])

    def test_gym_owner_application_must_name_a_gym(self):
        missing = self.client.post(
            self.url, self._payload(category='gym_owner'), format='json',
        )
        self.assertEqual(missing.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('gym_handle', missing.data['errors'])

        ok = self.client.post(
            self.url,
            self._payload(category='gym_owner', gym_handle='apply-gym', issued_date=None,
                          scope_of_practice=''),
            format='json',
        )
        self.assertEqual(ok.status_code, status.HTTP_201_CREATED, ok.data)
        self.assertEqual(VerificationSubmission.objects.get(pk=ok.data['id']).gym_id, self.gym.id)

    def test_identity_and_business_types_are_not_category_applications(self):
        """`id`, `shop` and `gym` belong to the other flow, not this queue."""
        for category in ('id', 'shop', 'gym'):
            with self.subTest(category=category):
                response = self.client.post(
                    self.url, self._payload(category=category), format='json',
                )
                self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertIn('category', response.data['errors'])

    def test_application_requires_authentication(self):
        anonymous = APIClient()
        self.assertEqual(
            anonymous.post(self.url, self._payload(), format='json').status_code,
            status.HTTP_401_UNAUTHORIZED,
        )


class MyApplicationsTests(TestCase):
    """"my applications" reflects pending then decided, with the reviewer's note."""

    def setUp(self):
        self.profile = _make_user('mine@test.com')
        self.client = APIClient()
        self.client.force_authenticate(self.profile.user)
        self.url = '/api/v1/verification/my-applications/'
        self.document = VerificationDocument.objects.create(
            profile=self.profile, document_type='certification',
            file_url='verification/mine.jpg',
        )
        self.submission = self._apply()

    def _apply(self, category='trainer'):
        return self.client.post('/api/v1/verification/category-applications/', {
            'category': category,
            'credential_title': 'NASM CPT',
            'credential_issuer': 'NASM',
            'credential_id': 'CPT-999',
            'issued_date': '2023-04-01',
            'scope_of_practice': 'general_fitness',
            'document_ids': [str(self.document.id)],
        }, format='json').json()

    def test_lists_the_applicants_own_application_as_pending(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        body = response.data
        self.assertEqual(body['count'], 1)

        row = body['results'][0]
        self.assertEqual(row['status'], 'submitted')
        # No approval raised yet, so nothing to show but nothing false either.
        self.assertIsNone(row['approval_state'])
        self.assertIsNone(row['pending_approval'])

    def test_pending_then_decided_state_with_reviewer_note(self):
        base = '/api/v1/verification/submissions'
        sid = self.submission['id']

        first = _make_staff('reviewer-a@test.com')
        second = _make_staff('reviewer-b@test.com')

        res = first.post(
            f'{base}/{sid}/review/',
            {'action': 'reject', 'rejection_reason': 'Pending check with NASM.'},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_202_ACCEPTED, res.json())

        # Pending: the applicant sees that a decision is in flight.
        row = self.client.get(self.url).data['results'][0]
        self.assertEqual(row['status'], 'under_review')
        self.assertEqual(row['pending_approval']['status'], 'pending')
        self.assertEqual(row['pending_approval']['decision'], 'reject')
        self.assertEqual(row['pending_approval']['required_scope'], 'shops.certifications')

        # Decided: the note is surfaced.
        res = second.post(
            f'{base}/{sid}/decide/',
            {'action': 'reject', 'note': 'Certification number does not resolve at NASM.'},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.json())

        row = self.client.get(self.url).data['results'][0]
        self.assertEqual(row['status'], 'rejected')
        self.assertIsNone(row['pending_approval'])
        state = row['approval_state']
        self.assertEqual(state['status'], 'rejected')
        self.assertEqual(state['decision_note'], 'Certification number does not resolve at NASM.')
        self.assertEqual(state['decided_by'], 'reviewer-b@test.com')
        self.assertIsNotNone(state['applied_at'])

    def test_a_user_only_sees_their_own_applications(self):
        other = _make_user('notmine@test.com')
        other_client = APIClient()
        other_client.force_authenticate(other.user)
        self.assertEqual(other_client.get(self.url).data['count'], 0)

    def test_staff_get_their_own_applications_here_not_the_queue(self):
        staff = _make_staff('staffer@test.com')
        staff_client = APIClient()
        refresh = RefreshToken.for_user(User.objects.get(email='staffer@test.com'))
        staff_client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        self.assertEqual(staff_client.get(self.url).data['count'], 0)

    def test_unknown_category_filter_is_rejected(self):
        response = self.client.get(f'{self.url}?category=wizard')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


# ---------------------------------------------------------------------------
# Two-person decisions
# ---------------------------------------------------------------------------

class TwoPersonVerificationDecisionTests(TestCase):
    """Approve/reject routes through governance; nothing applies before the second."""

    def setUp(self):
        self.profile = _make_user('decision@test.com')
        self.applicant = APIClient()
        self.applicant.force_authenticate(self.profile.user)
        self.base = '/api/v1/verification/submissions'

        self.document = VerificationDocument.objects.create(
            profile=self.profile, document_type='certification',
            file_url='verification/decision.jpg',
        )
        self.submission_id = self.applicant.post(
            '/api/v1/verification/category-applications/', {
                'category': 'trainer',
                'credential_title': 'NASM CPT',
                'credential_issuer': 'NASM',
                'credential_id': 'CPT-4242',
                'issued_date': '2023-04-01',
                'scope_of_practice': 'general_fitness',
                'document_ids': [str(self.document.id)],
            }, format='json',
        ).json()['id']

        self.reviewer_a = _make_staff('approver-a@test.com')
        self.reviewer_b = _make_staff('approver-b@test.com')

    def _submission(self):
        return VerificationSubmission.objects.get(pk=self.submission_id)

    def test_decision_creates_a_pending_approval_and_changes_nothing(self):
        from apps.governance.models import AccountActionRequest

        response = self.reviewer_a.post(
            f'{self.base}/{self.submission_id}/review/', {'action': 'approve'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED, response.json())

        # A real governance request, visible in the approvals queue.
        approval = AccountActionRequest.objects.get()
        self.assertEqual(approval.action, 'verification_decision')
        self.assertEqual(approval.status, 'pending')
        self.assertIsNone(approval.decided_by)
        self.assertIsNone(approval.applied_at)
        self.assertTrue(approval.requires_second)
        self.assertEqual(approval.target_user_id, self.profile.user_id)
        self.assertEqual(approval.payload['submission_id'], self.submission_id)
        self.assertEqual(approval.payload['decision'], 'approve')

        # Nothing applied.
        submission = self._submission()
        self.profile.refresh_from_db()
        self.document.refresh_from_db()
        self.assertEqual(submission.status, 'under_review')
        self.assertIsNone(submission.reviewed_by)
        self.assertIsNone(submission.reviewed_at)
        self.assertNotEqual(self.profile.verification_status, 'trainer')
        self.assertEqual(self.profile.role, 'user')
        self.assertFalse(self.profile.is_verified_role())
        self.assertEqual(self.document.status, 'pending')

    def test_requester_cannot_approve_their_own_request(self):
        self.reviewer_a.post(
            f'{self.base}/{self.submission_id}/review/', {'action': 'approve'}, format='json',
        )
        response = self.reviewer_a.post(
            f'{self.base}/{self.submission_id}/decide/', {'action': 'approve'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

        from apps.governance.models import AccountActionRequest
        approval = AccountActionRequest.objects.get()
        self.assertEqual(approval.status, 'pending')
        self.assertIsNone(approval.applied_at)
        self.profile.refresh_from_db()
        self.assertEqual(self.profile.verification_status, 'none')

    def test_second_different_approver_applies_the_decision_once(self):
        self.reviewer_a.post(
            f'{self.base}/{self.submission_id}/review/', {'action': 'approve'}, format='json',
        )
        response = self.reviewer_b.post(
            f'{self.base}/{self.submission_id}/decide/', {'action': 'approve'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.json())

        self.profile.refresh_from_db()
        submission = self._submission()
        self.assertEqual(self.profile.verification_status, 'trainer')
        # The role half of the pair: approval is the only thing that can set it now.
        self.assertEqual(self.profile.role, 'trainer')
        self.assertTrue(self.profile.is_verified_role())
        self.assertEqual(submission.status, 'approved')
        self.assertEqual(submission.reviewed_by, User.objects.get(email='approver-b@test.com'))

        from apps.governance.models import AccountActionRequest
        approval = AccountActionRequest.objects.get()
        self.assertEqual(approval.status, 'approved')
        self.assertIsNotNone(approval.applied_at)

    def test_effect_cannot_be_applied_a_second_time(self):
        self.reviewer_a.post(
            f'{self.base}/{self.submission_id}/review/', {'action': 'approve'}, format='json',
        )
        self.reviewer_b.post(
            f'{self.base}/{self.submission_id}/decide/', {'action': 'approve'}, format='json',
        )

        third = _make_staff('approver-c@test.com')
        response = third.post(
            f'{self.base}/{self.submission_id}/decide/', {'action': 'approve'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_409_CONFLICT)

        from apps.governance.models import AccountActionRequest
        self.assertEqual(AccountActionRequest.objects.get().status, 'approved')

    def test_duplicate_review_requests_are_refused(self):
        self.reviewer_a.post(
            f'{self.base}/{self.submission_id}/review/', {'action': 'approve'}, format='json',
        )
        response = self.reviewer_b.post(
            f'{self.base}/{self.submission_id}/review/', {'action': 'approve'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_409_CONFLICT)

    def test_applicant_reviewing_their_own_submission_is_refused(self):
        """A staff member cannot review their own application."""
        self.profile.user.is_staff = True
        self.profile.user.save()

        response = self.applicant.post(
            f'{self.base}/{self.submission_id}/review/', {'action': 'approve'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

        from apps.governance.models import AccountActionRequest
        self.assertFalse(AccountActionRequest.objects.exists())

    def test_rejection_requires_a_note_at_both_steps(self):
        # Raising a rejection with no reason.
        no_reason = self.reviewer_a.post(
            f'{self.base}/{self.submission_id}/review/', {'action': 'reject'}, format='json',
        )
        self.assertEqual(no_reason.status_code, status.HTTP_400_BAD_REQUEST)

        self.reviewer_a.post(
            f'{self.base}/{self.submission_id}/review/',
            {'action': 'reject', 'rejection_reason': 'Unreadable scan.'}, format='json',
        )
        # Settling a rejection with no note.
        no_note = self.reviewer_b.post(
            f'{self.base}/{self.submission_id}/decide/', {'action': 'reject'}, format='json',
        )
        self.assertEqual(no_note.status_code, status.HTTP_400_BAD_REQUEST)

        self.profile.refresh_from_db()
        self.assertEqual(self.profile.verification_status, 'none')
        self.assertEqual(self.profile.role, 'user')

    def test_rejection_leaves_the_profile_alone(self):
        self.reviewer_a.post(
            f'{self.base}/{self.submission_id}/review/',
            {'action': 'reject', 'rejection_reason': 'Unreadable scan.'}, format='json',
        )
        response = self.reviewer_b.post(
            f'{self.base}/{self.submission_id}/decide/',
            {'action': 'reject', 'note': 'Send a clearer scan.'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.json())

        submission = self._submission()
        self.profile.refresh_from_db()
        self.assertEqual(submission.status, 'rejected')
        self.assertEqual(self.profile.verification_status, 'none')
        self.assertEqual(self.profile.role, 'user')
        self.assertFalse(self.profile.is_verified_role())

    def test_approver_without_the_certification_scope_is_refused(self):
        narrow = _make_staff('narrow@test.com', scopes=[])
        # A 'support' StaffRole row exists, so this user no longer gets the
        # back-compat all-scopes branch.
        from apps.governance.services import has_scope
        self.assertFalse(has_scope(User.objects.get(email='narrow@test.com'),
                                   'shops.certifications'))

        self.reviewer_a.post(
            f'{self.base}/{self.submission_id}/review/', {'action': 'approve'}, format='json',
        )
        response = narrow.post(
            f'{self.base}/{self.submission_id}/decide/', {'action': 'approve'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.profile.refresh_from_db()
        self.assertEqual(self.profile.verification_status, 'none')

    def test_decide_without_a_request_is_not_found(self):
        response = self.reviewer_b.post(
            f'{self.base}/{self.submission_id}/decide/', {'action': 'approve'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_pending_approval_is_visible_on_the_review_queue(self):
        self.reviewer_a.post(
            f'{self.base}/{self.submission_id}/review/', {'action': 'approve'}, format='json',
        )
        response = self.reviewer_b.get(self.base + '/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        row = next(
            r for r in response.json()['results'] if r['id'] == self.submission_id
        )
        self.assertIsNotNone(row['pending_approval'])
        self.assertEqual(row['pending_approval']['status'], 'pending')
        self.assertTrue(row['pending_approval']['requested_by_profile'])

        # Once decided, it is no longer "pending" — the reviewer is not misled.
        self.reviewer_b.post(
            f'{self.base}/{self.submission_id}/decide/', {'action': 'approve'}, format='json',
        )
        response = self.reviewer_b.get(self.base + '/')
        row = next(
            r for r in response.json()['results'] if r['id'] == self.submission_id
        )
        self.assertIsNone(row['pending_approval'])
        self.assertEqual(row['approval_state']['status'], 'approved')

    def test_non_staff_cannot_review_or_decide(self):
        response = self.applicant.post(
            f'{self.base}/{self.submission_id}/review/', {'action': 'approve'}, format='json',
        )
        self.assertIn(response.status_code, (
            status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN,
        ))
