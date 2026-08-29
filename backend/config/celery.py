import os

from celery import Celery
from celery.schedules import crontab
from django.conf import settings

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')

app = Celery('buddyup')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()

# Entries defined here take precedence over settings.CELERY_BEAT_SCHEDULE
# (base.py) when keys collide.
CELERY_BEAT_SCHEDULE = {
    'generate-feed-cache': {
        'task': 'apps.feed.tasks.generate_feed_cache',
        'schedule': crontab(minute='*/5'),
    },
    'expire-moments': {
        'task': 'apps.feed.tasks.expire_moments',
        'schedule': crontab(minute='0'),
    },
    'check-streaks': {
        'task': 'apps.profiles.tasks.check_streaks',
        'schedule': crontab(hour='0', minute='0'),
    },
    'send-streak-reminder': {
        'task': 'apps.profiles.tasks.send_streak_reminder',
        'schedule': crontab(hour='18', minute='0'),
    },
    'clear-expired-sessions': {
        'task': 'apps.sessions.tasks.clear_expired_sessions',
        'schedule': crontab(minute='0'),
    },
    'generate-gym-schedule-notifications': {
        'task': 'apps.gyms.tasks.generate_schedule_notifications',
        'schedule': crontab(minute='0'),
    },
    'refresh-artifact-exchange-rates': {
        'task': 'apps.wallet.tasks.refresh_exchange_rates',
        'schedule': crontab(day_of_week='1'),
    },
    'scan-random-drop-pool': {
        'task': 'apps.lives.tasks.scan_random_drop_pool',
        'schedule': 30.0,
    },
    'send-live-reminders': {
        'task': 'apps.lives.tasks.send_live_reminders',
        'schedule': 60.0,
    },
    'retry-failed-replays': {
        'task': 'apps.lives.tasks.retry_failed_replays',
        'schedule': crontab(minute='*/30'),
    },
    'clear-locked-balance': {
        'task': 'apps.wallet.tasks.clear_locked_balance',
        'schedule': crontab(hour='*/2'),
    },
    'process-pending-withdrawals': {
        'task': 'apps.wallet.tasks.process_pending_withdrawals',
        'schedule': crontab(minute='*/15'),
    },
}

# Merge rather than replace: settings.CELERY_BEAT_SCHEDULE carries entries
# such as wallet reconciliation, verification purge and visual-search
# indexing that must keep running. Entries defined above take precedence.
#
# Plain assignment (app.conf.beat_schedule = {...}) is silently discarded by
# celery's lazy configuration pipeline (PendingConfiguration) when the config
# source is django.conf:settings, so mutate the resolved schedule dict
# directly — the same mechanism celery's add_periodic_task() uses.
app.conf.beat_schedule.update({
    **getattr(settings, 'CELERY_BEAT_SCHEDULE', {}),
    **CELERY_BEAT_SCHEDULE,
})
