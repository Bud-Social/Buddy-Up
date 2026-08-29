from django.urls import path
from . import views

app_name = 'marketplace'
urlpatterns = [
    # --- Shops ---
    path('shops/', views.ShopListView.as_view(), name='shops'),
    path('shops/my/', views.MyShopsView.as_view(), name='my_shops'),
    path('register-creator/', views.RegisterCreatorView.as_view(), name='register_creator'),
    path('shops/<slug:handle>/', views.ShopDetailView.as_view(), name='shop_detail'),
    path('shops/<slug:handle>/public/', views.UserShopView.as_view(), name='shop_public'),
    path('shops/<slug:handle>/members/', views.ShopMembershipView.as_view(), name='shop_members'),
    path('shops/<slug:handle>/gyms/', views.ShopGymLinkView.as_view(), name='shop_gyms'),
    path('shops/<slug:handle>/certification/', views.ShopVerificationApplicationView.as_view(), name='shop_cert'),

    # --- Image Upload ---
    path('upload-cover/', views.CoverImageUploadView.as_view(), name='upload_cover'),

    # --- Push Devices ---
    path('push-devices/', views.PushDeviceView.as_view(), name='push_devices'),

    # --- Meal Plans ---
    path('meal-plans/', views.MealPlanListView.as_view(), name='meal_plans'),
    path('meal-plans/<uuid:plan_id>/', views.MealPlanDetailView.as_view(), name='meal_plan_detail'),
    path('meal-plans/<uuid:plan_id>/purchase/', views.PurchaseMealPlanView.as_view(), name='purchase_meal_plan'),
    path('meal-plans/<uuid:plan_id>/personalise/', views.PersonaliseMealPlanView.as_view(), name='personalise'),
    path('meal-plans/<uuid:plan_id>/reviews/', views.MealPlanReviewView.as_view(), name='meal_plan_reviews'),

    # --- Training Programmes ---
    path('programmes/', views.TrainingProgrammeListView.as_view(), name='programmes'),
    path('programmes/<uuid:programme_id>/', views.TrainingProgrammeDetailView.as_view(), name='programme_detail'),
    path('programmes/<uuid:programme_id>/purchase/', views.PurchaseTrainingProgrammeView.as_view(), name='purchase_programme'),
    path('programmes/<uuid:programme_id>/reviews/', views.TrainingProgrammeReviewView.as_view(), name='programme_reviews'),
    path('programmes/<uuid:programme_id>/progress/', views.ProgrammeActivityProgressView.as_view(), name='programme_progress'),

    # --- Products ---
    path('products/', views.ProductListView.as_view(), name='products'),
    path('products/<uuid:product_id>/', views.ProductDetailView.as_view(), name='product_detail'),
    path('products/<uuid:product_id>/click/', views.ProductClickView.as_view(), name='product_click'),

    # --- Events ---
    path('events/', views.EventListView.as_view(), name='events'),
    path('events/my-tickets/', views.MyEventTicketsView.as_view(), name='my_tickets'),
    path('events/<uuid:event_id>/', views.EventDetailView.as_view(), name='event_detail'),
    path('events/<uuid:event_id>/tickets/', views.PurchaseEventTicketView.as_view(), name='purchase_ticket'),
    path('events/tickets/<uuid:ticket_id>/', views.EventTicketDetailView.as_view(), name='ticket_detail'),
    path('events/<uuid:event_id>/media/', views.EventMediaManageView.as_view(), name='event_media'),
    path('events/<uuid:event_id>/media/<uuid:media_id>/', views.EventMediaManageView.as_view(), name='event_media_delete'),

    # --- Food Recognition ---
    path('food-recognize/', views.FoodRecognizeView.as_view(), name='food_recognize'),

    # --- Creator Studio ---
    path('my-services/', views.MyMarketplaceServicesView.as_view(), name='my_services'),
    path('my-services/analytics/', views.CreatorAnalyticsView.as_view(), name='my_services_analytics'),

    # --- Cart & Checkout ---
    path('cart/', views.CartView.as_view(), name='cart'),
    path('cart/checkout/', views.CheckoutCartView.as_view(), name='cart_checkout'),
    path('cart/discount/', views.DiscountCodeView.as_view(), name='cart_discount'),

    # --- Orders & Tracking ---
    path('orders/', views.OrderListView.as_view(), name='orders'),
    path('orders/seller/', views.SellerOrdersView.as_view(), name='seller_orders'),
    path('creator/orders/', views.SellerOrdersView.as_view(), name='creator_orders'),
    path('orders/<uuid:order_id>/', views.OrderDetailView.as_view(), name='order_detail'),
    path('orders/<uuid:order_id>/fulfillment/', views.OrderFulfillmentView.as_view(), name='order_fulfillment'),
    path('orders/<uuid:order_id>/status/', views.OrderFulfillmentView.as_view(), name='order_status'),
    path('orders/<uuid:order_id>/cases/', views.OrderCaseView.as_view(), name='order_cases'),
    path('creator/payout-setup/', views.CreatorPayoutSetupView.as_view(), name='creator_payout_setup'),

    # --- Discount Codes ---
    path('discount-codes/', views.DiscountCodeManageView.as_view(), name='discount_codes'),
    path('discount-codes/<uuid:code_id>/', views.DiscountCodeManageView.as_view(), name='discount_code_detail'),
    path('discount-codes/<uuid:code_id>/analytics/', views.DiscountCodeAnalyticsView.as_view(), name='discount_code_analytics'),
    path('discount-codes/<uuid:code_id>/share/', views.DiscountCodeShareView.as_view(), name='discount_code_share'),
]
