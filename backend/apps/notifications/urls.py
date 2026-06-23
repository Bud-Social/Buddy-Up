from django.urls import path
from . import views

app_name = 'notifications'
urlpatterns = [
    path('', views.NotificationListView.as_view(), name='list'),
    path('unread-count/', views.UnreadCountView.as_view(), name='unread_count'),
    path('preferences/', views.NotificationPreferencesView.as_view(), name='preferences'),
    path('<uuid:notification_id>/read/', views.NotificationDetailView.as_view(), name='mark_read'),
]
