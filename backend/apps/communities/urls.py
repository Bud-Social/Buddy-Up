from django.urls import path
from . import views

app_name = 'communities'

urlpatterns = [
    path('', views.CommunityListView.as_view(), name='list'),
    path('create/', views.CommunityCreateView.as_view(), name='create'),
    path('posts/', views.AllCommunityPostsView.as_view(), name='all_posts'),
    path('<str:slug>/', views.CommunityDetailView.as_view(), name='detail'),
    path('<str:slug>/join/', views.CommunityJoinView.as_view(), name='join'),
    path('<str:slug>/leave/', views.CommunityLeaveView.as_view(), name='leave'),
    path('<str:slug>/posts/', views.CommunityPostsView.as_view(), name='posts'),
    path('<str:slug>/add-post/', views.CommunityPostCreateView.as_view(), name='add_post'),
]
