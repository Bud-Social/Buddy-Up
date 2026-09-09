import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
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
