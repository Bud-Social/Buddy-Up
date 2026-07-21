import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/gym_repository.dart';
import '../../../data/models/gym.dart';
import '../../../core/api/api_client.dart';

final gymRepositoryProvider = Provider<GymRepository>((ref) {
  final dio = ref.watch(apiClientProvider2).dio;
  return GymRepository(dio);
});

final apiClientProvider2 = Provider<ApiClient>((_) => ApiClient());

List<Gym> _parseGymList(dynamic data) =>
    (data as List).map((e) => Gym.fromJson(e as Map<String, dynamic>)).toList();
List<GymMembership> _parseMemberList(dynamic data) =>
    (data as List).map((e) => GymMembership.fromJson(e as Map<String, dynamic>)).toList();
List<GymSchedulePost> _parseScheduleList(dynamic data) =>
    (data as List).map((e) => GymSchedulePost.fromJson(e as Map<String, dynamic>)).toList();
List<GymReview> _parseReviewList(dynamic data) =>
    (data as List).map((e) => GymReview.fromJson(e as Map<String, dynamic>)).toList();
List<JoinRequest> _parseJoinRequestList(dynamic data) =>
    (data as List).map((e) => JoinRequest.fromJson(e as Map<String, dynamic>)).toList();
List<GymEvent> _parseEventList(dynamic data) =>
    (data as List).map((e) => GymEvent.fromJson(e as Map<String, dynamic>)).toList();
List<GymCategory> _parseCategoryList(dynamic data) =>
    (data as List).map((e) => GymCategory.fromJson(e as Map<String, dynamic>)).toList();

class GymListState {
  final List<Gym> gyms;
  final bool isLoading;
  final String? error;
  final String? query;
  final String? categoryFilter;

  const GymListState({
    this.gyms = const [],
    this.isLoading = false,
    this.error,
    this.query,
    this.categoryFilter,
  });

  GymListState copyWith({
    List<Gym>? gyms,
    bool? isLoading,
    String? error,
    String? query,
    String? categoryFilter,
  }) {
    return GymListState(
      gyms: gyms ?? this.gyms,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      query: query ?? this.query,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }
}

class GymListNotifier extends Notifier<GymListState> {
  @override
  GymListState build() => const GymListState();

  GymRepository get _repository => ref.read(gymRepositoryProvider);

  Future<void> loadGyms({String? query, String? category}) async {
    state = state.copyWith(isLoading: true, error: null, query: query, categoryFilter: category);
    try {
      final raw = await _repository.getGyms(query: query, category: category);
      state = state.copyWith(gyms: _parseGymList(raw['data']), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final gymListProvider = NotifierProvider<GymListNotifier, GymListState>(GymListNotifier.new);

final gymDetailProvider = FutureProvider.family<Gym, String>((ref, slug) async {
  final repo = ref.watch(gymRepositoryProvider);
  final raw = await repo.getGym(slug);
  return Gym.fromJson(raw['data'] as Map<String, dynamic>);
});

final membersProvider = FutureProvider.family<List<GymMembership>, String>((ref, slug) async {
  final repo = ref.watch(gymRepositoryProvider);
  final raw = await repo.getMembers(slug);
  return _parseMemberList(raw['data']);
});

final schedulePostsProvider = FutureProvider.family<List<GymSchedulePost>, String>((ref, slug) async {
  final repo = ref.watch(gymRepositoryProvider);
  final raw = await repo.getSchedulePosts(slug);
  return _parseScheduleList(raw['data']);
});

final reviewsProvider = FutureProvider.family<List<GymReview>, String>((ref, slug) async {
  final repo = ref.watch(gymRepositoryProvider);
  final raw = await repo.getReviews(slug);
  return _parseReviewList(raw['data']);
});

final joinRequestsProvider = FutureProvider.family<List<JoinRequest>, String>((ref, slug) async {
  final repo = ref.watch(gymRepositoryProvider);
  final raw = await repo.getJoinRequests(slug);
  return _parseJoinRequestList(raw['data']);
});

final gymEventsProvider = FutureProvider.family<List<GymEvent>, String>((ref, slug) async {
  final repo = ref.watch(gymRepositoryProvider);
  final raw = await repo.getEvents(slug);
  return _parseEventList(raw['data']);
});

final gymCategoriesProvider = FutureProvider<List<GymCategory>>((ref) async {
  final repo = ref.watch(gymRepositoryProvider);
  final raw = await repo.getCategories();
  return _parseCategoryList(raw['data']);
});
