import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/verification_repository.dart';
import '../../../data/models/verification.dart';
import '../../../core/api/api_client.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  final dio = ref.watch(apiClientProvider8).dio;
  return VerificationRepository(dio);
});

final apiClientProvider8 = Provider<ApiClient>((_) => ApiClient());

final verificationSubmissionsProvider = FutureProvider<List<VerificationSubmission>>((ref) async {
  final repo = ref.watch(verificationRepositoryProvider);
  final raw = await repo.getSubmissions();
  return (raw['data'] as List)
      .map((e) => VerificationSubmission.fromJson(e as Map<String, dynamic>))
      .toList();
});
