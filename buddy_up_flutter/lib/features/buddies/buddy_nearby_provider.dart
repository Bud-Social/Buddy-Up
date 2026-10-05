import 'package:dio/dio.dart';
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
  final String displayName;
  final double? distanceKm;
  final List<String> intents;
  final String customIntent;
  final List<String> modes;
  final String bio;
  final List<String> goals;
  final String pace;
  final String ageBand;
  final String neighbourhood;
  final List<String> photos;
  final bool availableNow;
  final String explanation;

  /// I have liked this buddy. Optimistically flipped by [BuddyNearbyNotifier.
  /// toggleLike] so the heart responds before the round-trip.
  final bool likedByMe;

  /// They have liked me — the back-signal that makes a mutual like possible.
  final bool likedMe;

  NearbyBuddy({
    required this.profile,
    required this.displayName,
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
    this.pace = '',
    this.neighbourhood = '',
    this.likedByMe = false,
    this.likedMe = false,
  });

  String get username => (profile['username'] ?? '') as String;

  NearbyBuddy copyWith({bool? likedByMe, bool? likedMe}) => NearbyBuddy(
        profile: profile,
        displayName: displayName,
        distanceKm: distanceKm,
        intents: intents,
        customIntent: customIntent,
        modes: modes,
        bio: bio,
        goals: goals,
        pace: pace,
        ageBand: ageBand,
        neighbourhood: neighbourhood,
        photos: photos,
        availableNow: availableNow,
        explanation: explanation,
        likedByMe: likedByMe ?? this.likedByMe,
        likedMe: likedMe ?? this.likedMe,
      );

  factory NearbyBuddy.fromJson(Map<String, dynamic> json) {
    final profile = (json['profile'] as Map<String, dynamic>?) ?? const {};
    final rawName = json['display_name'] as String?;
    return NearbyBuddy(
        profile: profile,
        displayName: (rawName != null && rawName.isNotEmpty)
            ? rawName
            : (profile['display_name'] as String? ?? ''),
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        intents: ((json['intents'] as List?) ?? []).map((e) => e.toString()).toList(),
        customIntent: json['custom_intent'] as String? ?? '',
        modes: ((json['modes'] as List?) ?? []).map((e) => e.toString()).toList(),
        bio: json['bio'] as String? ?? '',
        goals: ((json['goals'] as List?) ?? []).map((e) => e.toString()).toList(),
        pace: json['pace'] as String? ?? '',
        ageBand: json['age_band'] as String? ?? '',
        neighbourhood: json['neighbourhood'] as String? ?? '',
        photos: ((json['photos'] as List?) ?? []).map((e) => e.toString()).toList(),
        availableNow: json['available_now'] as bool? ?? false,
        explanation: json['explanation'] as String? ?? '',
        likedByMe: json['liked_by_me'] as bool? ?? false,
        likedMe: json['liked_me'] as bool? ?? false,
      );
  }
}

class SearchProfile {
  final List<String> intents;
  final String displayName;
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
  final double? searchRadiusKm;
  final String? availableUntil;

  const SearchProfile({
    this.intents = const [],
    this.displayName = '',
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
    this.searchRadiusKm,
    this.availableUntil,
  });

  factory SearchProfile.fromJson(Map<String, dynamic> json) => SearchProfile(
        intents: ((json['intents'] as List?) ?? []).map((e) => e.toString()).toList(),
        displayName: json['display_name'] as String? ?? '',
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
        searchRadiusKm: (json['search_radius_km'] as num?)?.toDouble(),
        availableUntil: json['available_until'] as String?,
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
  final int matchCount;

  /// Usernames with a like request in flight — the heart disables itself so a
  /// double tap can't race two toggles against each other.
  final Set<String> liking;

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
    this.matchCount = 0,
    this.liking = const {},
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
    int? matchCount,
    Set<String>? liking,
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
      matchCount: matchCount ?? this.matchCount,
      liking: liking ?? this.liking,
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

  /// Toggle the one-way like on [username].
  ///
  /// Flips the heart immediately, then reconciles against the server. The
  /// back-signal (`liked_me`) is only ever advanced by the server — when a
  /// like completes a mutual match the row re-reads it from the response. On
  /// failure the row rolls back to exactly what it was and [likeError]
  /// carries a message worth showing.
  Future<String?> toggleLike(String username) async {
    final idx = state.buddies.indexWhere((b) => b.username == username);
    if (idx == -1) return 'Buddy not in this list.';
    if (state.liking.contains(username)) return null;

    final snapshot = state.buddies;
    final buddy = snapshot[idx];
    final wasLiked = buddy.likedByMe;
    _writeLike(snapshot, idx, likedByMe: !wasLiked);
    state = state.copyWith(liking: {...state.liking, username});

    try {
      final raw = wasLiked
          ? await _repo.unlikeInterest(username)
          : await _repo.likeInterest(username);
      final data = raw['data'];
      final likedMe = data is Map ? data['liked_me'] as bool? : null;
      final still = state.buddies.indexWhere((b) => b.username == username);
      if (still != -1) {
        _writeLike(
          state.buddies,
          still,
          likedByMe: !wasLiked,
          likedMe: likedMe,
        );
      }
      return null;
    } catch (e) {
      final back = state.buddies.indexWhere((b) => b.username == username);
      if (back != -1) _writeLike(state.buddies, back, likedByMe: wasLiked);
      return _serverMessage(e, 'Could not save that like.');
    } finally {
      state = state.copyWith(liking: {...state.liking}..remove(username));
    }
  }

  /// Fold a like confirmed elsewhere (the detail page) back into the grid so
  /// the heart matches when you navigate back.
  void applyLike(String username, {required bool likedByMe, required bool likedMe}) {
    final idx = state.buddies.indexWhere((b) => b.username == username);
    if (idx == -1) return;
    _writeLike(state.buddies, idx, likedByMe: likedByMe, likedMe: likedMe);
  }

  /// Write the like flags into [list] at [index] and publish it.
  ///
  /// list must be the array currently in state (identity matters — copyWith
  /// treats null as "unchanged", so a fresh list has to be built).
  void _writeLike(List<NearbyBuddy> list, int index, {bool? likedByMe, bool? likedMe}) {
    final next = [...list];
    next[index] = next[index].copyWith(likedByMe: likedByMe, likedMe: likedMe);
    state = state.copyWith(buddies: next);
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
  void setMatchCount(int v) => state = state.copyWith(matchCount: v);

  /// The backend states its own refusal ("You cannot like yourself.",
  /// "This profile is not open to buddy interests.") inside the response
  /// envelope — surface that rather than a generic failure.
  static String _serverMessage(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final direct = data['message'] ?? data['detail'];
        if (direct is String && direct.isNotEmpty) return direct;
        if (data['errors'] is Map) {
          final first = (data['errors'] as Map).values.firstOrNull;
          if (first is List && first.isNotEmpty && first.first is String) {
            return first.first as String;
          }
        }
      }
    }
    return fallback;
  }
}

final buddyNearbyProvider = NotifierProvider<BuddyNearbyNotifier, BuddyNearbyState>(BuddyNearbyNotifier.new);
