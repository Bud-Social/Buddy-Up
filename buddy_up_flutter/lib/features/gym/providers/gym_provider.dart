import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/gym_repository.dart';
import '../../../data/models/gym.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/geo_notice.dart';

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
  final String formatFilter;
  final double? lat;
  final double? lng;
  final double? radiusKm;
  final GeoNotice? geo;

  const GymListState({
    this.gyms = const [],
    this.isLoading = false,
    this.error,
    this.query,
    this.categoryFilter,
    this.formatFilter = 'all',
    this.lat,
    this.lng,
    this.radiusKm,
    this.geo,
  });

  GymListState copyWith({
    List<Gym>? gyms,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? query,
    bool clearQuery = false,
    String? categoryFilter,
    bool clearCategory = false,
    String? formatFilter,
    double? lat,
    double? lng,
    double? radiusKm,
    GeoNotice? geo,
    bool clearGeo = false,
    bool clearCoords = false,
  }) {
    return GymListState(
      gyms: gyms ?? this.gyms,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      query: clearQuery ? null : (query ?? this.query),
      categoryFilter: clearCategory ? null : (categoryFilter ?? this.categoryFilter),
      formatFilter: formatFilter ?? this.formatFilter,
      lat: clearCoords ? null : (lat ?? this.lat),
      lng: clearCoords ? null : (lng ?? this.lng),
      radiusKm: radiusKm ?? this.radiusKm,
      geo: clearGeo ? null : (geo ?? this.geo),
    );
  }
}

class GymListNotifier extends Notifier<GymListState> {
  @override
  GymListState build() => const GymListState();

  GymRepository get _repository => ref.read(gymRepositoryProvider);

  Future<void> loadGyms({
    String? query,
    bool clearQuery = false,
    String? category,
    bool clearCategory = false,
    String? format,
    double? lat,
    double? lng,
    double? radiusKm,
    String? ordering,
  }) async {
    final fmt = format ?? state.formatFilter;
    final useLat = lat ?? state.lat;
    final useLng = lng ?? state.lng;
    final useGeo = useLat != null && useLng != null && fmt != 'virtual';
    final useRadius = radiusKm ?? state.radiusKm;
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      query: query,
      clearQuery: clearQuery,
      categoryFilter: category,
      clearCategory: clearCategory,
      formatFilter: fmt,
      lat: useLat,
      lng: useLng,
      radiusKm: useRadius,
      clearGeo: !useGeo,
    );
    try {
      final raw = await _repository.getGyms(
        query: clearQuery ? null : (query ?? state.query),
        category: clearCategory ? null : (category ?? state.categoryFilter),
        delivery: fmt == 'all' ? null : fmt,
        lat: useGeo ? useLat : null,
        lng: useGeo ? useLng : null,
        radiusKm: useGeo ? useRadius : null,
        ordering: ordering ?? (useGeo ? 'nearest' : null),
      );
      final gyms = _parseGymList(raw['data']);
      if (useGeo) {
        gyms.sort((a, b) => (a.distanceKm ?? double.infinity).compareTo(b.distanceKm ?? double.infinity));
      }
      GeoNotice? geo;
      final geoJson = raw['geo'];
      if (geoJson is Map<String, dynamic>) geo = GeoNotice.fromJson(geoJson);
      state = state.copyWith(gyms: gyms, isLoading: false, clearError: true, geo: geo, clearGeo: geo == null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setCoords(double? lat, double? lng) {
    if (lat == null || lng == null) {
      state = state.copyWith(clearCoords: true);
    } else {
      state = state.copyWith(lat: lat, lng: lng);
    }
  }

  void setRadius(double? radiusKm) {
    state = state.copyWith(radiusKm: radiusKm);
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
