import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet.freezed.dart';
part 'wallet.g.dart';

@freezed
abstract class BalanceItem with _$BalanceItem {
  const factory BalanceItem({
    @JsonKey(name: 'artifact_type') required String artifactType,
    required String label,
    required int quantity,
    @JsonKey(name: 'usd_value') required double usdValue,
  }) = _BalanceItem;

  factory BalanceItem.fromJson(Map<String, dynamic> json) =>
      _$BalanceItemFromJson(json);
}

@freezed
abstract class BalanceResponse with _$BalanceResponse {
  const factory BalanceResponse({
    required List<BalanceItem> balance,
    @JsonKey(name: 'total_label') required String totalLabel,
    @JsonKey(name: 'total_fiat') required double totalFiat,
    @JsonKey(name: 'fiat_currency') required String fiatCurrency,
    @JsonKey(name: 'regular_balance') @Default(<BalanceItem>[]) List<BalanceItem> regularBalance,
    @JsonKey(name: 'regular_total_fiat') @Default(0.0) double regularTotalFiat,
    @JsonKey(name: 'creator_balance') @Default(<BalanceItem>[]) List<BalanceItem> creatorBalance,
    @JsonKey(name: 'creator_total_fiat') @Default(0.0) double creatorTotalFiat,
    @JsonKey(name: 'creator_display_name') @Default('') String creatorDisplayName,
  }) = _BalanceResponse;

  factory BalanceResponse.fromJson(Map<String, dynamic> json) =>
      _$BalanceResponseFromJson(json);
}

@freezed
abstract class ArtifactTransaction with _$ArtifactTransaction {
  const factory ArtifactTransaction({
    required String id,
    @JsonKey(name: 'transaction_type') required String transactionType,
    @JsonKey(name: 'artifact_type') required String artifactType,
    required int quantity,
    required String direction,
    @JsonKey(name: 'counterparty_id') String? counterpartyId,
    @JsonKey(name: 'counterparty_name') String? counterpartyName,
    @JsonKey(name: 'reference_id') required String referenceId,
    required String status,
    @JsonKey(name: 'fiat_amount') String? fiatAmount,
    @JsonKey(name: 'fiat_currency') required String fiatCurrency,
    String? description,
    @JsonKey(name: 'clearance_at') String? clearanceAt,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _ArtifactTransaction;

  factory ArtifactTransaction.fromJson(Map<String, dynamic> json) =>
      _$ArtifactTransactionFromJson(json);
}

@freezed
abstract class BundleInfo with _$BundleInfo {
  const factory BundleInfo({
    required String id,
    @JsonKey(name: 'artifact_type') required String artifactType,
    @JsonKey(name: 'artifact_label') required String artifactLabel,
    required int quantity,
    @JsonKey(name: 'price_usd') required double priceUsd,
    required double savings,
  }) = _BundleInfo;

  factory BundleInfo.fromJson(Map<String, dynamic> json) =>
      _$BundleInfoFromJson(json);
}

@freezed
abstract class BankInfo with _$BankInfo {
  const factory BankInfo({
    required String code,
    required String name,
  }) = _BankInfo;

  factory BankInfo.fromJson(Map<String, dynamic> json) =>
      _$BankInfoFromJson(json);
}

@freezed
abstract class BankResolveResult with _$BankResolveResult {
  const factory BankResolveResult({
    @JsonKey(name: 'account_number') required String accountNumber,
    @JsonKey(name: 'bank_code') required String bankCode,
    @JsonKey(name: 'account_name') required String accountName,
  }) = _BankResolveResult;

  factory BankResolveResult.fromJson(Map<String, dynamic> json) =>
      _$BankResolveResultFromJson(json);
}

@freezed
abstract class InitializePurchaseResponse with _$InitializePurchaseResponse {
  const factory InitializePurchaseResponse({
    @JsonKey(name: 'tx_ref') required String txRef,
    @JsonKey(name: 'flutterwave_ref') String? flutterwaveRef,
    String? status,
    @JsonKey(name: 'requires_otp') @Default(false) bool requiresOtp,
    @JsonKey(name: 'public_key') required String publicKey,
    double? amount,
    String? currency,
    @JsonKey(name: 'customer_email') String? customerEmail,
    @JsonKey(name: 'customer_name') String? customerName,
  }) = _InitializePurchaseResponse;

  factory InitializePurchaseResponse.fromJson(Map<String, dynamic> json) =>
      _$InitializePurchaseResponseFromJson(json);
}

@freezed
abstract class ConfirmPurchaseResponse with _$ConfirmPurchaseResponse {
  const factory ConfirmPurchaseResponse({
    required ArtifactTransaction transaction,
    @JsonKey(name: 'new_balance') required Map<String, int> newBalance,
  }) = _ConfirmPurchaseResponse;

  factory ConfirmPurchaseResponse.fromJson(Map<String, dynamic> json) =>
      _$ConfirmPurchaseResponseFromJson(json);
}

@freezed
abstract class ExchangeRates with _$ExchangeRates {
  const factory ExchangeRates({
    required Map<String, double> rates,
    @JsonKey(name: 'base_currency') required String baseCurrency,
    @JsonKey(name: 'local_currency') required String localCurrency,
    @JsonKey(name: 'conversion_rate') required double conversionRate,
    required Map<String, String> labels,
  }) = _ExchangeRates;

  factory ExchangeRates.fromJson(Map<String, dynamic> json) =>
      _$ExchangeRatesFromJson(json);
}
