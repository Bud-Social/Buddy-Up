from django.urls import path
from . import views

app_name = 'wallet'
urlpatterns = [
    path('balance/', views.WalletBalanceView.as_view(), name='balance'),
    path('creator/transfer/', views.CreatorWalletTransferView.as_view(), name='creator_transfer'),
    path('creator/profile/', views.CreatorProfileView.as_view(), name='creator_profile'),
    path('transactions/', views.TransactionHistoryView.as_view(), name='transactions'),
    path('purchase/initialize/', views.InitializePurchaseView.as_view(), name='purchase_initialize'),
    path('purchase/confirm/', views.ConfirmPurchaseView.as_view(), name='purchase_confirm'),
    path('tip/', views.TipUserView.as_view(), name='tip'),
    path('gift/', views.GiftArtifactsView.as_view(), name='gift'),
    path('withdraw/', views.WithdrawView.as_view(), name='withdraw'),
    path('withdraw/banks/', views.BankListView.as_view(), name='bank_list'),
    path('withdraw/bank-resolve/', views.BankResolveView.as_view(), name='bank_resolve'),
    path('bundles/', views.BundleListView.as_view(), name='bundles'),
    path('exchange-rates/', views.ExchangeRateView.as_view(), name='exchange_rates'),
    path('payout-request/', views.PayoutRequestView.as_view(), name='payout_request'),
    path('payout-history/', views.PayoutHistoryView.as_view(), name='payout_history'),
    path('flutterwave-webhook/', views.FlutterwaveWebhookView.as_view(), name='flutterwave_webhook'),
]
