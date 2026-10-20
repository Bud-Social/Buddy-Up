import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../data/repositories/admin_portal_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/guardian_repository.dart';
import '../../../data/repositories/profile_repository.dart';

final settingsApiClientProvider = Provider<ApiClient>((_) => ApiClient());

final settingsAuthRepoProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(settingsApiClientProvider).dio;
  return AuthRepository(dio);
});

final settingsProfileRepoProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(settingsApiClientProvider).dio;
  return ProfileRepository(dio);
});

final settingsGuardianRepoProvider = Provider<GuardianRepository>((ref) {
  final dio = ref.watch(settingsApiClientProvider).dio;
  return GuardianRepository(dio);
});

/// The moderation surface reachable by an ordinary signed-in user: appeals
/// they raised and commendations addressed to them.
///
/// Deliberately the *same* typed client the admin console uses rather than a
/// second repository over the same routes — the endpoints are identical, and
/// two clients over one API is two places for the contract to drift. Only
/// `IsAuthenticated` endpoints are ever called from the settings tree.
final settingsAdminRepoProvider = Provider<AdminPortalRepository>((ref) {
  final dio = ref.watch(settingsApiClientProvider).dio;
  return AdminPortalRepository(dio);
});

/// Device-level left-handed mode: post interaction rows mirror so the
/// primary actions sit under a left thumb. Persisted in SharedPreferences.
class HandednessNotifier extends Notifier<bool> {
  static const _key = 'buddyup_left_handed';

  @override
  bool build() {
    var disposed = false;
    ref.onDispose(() => disposed = true);
    SharedPreferences.getInstance().then((prefs) {
      if (!disposed) state = prefs.getBool(_key) ?? false;
    }).catchError((_) {});
    return false;
  }

  Future<void> setLeftHanded(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}

final handednessProvider =
    NotifierProvider<HandednessNotifier, bool>(HandednessNotifier.new);

class ProfanityFilterNotifier extends Notifier<bool> {
  static const _key = 'buddyup_profanity_filter';

  @override
  bool build() {
    var disposed = false;
    ref.onDispose(() => disposed = true);
    SharedPreferences.getInstance().then((prefs) {
      if (!disposed) state = prefs.getBool(_key) ?? true;
    }).catchError((_) {});
    return false;
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}

final profanityFilterProvider =
    NotifierProvider<ProfanityFilterNotifier, bool>(ProfanityFilterNotifier.new);

