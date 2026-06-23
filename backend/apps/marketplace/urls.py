from django.urls import path
from . import views

app_name = 'marketplace'
urlpatterns = [
    path('meal-plans/', views.MealPlanListView.as_view(), name='meal_plans'),
    path('meal-plans/<uuid:plan_id>/', views.MealPlanDetailView.as_view(), name='meal_plan_detail'),
    path('meal-plans/<uuid:plan_id>/purchase/', views.PurchaseMealPlanView.as_view(), name='purchase_meal_plan'),
    path('meal-plans/<uuid:plan_id>/personalise/', views.PersonaliseMealPlanView.as_view(), name='personalise'),
    path('meal-plans/<uuid:plan_id>/reviews/', views.MealPlanReviewView.as_view(), name='meal_plan_reviews'),
    path('programmes/', views.TrainingProgrammeListView.as_view(), name='programmes'),
    path('products/', views.ProductListView.as_view(), name='products'),
]
