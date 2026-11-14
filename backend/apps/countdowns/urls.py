from django.urls import path
from . import views

app_name = 'countdowns'

urlpatterns = [
    path('templates/', views.CountdownTemplateListView.as_view(), name='templates'),
    path('templates/seed/', views.CountdownSeedTemplatesView.as_view(), name='seed_templates'),
    path('signals/', views.CountdownSignalListView.as_view(), name='signals'),
    path('', views.UserCountdownListView.as_view(), name='list'),
    path('<uuid:pk>/', views.UserCountdownDetailView.as_view(), name='detail'),
    path('<uuid:pk>/events/', views.CountdownEventListView.as_view(), name='events'),
    path('<uuid:pk>/checkin/', views.CountdownCheckInView.as_view(), name='checkin'),
    path('<uuid:pk>/reset/', views.CountdownResetView.as_view(), name='reset'),
    path('auto-advance/', views.CountdownAutoAdvanceView.as_view(), name='auto_advance'),
    path('routines/', views.RoutineListView.as_view(), name='routines_list'),
    path('routines/reorder/', views.RoutineReorderView.as_view(), name='routines_reorder'),
    path('routines/<uuid:pk>/', views.RoutineDetailView.as_view(), name='routines_detail'),
    path('routines/<uuid:pk>/checkin/', views.RoutineCheckInView.as_view(), name='routine_checkin'),
    path('routines/<uuid:pk>/checkins/', views.RoutineCheckInListView.as_view(), name='routine_checkins'),
    path('routines/<uuid:pk>/highlights/', views.RoutineHighlightListView.as_view(), name='routine_highlights'),
    path('routines/<uuid:pk>/highlights/<uuid:highlight_id>/', views.RoutineHighlightDetailView.as_view(), name='routine_highlight_detail'),
    path('routines/<uuid:pk>/share/', views.RoutineShareView.as_view(), name='routine_share'),
]
