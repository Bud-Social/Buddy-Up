from django.urls import path

from . import views

app_name = 'gamification'

urlpatterns = [
    path('achievements/', views.AchievementsView.as_view(), name='achievements'),
]
