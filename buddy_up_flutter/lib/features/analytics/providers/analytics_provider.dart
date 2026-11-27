import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../data/models/analytics.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../services/activity_queue_service.dart';

final apiClientProvider12 = Provider<ApiClient>((_) => ApiClient());

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final dio = ref.watch(apiClientProvider12).dio;
  return AnalyticsRepository(dio);
});

final activityQueueServiceProvider = Provider<ActivityQueueService>((ref) {
  return ActivityQueueService(ref.watch(analyticsRepositoryProvider));
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
      // Keep the last summary visible while reloading, and on failure: an
      // offline device should still show what it already knows.
      final previous = state.summary;
      final ownerId = ref.read(authProvider).user?.id;
      final localActivity = await ref
          .read(activityQueueServiceProvider)
          .localSummary(ownerId);
      final local = localActivity == null
          ? null
          : AnalyticsSummaryData(activity: localActivity);
      state = AnalyticsSummaryState(summary: previous, isLoading: true);
      try {
        final raw = await _repository.getSummary(period: p);
        state = AnalyticsSummaryState(
          summary: AnalyticsSummaryData.fromJson(
            raw['data'] as Map<String, dynamic>,
          ),
        );
      } catch (e) {
        state = AnalyticsSummaryState(
          summary: local ?? previous,
          error: e.toString(),
        );
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

  /// Full workout history — the summary's recent list omits the category and
  /// distance a share needs, so the rows read from here when it resolves.
  Future<void> loadWorkouts() async {
    try {
      final raw = await _repository.getWorkouts();
      final list = (raw['data'] as List?) ?? [];
      state = state.copyWith(
        items: [
          for (final entry in list)
            if (entry is Map<String, dynamic>) entry,
        ],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<Map<String, dynamic>?> logWorkout(Map<String, dynamic> data) async {
    try {
      final raw = await _repository.createWorkout(data);
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
    final queue = ref.read(activityQueueServiceProvider);
    final ownerId = ref.read(authProvider).user?.id;
    final payload = <String, dynamic>{
      ...data,
      'source_event_id':
          data['source_event_id'] ?? ActivityQueueService.newClientId(),
    };
    try {
      final raw = await _repository.createActivity(payload);
      if (ownerId != null) {
        await queue.recordLocalActivity(payload, ownerId: ownerId);
      }
      return raw['data'] as Map<String, dynamic>?;
    } catch (e) {
      // An unreachable or failing API should not cost the user their session:
      // keep it on the device and replay it when the server is healthy.
      if (ownerId != null && ActivityQueueService.isRetryable(e)) {
        try {
          final record = await queue.enqueue(payload, ownerId: ownerId);
          return {'queued': true, 'client_id': record.clientId};
        } catch (_) {
          // Local storage refused too — surface the original failure.
        }
      }
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

final analyticsLogProvider =
    NotifierProvider<AnalyticsLogNotifier, AnalyticsHistoryState>(
      AnalyticsLogNotifier.new,
    );
