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
    path('<uuid:live_id>/credentials/', views.LiveCredentialsView.as_view(), name='credentials'),
    path('<uuid:live_id>/refund-gift/<uuid:tx_id>/', views.RefundGiftView.as_view(), name='refund_gift'),
    path('<uuid:live_id>/co-host/', views.AddCoHostView.as_view(), name='co_host'),
    path('<uuid:live_id>/co-host/invite/', views.CohostInviteView.as_view(), name='co_host_invite'),
    path('<uuid:live_id>/co-host/respond/', views.RespondCohostInviteView.as_view(), name='co_host_respond'),
    path('<uuid:live_id>/co-host/request/', views.RequestToSpeakView.as_view(), name='co_host_request'),
    path('<uuid:live_id>/co-host/requests/', views.CohostRequestsView.as_view(), name='co_host_requests'),
    path('<uuid:live_id>/co-host/respond-request/', views.RespondToSpeakRequestView.as_view(), name='co_host_respond_request'),
    path('<uuid:live_id>/recording/init/', views.InitiateClientRecordingView.as_view(), name='recording_init'),
    path('<uuid:live_id>/recording/upload/', views.UploadReplayChunkView.as_view(), name='recording_upload'),
    path('<uuid:live_id>/recording/complete/', views.CompleteClientReplayView.as_view(), name='recording_complete'),
    path('<uuid:live_id>/attendees/', views.LiveAttendeesView.as_view(), name='attendees'),
    path('gym/<uuid:gym_id>/schedule/', views.GymScheduleView.as_view(), name='gym_schedule'),
    path('profile/<str:username>/', views.UserLivesView.as_view(), name='user_lives'),
]
