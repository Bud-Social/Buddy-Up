from django.apps import AppConfig


class LivesConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.lives'
    label = 'lives'

    def ready(self):
        # Deploy-time safety check (lives.W001) for the Agora non-secure
        # fallback — see checks.py.
        from . import checks  # noqa: F401
