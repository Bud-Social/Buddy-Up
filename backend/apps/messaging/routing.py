from django.urls import path
from . import consumers

websocket_urlpatterns = [
    path('ws/user/<str:user_id>/', consumers.UserConsumer.as_asgi()),
    path('ws/conversation/<str:conversation_id>/', consumers.ChatConsumer.as_asgi()),
    path('ws/live/<str:live_id>/', consumers.LiveConsumer.as_asgi()),
    path('ws/gym-chat/<str:gym_id>/', consumers.GymChatConsumer.as_asgi()),
    path('ws/random-drop/', consumers.RandomDropConsumer.as_asgi()),
]
