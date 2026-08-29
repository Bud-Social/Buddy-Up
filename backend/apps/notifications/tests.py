from datetime import datetime, time, timezone
from unittest.mock import patch

from django.test import SimpleTestCase
from .tasks import _quiet_hours


class NotificationPolicyTests(SimpleTestCase):
    def test_quiet_hours_uses_preference_timezone(self):
        prefs = type('Prefs', (), {'quiet_hours_start': time(22), 'quiet_hours_end': time(7), 'timezone': 'Africa/Nairobi'})()
        with patch('apps.notifications.tasks.timezone.now') as now:
            now.return_value = datetime(2026, 8, 27, 20, 0, tzinfo=timezone.utc)
            self.assertTrue(_quiet_hours(prefs))
