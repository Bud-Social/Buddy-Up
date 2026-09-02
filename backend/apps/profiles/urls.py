from django.urls import path
from . import views

app_name = 'profiles'
urlpatterns = [
    path('me/', views.MyProfileView.as_view(), name='my_profile'),
    path('me/avatar/', views.AvatarUploadView.as_view(), name='avatar_upload'),
    path('me/cover/', views.CoverUploadView.as_view(), name='cover_upload'),
    path('search/', views.ProfileSearchView.as_view(), name='search'),
    path('check-username/', views.CheckUsernameView.as_view(), name='check_username'),
    path('change-username/', views.ChangeUsernameView.as_view(), name='change_username'),
    path('onboarding/', views.OnboardingView.as_view(), name='onboarding'),
    path('blocked/', views.BlockedUsersView.as_view(), name='blocked_users'),
    path('pending-requests/', views.PendingBuddyRequestsView.as_view(), name='pending_requests'),
    path('buddies/search/', views.BuddySearchView.as_view(), name='buddy_search'),

    path('presence/', views.PresenceStatusView.as_view(), name='presence'),
    path('recommendations/', views.ProfileRecommendationsView.as_view(), name='recommendations'),
    path('recommendations/feedback/', views.ProfileRecommendationFeedbackView.as_view(), name='recommendation_feedback'),
    path('discover/trending/', views.DiscoverTrendingView.as_view(), name='discover_trending'),
    path('<str:username>/', views.UserProfileView.as_view(), name='user_profile'),
    path('<str:username>/buddy/', views.SendBuddyRequestView.as_view(), name='buddy_request'),
    path('<str:username>/buddy/accept/', views.AcceptBuddyRequestView.as_view(), name='buddy_accept'),
    path('<str:username>/buddy/decline/', views.DeclineBuddyRequestView.as_view(), name='buddy_decline'),
    path('<str:username>/follow/', views.FollowUserView.as_view(), name='follow'),
    path('<str:username>/block/', views.BlockUserView.as_view(), name='block'),
    path('<str:username>/ping/', views.SendPingView.as_view(), name='ping'),
    path('<str:username>/buddies/', views.BuddiesListView.as_view(), name='buddies'),
    path('<str:username>/followers/', views.FollowersListView.as_view(), name='followers'),
    path('<str:username>/following/', views.FollowingListView.as_view(), name='following'),
    path('<str:username>/posts/', views.UserPostsView.as_view(), name='user_posts'),
]
