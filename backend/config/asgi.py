import os
import dotenv
dotenv.load_dotenv(os.path.join(os.path.dirname(__file__), '..', '..', '.env'))

# These imports must run after dotenv.load_dotenv and get_asgi_application so
# Django's apps registry is configured before the routing table is imported.
# ruff: noqa: E402
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from config.origin import native_friendly_origin_validator

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')

django_asgi_app = get_asgi_application()

from apps.messaging.routing import websocket_urlpatterns  # noqa: E402

application = ProtocolTypeRouter({
    'http': django_asgi_app,
    # Native clients (the Flutter app) send no Origin, so the stock
    # AllowedHostsOriginValidator rejects every mobile handshake. This keeps the
    # ALLOWED_HOSTS match for browsers and only waives the *absent* header.
    'websocket': native_friendly_origin_validator(
        AuthMiddlewareStack(
            URLRouter(websocket_urlpatterns)
        )
    ),
})
