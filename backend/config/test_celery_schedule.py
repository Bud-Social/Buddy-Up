"""The effective beat schedule must merge settings entries with config/celery.py.

config/celery.py used to *replace* settings.CELERY_BEAT_SCHEDULE, silently
dropping production jobs such as wallet-provider reconciliation and
verification-document purge. These tests pin the merged behaviour.
"""
from django.conf import settings
from django.test import TestCase

from config.celery import CELERY_BEAT_SCHEDULE, app


class BeatScheduleMergeTests(TestCase):
    def test_settings_entries_survive_merge(self):
        schedule = app.conf.beat_schedule
        # Verify the exact keys still exist in settings before pinning them.
        self.assertTrue(
            {'wallet-provider-reconciliation', 'verification-document-retention'}
            <= set(getattr(settings, 'CELERY_BEAT_SCHEDULE', {})),
        )
        self.assertIn('wallet-provider-reconciliation', schedule)
        self.assertEqual(
            schedule['wallet-provider-reconciliation']['task'],
            'apps.wallet.tasks.reconcile_flutterwave_transactions',
        )
        self.assertIn('verification-document-retention', schedule)
        self.assertEqual(
            schedule['verification-document-retention']['task'],
            'apps.verification.tasks.purge_expired_verification_documents',
        )

    def test_celery_module_entries_present(self):
        schedule = app.conf.beat_schedule
        self.assertIn('generate-feed-cache', schedule)
        self.assertIn('scan-random-drop-pool', schedule)
        self.assertIn('process-pending-withdrawals', schedule)

    def test_module_entries_take_precedence_and_nothing_else_changes(self):
        expected = {
            **getattr(settings, 'CELERY_BEAT_SCHEDULE', {}),
            **CELERY_BEAT_SCHEDULE,
        }
        self.assertEqual(app.conf.beat_schedule, expected)
