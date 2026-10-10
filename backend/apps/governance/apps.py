from django.apps import AppConfig


class GovernanceConfig(AppConfig):
    # The app label is 'governance'. Deliberately *not* 'admin' or 'permissions'
    # for the same reason apps.admin_portal avoids 'admin': a top-level app named
    # ``admin`` would shadow ``django.contrib.admin`` on import.
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.governance'
    label = 'governance'
    verbose_name = 'Governance'
