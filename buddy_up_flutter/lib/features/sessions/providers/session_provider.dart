import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/models/session.dart';
import '../../../core/api/api_client.dart';
import '../../../core/cache/with_cache.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final dio = ref.watch(apiClientProvider9).dio;
  return SessionRepository(dio);
});

final apiClientProvider9 = Provider<ApiClient>((_) => ApiClient());

List<TrainerProfile> _parseTrainerList(dynamic data) =>
    (data as List).map((e) => TrainerProfile.fromJson(e as Map<String, dynamic>)).toList();

List<BookingSession> _parseBookingList(dynamic data) =>
    (data as List).map((e) => BookingSession.fromJson(e as Map<String, dynamic>)).toList();

final trainersProvider = FutureProvider<List<TrainerProfile>>((ref) async {
  return withCache(ref, 'trainers', () async {
    final repo = ref.watch(sessionRepositoryProvider);
    final raw = await repo.getTrainers(0, 50);
    return _parseTrainerList(raw['data']);
  });
});

final trainerProvider = FutureProvider.family<TrainerProfile, String>((ref, username) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final raw = await repo.getTrainer(username);
  return TrainerProfile.fromJson(raw['data'] as Map<String, dynamic>);
});

final trainerAvailabilityProvider = FutureProvider.family<List<AvailabilitySlot>, String>((ref, username) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final raw = await repo.getTrainerAvailability(username);
  return (raw['data'] as List)
      .map((e) => AvailabilitySlot.fromJson(e as Map<String, dynamic>))
      .toList();
});

final trainerReviewsProvider = FutureProvider.family<List<SessionReview>, String>((ref, username) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final raw = await repo.getTrainerReviews(username);
  return (raw['data'] as List)
      .map((e) => SessionReview.fromJson(e as Map<String, dynamic>))
      .toList();
});

final mySessionsProvider = FutureProvider<List<BookingSession>>((ref) async {
  return withCache(ref, 'my_sessions', () async {
    final repo = ref.watch(sessionRepositoryProvider);
    final raw = await repo.getMySessions(0, 50);
    return _parseBookingList(raw['data']);
  });
});

class PaginatedTrainerState {
  final List<TrainerProfile> trainers;
  final bool isLoadingMore;
  final bool hasMore;
  final int offset;

  const PaginatedTrainerState({
    this.trainers = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.offset = 0,
  });

  PaginatedTrainerState copyWith({
    List<TrainerProfile>? trainers,
    bool? isLoadingMore,
    bool? hasMore,
    int? offset,
  }) {
    return PaginatedTrainerState(
      trainers: trainers ?? this.trainers,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
    );
  }
}

class PaginatedTrainerNotifier extends Notifier<PaginatedTrainerState> {
  @override
  PaginatedTrainerState build() => const PaginatedTrainerState();

  SessionRepository get _repository => ref.read(sessionRepositoryProvider);

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final raw = await _repository.getTrainers(state.offset, 20);
      final data = raw['data'] as List;
      final items = data.map((e) => TrainerProfile.fromJson(e as Map<String, dynamic>)).toList();
      state = state.copyWith(
        trainers: [...state.trainers, ...items],
        isLoadingMore: false,
        hasMore: items.length >= 20,
        offset: state.offset + items.length,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    state = const PaginatedTrainerState();
    await loadMore();
  }
}

final paginatedTrainersProvider = NotifierProvider<PaginatedTrainerNotifier, PaginatedTrainerState>(
  PaginatedTrainerNotifier.new,
);

class PaginatedSessionState {
  final List<BookingSession> sessions;
  final bool isLoadingMore;
  final bool hasMore;
  final int offset;

  const PaginatedSessionState({
    this.sessions = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.offset = 0,
  });

  PaginatedSessionState copyWith({
    List<BookingSession>? sessions,
    bool? isLoadingMore,
    bool? hasMore,
    int? offset,
  }) {
    return PaginatedSessionState(
      sessions: sessions ?? this.sessions,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
    );
  }
}

class PaginatedSessionNotifier extends Notifier<PaginatedSessionState> {
  @override
  PaginatedSessionState build() => const PaginatedSessionState();

  SessionRepository get _repository => ref.read(sessionRepositoryProvider);

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final raw = await _repository.getMySessions(state.offset, 20);
      final data = raw['data'] as List;
      final items = data.map((e) => BookingSession.fromJson(e as Map<String, dynamic>)).toList();
      state = state.copyWith(
        sessions: [...state.sessions, ...items],
        isLoadingMore: false,
        hasMore: items.length >= 20,
        offset: state.offset + items.length,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    state = const PaginatedSessionState();
    await loadMore();
  }
}

final paginatedSessionsProvider = NotifierProvider<PaginatedSessionNotifier, PaginatedSessionState>(
  PaginatedSessionNotifier.new,
);

final myAvailabilityProvider = FutureProvider<List<AvailabilitySlot>>((ref) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final raw = await repo.getMyAvailability();
  return (raw['data'] as List)
      .map((e) => AvailabilitySlot.fromJson(e as Map<String, dynamic>))
      .toList();
});

final programmeWeeksProvider = FutureProvider.family<List<ProgrammeWeek>, String>((ref, programmeId) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final raw = await repo.getProgrammeWeeks(programmeId);
  return (raw['data'] as List)
      .map((e) => ProgrammeWeek.fromJson(e as Map<String, dynamic>))
      .toList();
});

final myEnrollmentsProvider = FutureProvider<List<ProgrammeEnrollment>>((ref) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final raw = await repo.getMyEnrollments();
  return (raw['data'] as List)
      .map((e) => ProgrammeEnrollment.fromJson(e as Map<String, dynamic>))
      .toList();
});
