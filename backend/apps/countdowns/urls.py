from django.urls import path
from . import views

app_name = 'countdowns'

urlpatterns = [
    path('templates/', views.CountdownTemplateListView.as_view(), name='templates'),
    path('templates/seed/', views.CountdownSeedTemplatesView.as_view(), name='seed_templates'),
    path('', views.UserCountdownListView.as_view(), name='list'),
    path('<uuid:pk>/', views.UserCountdownDetailView.as_view(), name='detail'),
    path('<uuid:pk>/checkin/', views.CountdownCheckInView.as_view(), name='checkin'),
    path('<uuid:pk>/reset/', views.CountdownResetView.as_view(), name='reset'),
    path('auto-advance/', views.CountdownAutoAdvanceView.as_view(), name='auto_advance'),
    path('routines/', views.RoutineListView.as_view(), name='routines_list'),
    path('routines/<uuid:pk>/', views.RoutineDetailView.as_view(), name='routines_detail'),
]
