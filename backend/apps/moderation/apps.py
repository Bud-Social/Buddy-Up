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