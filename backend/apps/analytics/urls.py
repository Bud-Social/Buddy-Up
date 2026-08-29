from django.urls import path
from . import views

app_name = 'analytics'

urlpatterns = [
    path('summary/', views.AnalyticsSummaryView.as_view(), name='summary'),
    path('activities/', views.ActivityRecordView.as_view(), name='activities'),
    path('activities/<uuid:pk>/', views.ActivityRecordView.as_view(), name='activity_detail'),
    path('workouts/', views.WorkoutLogView.as_view(), name='workouts'),
    path('workouts/<uuid:pk>/', views.WorkoutLogView.as_view(), name='workout_detail'),
    path('meals/analyze/', views.MealAnalyzeView.as_view(), name='meal_analyze'),
    path('meals/', views.MealLogView.as_view(), name='meals'),
    path('meals/<uuid:pk>/', views.MealLogView.as_view(), name='meal_detail'),
    path('body/read-weight/', views.BodyReadWeightView.as_view(), name='body_read_weight'),
    path('body/', views.BodyMetricView.as_view(), name='body'),
    path('body/<uuid:pk>/', views.BodyMetricView.as_view(), name='body_detail'),
    path('report/', views.AnalyticsReportView.as_view(), name='report'),
    path('report/download/', views.AnalyticsReportDownloadView.as_view(), name='report_download'),
    path('report/share/', views.AnalyticsReportShareView.as_view(), name='report_share'),
    path('events/', views.IngestEventsView.as_view(), name='events'),
]
