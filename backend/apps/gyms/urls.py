from django.urls import path
from . import views

app_name = 'gyms'
urlpatterns = [
    path('', views.GymListView.as_view(), name='list'),
    path('create/', views.CreateGymView.as_view(), name='create'),
    path('<str:gym_slug>/', views.GymDetailView.as_view(), name='detail'),
    path('<str:gym_slug>/join/', views.JoinGymView.as_view(), name='join'),
    path('<str:gym_slug>/leave/', views.LeaveGymView.as_view(), name='leave'),
    path('<str:gym_slug>/members/', views.GymMembersView.as_view(), name='members'),
    path('<str:gym_slug>/members/<uuid:user_id>/', views.ManageMemberView.as_view(), name='manage_member'),
]
