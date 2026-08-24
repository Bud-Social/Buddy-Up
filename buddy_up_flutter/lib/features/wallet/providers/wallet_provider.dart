import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../data/models/wallet.dart';
import '../../../core/api/api_client.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final dio = ref.watch(apiClientProvider6).dio;
  return WalletRepository(dio);
});

final apiClientProvider6 = Provider<ApiClient>((_) => ApiClient());

// -- Balance Provider --
class BalanceNotifier extends Notifier<AsyncValue<BalanceResponse?>> {
  @override
  AsyncValue<BalanceResponse?> build() => const AsyncData(null);

  WalletRepository get _repo => ref.read(walletRepositoryProvider);

  Future<void> loadBalance() async {
    state = const AsyncLoading();
    try {
      final raw = await _repo.getBalance();
      state = AsyncData(BalanceResponse.fromJson(raw['data'] as Map<String, dynamic>));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final balanceProvider = NotifierProvider<BalanceNotifier, AsyncValue<BalanceResponse?>>(BalanceNotifier.new);

// -- Transactions Provider --
class TransactionHistoryState {
  final List<ArtifactTransaction> transactions;
  final bool isLoading;
  final String? cursor;
  final bool hasMore;
  final String? error;
  final String? typeFilter;
  final String? directionFilter;

  const TransactionHistoryState({
    this.transactions = const [],
    this.isLoading = false,
    this.cursor,
    this.hasMore = true,
    this.error,
    this.typeFilter,
    this.directionFilter,
  });

  TransactionHistoryState copyWith({
    List<ArtifactTransaction>? transactions,
    bool? isLoading,
    String? cursor,
    bool? hasMore,
    String? error,
    String? typeFilter,
    String? directionFilter,
  }) {
    return TransactionHistoryState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      typeFilter: typeFilter ?? this.typeFilter,
      directionFilter: directionFilter ?? this.directionFilter,
    );
  }
}

class TransactionHistoryNotifier extends Notifier<TransactionHistoryState> {
  @override
  TransactionHistoryState build() => const TransactionHistoryState();

  WalletRepository get _repo => ref.read(walletRepositoryProvider);

  Future<void> load({String? type, String? direction}) async {
    state = state.copyWith(isLoading: true, error: null, typeFilter: type, directionFilter: direction);
    try {
      final raw = await _repo.getTransactions(type: type, direction: direction);
      state = state.copyWith(
        transactions: _parseTransactionList(raw['data']),
        isLoading: false,
        cursor: _extractCursor(raw['pagination']?['next'] as String?),
        hasMore: raw['pagination']?['next'] != null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    try {
      final raw = await _repo.getTransactions(
        type: state.typeFilter,
        direction: state.directionFilter,
        cursor: state.cursor,
      );
      state = state.copyWith(
        transactions: [...state.transactions, ..._parseTransactionList(raw['data'])],
        cursor: _extractCursor(raw['pagination']?['next'] as String?),
        hasMore: raw['pagination']?['next'] != null,
      );
    } catch (_) {}
  }

  String? _extractCursor(String? url) {
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    return uri?.queryParameters['cursor'];
  }
}

List<ArtifactTransaction> _parseTransactionList(dynamic data) =>
    (data as List).map((e) => ArtifactTransaction.fromJson(e as Map<String, dynamic>)).toList();

final transactionHistoryProvider = NotifierProvider<TransactionHistoryNotifier, TransactionHistoryState>(TransactionHistoryNotifier.new);

// -- Bundles Provider --
final bundlesProvider = FutureProvider<List<BundleInfo>>((ref) async {
  final repo = ref.watch(walletRepositoryProvider);
  final raw = await repo.getBundles();
  return (raw['data'] as List)
      .map((e) => BundleInfo.fromJson(e as Map<String, dynamic>))
      .toList();
});

// -- Exchange Rates Provider --
final exchangeRatesProvider = FutureProvider<ExchangeRates>((ref) async {
  final repo = ref.watch(walletRepositoryProvider);
  final raw = await repo.getExchangeRates();
  return ExchangeRates.fromJson(raw['data'] as Map<String, dynamic>);
});

// -- Banks Provider --
final banksProvider = FutureProvider<List<BankInfo>>((ref) async {
  final repo = ref.watch(walletRepositoryProvider);
  final raw = await repo.getBanks();
  return (raw['data'] as List)
      .map((e) => BankInfo.fromJson(e as Map<String, dynamic>))
      .toList();
});

// -- Creator Payouts Provider --
final creatorPayoutsProvider = FutureProvider<List<ArtifactTransaction>>((ref) async {
  final repo = ref.watch(walletRepositoryProvider);
  final raw = await repo.getPayoutHistory();
  return (raw['data'] as List)
      .map((e) => ArtifactTransaction.fromJson(e as Map<String, dynamic>))
      .toList();
});

