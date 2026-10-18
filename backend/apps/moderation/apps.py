from django.apps import AppConfig


class ModerationConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.moderation'
    label = 'moderation'

    def ready(self):
        # Registers the governance-approval receiver in apps/moderation/signals.py.
        # The sender is referenced as a string label so this import does not pull
        # apps.governance (and through it apps.admin_portal) into the app-loading
        # path.
        from . import signals  # noqa: F401

        # Auto-moderation for everything except posts. Posts were wired directly
        # in apps.feed; the other eight types reached the platform with no
        # checker at all. Resolved lazily by model label because the owning apps
        # must not be imported from here at app-load time.
        from . import dispatch

        dispatch.connect()