from django.urls import path
from . import views

app_name = 'gyms'
urlpatterns = [
    path('', views.GymListView.as_view(), name='list'),
    path('create/', views.CreateGymView.as_view(), name='create'),
    path('check-handle/', views.CheckHandleView.as_view(), name='check_handle'),
    path('categories/', views.GymCategoriesView.as_view(), name='categories'),
    path('cities/', views.CitySearchView.as_view(), name='cities'),
    path('<str:gym_slug>/', views.GymDetailView.as_view(), name='detail'),
    path('<str:gym_slug>/join/', views.JoinGymView.as_view(), name='join'),
    path('<str:gym_slug>/leave/', views.LeaveGymView.as_view(), name='leave'),
    path('<str:gym_slug>/members/', views.GymMembersView.as_view(), name='members'),
    path('<str:gym_slug>/members/<uuid:user_id>/', views.ManageMemberView.as_view(), name='manage_member'),
    path('<str:gym_slug>/join-requests/', views.JoinRequestListView.as_view(), name='join_requests'),
    path('<str:gym_slug>/join-requests/<int:request_id>/', views.ManageJoinRequestView.as_view(), name='manage_join_request'),
    path('<str:gym_slug>/invite/', views.InviteCreateView.as_view(), name='invite'),
    path('<str:gym_slug>/invites/<int:invite_id>/<str:action>/', views.InviteActionView.as_view(), name='invite_action'),
    path('<str:gym_slug>/schedule-posts/', views.GymSchedulePostListView.as_view(), name='schedule_posts'),
    path('<str:gym_slug>/schedule-posts/<uuid:post_id>/', views.GymSchedulePostDetailView.as_view(), name='schedule_post_detail'),
    path('<str:gym_slug>/reviews/', views.GymReviewListView.as_view(), name='reviews'),
    path('<str:gym_slug>/reviews/<uuid:review_id>/reply/', views.GymReviewReplyView.as_view(), name='review_reply'),
    path('<str:gym_slug>/feed/', views.GymFeedListView.as_view(), name='feed'),
    path('<str:gym_slug>/donate/', views.GymDonationCreateView.as_view(), name='donate'),
    path('<str:gym_slug>/schedule-posts/<uuid:post_id>/enroll/', views.SlotEnrollView.as_view(), name='slot_enroll'),
    path('<str:gym_slug>/my-enrollments/', views.MySlotEnrollmentsView.as_view(), name='my_enrollments'),
    path('<str:gym_slug>/events/', views.GymEventsView.as_view(), name='gym_events'),
]
