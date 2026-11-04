import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../models/countdown_models.dart';
import '../repositories/countdown_repository.dart';

final countdownApiClientProvider = Provider<ApiClient>((_) => ApiClient());

final countdownRepositoryProvider = Provider<CountdownRepository>((ref) {
  final dio = ref.watch(countdownApiClientProvider).dio;
  return CountdownRepository(dio);
});

/// State for the countdowns feature.
class CountdownsState {
  final List<CountdownTemplate> templates;
  final List<UserCountdown> countdowns;
  final bool isLoading;
  final String? error;

  const CountdownsState({
    this.templates = const [],
    this.countdowns = const [],
    this.isLoading = false,
    this.error,
  });

  CountdownsState copyWith({
    List<CountdownTemplate>? templates,
    List<UserCountdown>? countdowns,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CountdownsState(
      templates: templates ?? this.templates,
      countdowns: countdowns ?? this.countdowns,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CountdownsNotifier extends Notifier<CountdownsState> {
  @override
  CountdownsState build() => const CountdownsState();

  CountdownRepository get _repository => ref.read(countdownRepositoryProvider);

  /// Fetch templates and the user's countdowns.
  Future<void> load({bool? isActive}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final templates = await _repository.listTemplates();
      final countdowns = await _repository.listCountdowns(isActive: isActive);
      state = CountdownsState(
        templates: templates,
        countdowns: countdowns,
        isLoading: false,
      );
    } catch (e) {
      state = CountdownsState(
        templates: state.templates,
        countdowns: state.countdowns,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create a new countdown from a template or custom reason.
  Future<UserCountdown?> create({
    required String templateId,
    String? customReason,
    String countdownType = 'manual',
    String unit = 'days',
    int targetCount = 0,
    String? startDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final created = await _repository.createCountdown(
        CreateUserCountdown(
          templateId: templateId.isNotEmpty ? templateId : null,
          customReason: customReason,
          countdownType: countdownType,
          unit: unit,
          targetCount: targetCount,
          startDate: startDate,
        ).toRequestJson(),
      );
      state = state.copyWith(
        countdowns: [created, ...state.countdowns],
        isLoading: false,
      );
      return created;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Manual check-in: advance a manual countdown by one unit.
  Future<bool> checkIn(String id) async {
    try {
      final updated = await _repository.checkIn(id);
      state = state.copyWith(
        countdowns: [
          for (final c in state.countdowns)
            if (c.id == id) updated else c,
        ],
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Reset a countdown to zero.
  Future<bool> reset(String id) async {
    try {
      final updated = await _repository.reset(id);
      state = state.copyWith(
        countdowns: [
          for (final c in state.countdowns)
            if (c.id == id) updated else c,
        ],
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update a countdown (reason, target, etc.).
  Future<bool> update(String id, UpdateUserCountdown data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await _repository.updateCountdown(
        id,
        data.toRequestJson(),
      );
      state = state.copyWith(
        countdowns: [
          for (final c in state.countdowns)
            if (c.id == id) updated else c,
        ],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Delete a countdown.
  Future<bool> delete(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.deleteCountdown(id);
      state = state.copyWith(
        countdowns: state.countdowns.where((c) => c.id != id).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Advance automatic countdowns for a given signal (e.g. 'activity_walk').
  /// Called by the activity logger when a walk/run is saved.
  Future<void> autoAdvance(String signal) async {
    try {
      await _repository.autoAdvance({'signal': signal});
      // Refresh countdowns to pick up any advances.
      await load(isActive: true);
    } catch (_) {
      // Auto-advance failures are non-fatal; the countdowns will be
      // reconciled on the next load.
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final countdownsProvider = NotifierProvider<CountdownsNotifier, CountdownsState>(
  CountdownsNotifier.new,
);
