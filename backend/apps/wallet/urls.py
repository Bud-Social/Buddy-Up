from django.urls import path
from . import views

app_name = 'wallet'
urlpatterns = [
    path('balance/', views.WalletBalanceView.as_view(), name='balance'),
    path('transactions/', views.TransactionHistoryView.as_view(), name='transactions'),
    path('purchase/', views.PurchaseArtifactsView.as_view(), name='purchase'),
    path('tip/', views.TipUserView.as_view(), name='tip'),
    path('gift/', views.GiftArtifactsView.as_view(), name='gift'),
    path('withdraw/', views.WithdrawView.as_view(), name='withdraw'),
    path('bundles/', views.BundleListView.as_view(), name='bundles'),
    path('exchange-rates/', views.ExchangeRateView.as_view(), name='exchange_rates'),
]
