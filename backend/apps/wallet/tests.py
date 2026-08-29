from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from datetime import date
from unittest.mock import patch
from common.utils import hash_dob
from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.wallet.models import ArtifactTransaction, JournalEntry, JournalLine
from apps.wallet.ledger import IdempotencyConflict, PostingLine, post_entry
from apps.wallet.utils import hold_artifacts, release_held_to_party, transfer_artifacts
from apps.wallet.flutterwave import FlutterwaveResponse
from apps.wallet.tasks import _refund_failed_withdrawal


class WalletTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='wallet@example.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.email_verified = True
        self.user.save()
        self.profile = Profile.objects.create(user=self.user, username='walletuser', display_name='Wallet User')

        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

    def test_get_balance(self):
        response = self.client.get('/api/v1/wallet/balance/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('balance', response.data['data'])
        self.assertIn('total_label', response.data['data'])

    def test_purchase_artifacts(self):
        data = {'artifact_type': 'dumbbell', 'quantity': 10, 'payment_method': 'card'}
        response = self.client.post('/api/v1/wallet/purchase/initialize/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['amount'], 1.0)
        self.assertTrue(ArtifactTransaction.objects.filter(user=self.profile, transaction_type='purchase').exists())

    def test_get_bundles(self):
        response = self.client.get('/api/v1/wallet/bundles/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsInstance(response.data['data'], list)

    def test_ledger_posting_requires_balanced_lines(self):
        with self.assertRaises(Exception):
            post_entry(
                operation='test', owner=self.profile, idempotency_key='unbalanced',
                payload={'value': 1}, lines=[
                    PostingLine('buyer', 'dumbbell', 'debit', 2, self.profile, 'regular'),
                    PostingLine('platform', 'dumbbell', 'credit', 1),
                ],
            )

    def test_transfer_is_atomic_and_idempotent(self):
        recipient_user = User.objects.create_user(email='recipient@example.com', password='TestPass123!')
        recipient = Profile.objects.create(user=recipient_user, username='recipient', display_name='Recipient')
        self.profile.artifact_balance = {'dumbbell': 10}
        self.profile.save(update_fields=['artifact_balance'])

        result = transfer_artifacts(
            self.profile, recipient, 'dumbbell', 5, operation='test_transfer',
            idempotency_key='same-request', reference_id='test-transfer', platform_fee=1,
        )
        self.assertTrue(result[1])
        replay = transfer_artifacts(
            self.profile, recipient, 'dumbbell', 5, operation='test_transfer',
            idempotency_key='same-request', reference_id='test-transfer', platform_fee=1,
        )
        self.assertFalse(replay[1])
        self.profile.refresh_from_db()
        recipient.refresh_from_db()
        self.assertEqual(self.profile.artifact_balance['dumbbell'], 5)
        self.assertEqual(recipient.artifact_balance['dumbbell'], 4)
        self.assertEqual(JournalEntry.objects.filter(operation='test_transfer').count(), 1)
        self.assertEqual(JournalLine.objects.filter(journal_entry=result[0]).count(), 3)

    def test_idempotency_key_rejects_changed_payload(self):
        lines = [
            PostingLine('buyer', 'dumbbell', 'debit', 1, self.profile, 'regular'),
            PostingLine('platform', 'dumbbell', 'credit', 1),
        ]
        post_entry(operation='test_conflict', owner=self.profile, idempotency_key='key', payload={'qty': 1}, lines=lines)
        with self.assertRaises(IdempotencyConflict):
            post_entry(operation='test_conflict', owner=self.profile, idempotency_key='key', payload={'qty': 2}, lines=lines)

    def test_escrow_hold_and_release_are_ledger_backed_and_replay_safe(self):
        recipient_user = User.objects.create_user(email='trainer@example.com', password='TestPass123!')
        recipient = Profile.objects.create(user=recipient_user, username='trainer', display_name='Trainer')
        self.profile.artifact_balance = {'dumbbell': 5}
        self.profile.save(update_fields=['artifact_balance'])

        held = hold_artifacts(self.profile, 'dumbbell', 2, recipient, 'booking-1')
        replay = hold_artifacts(self.profile, 'dumbbell', 2, recipient, 'booking-1')
        self.assertEqual(held.id, replay.id)
        self.assertTrue(release_held_to_party(
            self.profile, recipient, 'dumbbell', 2, reference_id=f'{held.id}:party',
        ))
        self.assertTrue(release_held_to_party(
            self.profile, recipient, 'dumbbell', 2, reference_id=f'{held.id}:party',
        ))
        self.profile.refresh_from_db()
        recipient.refresh_from_db()
        self.assertEqual(self.profile.locked_balance.get('dumbbell', 0), 0)
        self.assertEqual(recipient.artifact_balance['dumbbell'], 2)
        self.assertEqual(JournalEntry.objects.filter(operation='escrow_hold').count(), 1)
        self.assertEqual(JournalEntry.objects.filter(operation='escrow_release').count(), 1)


class FlutterwaveWebhookSecurityTests(TestCase):
    """The webhook must fail closed and only credit verified successful charges."""

    def setUp(self):
        from django.test import override_settings
        self.override = override_settings(FLUTTERWAVE_WEBHOOK_HASH='test-secret-hash')
        self.override.enable()
        self.addCleanup(self.override.disable)

        self.client = APIClient()
        self.user = User.objects.create_user(email='hook@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='hookuser', display_name='Hook User')
        self.tx = ArtifactTransaction.objects.create(
            user=self.profile,
            transaction_type='purchase',
            artifact_type='dumbbell',
            quantity=10,
            direction='credit',
            status='pending',
            tx_ref='BU-TEST-REF-1',
            fiat_amount=1.00,
            fiat_currency='USD',
        )
        self.url = '/api/v1/wallet/flutterwave-webhook/'
        self.payload = {
            'event': 'charge.completed',
            'data': {
                'id': 987654,
                'tx_ref': 'BU-TEST-REF-1',
                'status': 'successful',
                'amount': 1.00,
                'currency': 'USD',
            },
        }

    def _post_signed(self):
        return self.client.post(
            self.url, data=self.payload, format='json', HTTP_VERIF_HASH='test-secret-hash',
        )

    def test_rejects_when_hash_not_configured(self):
        from django.test import override_settings
        with override_settings(FLUTTERWAVE_WEBHOOK_HASH=''):
            resp = self.client.post(self.url, data=self.payload, format='json', HTTP_VERIF_HASH='')
            self.assertEqual(resp.status_code, status.HTTP_503_SERVICE_UNAVAILABLE)
        self.tx.refresh_from_db()
        self.assertEqual(self.tx.status, 'pending')

    def test_rejects_bad_signature(self):
        resp = self.client.post(self.url, data=self.payload, format='json', HTTP_VERIF_HASH='wrong')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)
        self.tx.refresh_from_db()
        self.assertEqual(self.tx.status, 'pending')

    def test_successful_charge_credits_once(self):
        balance_before = ArtifactTransaction.objects.filter(
            user=self.profile, transaction_type='purchase', status='completed',
        ).count()
        resp = self._post_signed()
        self.assertEqual(resp.status_code, 200)
        self.tx.refresh_from_db()
        self.assertEqual(self.tx.status, 'completed')
        self.assertEqual(self.tx.flutterwave_id, '987654')

        # Replay: already completed -> no double credit, no crash.
        resp2 = self._post_signed()
        self.assertEqual(resp2.status_code, 200)
        balance_after = ArtifactTransaction.objects.filter(
            user=self.profile, transaction_type='purchase', status='completed',
        ).count()
        self.assertEqual(balance_before + 1, balance_after)

    def test_ignores_unsuccessful_charge(self):
        self.payload['data']['status'] = 'failed'
        resp = self._post_signed()
        self.assertEqual(resp.status_code, 200)
        self.tx.refresh_from_db()
        self.assertEqual(self.tx.status, 'pending')

    def test_rejects_amount_mismatch(self):
        self.payload['data']['amount'] = 0.01
        resp = self._post_signed()
        self.assertEqual(resp.status_code, 400)
        self.tx.refresh_from_db()
        self.assertEqual(self.tx.status, 'pending')


class WithdrawalSafetyTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(email='payout@example.com', password='TestPass123!')
        self.user.email_verified = True
        self.user.dob_hash = hash_dob(date(1990, 1, 1))
        self.user.save()
        self.profile = Profile.objects.create(
            user=self.user,
            username='payoutuser',
            display_name='Payout User',
            verification_status='id',
            artifact_balance={'champion': 10},
        )
        self.client = APIClient()
        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

    def test_unsupported_payout_method_rejected_before_deduction(self):
        response = self.client.post('/api/v1/wallet/withdraw/', {
            'artifact_type': 'champion',
            'quantity': 1,
            'method': 'mpesa',
            'phone_number': '+254700000000',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.profile.refresh_from_db()
        self.assertEqual(self.profile.artifact_balance['champion'], 10)
        self.assertFalse(ArtifactTransaction.objects.filter(transaction_type='withdrawal').exists())

    @patch('apps.wallet.tasks.process_withdrawal.delay')
    @patch('apps.wallet.views.FlutterwaveClient')
    def test_bank_transfer_initiation_remains_pending(self, client_cls, delay):
        client = client_cls.return_value
        client.create_transfer_recipient.return_value = FlutterwaveResponse(
            success=True, status='success', message='ok',
            data={'id': 'recipient-1'}, flutterwave_ref='recipient-1',
        )
        client.initiate_transfer.return_value = FlutterwaveResponse(
            success=True, status='success', message='queued',
            data={'id': 'transfer-1', 'status': 'NEW'}, flutterwave_ref='transfer-1',
        )

        response = self.client.post('/api/v1/wallet/withdraw/', {
            'artifact_type': 'champion',
            'quantity': 1,
            'method': 'bank_transfer',
            'bank_account': '0011223344',
            'bank_code': 'KE001',
            'account_name': 'Payout User',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        tx = ArtifactTransaction.objects.get(transaction_type='withdrawal')
        self.assertEqual(tx.status, 'pending')
        self.assertEqual(tx.fiat_currency, 'KES')
        self.assertEqual(tx.payment_provider, 'flutterwave')
        self.assertEqual(tx.flutterwave_id, 'transfer-1')
        delay.assert_called_once_with(str(tx.id))

    def test_failed_withdrawal_refund_is_idempotent(self):
        tx = ArtifactTransaction.objects.create(
            user=self.profile,
            transaction_type='withdrawal',
            artifact_type='champion',
            quantity=2,
            direction='debit',
            status='pending',
            tx_ref='withdraw-test-1',
            flutterwave_response={'wallet_source': 'regular'},
        )
        self.profile.artifact_balance['champion'] = 8
        self.profile.save(update_fields=['artifact_balance'])

        self.assertTrue(_refund_failed_withdrawal(tx, 'test failure'))
        self.assertFalse(_refund_failed_withdrawal(tx, 'replayed failure'))
        self.profile.refresh_from_db()
        tx.refresh_from_db()
        self.assertEqual(self.profile.artifact_balance['champion'], 10)
        self.assertEqual(tx.status, 'failed')
        self.assertEqual(
            ArtifactTransaction.objects.filter(reference_id=f'withdrawal_refund:{tx.id}').count(),
            1,
        )
