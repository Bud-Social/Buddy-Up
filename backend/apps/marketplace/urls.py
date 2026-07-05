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
    path('programmes/<uuid:programme_id>/', views.TrainingProgrammeDetailView.as_view(), name='programme_detail'),
    path('programmes/<uuid:programme_id>/purchase/', views.PurchaseTrainingProgrammeView.as_view(), name='purchase_programme'),
    path('programmes/<uuid:programme_id>/reviews/', views.TrainingProgrammeReviewView.as_view(), name='programme_reviews'),
    path('products/', views.ProductListView.as_view(), name='products'),
    path('products/<uuid:product_id>/', views.ProductDetailView.as_view(), name='product_detail'),
    path('products/<uuid:product_id>/click/', views.ProductClickView.as_view(), name='product_click'),
    path('events/', views.EventListView.as_view(), name='events'),
    path('events/my-tickets/', views.MyEventTicketsView.as_view(), name='my_tickets'),
    path('events/<uuid:event_id>/', views.EventDetailView.as_view(), name='event_detail'),
    path('events/<uuid:event_id>/tickets/', views.PurchaseEventTicketView.as_view(), name='purchase_ticket'),
    path('events/tickets/<uuid:ticket_id>/', views.EventTicketDetailView.as_view(), name='ticket_detail'),
]
