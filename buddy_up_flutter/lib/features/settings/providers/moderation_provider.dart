import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/admin_portal.dart';
import '../../../data/models/notification.dart';
import '../../admin/providers/admin_provider.dart';
import '../../admin/providers/governance_provider.dart';
import '../../notifications/providers/notification_provider.dart';

/// The user-side half of moderation: what was done to this account, and the
/// appeal route for it.
///
/// `POST /moderation/appeals/` existed before this screen and had no caller on
/// any client, which made the whole appeal process decorative — a moderator
/// writes a reason expecting the target to see it and challenge it, and the
/// target has nowhere to put the challenge.
///
/// **Where the action ids come from.** The appeals endpoint takes a
/// `ModerationAction` id, and a non-staff user cannot list their own actions:
/// `GET /moderation/actions/` is `IsAdminUser`. The one place a normal user
/// learns an action id is the notification the action raised — see
/// `apps.moderation.services.notify_action_taken`, which puts
/// `moderation_action_id`, `reason`, `duration_days`, `suspended_until` and
/// `permanent` into the metadata of the notification the target receives. So
/// this screen reads the notification feed, not an endpoint of its own.

/// Notification types that correspond to an appealable moderation action.
///
/// Mirrors `moderation.services.ACTION_NOTIFICATION_TYPES`. `escalated` and
/// `report_dismissed` are deliberately absent from that map and from this one:
/// they are internal routing decisions, and showing them as something to
/// appeal would be alarming and meaningless.
const Set<String> kModerationNoticeTypes = {
  'moderation_warning',
  'moderation_content_removed',
  'moderation_suspension',
  'moderation_ban',
};

/// Notification types that describe *current* standing, reversals included.
///
/// A reversal is collected here but is not itself standing: `notify_action_
/// reversed` names the action it undoes under `original_action_id` and carries
/// **no** `moderation_action_id` at all (it has `reversal_action_id`). So a
/// reversal has to be gathered before the action list is built — filtering for
/// `moderation_action_id` first would drop every reversal the server actually
/// sends, and a lifted ban would sit on the account forever.
const Set<String> kStandingNotificationTypes = {
  ...kModerationNoticeTypes,
  'moderation_action_reversed',
};

/// How a notice reads to the person who received it.
enum ModerationNoticeKind { warning, contentRemoved, suspension, ban }

/// One moderation action as the target sees it.
///
/// Derived from a notification rather than fetched: the payload the appeal
/// form needs — the action id, the reason, and whether the action has an end
/// date — is exactly what the notification metadata carries, and duplicating
/// it as a second endpoint would create a second thing to keep in step.
class MyModerationNotice {
  final String notificationId;
  /// The `ModerationAction` id to appeal. Empty when the notification carried
  /// none, in which case the row is shown but not appealable.
  final String actionId;
  final String action;
  final String reason;
  final String? suspendedUntil;
  final bool permanent;
  final int? durationDays;
  final String createdAt;

  /// True when a later notification reversed this action.
  ///
  /// History, not standing: a reversed row must stop being shown as a live
  /// restriction and must not offer an appeal button for something that no
  /// longer exists.
  final bool reversed;

  const MyModerationNotice({
    required this.notificationId,
    required this.actionId,
    required this.action,
    required this.reason,
    required this.createdAt,
    this.suspendedUntil,
    this.permanent = false,
    this.durationDays,
    this.reversed = false,
  });

  ModerationNoticeKind get kind {
    switch (action) {
      case 'user_suspended':
        return ModerationNoticeKind.suspension;
      case 'user_banned':
        return ModerationNoticeKind.ban;
      case 'content_removed':
        return ModerationNoticeKind.contentRemoved;
      default:
        return ModerationNoticeKind.warning;
    }
  }

  String get title => switch (kind) {
        ModerationNoticeKind.warning => 'You received a warning',
        ModerationNoticeKind.contentRemoved => 'Content was removed',
        ModerationNoticeKind.suspension => 'Your account was suspended',
        ModerationNoticeKind.ban => 'Your account was banned',
      };

  /// The sentence answering "when does this end?" — which is the first
  /// question anyone with a suspension or ban actually has.
  ///
  /// A warning and a removal change no access state and so have no end date;
  /// a ban is permanent by definition; a suspension carries one only when the
  /// server sent one.
  String get endDateLabel => switch (kind) {
        ModerationNoticeKind.suspension => suspendedUntil != null
            ? 'Until ${_humanDate(suspendedUntil!)}'
            : 'No end date recorded.',
        ModerationNoticeKind.ban =>
          permanent ? 'Permanent. A ban has no end date.' : 'No end date recorded.',
        _ => 'Not applicable — no access change.',
      };

  bool get restrictsAccess =>
      !reversed &&
      (kind == ModerationNoticeKind.suspension || kind == ModerationNoticeKind.ban);

  /// A reversal is not appealable — there is nothing left to challenge.
  bool get isAppealable => actionId.isNotEmpty && !reversed;

  /// True while this action still governs the account.
  bool get isActive => !reversed;

  static String _humanDate(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }
}

/// Project a notification into a [MyModerationNotice], or null when it is not a
/// moderation notice.
///
/// Every field is read defensively out of a free-form metadata map: the map is
/// written by a Celery task in another app, and a renamed key must degrade to
/// "no reason recorded" rather than throw inside a settings screen.
MyModerationNotice? moderationNoticeFrom(BuddyNotification notification) {
  if (!kModerationNoticeTypes.contains(notification.notificationType)) {
    return null;
  }
  final metadata = notification.metadata ?? const <String, dynamic>{};
  final action = metadata['action'];
  final actionId = metadata['moderation_action_id'];
  final reason = metadata['reason'];
  final suspendedUntil = metadata['suspended_until'];
  final permanent = metadata['permanent'];
  final durationDays = metadata['duration_days'];
  return MyModerationNotice(
    notificationId: notification.id,
    actionId: actionId is String ? actionId : '',
    action: action is String && action.isNotEmpty
        ? action
        : _actionFromType(notification.notificationType),
    reason: reason is String ? reason : '',
    suspendedUntil: suspendedUntil is String && suspendedUntil.isNotEmpty
        ? suspendedUntil
        : null,
    permanent: permanent == true,
    durationDays: switch (durationDays) {
      final int value => value,
      final num value => value.toInt(),
      _ => int.tryParse('$durationDays'),
    },
    createdAt: notification.createdAt,
  );
}

/// Fall back to the action name implied by the notification type, so a notice
/// still reads correctly if `metadata.action` ever goes missing.
String _actionFromType(String notificationType) => switch (notificationType) {
      'moderation_warning' => 'warning',
      'moderation_content_removed' => 'content_removed',
      'moderation_suspension' => 'user_suspended',
      'moderation_ban' => 'user_banned',
      _ => 'warning',
    };

/// True when [a] is strictly older than [b].
///
/// `_compareTo`, not `<`: the operator is not defined on `String`, and the feed
/// is ISO-8601 so lexicographic order is chronological order.
bool _olderThan(String a, String b) => a.compareTo(b) < 0;

/// Every moderation action taken against this account, newest first, with
/// reversals resolved across the whole feed.
///
/// One row per `moderation_action_id` rather than one per notification: a
/// repeated action on the same row would otherwise show twice, and the app-wide
/// standing banner below takes the first entry as *the* current standing.
final myModerationNoticesProvider =
    FutureProvider<List<MyModerationNotice>>((ref) async {
  final notifications = await ref.watch(notificationsProvider.future);
  return buildStanding(notifications);
});

/// Fold this account's moderation notifications into one row per action.
///
/// Pure and separate from the provider so it is directly testable against
/// fixtures rather than only through the screen — the reversal rule is the part
/// that is easy to get subtly wrong and impossible to notice in a widget test.
///
/// Two things this has to get right, both of which are user-facing mistakes
/// rather than crashes:
///
/// * **Reversal.** A lifted ban must stop showing "your account was banned"
///   and must stop offering an appeal for it.
/// * **Reversals are not themselves listable.** A reversal is not something to
///   appeal, so only the punitive notification types survive the final filter.
List<MyModerationNotice> buildStanding(List<BuddyNotification> notifications) {
  final standing = notifications
      .where((n) => kStandingNotificationTypes.contains(n.notificationType))
      .toList();

  final reversedIds = <String>{
    for (final n in standing)
      if (n.notificationType == 'moderation_action_reversed')
        if (n.metadata?['original_action_id'] is String)
          (n.metadata!['original_action_id'] as String).trim(),
  }..removeWhere((id) => id.isEmpty);

  final byAction = <String, MyModerationNotice>{};
  for (final n in standing) {
    final notice = moderationNoticeFrom(n);
    if (notice == null) continue;
    // A reversal notice names the action it undoes, not an action of its own.
    if (!kModerationNoticeTypes.contains(n.notificationType)) continue;
    if (notice.actionId.isEmpty) continue;
    final entry = MyModerationNotice(
      notificationId: notice.notificationId,
      actionId: notice.actionId,
      action: notice.action,
      reason: notice.reason.isEmpty ? n.body : notice.reason,
      createdAt: notice.createdAt,
      suspendedUntil: notice.suspendedUntil,
      permanent: notice.permanent,
      durationDays: notice.durationDays,
      reversed: reversedIds.contains(notice.actionId),
    );
    final existing = byAction[notice.actionId];
    // The feed is newest-first, so an existing row is the older one.
    if (existing == null || _olderThan(existing.createdAt, entry.createdAt)) {
      byAction[notice.actionId] = entry;
    }
  }
  final rows = byAction.values.toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return rows.reversed.toList();
}

/// The one row the app-wide standing banner shows: the newest action still in
/// force, or null when there is none.
///
/// Null rather than an empty list, and the banner renders nothing at all for
/// it — a failed or empty load must never put an alarming banner in front of an
/// account with nothing on it.
final currentStandingProvider =
    FutureProvider<MyModerationNotice?>((ref) async {
  final notices = await ref.watch(myModerationNoticesProvider.future);
  for (final notice in notices) {
    if (notice.isActive && notice.restrictsAccess) return notice;
  }
  return null;
});

/// Appeals this account has raised.
final myAppealsProvider = FutureProvider<PortalPage<ModerationAppeal>>((ref) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getModerationAppeals();
  final rows = moderationRows(raw);
  return PortalPage(
    rows.map(ModerationAppeal.fromJson).toList(),
    moderationPagination(raw, rows.length),
  );
});

/// Commendations addressed to this account, plus any it issued.
///
/// The endpoint already scopes a non-staff caller to their own rows and hides
/// revoked ones, so this does not re-filter.
final myCommendationsProvider =
    FutureProvider<PortalPage<ModerationCommendation>>((ref) async {
  final raw =
      await ref.watch(adminPortalRepositoryProvider).getModerationCommendations();
  final rows = moderationRows(raw);
  return PortalPage(
    rows.map(ModerationCommendation.fromJson).toList(),
    moderationPagination(raw, rows.length),
  );
});