"""Admin portal routes, mounted at ``/api/v1/portal/``.

Every path here is staff-only. This is a separate mount from ``/api/v1/admin/``
(apps.ai.urls_admin, the ML dashboard) which is left untouched.

One path == one view. GET and PATCH for the same resource live on the same
class: Django resolves a pattern once, so registering two views on one path
would leave the second unreachable behind a 405.
"""
from django.urls import path

from . import views

app_name = 'admin_portal'

urlpatterns = [
    # --- Users ---
    path('users/', views.UserListView.as_view(), name='users'),
    path('users/<uuid:user_id>/', views.UserDetailView.as_view(), name='user_detail'),
    path('users/<uuid:user_id>/suspend/', views.UserSuspendView.as_view(), name='user_suspend'),
    path('users/<uuid:user_id>/reinstate/', views.UserReinstateView.as_view(), name='user_reinstate'),

    # --- Shops & products ---
    path('shops/', views.ShopListView.as_view(), name='shops'),
    path('shops/<str:handle>/', views.ShopDetailView.as_view(), name='shop_detail'),
    path('products/', views.ProductListView.as_view(), name='products'),

    # --- Buddy Up certification review queue (did not exist before) ---
    path('shop-certifications/', views.ShopCertificationQueueView.as_view(),
         name='shop_certifications'),
    path('shop-certifications/<uuid:application_id>/',
         views.ShopCertificationDetailView.as_view(), name='shop_certification'),

    # --- Orders (platform-wide) ---
    path('orders/', views.OrderListView.as_view(), name='orders'),
    path('orders/<uuid:order_id>/', views.OrderDetailView.as_view(), name='order_detail'),
    path('orders/<uuid:order_id>/status/', views.OrderStatusView.as_view(), name='order_status'),
    path('orders/<uuid:order_id>/notes/', views.OrderNoteView.as_view(), name='order_notes'),
    path('orders/<uuid:order_id>/cases/', views.OrderCaseView.as_view(), name='order_cases'),
    path('order-cases/', views.OrderCaseListView.as_view(), name='order_cases_list'),
    path('order-cases/<int:case_id>/', views.OrderCaseUpdateView.as_view(),
         name='order_case_update'),

    # --- Gyms ---
    path('gyms/', views.GymListView.as_view(), name='gyms'),
    path('gyms/<uuid:gym_id>/', views.GymDetailView.as_view(), name='gym_detail'),

    # --- Communities ---
    path('communities/', views.CommunityListView.as_view(), name='communities'),
    path('communities/<uuid:conversation_id>/', views.CommunityDetailView.as_view(),
         name='community_detail'),

    # --- Pickup stations & delivery personnel ---
    path('stations/', views.PickupStationListView.as_view(), name='stations'),
    path('stations/<uuid:station_id>/', views.PickupStationDetailView.as_view(),
         name='station_detail'),
    path('delivery-personnel/', views.DeliveryPersonnelListView.as_view(),
         name='delivery_personnel'),
    path('delivery-personnel/<uuid:personnel_id>/',
         views.DeliveryPersonnelDetailView.as_view(), name='delivery_personnel_detail'),

    # --- Application review queues ---
    path('station-applications/', views.StationApplicationQueueView.as_view(),
         name='station_applications'),
    path('station-applications/<uuid:application_id>/',
         views.StationApplicationReviewView.as_view(), name='station_application'),
    path('delivery-personnel-applications/',
         views.DeliveryPersonnelApplicationQueueView.as_view(),
         name='delivery_personnel_applications'),
    path('delivery-personnel-applications/<uuid:application_id>/',
         views.DeliveryPersonnelApplicationReviewView.as_view(),
         name='delivery_personnel_application'),

    # --- Wallet (read-only) ---
    path('transactions/', views.TransactionListView.as_view(), name='transactions'),
    path('transactions/<uuid:transaction_id>/', views.TransactionDetailView.as_view(),
         name='transaction_detail'),
    path('wallet/reconciliation/', views.WalletReconciliationView.as_view(),
         name='wallet_reconciliation'),
]
