import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/geo_notice.dart';

export '../../../shared/models/geo_notice.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((_) {
  return ProfileRepository(ApiClient().dio);
});

class NearbyBuddy {
  final Map<String, dynamic> profile;
  final double? distanceKm;
  final List<String> intents;
  final String customIntent;
  final List<String> modes;
  final String bio;
  final List<String> goals;
  final String ageBand;
  final List<String> photos;
  final bool availableNow;
  final String explanation;

  NearbyBuddy({
    required this.profile,
    required this.distanceKm,
    required this.intents,
    required this.customIntent,
    required this.modes,
    required this.bio,
    required this.goals,
    required this.ageBand,
    required this.photos,
    required this.availableNow,
    required this.explanation,
  });

  factory NearbyBuddy.fromJson(Map<String, dynamic> json) => NearbyBuddy(
        profile: (json['profile'] as Map<String, dynamic>?) ?? const {},
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        intents: ((json['intents'] as List?) ?? []).map((e) => e.toString()).toList(),
        customIntent: json['custom_intent'] as String? ?? '',
        modes: ((json['modes'] as List?) ?? []).map((e) => e.toString()).toList(),
        bio: json['bio'] as String? ?? '',
        goals: ((json['goals'] as List?) ?? []).map((e) => e.toString()).toList(),
        ageBand: json['age_band'] as String? ?? '',
        photos: ((json['photos'] as List?) ?? []).map((e) => e.toString()).toList(),
        availableNow: json['available_now'] as bool? ?? false,
        explanation: json['explanation'] as String? ?? '',
      );
}

class SearchProfile {
  final List<String> intents;
  final String customIntent;
  final List<String> modes;
  final String bio;
  final List<String> goals;
  final String ageBand;
  final List<String> photos;
  final String neighbourhood;
  final String pace;
  final String visibility;
  final bool incognito;
  final bool availableNow;

  const SearchProfile({
    this.intents = const [],
    this.customIntent = '',
    this.modes = const [],
    this.bio = '',
    this.goals = const [],
    this.ageBand = '',
    this.photos = const [],
    this.neighbourhood = '',
    this.pace = '',
    this.visibility = 'public',
    this.incognito = false,
    this.availableNow = false,
  });

  factory SearchProfile.fromJson(Map<String, dynamic> json) => SearchProfile(
        intents: ((json['intents'] as List?) ?? []).map((e) => e.toString()).toList(),
        customIntent: json['custom_intent'] as String? ?? '',
        modes: ((json['modes'] as List?) ?? []).map((e) => e.toString()).toList(),
        bio: json['bio'] as String? ?? '',
        goals: ((json['goals'] as List?) ?? []).map((e) => e.toString()).toList(),
        ageBand: json['age_band'] as String? ?? '',
        photos: ((json['photos'] as List?) ?? []).map((e) => e.toString()).toList(),
        neighbourhood: json['neighbourhood'] as String? ?? '',
        pace: json['pace'] as String? ?? '',
        visibility: json['visibility'] as String? ?? 'public',
        incognito: json['incognito'] as bool? ?? false,
        availableNow: json['available_now'] as bool? ?? false,
      );
}

class BuddyNearbyState {
  final List<NearbyBuddy> buddies;
  final bool isLoading;
  final String? error;
  final String? intent;
  final String? mode;
  final bool nowOnly;
  final double? lat;
  final double? lng;
  final double? radiusKm;
  final GeoNotice? geo;

  const BuddyNearbyState({
    this.buddies = const [],
    this.isLoading = false,
    this.error,
    this.intent,
    this.mode,
    this.nowOnly = false,
    this.lat,
    this.lng,
    this.radiusKm,
    this.geo,
  });

  BuddyNearbyState copyWith({
    List<NearbyBuddy>? buddies,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? intent,
    bool clearIntent = false,
    String? mode,
    bool clearMode = false,
    bool? nowOnly,
    double? lat,
    double? lng,
    double? radiusKm,
    GeoNotice? geo,
    bool clearGeo = false,
    bool clearCoords = false,
  }) {
    return BuddyNearbyState(
      buddies: buddies ?? this.buddies,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      intent: clearIntent ? null : (intent ?? this.intent),
      mode: clearMode ? null : (mode ?? this.mode),
      nowOnly: nowOnly ?? this.nowOnly,
      lat: clearCoords ? null : (lat ?? this.lat),
      lng: clearCoords ? null : (lng ?? this.lng),
      radiusKm: radiusKm ?? this.radiusKm,
      geo: clearGeo ? null : (geo ?? this.geo),
    );
  }
}

class BuddyNearbyNotifier extends Notifier<BuddyNearbyState> {
  @override
  BuddyNearbyState build() => const BuddyNearbyState();

  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  Future<void> load({String? intent, bool clearIntent = false, String? mode, bool clearMode = false}) async {
    final useIntent = clearIntent ? null : (intent ?? state.intent);
    final useMode = clearMode ? null : (mode ?? state.mode);
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      intent: useIntent,
      clearIntent: clearIntent,
      mode: useMode,
      clearMode: clearMode,
    );
    try {
      final raw = await _repo.getNearbyBuddies(
        intent: useIntent,
        mode: useMode,
        lat: state.lat,
        lng: state.lng,
        radiusKm: state.radiusKm,
        now: state.nowOnly ? true : null,
      );
      final list = ((raw['data'] as List?) ?? [])
          .map((e) => NearbyBuddy.fromJson(e as Map<String, dynamic>))
          .toList();
      GeoNotice? geo;
      final geoJson = raw['geo'];
      if (geoJson is Map<String, dynamic>) geo = GeoNotice.fromJson(geoJson);
      state = state.copyWith(buddies: list, isLoading: false, clearError: true, geo: geo, clearGeo: geo == null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Persist the opt-in search profile (intents + GPS) so nearby keeps
  /// working and other users can find me. Fire-and-forget safe.
  Future<void> persistSearchProfile() async {
    try {
      await _repo.updateSearchProfile({
        if (state.intent != null) 'intents': [state.intent],
        if (state.mode != null) 'modes': [state.mode],
        if (state.lat != null) 'latitude': state.lat,
        if (state.lng != null) 'longitude': state.lng,
      });
    } catch (_) {}
  }

  void setCoords(double? lat, double? lng) {
    if (lat == null || lng == null) {
      state = state.copyWith(clearCoords: true);
    } else {
      state = state.copyWith(lat: lat, lng: lng);
    }
  }

  void setRadius(double? radiusKm) => state = state.copyWith(radiusKm: radiusKm);
  void setNowOnly(bool v) => state = state.copyWith(nowOnly: v);
}

final buddyNearbyProvider = NotifierProvider<BuddyNearbyNotifier, BuddyNearbyState>(BuddyNearbyNotifier.new);
