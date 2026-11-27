from django.urls import path

from .views import LiveKitWebhookView, RealtimeHealthView

app_name = 'realtime'

urlpatterns = [
    path('health/', RealtimeHealthView.as_view(), name='health'),
    path('webhooks/livekit/', LiveKitWebhookView.as_view(), name='livekit_webhook'),
]
