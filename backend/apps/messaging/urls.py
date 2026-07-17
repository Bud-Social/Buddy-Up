from django.urls import path
from . import views

app_name = 'messaging'
urlpatterns = [
    path('conversations/', views.ConversationListView.as_view(), name='conversations'),
    path('conversations/start/', views.StartConversationView.as_view(), name='start_conversation'),
    path('conversations/<uuid:conversation_id>/', views.ConversationDetailView.as_view(), name='conversation_detail'),
    path('conversations/<uuid:conversation_id>/messages/', views.MessageListView.as_view(), name='messages'),
    path('conversations/<uuid:conversation_id>/read/', views.MarkReadView.as_view(), name='mark_read'),
    path('conversations/<uuid:conversation_id>/calls/', views.CallLogView.as_view(), name='call_logs'),
    path('messages/<uuid:message_id>/react/', views.MessageReactionView.as_view(), name='message_react'),
    path('messages/<uuid:message_id>/delete/', views.DeleteMessageView.as_view(), name='message_delete'),
    path('upload/', views.UploadAttachmentView.as_view(), name='upload_attachment'),
    path('conversations/group/', views.CreateGroupConversationView.as_view(), name='create_group'),
]
