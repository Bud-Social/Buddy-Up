// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BalanceItem _$BalanceItemFromJson(Map<String, dynamic> json) => _BalanceItem(
  artifactType: json['artifact_type'] as String,
  label: json['label'] as String,
  quantity: (json['quantity'] as num).toInt(),
  usdValue: (json['usd_value'] as num).toDouble(),
);

Map<String, dynamic> _$BalanceItemToJson(_BalanceItem instance) =>
    <String, dynamic>{
      'artifact_type': instance.artifactType,
      'label': instance.label,
      'quantity': instance.quantity,
      'usd_value': instance.usdValue,
    };

_BalanceResponse _$BalanceResponseFromJson(Map<String, dynamic> json) =>
    _BalanceResponse(
      balance: (json['balance'] as List<dynamic>)
          .map((e) => BalanceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalLabel: json['total_label'] as String,
      totalFiat: (json['total_fiat'] as num).toDouble(),
      fiatCurrency: json['fiat_currency'] as String,
      regularBalance:
          (json['regular_balance'] as List<dynamic>?)
              ?.map((e) => BalanceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <BalanceItem>[],
      regularTotalFiat: (json['regular_total_fiat'] as num?)?.toDouble() ?? 0.0,
      creatorBalance:
          (json['creator_balance'] as List<dynamic>?)
              ?.map((e) => BalanceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <BalanceItem>[],
      creatorTotalFiat: (json['creator_total_fiat'] as num?)?.toDouble() ?? 0.0,
      creatorDisplayName: json['creator_display_name'] as String? ?? '',
    );

Map<String, dynamic> _$BalanceResponseToJson(_BalanceResponse instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'total_label': instance.totalLabel,
      'total_fiat': instance.totalFiat,
      'fiat_currency': instance.fiatCurrency,
      'regular_balance': instance.regularBalance,
      'regular_total_fiat': instance.regularTotalFiat,
      'creator_balance': instance.creatorBalance,
      'creator_total_fiat': instance.creatorTotalFiat,
      'creator_display_name': instance.creatorDisplayName,
    };

_ArtifactTransaction _$ArtifactTransactionFromJson(Map<String, dynamic> json) =>
    _ArtifactTransaction(
      id: json['id'] as String,
      transactionType: json['transaction_type'] as String,
      artifactType: json['artifact_type'] as String,
      quantity: (json['quantity'] as num).toInt(),
      direction: json['direction'] as String,
      counterpartyId: json['counterparty_id'] as String?,
      counterpartyName: json['counterparty_name'] as String?,
      referenceId: json['reference_id'] as String,
      status: json['status'] as String,
      fiatAmount: json['fiat_amount'] as String?,
      fiatCurrency: json['fiat_currency'] as String,
      description: json['description'] as String?,
      clearanceAt: json['clearance_at'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$ArtifactTransactionToJson(
  _ArtifactTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'transaction_type': instance.transactionType,
  'artifact_type': instance.artifactType,
  'quantity': instance.quantity,
  'direction': instance.direction,
  'counterparty_id': instance.counterpartyId,
  'counterparty_name': instance.counterpartyName,
  'reference_id': instance.referenceId,
  'status': instance.status,
  'fiat_amount': instance.fiatAmount,
  'fiat_currency': instance.fiatCurrency,
  'description': instance.description,
  'clearance_at': instance.clearanceAt,
  'created_at': instance.createdAt,
};

_BundleInfo _$BundleInfoFromJson(Map<String, dynamic> json) => _BundleInfo(
  id: json['id'] as String,
  artifactType: json['artifact_type'] as String,
  artifactLabel: json['artifact_label'] as String,
  quantity: (json['quantity'] as num).toInt(),
  priceUsd: (json['price_usd'] as num).toDouble(),
  savings: (json['savings'] as num).toDouble(),
);

Map<String, dynamic> _$BundleInfoToJson(_BundleInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'artifact_type': instance.artifactType,
      'artifact_label': instance.artifactLabel,
      'quantity': instance.quantity,
      'price_usd': instance.priceUsd,
      'savings': instance.savings,
    };

_BankInfo _$BankInfoFromJson(Map<String, dynamic> json) =>
    _BankInfo(code: json['code'] as String, name: json['name'] as String);

Map<String, dynamic> _$BankInfoToJson(_BankInfo instance) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
};

_BankResolveResult _$BankResolveResultFromJson(Map<String, dynamic> json) =>
    _BankResolveResult(
      accountNumber: json['account_number'] as String,
      bankCode: json['bank_code'] as String,
      accountName: json['account_name'] as String,
    );

Map<String, dynamic> _$BankResolveResultToJson(_BankResolveResult instance) =>
    <String, dynamic>{
      'account_number': instance.accountNumber,
      'bank_code': instance.bankCode,
      'account_name': instance.accountName,
    };

_InitializePurchaseResponse _$InitializePurchaseResponseFromJson(
  Map<String, dynamic> json,
) => _InitializePurchaseResponse(
  txRef: json['tx_ref'] as String,
  flutterwaveRef: json['flutterwave_ref'] as String?,
  status: json['status'] as String?,
  requiresOtp: json['requires_otp'] as bool? ?? false,
  publicKey: json['public_key'] as String,
  amount: (json['amount'] as num?)?.toDouble(),
  currency: json['currency'] as String?,
  customerEmail: json['customer_email'] as String?,
  customerName: json['customer_name'] as String?,
);

Map<String, dynamic> _$InitializePurchaseResponseToJson(
  _InitializePurchaseResponse instance,
) => <String, dynamic>{
  'tx_ref': instance.txRef,
  'flutterwave_ref': instance.flutterwaveRef,
  'status': instance.status,
  'requires_otp': instance.requiresOtp,
  'public_key': instance.publicKey,
  'amount': instance.amount,
  'currency': instance.currency,
  'customer_email': instance.customerEmail,
  'customer_name': instance.customerName,
};

_ConfirmPurchaseResponse _$ConfirmPurchaseResponseFromJson(
  Map<String, dynamic> json,
) => _ConfirmPurchaseResponse(
  transaction: ArtifactTransaction.fromJson(
    json['transaction'] as Map<String, dynamic>,
  ),
  newBalance: Map<String, int>.from(json['new_balance'] as Map),
);

Map<String, dynamic> _$ConfirmPurchaseResponseToJson(
  _ConfirmPurchaseResponse instance,
) => <String, dynamic>{
  'transaction': instance.transaction,
  'new_balance': instance.newBalance,
};

_ExchangeRates _$ExchangeRatesFromJson(Map<String, dynamic> json) =>
    _ExchangeRates(
      rates: (json['rates'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      baseCurrency: json['base_currency'] as String,
      localCurrency: json['local_currency'] as String,
      conversionRate: (json['conversion_rate'] as num).toDouble(),
      labels: Map<String, String>.from(json['labels'] as Map),
    );

Map<String, dynamic> _$ExchangeRatesToJson(_ExchangeRates instance) =>
    <String, dynamic>{
      'rates': instance.rates,
      'base_currency': instance.baseCurrency,
      'local_currency': instance.localCurrency,
      'conversion_rate': instance.conversionRate,
      'labels': instance.labels,
    };
