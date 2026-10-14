import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../data/models/verification.dart';
import '../../../data/repositories/verification_repository.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  final dio = ref.watch(apiClientProvider8).dio;
  return VerificationRepository(dio);
});

final apiClientProvider8 = Provider<ApiClient>((_) => ApiClient());

/// Normalise a `/verification/**` list body.
///
/// This namespace has **no envelope**: `/verification/submissions/` is a
/// cursor-paginated DRF viewset (`{next, previous, results}`),
/// `my-applications` is `{count, results}`, and a bare array is what an older
/// deployment returned. All three are read; anything else is an empty list
/// rather than a `CastError` inside a settings screen.
List<Map<String, dynamic>> verificationRows(dynamic body) {
  if (body is List) {
    return body.whereType<Map>().map((row) => _stringKeyed(row)).toList();
  }
  if (body is Map) {
    for (final key in const ['results', 'data', 'items']) {
      final value = body[key];
      if (value is List) {
        return value.whereType<Map>().map((row) => _stringKeyed(row)).toList();
      }
    }
  }
  return [];
}

Map<String, dynamic> _stringKeyed(Map<dynamic, dynamic> json) =>
    json.map((key, value) => MapEntry('$key', value));

/// Every submission this session can see.
///
/// Server-scoped: a non-staff caller gets only their own. Cursor-paginated, so
/// there is no page number and no total — this reads the first page and the
/// console says how many rows it is holding rather than inventing a count.
final verificationSubmissionsProvider =
    FutureProvider<List<VerificationSubmission>>((ref) async {
  final repo = ref.watch(verificationRepositoryProvider);
  final raw = await repo.getSubmissions();
  return verificationRows(raw).map(VerificationSubmission.fromJson).toList();
});

final verificationDocumentsProvider =
    FutureProvider<List<VerificationDocument>>((ref) async {
  final repo = ref.watch(verificationRepositoryProvider);
  final raw = await repo.getDocuments();
  return verificationRows(raw).map(VerificationDocument.fromJson).toList();
});

/// Documents the applicant may cite in a category application.
///
/// The server re-checks ownership on every submit (`document_ids` are matched
/// against the caller's own profile and a foreign id is a 400), so this list is
/// a convenience for the picker rather than a gate.
final attachableDocumentsProvider =
    FutureProvider<List<VerificationDocument>>((ref) async {
  final documents = await ref.watch(verificationDocumentsProvider.future);
  return documents.where((doc) => !doc.isDecided).toList();
});

/// This applicant's category applications, newest first.
///
/// Read from `GET /verification/my-applications/` rather than from
/// `submissions/`: the route is scoped to the caller's profile for *everyone*,
/// staff included, and it is the one that carries a decision and the reviewer's
/// note as a first-class pair.
final myApplicationsProvider =
    FutureProvider<List<MyApplication>>((ref) async {
  final raw =
      await ref.watch(verificationRepositoryProvider).getMyApplications();
  return verificationRows(raw).map(MyApplication.fromJson).toList();
});

/// Submissions waiting on a *second* approver, for the staff queue.
///
/// Derived from [verificationSubmissionsProvider] rather than a second call:
/// `pending_approval` is non-null on the row exactly while a decision has been
/// requested and not settled, so the queue can point at the ones a reviewer
/// could actually settle right now.
final submissionsAwaitingDecisionProvider =
    FutureProvider<List<VerificationSubmission>>((ref) async {
  final submissions = await ref.watch(verificationSubmissionsProvider.future);
  return submissions.where((s) => s.awaitsSecondApprover).toList();
});