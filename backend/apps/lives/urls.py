from django.urls import path
from . import views

app_name = 'lives'
urlpatterns = [
    path('browse/', views.LiveBrowserView.as_view(), name='browse'),
    path('start/', views.StartLiveView.as_view(), name='start'),
    path('<uuid:live_id>/', views.LiveDetailView.as_view(), name='detail'),
    path('<uuid:live_id>/end/', views.EndLiveView.as_view(), name='end'),
    path('<uuid:live_id>/join/', views.JoinLiveView.as_view(), name='join'),
    path('<uuid:live_id>/rsvp/', views.RSVPLiveView.as_view(), name='rsvp'),
    path('random-drop/start/', views.RandomDropStartView.as_view(), name='random_drop_start'),
    path('random-drop/status/', views.RandomDropStatusView.as_view(), name='random_drop_status'),
    path('gym/<uuid:gym_id>/schedule/', views.GymScheduleView.as_view(), name='gym_schedule'),
]
