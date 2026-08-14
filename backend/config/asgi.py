import os
import dotenv
dotenv.load_dotenv(os.path.join(os.path.dirname(__file__), '..', '..', '.env'))

# These imports must run after dotenv.load_dotenv and get_asgi_application so
# Django's apps registry is configured before the routing table is imported.
# ruff: noqa: E402
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from channels.security.websocket import AllowedHostsOriginValidator

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')

django_asgi_app = get_asgi_application()

from apps.messaging.routing import websocket_urlpatterns  # noqa: E402

application = ProtocolTypeRouter({
    'http': django_asgi_app,
    'websocket': AllowedHostsOriginValidator(
        AuthMiddlewareStack(
            URLRouter(websocket_urlpatterns)
        )
    ),
})
