import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../data/models/routine.dart';
import '../../../data/repositories/routine_repository.dart';

final routineApiClientProvider = Provider<ApiClient>((_) => ApiClient());

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  final dio = ref.watch(routineApiClientProvider).dio;
  return RoutineRepository(dio);
});

class RoutinesState {
  final List<Routine> routines;
  final bool isLoading;
  final String? error;

  const RoutinesState({
    this.routines = const [],
    this.isLoading = false,
    this.error,
  });

  RoutinesState copyWith({
    List<Routine>? routines,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return RoutinesState(
      routines: routines ?? this.routines,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RoutinesNotifier extends Notifier<RoutinesState> {
  @override
  RoutinesState build() => const RoutinesState();

  RoutineRepository get _repo => ref.read(routineRepositoryProvider);

  static List<Routine> _parse(dynamic raw) {
    final data = raw is Map ? raw['data'] : raw;
    final list = data is List ? data : (data is Map ? data['results'] : null);
    if (list is! List) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(Routine.fromJson)
        .toList()
      ..sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        if (byOrder != 0) return byOrder;
        return b.createdAt?.compareTo(a.createdAt ?? '') ?? 0;
      });
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final raw = await _repo.getRoutines();
      state = RoutinesState(routines: _parse(raw), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Could not load routines');
    }
  }

  Future<bool> createOrUpdate({
    String? existingId,
    required String type,
    String? customName,
    String? name,
    required int target,
    required String unit,
    required List<int> days,
    int? targetDay,
    String? timeOfDay,
    required List<int> reminderMinutes,
    required String activation,
    required String tracking,
  }) async {
    final payload = <String, dynamic>{
      'type': type,
      'name': name ?? '',
      'target': target,
      'unit': unit,
      'days': days,
      'reminder_minutes': reminderMinutes,
      'activation': activation,
      'tracking': tracking,
      'custom_name': ?customName,
      'target_day': ?targetDay,
      'time_of_day': ?timeOfDay,
    };
    try {
      if (existingId != null) {
        await _repo.updateRoutine(existingId, payload);
      } else {
        await _repo.createRoutine(payload);
      }
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Could not save that routine');
      return false;
    }
  }

  Future<void> deleteRoutine(String id) async {
    await _repo.deleteRoutine(id);
    await load();
  }

  Future<RoutineCheckIn?> checkIn(String id, {int? value, String? note}) async {
    try {
      final raw = await _repo.checkIn(id, {
        'value': ?value,
        if (note != null && note.isNotEmpty) 'note': note,
      });
      final data = raw['data'] as Map<String, dynamic>?;
      final checkIn = data?['check_in'] as Map<String, dynamic>?;
      await load();
      if (checkIn != null) {
        return RoutineCheckIn.fromJson(checkIn);
      }
      return null;
    } catch (_) {
      state = state.copyWith(error: 'Check-in failed');
      return null;
    }
  }

  Future<void> reorder(List<String> orderedIds) async {
    await _repo.reorder({'ordered_ids': orderedIds});
    await load();
  }
}

final routinesProvider =
    NotifierProvider<RoutinesNotifier, RoutinesState>(RoutinesNotifier.new);
