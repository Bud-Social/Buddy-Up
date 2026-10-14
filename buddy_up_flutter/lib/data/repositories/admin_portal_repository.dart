import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'admin_portal_repository.g.dart';

/// Typed client for `/api/v1/portal/**`, mirroring
/// `frontend/src/api/adminPortal.ts` path-for-path.
///
/// Every method returns the raw `{success, data, message, errors, pagination}`
/// envelope (unwrapped one level, not `data.data`) and every list takes an
/// optional filter map passed straight through as query params — same
/// convention as `MarketplaceRepository`.
///
/// The portal half is read-mostly by design: it is the mobile shadow of the web
/// admin console, not a second moderation desk.
///
/// Two namespaces are appended below and are deliberately *not* folded into the
/// portal surface:
///
/// * `/governance/**` — staff roles, two-person approvals, the audit trail and
///   the staff email console. Same envelope, same conventions.
/// * `/moderation/**` — flags, reports, the action ledger, appeals and
///   commendations. These are DRF viewsets, so the list shape differs; see the
///   section comment above those methods.
///
/// Filters are always passed through rather than validated client-side. The
/// endpoints 400 on an unknown value naming the allowed set, and that error is
/// more useful than a guess that silently returns everything.
@RestApi()
abstract class AdminPortalRepository {
  factory AdminPortalRepository(Dio dio, {String baseUrl}) = _AdminPortalRepository;

  // --- Users ---
  @GET('/portal/users/')
  Future<dynamic> getUsers({
    @Query('q') String? query,
    @Query('role') String? role,
    @Query('is_active') bool? isActive,
    @Query('verification_status') String? verificationStatus,
    @Query('has_search_profile') bool? hasSearchProfile,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/portal/users/{id}/')
  Future<dynamic> getUser(@Path('id') String userId);

  @PATCH('/portal/users/{id}/')
  Future<dynamic> updateUser(
    @Path('id') String userId,
    @Body() Map<String, dynamic> data,
  );

  @POST('/portal/users/{id}/suspend/')
  Future<dynamic> suspendUser(
    @Path('id') String userId,
    @Body() Map<String, dynamic> data,
  );

  @POST('/portal/users/{id}/reinstate/')
  Future<dynamic> reinstateUser(
    @Path('id') String userId,
    @Body() Map<String, dynamic> data,
  );

  // --- Shops & products ---
  @GET('/portal/shops/')
  Future<dynamic> getShops({
    @Query('q') String? query,
    @Query('verification_status') String? verificationStatus,
    @Query('is_active') bool? isActive,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/portal/shops/{handle}/')
  Future<dynamic> getShop(@Path('handle') String handle);

  @PATCH('/portal/shops/{handle}/')
  Future<dynamic> updateShop(
    @Path('handle') String handle,
    @Body() Map<String, dynamic> data,
  );

  @GET('/portal/products/')
  Future<dynamic> getProducts({
    @Query('q') String? query,
    @Query('category') String? category,
    @Query('is_active') bool? isActive,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  // --- Shop certifications (the review queue) ---
  @GET('/portal/shop-certifications/')
  Future<dynamic> getShopCertifications({
    @Query('status') String? status,
    @Query('q') String? query,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @PATCH('/portal/shop-certifications/{id}/')
  Future<dynamic> reviewShopCertification(
    @Path('id') String applicationId,
    @Body() Map<String, dynamic> data,
  );

  // --- Orders ---
  @GET('/portal/orders/')
  Future<dynamic> getOrders({
    @Query('status') String? status,
    @Query('fulfillment_type') String? fulfillmentType,
    @Query('payment_status') String? paymentStatus,
    @Query('payment_method') String? paymentMethod,
    @Query('q') String? query,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/portal/orders/{id}/')
  Future<dynamic> getOrder(@Path('id') String orderId);

  @PATCH('/portal/orders/{id}/status/')
  Future<dynamic> updateOrderStatus(
    @Path('id') String orderId,
    @Body() Map<String, dynamic> data,
  );

  // --- Gyms ---
  @GET('/portal/gyms/')
  Future<dynamic> getGyms({
    @Query('q') String? query,
    @Query('category') String? category,
    @Query('access_type') String? accessType,
    @Query('is_verified') bool? isVerified,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @PATCH('/portal/gyms/{id}/')
  Future<dynamic> updateGym(
    @Path('id') String gymId,
    @Body() Map<String, dynamic> data,
  );

  // --- Communities ---
  @GET('/portal/communities/')
  Future<dynamic> getCommunities({
    @Query('q') String? query,
    @Query('is_public') bool? isPublic,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  // --- Stations ---
  @GET('/portal/stations/')
  Future<dynamic> getStations({
    @Query('q') String? query,
    @Query('is_active') bool? isActive,
    @Query('is_primary') bool? isPrimary,
    @Query('owner_type') String? ownerType,
    @Query('city') String? city,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @PATCH('/portal/stations/{id}/')
  Future<dynamic> updateStation(
    @Path('id') String stationId,
    @Body() Map<String, dynamic> data,
  );

  // --- Application review queues ---
  @GET('/portal/station-applications/')
  Future<dynamic> getStationApplications({
    @Query('status') String? status,
    @Query('q') String? query,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @PATCH('/portal/station-applications/{id}/')
  Future<dynamic> reviewStationApplication(
    @Path('id') String applicationId,
    @Body() Map<String, dynamic> data,
  );

  @GET('/portal/delivery-personnel/')
  Future<dynamic> getDeliveryPersonnel({
    @Query('q') String? query,
    @Query('vehicle_type') String? vehicleType,
    @Query('is_active') bool? isActive,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @PATCH('/portal/delivery-personnel/{id}/')
  Future<dynamic> updateDeliveryPersonnel(
    @Path('id') String personnelId,
    @Body() Map<String, dynamic> data,
  );

  @GET('/portal/delivery-personnel-applications/')
  Future<dynamic> getDeliveryApplications({
    @Query('status') String? status,
    @Query('q') String? query,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @PATCH('/portal/delivery-personnel-applications/{id}/')
  Future<dynamic> reviewDeliveryApplication(
    @Path('id') String applicationId,
    @Body() Map<String, dynamic> data,
  );

  // --- Wallet (read-only) ---
  @GET('/portal/transactions/')
  Future<dynamic> getTransactions({
    @Query('status') String? status,
    @Query('transaction_type') String? transactionType,
    @Query('direction') String? direction,
    @Query('email') String? email,
    @Query('q') String? query,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/portal/wallet/reconciliation/')
  Future<dynamic> getReconciliation();

  // -------------------------------------------------------------------------
  // `/portal/analytics/**` — the platform reports.
  //
  // Separate block because these six read a different thing than anything else
  // in this file: the portal half reads *rows*, and these read *aggregates* of
  // rows the portal cannot see. Each one returns the server's own payload with
  // its own per-figure window attached; nothing here composes a number the
  // server did not send.
  //
  // `from`/`to` are passed through unvalidated on purpose. The server owns the
  // window grammar (YYYY-MM-DD, UTC calendar days, never in the future, bounded
  // by ANALYTICS_MAX_RANGE_DAYS) and answers a bad range with a 400 naming the
  // limit — a message better than any guess made here.
  //
  // Every response also carries a `table` block, which is the *same* rows the
  // export writer renders. That is the property that makes "export what I am
  // looking at" true rather than aspirational.
  // -------------------------------------------------------------------------

  @GET('/portal/analytics/overview/')
  Future<dynamic> getAnalyticsOverview({
    @Query('from') String? from,
    @Query('to') String? to,
  });

  /// `metric` is required by the server (400 naming the allowed set) and
  /// `granularity` is `day` or `week`. Metric keys are namespaced
  /// (`analytics.orders.count` style on the web; here exactly the keys
  /// `METRIC_SPECS` holds) — the catalogue in the response is the picker
  /// source, so a key can never be hardcoded and stale.
  @GET('/portal/analytics/timeseries/')
  Future<dynamic> getAnalyticsTimeseries({
    @Query('metric') String? metric,
    @Query('granularity') String? granularity,
    @Query('from') String? from,
    @Query('to') String? to,
  });

  /// `kind` is one of posts / services / events / hashtags / pages. `pages`
  /// answers `{available: false, reason}` — a refusal with a reason, not an
  /// empty list, and the screen renders it as such.
  @GET('/portal/analytics/trending/')
  Future<dynamic> getAnalyticsTrending({
    @Query('kind') String? kind,
    @Query('limit') int? limit,
    @Query('from') String? from,
    @Query('to') String? to,
  });

  @GET('/portal/analytics/ai-quality/')
  Future<dynamic> getAnalyticsAiQuality({
    @Query('from') String? from,
    @Query('to') String? to,
  });

  @GET('/portal/analytics/predictive/')
  Future<dynamic> getAnalyticsPredictive({
    @Query('from') String? from,
    @Query('to') String? to,
  });

  /// CSV / XLSX bytes for one report, with the same filters the screen used.
  ///
  /// Bytes rather than a URL handed straight to a browser, for the same reason
  /// `exportAuditLog` is: the route is staff-scoped and the app authenticates
  /// with a Bearer token, so a browser opened at the address would answer 401
  /// rather than a file. Returning `HttpResponse` also hands back the headers,
  /// which is the only place `X-Analytics-Rows`, `X-Analytics-From` /
  /// `-To` and the `Content-Disposition` filename exist — and the row count is
  /// what the screen needs in order not to present a short file as a complete
  /// one.
  ///
  /// `@DioResponseType(ResponseType.bytes)` keeps Dio from trying to parse a
  /// spreadsheet as JSON.
  @GET('/portal/analytics/export/')
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<dynamic>> exportAnalyticsReport({
    @Query('report') String? report,
    @Query('format') String? format,
    @Query('from') String? from,
    @Query('to') String? to,
    @Query('metric') String? metric,
    @Query('granularity') String? granularity,
    @Query('kind') String? kind,
    @Query('limit') int? limit,
  });

  // -------------------------------------------------------------------------
  // `/governance/**` — two-person approvals, the audit trail, staff email.
  //
  // Separate from `/portal/**` because that is how the server splits it: the
  // routes that grant access must not live in the same table as the routes
  // access is granted over. Envelope-identical to the portal surface.
  // -------------------------------------------------------------------------

  // --- Staff roles ---

  @GET('/governance/staff-roles/')
  Future<dynamic> getStaffRoles({
    @Query('role') String? role,
    @Query('revoked') String? revoked,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  /// Grants a role. Returns a `StaffRole` at 201 when applied directly, or an
  /// `AccountActionRequest` at 202 when `requiresSecond` put it in the approval
  /// queue — the same endpoint, two very different outcomes.
  @POST('/governance/staff-roles/')
  Future<dynamic> grantStaffRole(@Body() Map<String, dynamic> data);

  @GET('/governance/staff-roles/{id}/')
  Future<dynamic> getStaffRole(@Path('id') String roleId);

  @PATCH('/governance/staff-roles/{id}/')
  Future<dynamic> updateStaffRole(
    @Path('id') String roleId,
    @Body() Map<String, dynamic> data,
  );

  /// Revokes rather than deletes: the row is the record of who was given what.
  @DELETE('/governance/staff-roles/{id}/')
  Future<dynamic> revokeStaffRole(@Path('id') String roleId);

  // --- Approvals ---

  @GET('/governance/approvals/')
  Future<dynamic> getApprovals({
    @Query('status') String? status,
    @Query('action') String? action,
    @Query('target_user') String? targetUser,
    @Query('mine') String? mine,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/governance/approvals/{id}/')
  Future<dynamic> getApproval(@Path('id') String approvalId);

  @POST('/governance/approvals/request/')
  Future<dynamic> requestApproval(@Body() Map<String, dynamic> data);

  @POST('/governance/approvals/{id}/approve/')
  Future<dynamic> approveApproval(
    @Path('id') String approvalId,
    @Body() Map<String, dynamic> data,
  );

  @POST('/governance/approvals/{id}/reject/')
  Future<dynamic> rejectApproval(
    @Path('id') String approvalId,
    @Body() Map<String, dynamic> data,
  );

  @POST('/governance/approvals/{id}/cancel/')
  Future<dynamic> cancelApproval(
    @Path('id') String approvalId,
    @Body() Map<String, dynamic> data,
  );

  // --- Audit trail ---

  @GET('/governance/audit/')
  Future<dynamic> getAuditLog({
    @Query('action') String? action,
    @Query('target_type') String? targetType,
    @Query('target_id') String? targetId,
    @Query('actor') String? actor,
    @Query('date_from') String? dateFrom,
    @Query('date_to') String? dateTo,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/governance/audit/{id}/')
  Future<dynamic> getAuditRow(@Path('id') String rowId);

  /// Chronological history of one object. `target_type` is required — the
  /// server 400s without it rather than returning every action on record.
  @GET('/governance/audit/timeline/')
  Future<dynamic> getAuditTimeline({
    @Query('target_type') String? targetType,
    @Query('target_id') String? targetId,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  /// CSV of the *current* filter, `Content-Disposition: attachment`.
  ///
  /// Not a normal JSON call. `@DioResponseType(bytes)` keeps Dio from trying to
  /// parse a CSV as JSON, and returning `HttpResponse` hands back the headers
  /// alongside the body — the filename, which names the filter and the export
  /// time, exists nowhere else. Uses the same filter names as `getAuditLog` so
  /// an export is always exactly what the operator was looking at.
  @GET('/governance/audit/export/')
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<dynamic>> exportAuditLog({
    @Query('action') String? action,
    @Query('target_type') String? targetType,
    @Query('target_id') String? targetId,
    @Query('actor') String? actor,
    @Query('date_from') String? dateFrom,
    @Query('date_to') String? dateTo,
  });

  // --- Assistance console ---

  /// One message to one registered, non-deleted account.
  ///
  /// Exactly one of `user_id` / `email`. The serializer rejects unknown keys
  /// outright, so there is nowhere to put a second recipient and no bulk send
  /// to accidentally build.
  @POST('/governance/emails/send/')
  Future<dynamic> sendStaffEmail(@Body() Map<String, dynamic> data);

  @GET('/governance/emails/log/')
  Future<dynamic> getEmailLog({
    @Query('status') String? status,
    @Query('recipient_email') String? recipientEmail,
    @Query('sent_by') String? sentBy,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  /// Failed deliveries only — the server 409s on any other status.
  @POST('/governance/emails/{id}/resend/')
  Future<dynamic> resendStaffEmail(@Path('id') String emailId);

  // -------------------------------------------------------------------------
  // `/moderation/**` — flags, reports, the action ledger, appeals, praise.
  //
  // A different envelope convention to `/portal/**` and `/governance/**`:
  // these are DRF viewsets, so a list is `{next, previous, results}` and the
  // hand-written action views return the raw serializer row with no envelope
  // at all. `moderationRows` / `moderationPagination` in the provider
  // normalise both shapes.
  //
  // They are also *cursor*-paginated: there is no page number and no `count`.
  // Every list below therefore takes `cursor`/`limit`; passing `page` would be
  // accepted and ignored, which looks like paging and is not.
  // -------------------------------------------------------------------------

  /// Cursor-paginated, so this takes `cursor`/`limit` rather than a page
  /// number. DRF's `CursorPagination` ignores `page` entirely; sending one
  /// would look like paging and silently return the same first page every
  /// time.
  @GET('/moderation/reports/')
  Future<dynamic> getModerationReports({
    @Query('status') String? status,
    @Query('reason') String? reason,
    /// `me` or a staff user id. Staff-only; ignored for a reporter's own list.
    @Query('assigned_to') String? assignedTo,
    @Query('unassigned') String? unassigned,
    @Query('cursor') String? cursor,
    @Query('limit') int? limit,
  });

  @GET('/moderation/reports/{id}/')
  Future<dynamic> getModerationReport(@Path('id') String reportId);

  @POST('/moderation/reports/{id}/handle/')
  Future<dynamic> handleModerationReport(
    @Path('id') String reportId,
    @Body() Map<String, dynamic> data,
  );

  /// Assign to a staff user, or unassign by sending an explicit `null`.
  @POST('/moderation/reports/{id}/assign/')
  Future<dynamic> assignModerationReport(
    @Path('id') String reportId,
    @Body() Map<String, dynamic> data,
  );

  /// Un-actioned flags, worst severity and highest confidence first.
  @GET('/moderation/content-flags/queue/')
  Future<dynamic> getContentFlagQueue({
    @Query('flag_reason') String? flagReason,
    @Query('severity') String? severity,
  });

  @GET('/moderation/content-flags/stats/')
  Future<dynamic> getContentFlagStats();

  @GET('/moderation/content-flags/pending-approvals/')
  Future<dynamic> getPendingModerationApprovals();

  @POST('/moderation/content-flags/{id}/act/')
  Future<dynamic> actOnContentFlag(
    @Path('id') String flagId,
    @Body() Map<String, dynamic> data,
  );

  /// The ledger. `action` filter vocabulary: warning, content_removed,
  /// user_suspended, user_banned, report_dismissed, escalated, action_reversed.
  @GET('/moderation/actions/')
  Future<dynamic> getModerationActions({
    @Query('action') String? action,
    @Query('cursor') String? cursor,
    @Query('limit') int? limit,
  });

  @GET('/moderation/actions/{id}/')
  Future<dynamic> getModerationAction(@Path('id') String actionId);

  /// `warning` applies immediately (201). `user_suspended` / `user_banned`
  /// never do: they create a governance request and answer 202 with
  /// `applied: false`. Read the status code, not just the body.
  @POST('/moderation/actions/')
  Future<dynamic> createModerationAction(@Body() Map<String, dynamic> data);

  @POST('/moderation/actions/{id}/reverse/')
  Future<dynamic> reverseModerationAction(
    @Path('id') String actionId,
    @Body() Map<String, dynamic> data,
  );

  /// The caller's own appeals for a non-staff user, every appeal for staff.
  @GET('/moderation/appeals/')
  Future<dynamic> getModerationAppeals({
    @Query('status') String? status,
    @Query('cursor') String? cursor,
    @Query('limit') int? limit,
  });

  @GET('/moderation/appeals/{id}/')
  Future<dynamic> getModerationAppeal(@Path('id') String appealId);

  /// `{action: <moderation_action_id>, reason}` — the action must be one
  /// applied to the caller's own account, and there may be only one appeal per
  /// (action, appellant) pair.
  @POST('/moderation/appeals/')
  Future<dynamic> createModerationAppeal(@Body() Map<String, dynamic> data);

  @POST('/moderation/appeals/{id}/review/')
  Future<dynamic> reviewModerationAppeal(
    @Path('id') String appealId,
    @Body() Map<String, dynamic> data,
  );

  /// Commendations addressed to the caller plus the ones they issued.
  @GET('/moderation/commendations/')
  Future<dynamic> getModerationCommendations({
    @Query('category') String? category,
    @Query('cursor') String? cursor,
    @Query('limit') int? limit,
  });

  /// `recipient` is a **Profile** id, not a user id.
  @POST('/moderation/commendations/')
  Future<dynamic> createModerationCommendation(@Body() Map<String, dynamic> data);

  /// Hard delete. The recipient may remove their own; staff may remove any.
  @DELETE('/moderation/commendations/{id}/')
  Future<dynamic> deleteModerationCommendation(@Path('id') String commendationId);

  /// Withdraw without erasing: the row stays, `visible_to_recipient` goes
  /// false, so an operator cannot quietly un-send a commendation they regret.
  @POST('/moderation/commendations/{id}/revoke/')
  Future<dynamic> revokeModerationCommendation(
    @Path('id') String commendationId,
    @Body() Map<String, dynamic> data,
  );
}