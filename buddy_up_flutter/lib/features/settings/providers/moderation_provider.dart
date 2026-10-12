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

  const MyModerationNotice({
    required this.notificationId,
    required this.actionId,
    required this.action,
    required this.reason,
    required this.createdAt,
    this.suspendedUntil,
    this.permanent = false,
    this.durationDays,
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
      kind == ModerationNoticeKind.suspension || kind == ModerationNoticeKind.ban;

  bool get isAppealable => actionId.isNotEmpty;

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

/// Every moderation action taken against this account, newest first.
final myModerationNoticesProvider =
    FutureProvider<List<MyModerationNotice>>((ref) async {
  final notifications = await ref.watch(notificationsProvider.future);
  return notifications
      .map(moderationNoticeFrom)
      .whereType<MyModerationNotice>()
      .toList();
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