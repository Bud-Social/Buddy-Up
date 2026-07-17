from django.urls import path
from . import views

app_name = 'sessions'
urlpatterns = [
    path('trainers/', views.TrainerListView.as_view(), name='trainers_list'),
    path('trainers/<str:username>/', views.TrainerDetailView.as_view(), name='trainer_detail'),
    path('trainers/<str:username>/availability/', views.AvailabilityView.as_view(), name='availability'),
    path('trainers/<str:username>/reviews/', views.TrainerReviewsView.as_view(), name='trainer_reviews'),
    path('my/', views.MyBookingsView.as_view(), name='my_bookings'),
    path('book/<str:username>/', views.BookingCreateView.as_view(), name='book'),
    path('bookings/<uuid:booking_id>/', views.BookingDetailView.as_view(), name='booking_detail'),
    path('bookings/<uuid:booking_id>/review/', views.ReviewView.as_view(), name='review'),
    path('my-availability/', views.AvailabilityView.as_view(), name='my_availability'),
    path('programmes/', views.ProgrammeListView.as_view(), name='programmes'),
    path('programmes/<int:programme_id>/enroll/', views.ProgrammeEnrollmentView.as_view(), name='enroll'),
    path('programmes/<int:programme_id>/weeks/', views.ProgrammeWeekListView.as_view(), name='programme_weeks'),
    path('programmes/<int:programme_id>/weeks/<int:week_number>/complete/', views.ProgrammeWeekCompleteView.as_view(), name='complete_week'),
    path('my-enrollments/', views.MyEnrolmentsView.as_view(), name='my_enrollments'),
    path('bookings/<uuid:booking_id>/calendar.ics', views.CalendarSyncView.as_view(), name='booking_ics'),
]
