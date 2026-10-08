from django.apps import AppConfig


class AdminPortalConfig(AppConfig):
    # NOTE: the app label is 'admin_portal', never 'admin'. A top-level app
    # named ``admin`` would shadow ``django.contrib.admin`` on import and break
    # the whole Django admin site.
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.admin_portal'
    label = 'admin_portal'
    verbose_name = 'Admin Portal'
