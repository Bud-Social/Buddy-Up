import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../data/models/live.dart';
import '../../../core/api/api_client.dart';

final liveRepositoryProvider = Provider<LiveRepository>((ref) {
  final dio = ref.watch(apiClientProvider3).dio;
  return LiveRepository(dio);
});

final apiClientProvider3 = Provider<ApiClient>((_) => ApiClient());

List<BuddyLive> _parseLiveList(dynamic data) =>
    (data as List).map((e) => BuddyLive.fromJson(e as Map<String, dynamic>)).toList();

class LiveBrowserState {
  final List<BuddyLive> lives;
  final String activeTab;
  final bool isLoading;
  final String? cursor;
  final bool hasMore;
  final String? error;

  const LiveBrowserState({
    this.lives = const [],
    this.activeTab = 'live',
    this.isLoading = false,
    this.cursor,
    this.hasMore = true,
    this.error,
  });

  LiveBrowserState copyWith({
    List<BuddyLive>? lives,
    String? activeTab,
    bool? isLoading,
    String? cursor,
    bool? hasMore,
    String? error,
  }) {
    return LiveBrowserState(
      lives: lives ?? this.lives,
      activeTab: activeTab ?? this.activeTab,
      isLoading: isLoading ?? this.isLoading,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}

class LiveBrowserNotifier extends Notifier<LiveBrowserState> {
  @override
  LiveBrowserState build() => const LiveBrowserState();

  LiveRepository get _repository => ref.read(liveRepositoryProvider);

  Future<void> browse({String? tab}) async {
    final t = tab ?? state.activeTab;
    state = state.copyWith(isLoading: true, error: null, activeTab: t);
    try {
      final raw = await _repository.browse(tab: t);
      final pagination = raw['pagination'] as Map<String, dynamic>?;
      state = state.copyWith(
        lives: _parseLiveList(raw['data']),
        isLoading: false,
        cursor: _extractCursor(pagination?['next'] as String?),
        hasMore: pagination?['next'] != null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    try {
      final raw = await _repository.browse(tab: state.activeTab, cursor: state.cursor);
      final pagination = raw['pagination'] as Map<String, dynamic>?;
      state = state.copyWith(
        lives: [...state.lives, ..._parseLiveList(raw['data'])],
        cursor: _extractCursor(pagination?['next'] as String?),
        hasMore: pagination?['next'] != null,
      );
    } catch (_) {}
  }

  void setTab(String tab) {
    if (tab != state.activeTab) {
      state = state.copyWith(lives: [], cursor: null, hasMore: true);
      browse(tab: tab);
    }
  }

  String? _extractCursor(String? url) {
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    return uri?.queryParameters['cursor'];
  }
}

final liveBrowserProvider = NotifierProvider<LiveBrowserNotifier, LiveBrowserState>(LiveBrowserNotifier.new);

final liveDetailProvider = FutureProvider.family<BuddyLive, String>((ref, liveId) async {
  final repo = ref.watch(liveRepositoryProvider);
  final raw = await repo.getLive(liveId);
  return BuddyLive.fromJson(raw['data'] as Map<String, dynamic>);
});

final userLivesProvider = FutureProvider.family<List<BuddyLive>, String>((ref, username) async {
  final repo = ref.watch(liveRepositoryProvider);
  final raw = await repo.getUserLives(username);
  return _parseLiveList(raw['data']);
});

final gymScheduleLivesProvider = FutureProvider.family<List<BuddyLive>, String>((ref, gymId) async {
  final repo = ref.watch(liveRepositoryProvider);
  final raw = await repo.getGymSchedule(gymId);
  return _parseLiveList(raw['data']);
});

final randomDropStatusProvider = FutureProvider<RandomDropStatus?>((ref) async {
  final repo = ref.watch(liveRepositoryProvider);
  try {
    final raw = await repo.getRandomDropStatus();
    return RandomDropStatus.fromJson(raw['data'] as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
});
