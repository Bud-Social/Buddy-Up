import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'verification_repository.g.dart';

/// Typed client for `/api/v1/verification/**`, mirroring
/// `frontend/src/api/verification.ts`.
///
/// **This app has no envelope.** `/verification/**` is a plain DRF viewset plus
/// two `APIView`s, so a list is `{next, previous, results}` (cursor-paginated —
/// `DEFAULT_PAGINATION_CLASS` is `CursorPagination`, so there is no page number
/// and no `count`) and the hand-written actions return the bare serializer row
/// with no wrapper at all. [verificationRows] normalises that; reading
/// `response['data']` here would throw on every call.
///
/// **Two application routes, added alongside the old one.** Registration no
/// longer accepts an elevated role — `RegisterSerializer.validate_role` refuses
/// anything but `user` and points at `category-applications` — so that route is
/// now the only way a person becomes a trainer or a practitioner, and
/// `my-applications` is where they watch it happen.
@RestApi()
abstract class VerificationRepository {
  factory VerificationRepository(Dio dio, {String baseUrl}) =
      _VerificationRepository;

  // --- Documents ---
  //
  // Scoped server-side: a non-staff caller gets only their own rows. There is no
  // query filter to pass, because there is nothing to filter — the endpoint
  // decides who may see what.

  @GET('/verification/documents/')
  Future<dynamic> getDocuments();

  /// `{document_type, file_url}` — `file_url` is a `SerializerMethodField`, so
  /// it is read-only on create and the value is ignored if sent. The honest
  /// client sends `document_type` alone and lets the id come back.
  @POST('/verification/documents/')
  Future<dynamic> uploadDocument(@Body() Map<String, dynamic> data);

  /// Multipart upload that actually attaches the file.
  ///
  /// `file_url` on [uploadDocument] is a `SerializerMethodField`: posting a URL
  /// there is silently discarded, so the document row is created with nothing
  /// attached. Anything that needs real evidence has to go through this.
  @MultiPart()
  @POST('/verification/documents/upload/')
  Future<dynamic> uploadCredentialFile(@Part() Map<String, dynamic> fields);

  @GET('/verification/documents/{id}/')
  Future<dynamic> getDocument(@Path('id') String documentId);

  /// Short-lived signed URL for one document, or a streamed body.
  ///
  /// Access-audited server-side: every call writes a
  /// `VerificationDocumentAccess` row, which is why this is a deliberate GET
  /// rather than something the UI does casually.
  @POST('/verification/documents/{id}/access/')
  Future<dynamic> requestDocumentAccess(
    @Path('id') String documentId, {
    @Body() Map<String, dynamic>? body,
  });

  // --- Submissions ---

  /// Cursor-paginated: `{next, previous, results}`.
  @GET('/verification/submissions/')
  Future<dynamic> getSubmissions();

  @GET('/verification/submissions/{id}/')
  Future<dynamic> getSubmission(@Path('id') String submissionId);

  /// Creates a **draft**. Only `verification_type` is required here; the older
  /// multistep identity flow then walks `start` / `upload_step` / `submit`.
  @POST('/verification/submissions/')
  Future<dynamic> createSubmission(@Body() Map<String, dynamic> data);

  @POST('/verification/submissions/{id}/submit/')
  Future<dynamic> submitSubmission(@Path('id') String submissionId);

  /// **Asks for a decision. Applies nothing.**
  ///
  /// Answers **202** with the submission plus an `approval_request` block. It
  /// used to settle the application outright in one call; it now only raises
  /// `AccountActionRequest(action='verification_decision')`, so a *different*
  /// member of staff has to call [decideSubmission] before
  /// `Profile.verification_status`, `Profile.role` or `Gym.is_verified` change.
  ///
  /// Two refusals a client must surface rather than swallow: 403 when the
  /// applicant is the caller ("you cannot submit a decision on your own
  /// application"), and 409 when a decision for this submission is already in
  /// flight.
  @POST('/verification/submissions/{id}/review/')
  Future<dynamic> reviewSubmission(
    @Path('id') String submissionId,
    @Body() Map<String, dynamic> data,
  );

  /// **The second approver settles it.** The only endpoint that applies.
  ///
  /// `{action: approve|reject, note}` — `note` is required on a rejection
  /// because it is the record the applicant reads. 403 when the caller is the
  /// person who raised the request, 409 when it is already settled or has
  /// already been applied.
  @POST('/verification/submissions/{id}/decide/')
  Future<dynamic> decideSubmission(
    @Path('id') String submissionId,
    @Body() Map<String, dynamic> data,
  );

  // --- Category applications (the elevated-role route) ---

  /// Apply for `trainer` / `practitioner` / `gym_owner` / `shop_owner` /
  /// `delivery_partner`.
  ///
  /// Stamps `status='submitted'` and `submitted_at` straight away, so a
  /// reviewer can see it. Refuses up front — 400 — an application missing a
  /// required credential field or its supporting `document_ids`, and refuses
  /// document ids the applicant does not own. The profile is the caller's, with
  /// no field to override.
  @POST('/verification/category-applications/')
  Future<dynamic> createCategoryApplication(@Body() Map<String, dynamic> data);

  /// This applicant's own applications: `{count, results}`.
  ///
  /// Scoped to the caller's profile unconditionally, staff included — staff get
  /// *their own* applications here rather than the queue, which is what the
  /// staff-only submissions endpoint is for.
  @GET('/verification/my-applications/')
  Future<dynamic> getMyApplications({
    @Query('category') String? category,
  });
}