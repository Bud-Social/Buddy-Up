import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/messaging.dart';
import '../../messaging/providers/messaging_provider.dart'
    show messagingRepositoryProvider;

final communityActivitiesRepositoryProvider = messagingRepositoryProvider;

List<T> _parse<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
  final list = raw is List ? raw : (raw is Map && raw['data'] is List ? raw['data'] as List : const []);
  return list
      .map((e) => fromJson(e as Map<String, dynamic>))
      .toList();
}

class CommunityActivitiesState {
  final List<CommunityEvent> events;
  final List<CommunityLive> lives;
  final List<CommunitySchedule> schedules;
  final bool isLoading;
  final String? error;

  const CommunityActivitiesState({
    this.events = const [],
    this.lives = const [],
    this.schedules = const [],
    this.isLoading = false,
    this.error,
  });

  CommunityActivitiesState copyWith({
    List<CommunityEvent>? events,
    List<CommunityLive>? lives,
    List<CommunitySchedule>? schedules,
    bool? isLoading,
    String? error,
  }) {
    return CommunityActivitiesState(
      events: events ?? this.events,
      lives: lives ?? this.lives,
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CommunityActivitiesNotifier
    extends AsyncNotifier<CommunityActivitiesState> {
  final String communityId;

  CommunityActivitiesNotifier(this.communityId);

  @override
  Future<CommunityActivitiesState> build() => _load();

  Future<CommunityActivitiesState> _load() async {
    final repo = ref.read(communityActivitiesRepositoryProvider);
    final results = await Future.wait([
      repo.getCommunityEvents(communityId),
      repo.getCommunityLives(communityId),
      repo.getCommunitySchedules(communityId),
    ]);
    return CommunityActivitiesState(
      events: _parse(results[0], CommunityEvent.fromJson),
      lives: _parse(results[1], CommunityLive.fromJson),
      schedules: _parse(results[2], CommunitySchedule.fromJson),
      isLoading: false,
    );
  }

  Future<void> reload() async {
    try {
      state = AsyncValue.data(await _load());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createEvent(Map<String, dynamic> payload) async {
    final repo = ref.read(communityActivitiesRepositoryProvider);
    await repo.createCommunityEvent(communityId, payload);
    await reload();
  }

  Future<void> createLive(Map<String, dynamic> payload) async {
    final repo = ref.read(communityActivitiesRepositoryProvider);
    await repo.createCommunityLive(communityId, payload);
    await reload();
  }

  Future<void> createSchedule(Map<String, dynamic> payload) async {
    final repo = ref.read(communityActivitiesRepositoryProvider);
    await repo.createCommunitySchedule(communityId, payload);
    await reload();
  }

  Future<void> deleteEvent(String id) async {
    final repo = ref.read(communityActivitiesRepositoryProvider);
    await repo.deleteCommunityEvent(communityId, id);
    await reload();
  }

  Future<void> deleteLive(String id) async {
    final repo = ref.read(communityActivitiesRepositoryProvider);
    await repo.deleteCommunityLive(communityId, id);
    await reload();
  }

  Future<void> deleteSchedule(String id) async {
    final repo = ref.read(communityActivitiesRepositoryProvider);
    await repo.deleteCommunitySchedule(communityId, id);
    await reload();
  }
}

final communityActivitiesProvider =
    AsyncNotifierProvider.family<
      CommunityActivitiesNotifier,
      CommunityActivitiesState,
      String
    >(CommunityActivitiesNotifier.new);
