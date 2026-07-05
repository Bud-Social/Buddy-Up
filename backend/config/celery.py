import os
from celery import Celery
from celery.schedules import crontab

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')

app = Celery('buddyup')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()

app.conf.beat_schedule = {
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
