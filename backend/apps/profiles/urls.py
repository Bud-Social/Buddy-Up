from django.urls import path
from . import views

app_name = 'profiles'
urlpatterns = [
    path('me/', views.MyProfileView.as_view(), name='my_profile'),
    path('search/', views.ProfileSearchView.as_view(), name='search'),
    path('onboarding/', views.OnboardingView.as_view(), name='onboarding'),
    path('blocked/', views.BlockedUsersView.as_view(), name='blocked_users'),

    path('<str:username>/', views.UserProfileView.as_view(), name='user_profile'),
    path('<str:username>/buddy/', views.SendBuddyRequestView.as_view(), name='buddy_request'),
    path('<str:username>/buddy/accept/', views.AcceptBuddyRequestView.as_view(), name='buddy_accept'),
    path('<str:username>/buddy/decline/', views.DeclineBuddyRequestView.as_view(), name='buddy_decline'),
    path('<str:username>/follow/', views.FollowUserView.as_view(), name='follow'),
    path('<str:username>/block/', views.BlockUserView.as_view(), name='block'),
    path('<str:username>/buddies/', views.BuddiesListView.as_view(), name='buddies'),
    path('<str:username>/followers/', views.FollowersListView.as_view(), name='followers'),
    path('<str:username>/following/', views.FollowingListView.as_view(), name='following'),
]
