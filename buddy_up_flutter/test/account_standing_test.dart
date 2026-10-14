import 'package:buddy_up_flutter/data/models/notification.dart';
import 'package:buddy_up_flutter/features/settings/providers/moderation_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// Account standing: what a warned, suspended or banned member sees, and what
/// they can do about it.
///
/// The web wave already had this (`pages/settings/standing.ts` +
/// `components/layout/StandingBanner.tsx`). The Flutter side had the Settings
/// record but not the reversal rule, which is the part that is easy to get
/// wrong in a way nobody notices: a lifted ban keeps showing "your account has
/// been banned", and offers an appeal button for a decision that no longer
/// exists.
void main() {
  BuddyNotification notice(
    String type,
    Map<String, dynamic> metadata, {
    String id = 'n1',
    String createdAt = '2026-03-01T10:00:00Z',
    String body = '',
  }) =>
      BuddyNotification(
        id: id,
        notificationType: type,
        title: type,
        body: body,
        createdAt: createdAt,
        metadata: metadata,
      );

  group('a punitive action is standing and is appealable', () {
    test('a suspension carries its reason and its end date', () {
      final standing = buildStanding([
        notice('moderation_suspension', {
          'action': 'user_suspended',
          'moderation_action_id': 'act-1',
          'reason': 'Repeated harassment in DMs.',
          'suspended_until': '2026-03-15T00:00:00Z',
          'duration_days': 14,
          'permanent': false,
        }),
      ]);

      expect(standing, hasLength(1));
      final entry = standing.single;
      expect(entry.kind, ModerationNoticeKind.suspension);
      expect(entry.reason, 'Repeated harassment in DMs.');
      expect(entry.endDateLabel, 'Until 2026-03-15');
      expect(entry.durationDays, 14);
      expect(entry.restrictsAccess, isTrue);
      expect(entry.isActive, isTrue);
      expect(entry.isAppealable, isTrue);
    });

    test('a permanent ban says so rather than leaving the end date blank', () {
      final entry = buildStanding([
        notice('moderation_ban', {
          'action': 'user_banned',
          'moderation_action_id': 'act-2',
          'reason': 'Selling prescription medication.',
          'permanent': true,
        }),
      ]).single;

      expect(entry.kind, ModerationNoticeKind.ban);
      expect(entry.endDateLabel, contains('Permanent'));
      expect(entry.isAppealable, isTrue);
    });

    test('a warning restricts nothing and has no end date', () {
      final entry = buildStanding([
        notice('moderation_warning', {
          'action': 'warning',
          'moderation_action_id': 'act-3',
          'reason': 'Off-platform payment request.',
        }),
      ]).single;

      expect(entry.restrictsAccess, isFalse);
      expect(entry.endDateLabel, contains('Not applicable'));
      expect(entry.isAppealable, isTrue);
    });
  });

  group('a reversed action is history, not standing', () {
    // `notify_action_reversed` writes `original_action_id` and **no**
    // `moderation_action_id` — it carries `reversal_action_id`. A fold that
    // required `moderation_action_id` would drop every reversal the server
    // actually sends.
    test('a reversed ban stops being shown as standing', () {
      final standing = buildStanding([
        notice('moderation_ban', {
          'action': 'user_banned',
          'moderation_action_id': 'act-1',
          'reason': 'Appealed in error.',
          'permanent': true,
        }, id: 'n1', createdAt: '2026-03-01T10:00:00Z'),
        notice('moderation_action_reversed', {
          'original_action_id': 'act-1',
          'reversal_action_id': 'act-2',
          'reason': 'Appealed in error.',
        }, id: 'n2', createdAt: '2026-03-04T09:00:00Z'),
      ]);

      expect(standing, hasLength(1));
      expect(standing.single.reversed, isTrue);
      expect(standing.single.isActive, isFalse);
      // No appeal button for something that no longer exists.
      expect(standing.single.isAppealable, isFalse);
      expect(standing.single.restrictsAccess, isFalse);
    });

    test('the reversal itself is not listed as standing', () {
      final standing = buildStanding([
        notice('moderation_action_reversed', {
          'original_action_id': 'act-1',
          'reversal_action_id': 'act-2',
        }),
      ]);
      // A reversal is not something to appeal, so it never becomes a row.
      expect(standing, isEmpty);
    });

    test('a reversal with a blank id does not mark anything', () {
      final standing = buildStanding([
        notice('moderation_ban', {
          'action': 'user_banned',
          'moderation_action_id': 'act-1',
          'reason': 'x',
        }),
        notice('moderation_action_reversed', {'original_action_id': '   '}),
      ]);
      expect(standing.single.reversed, isFalse);
    });

    test('only the reversed action is affected, not its neighbours', () {
      final standing = buildStanding([
        notice('moderation_warning', {
          'action': 'warning',
          'moderation_action_id': 'act-1',
          'reason': 'First.',
        }, id: 'n1', createdAt: '2026-03-01T10:00:00Z'),
        notice('moderation_suspension', {
          'action': 'user_suspended',
          'moderation_action_id': 'act-2',
          'reason': 'Second.',
          'suspended_until': '2026-03-20T00:00:00Z',
        }, id: 'n2', createdAt: '2026-03-02T10:00:00Z'),
        notice('moderation_action_reversed', {
          'original_action_id': 'act-1',
          'reversal_action_id': 'act-9',
        }, id: 'n3', createdAt: '2026-03-03T10:00:00Z'),
      ]);

      expect(standing, hasLength(2));
      final byAction = {for (final e in standing) e.actionId: e};
      expect(byAction['act-1']!.reversed, isTrue);
      expect(byAction['act-2']!.reversed, isFalse);
      expect(byAction['act-2']!.isAppealable, isTrue);
    });
  });

  group('one row per action, newest first', () {
    test('two notices for the same action collapse to the newer one', () {
      final standing = buildStanding([
        notice('moderation_suspension', {
          'action': 'user_suspended',
          'moderation_action_id': 'act-1',
          'reason': 'Original reason.',
          'suspended_until': '2026-03-10T00:00:00Z',
        }, id: 'n1', createdAt: '2026-03-01T10:00:00Z'),
        notice('moderation_suspension', {
          'action': 'user_suspended',
          'moderation_action_id': 'act-1',
          'reason': 'Extended reason.',
          'suspended_until': '2026-03-20T00:00:00Z',
        }, id: 'n2', createdAt: '2026-03-05T10:00:00Z'),
      ]);

      expect(standing, hasLength(1));
      expect(standing.single.reason, 'Extended reason.');
      expect(standing.single.endDateLabel, 'Until 2026-03-20');
    });

    test('the newest action is first, whatever order the feed arrives in', () {
      final standing = buildStanding([
        notice('moderation_warning', {
          'action': 'warning',
          'moderation_action_id': 'old',
          'reason': 'Older.',
        }, id: 'n1', createdAt: '2026-03-01T10:00:00Z'),
        notice('moderation_ban', {
          'action': 'user_banned',
          'moderation_action_id': 'new',
          'reason': 'Newer.',
        }, id: 'n2', createdAt: '2026-03-09T10:00:00Z'),
      ]);
      expect(standing.first.actionId, 'new');
    });
  });

  group('a missing or renamed field degrades rather than throwing', () {
    test('a notice with no action id is not listed, and parsing survives it',
        () {
      expect(moderationNoticeFrom(notice('moderation_warning', {})), isNotNull);
      // No action id means there is nothing to appeal and nothing to link to,
      // so the row is dropped rather than shown with a dead button — the same
      // rule `pages/settings/standing.ts` applies on the web.
      expect(buildStanding([notice('moderation_warning', {})]), isEmpty);
    });

    test('a non-string original_action_id is ignored', () {
      final standing = buildStanding([
        notice('moderation_ban', {
          'action': 'user_banned',
          'moderation_action_id': 'act-1',
          'reason': 'x',
        }),
        notice('moderation_action_reversed', {'original_action_id': 42}),
      ]);
      expect(standing.single.reversed, isFalse);
    });

    test('an unrelated notification never becomes standing', () {
      expect(buildStanding([notice('post_reaction', {'post_id': 'p1'})]), isEmpty);
      expect(buildStanding([]), isEmpty);
    });
  });
}