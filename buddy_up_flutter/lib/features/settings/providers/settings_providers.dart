import 'package:flutter_riverpod/flutter_riverpod.dart';
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
