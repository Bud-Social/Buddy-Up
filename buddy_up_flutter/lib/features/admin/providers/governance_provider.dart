import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../data/models/admin_portal.dart';
import '../providers/admin_provider.dart';

/// Providers for `/api/v1/governance/**` and `/api/v1/moderation/**`.
///
/// Split from `admin_provider.dart` rather than appended to it: the portal's
/// lists are all one `{success, data, pagination}` envelope, while the
/// moderation app is DRF viewsets returning `{next, previous, results}` with no
/// count, and its hand-written action views return a bare serializer row. The
/// two conventions need different unwrappers, and mixing them in one file is
/// how a queue ends up silently showing zero results.

/// Unwrap a moderation list body.
///
/// Three shapes are all legal here and all in production:
///  * the `{success, data, message}` envelope, `data` an array — the flag queue
///    and pending-approvals views build this by hand;
///  * a bare DRF cursor page `{next, previous, results}`;
///  * a bare array.
///
/// A shape this has never seen must render as "no rows", never as a crash on a
/// staff screen mid-incident.
List<Map<String, dynamic>> moderationRows(dynamic body) {
  if (body is List) return body.whereType<Map<String, dynamic>>().toList();
  if (body is Map) {
    final envelope = body['success'] == true && body.containsKey('data');
    final candidate = envelope ? body['data'] : body;
    if (candidate is List) {
      return candidate.whereType<Map<String, dynamic>>().toList();
    }
    if (candidate is Map) {
      for (final key in const ['results', 'items']) {
        final nested = candidate[key];
        if (nested is List) {
          return nested.whereType<Map<String, dynamic>>().toList();
        }
      }
    }
  }
  return [];
}

/// Real total behind a moderation list.
///
/// Cursor pagination carries no `count` at all, so a page reads its total from
/// the page-number shape when there is one and otherwise falls back to the rows
/// in hand. `PortalPager` divides by [kPortalPageSize] to decide whether a
/// "Next" exists, so a cursor page honestly reports one page rather than
/// inventing a total that would offer a Next that leads nowhere.
PortalPagination moderationPagination(dynamic body, int fallbackCount) {
  if (body is! Map) return PortalPagination(count: fallbackCount);
  final envelopePagination = body['pagination'];
  if (envelopePagination is Map<String, dynamic>) {
    return PortalPagination.fromJson(envelopePagination);
  }
  // Some moderation views put the total beside `data` rather than in
  // `pagination`, so a queue can show "240 pending" without paginating.
  final topLevelCount = body['count'];
  if (topLevelCount is int) {
    return PortalPagination(
      count: topLevelCount,
      next: body['next'] as String?,
      previous: body['previous'] as String?,
    );
  }
  final results = body['results'];
  if (results is List) {
    return PortalPagination(
      count: fallbackCount,
      next: body['next'] as String?,
      previous: body['previous'] as String?,
    );
  }
  return PortalPagination.fromJson({
    if (topLevelCount is int) 'count': topLevelCount,
    if (body['next'] is String) 'next': body['next'],
    if (body['previous'] is String) 'previous': body['previous'],
  });
}

PortalPage<T> _page<T>(
  dynamic body,
  T Function(Map<String, dynamic>) parse,
) {
  final rows = moderationRows(body);
  return PortalPage(rows.map(parse).toList(), moderationPagination(body, rows.length));
}

// ---------------------------------------------------------------------------
// Moderation — cursor paging
// ---------------------------------------------------------------------------

/// Immutable list query for the cursor-paginated moderation endpoints.
///
/// Not [PortalQuery]: these are DRF viewsets on `CursorPagination`, which has
/// no page number and no count. Sending `page` would be accepted and ignored,
/// so a page-number pager over them would offer a "Next" that silently returns
/// the same rows. Filters travel in the same map as the portal's, with the
/// `all` sentinel meaning "no filter".
class ModerationQuery {
  final String? cursor;
  final Map<String, dynamic> params;

  const ModerationQuery({this.cursor, this.params = const {}});

  factory ModerationQuery.of(String? cursor, [Map<String, dynamic> filters = const {}]) {
    final clean = <String, dynamic>{};
    filters.forEach((key, value) {
      if (value == null || value == '' || value == 'all') return;
      clean[key] = value;
    });
    return ModerationQuery(cursor: cursor, params: clean);
  }

  String? text(String key) => params[key] as String?;

  /// Stable identity for a Riverpod family — the map has no value equality.
  String get key => jsonEncode({'cursor': cursor, 'params': params});

  @override
  bool operator ==(Object other) =>
      other is ModerationQuery && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

/// Page size for the cursor-paginated moderation lists.
///
/// `CursorPagination.page_size` is 20 with `limit` overridable, so asking for
/// 25 is a real request rather than a silent clamp.
const int kModerationPageSize = 25;

/// Pull the opaque `cursor` out of a DRF pagination link.
///
/// DRF hands back an absolute URL (`.../reports/?cursor=cD0yMDI2`), and the
/// cursor is the only paging state it has. Following the number would be
/// meaningless — cursors are not ordered by anything a client can reconstruct.
String? cursorFromLink(String? link) {
  if (link == null || link.isEmpty) return null;
  final uri = Uri.tryParse(link);
  if (uri == null) return null;
  final cursor = uri.queryParameters['cursor'];
  return (cursor == null || cursor.isEmpty) ? null : cursor;
}

/// A cursor stack for one moderation list.
///
/// Cursors cannot be computed, only followed, so going back is a pop rather
/// than a subtraction — and holding the visited cursors is what makes "Back"
/// return the page the operator was on instead of jumping to the end again.
class CursorStack {
  final List<String?> _cursors = [null];

  /// 1-based, for the "Page N" label only.
  int get page => _cursors.length;

  /// The cursor the current request should carry; null means "from the top".
  String? get cursor => _cursors.last;

  bool get canGoBack => _cursors.length > 1;

  /// Advance using the `next` link from the response just rendered. A null
  /// [nextLink] means the end of the list, so this is a no-op rather than a
  /// push of null that would silently restart at page one.
  bool advance(String? nextLink) {
    final next = cursorFromLink(nextLink);
    if (next == null) return false;
    _cursors.add(next);
    return true;
  }

  bool goBack() {
    if (!canGoBack) return false;
    _cursors.removeLast();
    return true;
  }

  /// Any filter change invalidates every cursor behind it.
  void reset() {
    _cursors
      ..clear()
      ..add(null);
  }
}

// ---------------------------------------------------------------------------
// Staff roles
// ---------------------------------------------------------------------------

/// `StaffRole.ROLE_CHOICES`, verbatim. A value outside this set is a 400 from
/// the server, so the console offers exactly what can be granted.
const List<({String value, String label})> kStaffRoleChoices = [
  (value: 'admin', label: 'Administrator'),
  (value: 'moderator', label: 'Moderator'),
  (value: 'support', label: 'Support Agent'),
  (value: 'gym_relations', label: 'Gym Relations'),
  (value: 'supplier_relations', label: 'Supplier Relations'),
  (value: 'logistics', label: 'Logistics'),
  (value: 'finance', label: 'Finance'),
  (value: 'verification_regulator', label: 'Verification Regulator'),
];

final staffRolesProvider =
    FutureProvider.family<PortalPage<StaffRole>, PortalQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getStaffRoles(
        role: q.text('role'),
        revoked: q.text('revoked'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(raw, StaffRole.fromJson);
});

// ---------------------------------------------------------------------------
// Approvals
// ---------------------------------------------------------------------------

/// `AccountActionRequest.ACTION_CHOICES` — the actions a request may raise.
const List<({String value, String label})> kApprovalActionChoices = [
  (value: 'ban', label: 'Ban Account'),
  (value: 'suspension', label: 'Suspend Account'),
  (value: 'verification_decision', label: 'Verification Decision'),
  (value: 'payout', label: 'Payout'),
  (value: 'staff_role_grant', label: 'Grant Staff Role'),
];

/// `AccountActionRequest.STATUS_CHOICES`.
const List<({String value, String label})> kApprovalStatusChoices = [
  (value: 'pending', label: 'Pending'),
  (value: 'approved', label: 'Approved'),
  (value: 'rejected', label: 'Rejected'),
  (value: 'cancelled', label: 'Cancelled'),
];

final approvalsProvider =
    FutureProvider.family<PortalPage<AccountActionRequest>, PortalQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getApprovals(
        status: q.text('status'),
        action: q.text('action'),
        targetUser: q.text('target_user'),
        mine: q.text('mine'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(raw, AccountActionRequest.fromJson);
});

// ---------------------------------------------------------------------------
// Audit trail
// ---------------------------------------------------------------------------

/// Verbs this platform actually writes, offered as shortcuts. The endpoint
/// accepts any dotted lowercase verb — it validates the *grammar*, not
/// membership — so the free-text field stays available and these are just the
/// common ones.
const List<String> kAuditActionShortcuts = [
  'users.suspend',
  'users.reinstate',
  'orders.status_change',
  'staff_roles.grant',
  'staff_roles.revoke',
  'approvals.decide',
  'approvals.request',
  'emails.send',
];

/// Object kinds that appear as an audit `target_type`, as filter chips.
///
/// Not exhaustive and deliberately not validated client-side: the server
/// checks the *shape* of a `target_type` (a lowercase word) and not its
/// membership, because the vocabulary is declared by whichever app performed
/// the action and `admin_portal` writes verbs this app has never heard of.
const List<({String value, String label})> kAuditTargetTypes = [
  (value: 'user', label: 'User'),
  (value: 'order', label: 'Order'),
  (value: 'shop', label: 'Shop'),
  (value: 'gym', label: 'Gym'),
  (value: 'community', label: 'Community'),
  (value: 'station', label: 'Station'),
  (value: 'staff_role', label: 'Staff role'),
  (value: 'account_action_request', label: 'Request'),
];

final auditLogProvider =
    FutureProvider.family<PortalPage<AdminActionLog>, PortalQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getAuditLog(
        action: q.text('action'),
        targetType: q.text('target_type'),
        targetId: q.text('target_id'),
        actor: q.text('actor'),
        dateFrom: q.text('date_from'),
        dateTo: q.text('date_to'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(raw, AdminActionLog.fromJson);
});

/// `GET /governance/audit/timeline/` — oldest first, and `target_type` is
/// mandatory: the server 400s without it rather than returning the whole table.
///
/// Separate family argument from [PortalQuery] because `target_type` is
/// required here rather than optional, and folding it into an optional filter
/// map would let the UI build a request the server will refuse.
final auditTimelineProvider = FutureProvider.family<PortalPage<AdminActionLog>,
    ({String targetType, String targetId, int page})>((ref, args) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getAuditTimeline(
        targetType: args.targetType,
        targetId: args.targetId.isEmpty ? null : args.targetId,
        page: args.page,
        pageSize: kPortalPageSize,
      );
  return _page(raw, AdminActionLog.fromJson);
});

/// A downloaded audit export: the bytes and the name the server chose.
class AuditCsvExport {
  final Uint8List bytes;
  final String filename;

  const AuditCsvExport({required this.bytes, required this.filename});
}

/// Pull the filename out of a `Content-Disposition` header.
///
/// The header is the only place the export's name exists, and it encodes the
/// filter stamp (`admin-audit-20260304-141200.csv`), so honouring it is the
/// difference between a file an operator can file and "download (1)". Falls
/// back to a name the platform controls rather than showing the operator a
/// stray `null`.
String auditExportFilename(String? contentDisposition, {String fallback = 'admin-audit.csv'}) {
  if (contentDisposition == null || contentDisposition.isEmpty) return fallback;
  // `attachment; filename="admin-audit-...csv"` and the RFC 5987
  // `filename*=UTF-8''...` form both appear in the wild.
  for (final marker in const ['filename*=UTF-8\'\'', 'filename*=utf-8\'\'', 'filename=']) {
    final index = contentDisposition.indexOf(marker);
    if (index < 0) continue;
    var value = contentDisposition.substring(index + marker.length);
    final end = value.indexOf(';');
    if (end >= 0) value = value.substring(0, end);
    final cleaned = value.trim().replaceAll('"', '').trim();
    if (cleaned.isNotEmpty) {
      try {
        return Uri.decodeComponent(cleaned);
      } on ArgumentError {
        // A stray `%` in the header is not worth losing the download over.
        return cleaned;
      } on FormatException {
        return cleaned;
      }
    }
  }
  return fallback;
}

/// Fetch the audit CSV for the current filter.
///
/// Bytes rather than a URL: the endpoint is scope-gated, so handing the address
/// to `url_launcher` would open a login page instead of a file.
Future<AuditCsvExport> fetchAuditExport(WidgetRef ref, PortalQuery q) async {
  final response = await ref.read(adminPortalRepositoryProvider).exportAuditLog(
        action: q.text('action'),
        targetType: q.text('target_type'),
        targetId: q.text('target_id'),
        actor: q.text('actor'),
        dateFrom: q.text('date_from'),
        dateTo: q.text('date_to'),
      );
  final data = response.data;
  return AuditCsvExport(
    bytes: switch (data) {
      final Uint8List bytes => bytes,
      final List<int> bytes => Uint8List.fromList(bytes),
      _ => Uint8List(0),
    },
    filename: auditExportFilename(
      response.response.headers.value('content-disposition'),
    ),
  );
}

// ---------------------------------------------------------------------------
// Assistance console
// ---------------------------------------------------------------------------

/// `EmailLog.STATUS_CHOICES`.
const List<({String value, String label})> kEmailStatusChoices = [
  (value: 'queued', label: 'Queued'),
  (value: 'sent', label: 'Sent'),
  (value: 'failed', label: 'Failed'),
  (value: 'skipped', label: 'Skipped'),
];

/// The per-staff-hour ceiling the view enforces, repeated client-side only so
/// the console can *say* it. The refusal itself is the server's 429 and this
/// number is never used to let a send through.
const int kStaffEmailHourlyCeiling = 20;

final emailLogProvider =
    FutureProvider.family<PortalPage<EmailLog>, PortalQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getEmailLog(
        status: q.text('status'),
        recipientEmail: q.text('recipient_email'),
        sentBy: q.text('sent_by'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(raw, EmailLog.fromJson);
});

// ---------------------------------------------------------------------------
// Moderation — flags
// ---------------------------------------------------------------------------

/// `ContentFlag.FLAG_REASONS`.
const List<({String value, String label})> kFlagReasonChoices = [
  (value: 'nsfw', label: 'NSFW'),
  (value: 'toxic', label: 'Toxic'),
  (value: 'spam', label: 'Spam'),
  (value: 'misinfo', label: 'Misinfo'),
  (value: 'medical_claim', label: 'Medical claim'),
  (value: 'undisclosed_sponsor', label: 'Undisclosed sponsor'),
  (value: 'adult_ungated', label: 'Adult outside Mature'),
  (value: 'custom', label: 'Custom'),
];

/// `ContentFlag.SEVERITY_CHOICES`.
/// Every takedown-able content type, mirroring the server registry. Modelled as
/// a constant rather than read from `supported_content_types` so the chips are
/// present before the queue responds, and so the labels are ours to write.
const List<({String value, String label})> kContentTypeChoices = [
  (value: 'feed.post', label: 'Posts'),
  (value: 'feed.comment', label: 'Comments'),
  (value: 'user.profile', label: 'Profiles'),
  (value: 'profiles.buddy_search_profile', label: 'Find a buddy'),
  (value: 'messaging.community', label: 'Communities'),
  (value: 'messaging.community_post', label: 'Community posts'),
  (value: 'marketplace.product', label: 'Products'),
  (value: 'marketplace.meal_plan', label: 'Meal plans'),
  (value: 'marketplace.programme', label: 'Programmes'),
  (value: 'marketplace.event', label: 'Events'),
  (value: 'gym', label: 'Gyms'),
  (value: 'gyms.schedule_post', label: 'Schedules'),
  (value: 'lives.buddy_live', label: 'Lives'),
  (value: 'sessions.booking', label: 'Sessions'),
  (value: 'sessions.trainer_profile', label: 'Trainer profiles'),
  (value: 'sessions.availability', label: 'Availability'),
];

const List<({String value, String label})> kFlagSeverityChoices = [
  (value: 'critical', label: 'Critical'),
  (value: 'high', label: 'High'),
  (value: 'medium', label: 'Medium'),
  (value: 'low', label: 'Low'),
];

/// What a flag is complaining about, in words. Copied from the web queue's
/// `REASON_HELP` because the guidance is the part a moderator acts on — three
/// of these are policy calls a dropdown cannot make.
const Map<String, String> kFlagReasonGuidance = {
  'medical_claim':
      'Content claims a meal plan or programme treats, cures or manages a '
      'medical condition. Non-practitioners must never make these claims.',
  'undisclosed_sponsor':
      'Content reads as promotional (gifted or paid) without a clear, prominent '
      'disclosure. A hidden disclosure counts as no disclosure.',
  'adult_ungated':
      'Adult content posted outside the Mature category. Move it behind the age '
      'gate or remove it.',
};

/// One page of the flag queue plus the registry the takedowns are backed by.
class FlagQueuePage extends PortalPage<ContentFlag> {
  /// `ContentType` labels the server can actually take down. A flag naming a
  /// type outside this registry cannot be removed, and finding that out after
  /// pressing Remove is worse than seeing it beforehand.
  final Map<String, String> supportedContentTypes;

  const FlagQueuePage(
    super.items,
    super.pagination,
    this.supportedContentTypes,
  );

  bool isRemovable(ContentFlag flag) =>
      supportedContentTypes.containsKey(flag.contentType);
}

final flagQueueProvider = FutureProvider.family<FlagQueuePage,
    ({String flagReason, String severity, String contentType})>((ref, args) async {
  final raw = await ref
      .watch(adminPortalRepositoryProvider)
      .getContentFlagQueue(
        flagReason: args.flagReason.isEmpty ? null : args.flagReason,
        severity: args.severity.isEmpty ? null : args.severity,
        contentType: args.contentType.isEmpty ? null : args.contentType,
      );
  final rows = moderationRows(raw);
  final registry = <String, String>{};
  if (raw is Map && raw['supported_content_types'] is Map) {
    (raw['supported_content_types'] as Map).forEach((key, value) {
      if (key is String && value is Map && value['label'] is String) {
        registry[key] = value['label'] as String;
      }
    });
  }
  return FlagQueuePage(
    rows.map(ContentFlag.fromJson).toList(),
    moderationPagination(raw, rows.length),
    registry,
  );
});

final contentFlagStatsProvider = FutureProvider<ModerationStats>((ref) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getContentFlagStats();
  final data = raw is Map ? raw['data'] : null;
  return ModerationStats.fromJson(
      data is Map<String, dynamic> ? data : const <String, dynamic>{});
});

/// A band for a report's SLA clock.
enum SlaState { breached, dueSoon, onTrack, settled }

/// Classify a report against its server-computed deadline.
///
/// `sla_breached` is authoritative and always wins: the server is the thing
/// that counts time, and a device clock that has drifted must not turn an
/// overdue report green. `sla_due_at` is only consulted to distinguish "due
/// soon" from "on track" for a report that has not yet breached.
SlaState slaStateFor(ModerationReport report, {DateTime? now}) {
  if (report.status == 'resolved' || report.status == 'dismissed') {
    return SlaState.settled;
  }
  if (report.slaBreached) return SlaState.breached;
  final due = DateTime.tryParse(report.slaDueAt ?? '');
  if (due == null) return SlaState.onTrack;
  final at = (now ?? DateTime.now()).toUtc();
  if (!due.toUtc().isAfter(at)) return SlaState.breached;
  return due.toUtc().difference(at).inHours < kSlaSoonHours
      ? SlaState.dueSoon
      : SlaState.onTrack;
}

/// A report inside this many hours of its deadline reads as "due soon" rather
/// than comfortably on track. Matches the server's own urgent window.
const int kSlaSoonHours = 4;

/// `ModerationReport.REPORT_REASONS`.
const List<({String value, String label})> kReportReasonChoices = [
  (value: 'spam', label: 'Spam'),
  (value: 'harassment', label: 'Harassment'),
  (value: 'hate_speech', label: 'Hate speech'),
  (value: 'nudity', label: 'Nudity / sexual'),
  (value: 'adult_ungated', label: 'Adult outside Mature'),
  (value: 'violence', label: 'Violence'),
  (value: 'misinformation', label: 'Misinformation'),
  (value: 'impersonation', label: 'Impersonation'),
  (value: 'other', label: 'Other'),
];

/// `ModerationReport.STATUS_CHOICES`.
const List<({String value, String label})> kReportStatusChoices = [
  (value: 'open', label: 'Open'),
  (value: 'investigating', label: 'Investigating'),
  (value: 'resolved', label: 'Resolved'),
  (value: 'dismissed', label: 'Dismissed'),
];

/// How the reports queue is scoped. `mine` and `unassigned` are the two
/// filters that turn a shared queue into a work queue.
const List<({String value, String label})> kReportAssignmentChoices = [
  (value: 'all', label: 'All reports'),
  (value: 'mine', label: 'Assigned to me'),
  (value: 'unassigned', label: 'Unassigned'),
];

final moderationReportsProvider =
    FutureProvider.family<PortalPage<ModerationReport>, ModerationQuery>(
        (ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getModerationReports(
        status: q.text('status'),
        reason: q.text('reason'),
        assignedTo: q.text('assigned_to'),
        unassigned: q.text('unassigned'),
        cursor: q.cursor,
        limit: kModerationPageSize,
      );
  return _page(raw, ModerationReport.fromJson);
});

// ---------------------------------------------------------------------------
// Moderation — the action ledger
// ---------------------------------------------------------------------------

/// `ModerationAction.ACTION_CHOICES`.
const List<({String value, String label})> kModerationActionChoices = [
  (value: 'warning', label: 'Warning'),
  (value: 'content_removed', label: 'Content removed'),
  (value: 'user_suspended', label: 'User suspended'),
  (value: 'user_banned', label: 'User banned'),
  (value: 'report_dismissed', label: 'Report dismissed'),
  (value: 'escalated', label: 'Escalated'),
  (value: 'action_reversed', label: 'Action reversed'),
];

/// The three actions `POST /moderation/actions/` accepts.
///
/// `content_removed` is absent on purpose: it needs a `ContentFlag` to say
/// *which* content, so it is taken through the flag's `act/` endpoint and the
/// two cannot drift apart. The other four are server-owned outcomes.
const List<({String value, String label})> kRequestableModerationActions = [
  (value: 'warning', label: 'Warning'),
  (value: 'user_suspended', label: 'Suspend (needs a second approver)'),
  (value: 'user_banned', label: 'Ban (needs a second approver)'),
];

final moderationActionsProvider =
    FutureProvider.family<PortalPage<ModerationAction>, ModerationQuery>(
        (ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getModerationActions(
        action: q.text('action'),
        cursor: q.cursor,
        limit: kModerationPageSize,
      );
  return _page(raw, ModerationAction.fromJson);
});

/// Result of issuing a disciplinary action, whichever way the server answered.
///
/// A `warning` is a `ModerationAction` at 201 and is already in force. A
/// suspension or ban is an `AccountActionRequest` at 202 with `applied: false`
/// — nothing has happened to the account and a second person has to say yes.
/// Collapsing both into one "done" toast is the mistake this shape exists to
/// prevent.
class ModerationActionResult {
  final ModerationAction? action;
  final ModerationApprovalStub? approval;
  final String message;

  const ModerationActionResult({this.action, this.approval, this.message = ''});

  /// True only when the effect is actually in force.
  bool get isApplied => action != null && approval == null;

  bool get isPendingSecondApprover => approval != null;
}

/// Turn a create response into a [ModerationActionResult].
///
/// Reads the body, not the status code, because both outcomes are successful
/// HTTP calls and the discriminator the server documents is `applied`.
ModerationActionResult moderationActionResult(dynamic raw, {String fallback = ''}) {
  final message = portalMessage(raw, fallback: fallback);
  final data = raw is Map ? raw['data'] : null;
  if (data is! Map<String, dynamic>) {
    return ModerationActionResult(message: message);
  }
  final approval = data['approval'];
  if (approval is Map<String, dynamic>) {
    return ModerationActionResult(
      action: data['moderation_action'] is Map<String, dynamic>
          ? ModerationAction.fromJson(data['moderation_action'] as Map<String, dynamic>)
          : null,
      approval: ModerationApprovalStub.fromJson(approval),
      message: message,
    );
  }
  // The 201 shape: the row itself, not a wrapper.
  return ModerationActionResult(
    action: ModerationAction.fromJson(data),
    message: message,
  );
}

// ---------------------------------------------------------------------------
// Moderation — pending approvals (the moderation-side view of the same queue)
// ---------------------------------------------------------------------------

/// Ban/suspension requests still waiting for their second approver.
///
/// Raised by `POST /moderation/actions/`, decided in `/governance/approvals/`.
/// Surfaced here because the moderator who asked has no other way to tell
/// "queued" from "failed".
final pendingModerationApprovalsProvider =
    FutureProvider<List<ModerationPendingApproval>>((ref) async {
  final raw = await ref
      .watch(adminPortalRepositoryProvider)
      .getPendingModerationApprovals();
  return moderationRows(raw).map(ModerationPendingApproval.fromJson).toList();
});

// ---------------------------------------------------------------------------
// Moderation — appeals and commendations
// ---------------------------------------------------------------------------

/// `ModerationAppeal.STATUS_CHOICES`.
const List<({String value, String label})> kAppealStatusChoices = [
  (value: 'submitted', label: 'Submitted'),
  (value: 'under_review', label: 'Under review'),
  (value: 'approved', label: 'Approved'),
  (value: 'denied', label: 'Denied'),
];

/// `ModerationAppealReviewSerializer` decisions.
///
/// `review` is the honest third option: an approver who needs more time moves
/// the appeal to `under_review` instead of leaving it looking untouched.
const List<({String value, String label})> kAppealDecisionChoices = [
  (value: 'approve', label: 'Approve (reverses the action)'),
  (value: 'review', label: 'Mark under review'),
  (value: 'deny', label: 'Deny'),
];

final appealsProvider =
    FutureProvider.family<PortalPage<ModerationAppeal>, ModerationQuery>(
        (ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getModerationAppeals(
        status: q.text('status'),
        cursor: q.cursor,
        limit: kModerationPageSize,
      );
  return _page(raw, ModerationAppeal.fromJson);
});

/// `Commendation.CATEGORY_CHOICES`.
const List<({String value, String label})> kCommendationCategories = [
  (value: 'excellent_service', label: 'Excellent service'),
  (value: 'helpful', label: 'Helpful'),
  (value: 'reliable', label: 'Reliable'),
  (value: 'community_builder', label: 'Community builder'),
  (value: 'above_and_beyond', label: 'Above and beyond'),
  (value: 'resolved_issue', label: 'Resolved issue'),
];

final commendationsProvider =
    FutureProvider.family<PortalPage<ModerationCommendation>, ModerationQuery>(
        (ref, q) async {
  final raw = await ref
      .watch(adminPortalRepositoryProvider)
      .getModerationCommendations(
        category: q.text('category'),
        cursor: q.cursor,
        limit: kModerationPageSize,
      );
  return _page(raw, ModerationCommendation.fromJson);
});

/// The server's refusal, read for the cases a generic message would lose.
///
/// A 429 from the email console means something specific — this account has
/// queued 20 messages in the hour — and the operator's next move is to wait or
/// escalate, not to retry. Surfacing the server's own sentence avoids sending
/// them into a retry loop against a ceiling that will not move.
String moderationRefusal(Object error, {String fallback = 'That action was refused.'}) {
  final status = apiStatusCode(error);
  if (status == 429) {
    return apiErrorMessage(
      error,
      fallback: 'You have reached the $kStaffEmailHourlyCeiling messages per '
          'hour ceiling for this staff account. Try again later, or escalate '
          'to an administrator.',
    );
  }
  return apiErrorMessage(error, fallback: fallback);
}