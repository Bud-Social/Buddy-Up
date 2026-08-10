import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/analytics.dart';
import '../../../data/repositories/analytics_repository.dart';

final apiClientProvider12 = Provider<ApiClient>((_) => ApiClient());

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final dio = ref.watch(apiClientProvider12).dio;
  return AnalyticsRepository(dio);
});

final analyticsPeriodProvider =
    NotifierProvider<AnalyticsPeriodNotifier, String>(
      AnalyticsPeriodNotifier.new,
    );

class AnalyticsPeriodNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void set(String period) => state = period;
}

class AnalyticsSummaryState {
  final AnalyticsSummaryData? summary;
  final bool isLoading;
  final String? error;

  const AnalyticsSummaryState({
    this.summary,
    this.isLoading = false,
    this.error,
  });

  AnalyticsSummaryState copyWith({
    AnalyticsSummaryData? summary,
    bool? isLoading,
    String? error,
    bool clearSummary = false,
  }) {
    return AnalyticsSummaryState(
      summary: clearSummary ? null : (summary ?? this.summary),
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AnalyticsSummaryNotifier extends Notifier<AnalyticsSummaryState> {
  @override
  AnalyticsSummaryState build() => const AnalyticsSummaryState();

  AnalyticsRepository get _repository => ref.read(analyticsRepositoryProvider);

  Future<void> load({String? period}) async {
    final p = period ?? ref.read(analyticsPeriodProvider);
    if (p != null) {
      ref.read(analyticsPeriodProvider.notifier).set(p);
      state = const AnalyticsSummaryState(isLoading: true);
      try {
        final raw = await _repository.getSummary(period: p);
        state = AnalyticsSummaryState(
          summary: AnalyticsSummaryData.fromJson(
            raw['data'] as Map<String, dynamic>,
          ),
        );
      } catch (e) {
        state = AnalyticsSummaryState(error: e.toString());
      }
    }
  }

  Future<void> setPeriod(String period) async {
    if (period != ref.read(analyticsPeriodProvider)) {
      await load(period: period);
    }
  }

  Future<void> refresh() => load();
}

final analyticsSummaryProvider =
    NotifierProvider<AnalyticsSummaryNotifier, AnalyticsSummaryState>(
      AnalyticsSummaryNotifier.new,
    );

class AnalyticsHistoryState {
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final String? error;

  const AnalyticsHistoryState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  AnalyticsHistoryState copyWith({
    List<Map<String, dynamic>>? items,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsHistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AnalyticsLogNotifier extends Notifier<AnalyticsHistoryState> {
  @override
  AnalyticsHistoryState build() => const AnalyticsHistoryState();

  AnalyticsRepository get _repository => ref.read(analyticsRepositoryProvider);

  Future<Map<String, dynamic>?> logWorkout(Map<String, dynamic> data) async {
    try {
      final raw = await _repository.createWorkout(data);
      return raw['data'] as Map<String, dynamic>?;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> logMeal(Map<String, dynamic> data) async {
    try {
      final raw = await _repository.createMeal(data);
      return raw['data'] as Map<String, dynamic>?;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> logMealWithPhoto(
    Map<String, dynamic> data,
  ) async {
    try {
      final raw = await _repository.createMealWithPhoto(data);
      return raw['data'] as Map<String, dynamic>?;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> analyzeMealPhoto(
    Map<String, dynamic> data,
  ) async {
    try {
      final raw = await _repository.analyzeMealPhoto(data);
      return raw['data'] as Map<String, dynamic>?;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> logBodyMetric(Map<String, dynamic> data) async {
    try {
      final raw = await _repository.createBodyMetric(data);
      return raw['data'] as Map<String, dynamic>?;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> readBodyWeight(
    Map<String, dynamic> data,
  ) async {
    try {
      final raw = await _repository.readBodyWeight(data);
      return raw['data'] as Map<String, dynamic>?;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> logActivity(Map<String, dynamic> data) async {
    try {
      final raw = await _repository.createActivity(data);
      return raw['data'] as Map<String, dynamic>?;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

final analyticsLogProvider =
    NotifierProvider<AnalyticsLogNotifier, AnalyticsHistoryState>(
      AnalyticsLogNotifier.new,
    );
