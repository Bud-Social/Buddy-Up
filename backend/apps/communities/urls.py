from django.urls import path
from . import views

app_name = 'communities'

urlpatterns = [
    path('', views.CommunityListView.as_view(), name='list'),
    path('create/', views.CommunityCreateView.as_view(), name='create'),
    path('<slug:slug>/', views.CommunityDetailView.as_view(), name='detail'),
    path('<slug:slug>/join/', views.CommunityJoinView.as_view(), name='join'),
    path('<slug:slug>/leave/', views.CommunityLeaveView.as_view(), name='leave'),
    path('<slug:slug>/posts/', views.CommunityPostsView.as_view(), name='posts'),
    path('<slug:slug>/add-post/', views.CommunityPostCreateView.as_view(), name='add_post'),
    path('posts/', views.AllCommunityPostsView.as_view(), name='all_posts'),
]
