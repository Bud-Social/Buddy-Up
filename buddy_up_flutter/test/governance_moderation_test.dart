import 'package:buddy_up_flutter/data/models/admin_portal.dart';
import 'package:buddy_up_flutter/data/models/notification.dart';
import 'package:buddy_up_flutter/features/admin/providers/admin_provider.dart';
import 'package:buddy_up_flutter/features/admin/providers/governance_provider.dart';
import 'package:buddy_up_flutter/features/settings/providers/moderation_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixtures shaped from `apps/governance/serializers.py`,
/// `apps/moderation/serializers.py` and the response bodies
/// `apps/moderation/views.py` actually builds.
void main() {
  group('moderationRows unwraps every list shape the server emits', () {
    test('the hand-built envelope, where the rows sit under `data`', () {
      // ContentFlagViewSet.queue builds this by hand.
      expect(moderationRows({
        'success': true,
        'data': [
          {'id': 'f1'},
          {'id': 'f2'},
        ],
        'count': 2,
      }), hasLength(2));
    });

    test('a bare DRF cursor page, which is what the viewsets return', () {
      expect(moderationRows({
        'next': 'https://api.example.com/api/v1/moderation/reports/?cursor=x',
        'previous': null,
        'results': [
          {'id': 'r1'},
        ],
      }), hasLength(1));
    });

    test('a bare array still works', () {
      expect(moderationRows([
        {'id': 'a1'},
      ]), hasLength(1));
    });

    test('a shape this has never seen is empty, not an exception', () {
      // A staff screen mid-incident must render "nothing" rather than throw.
      expect(moderationRows(null), isEmpty);
      expect(moderationRows(42), isEmpty);
      expect(moderationRows({'unexpected': 'shape'}), isEmpty);
    });

    test('non-map rows are dropped rather than crashing the row parser', () {
      expect(moderationRows([
        {'id': 'f1'},
        'garbage',
        null,
      ]), hasLength(1));
    });
  });

  group('moderationPagination reads the real total, or admits it has none', () {
    test('the envelope `pagination` block wins', () {
      final pagination = moderationPagination({
        'success': true,
        'data': [],
        'pagination': {'count': 137},
      }, 0);
      expect(pagination.count, 137);
    });

    test('a top-level `count` is used when there is no pagination block', () {
      // The flag queue puts its total beside `data` precisely so a queue can
      // say "240 pending" without paginating.
      final pagination = moderationPagination({
        'success': true,
        'data': [],
        'count': 240,
      }, 0);
      expect(pagination.count, 240);
    });

    test('a cursor page has no count, so it honestly reports one page', () {
      // Inventing a total here would offer a "Next" that leads nowhere.
      final pagination = moderationPagination({
        'next': null,
        'previous': null,
        'results': [
          {'id': 'r1'},
          {'id': 'r2'},
        ],
      }, 2);
      expect(pagination.count, 2);
      expect(pagination.next, isNull);
    });
  });

  group('auditExportFilename', () {
    test('reads the quoted filename the server writes', () {
      expect(
        auditExportFilename(
          'attachment; filename="admin-audit-20260304-141200.csv"',
        ),
        'admin-audit-20260304-141200.csv',
      );
    });

    test('reads the RFC 5987 form too', () {
      expect(
        auditExportFilename("attachment; filename*=UTF-8''admin%20audit.csv"),
        'admin audit.csv',
      );
    });

    test('a missing or useless header falls back rather than showing null', () {
      expect(auditExportFilename(null), 'admin-audit.csv');
      expect(auditExportFilename('attachment'), 'admin-audit.csv');
    });

    test('a stray percent sign does not lose the download', () {
      expect(auditExportFilename('attachment; filename=100%.csv'), '100%.csv');
    });
  });

  group('SLA badges read the server clock, not the device clock', () {
    final now = DateTime.utc(2026, 3, 4, 12);

    test('sla_breached is authoritative even with a future deadline', () {
      // A device clock that has drifted must not turn an overdue report green.
      final report = ModerationReport.fromJson({
        'id': 'r1',
        'sla_due_at': '2026-03-04T20:00:00Z',
        'sla_breached': true,
      });
      expect(slaStateFor(report, now: now), SlaState.breached);
    });

    test('a settled report has no clock to be late against', () {
      for (final status in const ['resolved', 'dismissed']) {
        final report = ModerationReport.fromJson({
          'id': 'r1',
          'status': status,
          'sla_breached': true,
        });
        expect(slaStateFor(report, now: now), SlaState.settled);
      }
    });

    test('inside the urgent window reads as due soon', () {
      final report = ModerationReport.fromJson({
        'id': 'r1',
        'status': 'open',
        'sla_due_at': '2026-03-04T14:00:00Z',
      });
      expect(slaStateFor(report, now: now), SlaState.dueSoon);
    });

    test('comfortably inside the window reads as on track', () {
      final report = ModerationReport.fromJson({
        'id': 'r1',
        'status': 'open',
        'sla_due_at': '2026-03-05T12:00:00Z',
      });
      expect(slaStateFor(report, now: now), SlaState.onTrack);
    });

    test('a missing deadline is on track, never a crash', () {
      final report = ModerationReport.fromJson({'id': 'r1', 'status': 'open'});
      expect(slaStateFor(report, now: now), SlaState.onTrack);
    });

    test('a deadline in the past is breached even if the flag says otherwise', () {
      final report = ModerationReport.fromJson({
        'id': 'r1',
        'status': 'open',
        'sla_due_at': '2026-03-04T11:00:00Z',
        'sla_breached': false,
      });
      expect(slaStateFor(report, now: now), SlaState.breached);
    });
  });

  group('a disciplinary action is not applied until it is approved', () {
    test('a warning comes back as a plain 201 row and counts as applied', () {
      // ModerationActionViewSet.create, 201 branch.
      final outcome = moderationActionResult({
        'success': true,
        'message': 'Warning issued and the user has been notified.',
        'data': {
          'id': 'a1',
          'action': 'warning',
          'target_user': 'user-1',
          'reason': 'Repeated spam in DMs',
        },
      });
      expect(outcome.isApplied, isTrue);
      expect(outcome.isPendingSecondApprover, isFalse);
      expect(outcome.action?.action, 'warning');
      expect(outcome.message, contains('notified'));
    });

    test('a ban comes back as a 202 with applied:false and no effect yet', () {
      // ModerationActionViewSet.create, 202 branch. This is the case that must
      // never be reported to the moderator as "done".
      final outcome = moderationActionResult({
        'success': true,
        'message': 'user_banned requires a second approver. Nothing has been '
            'applied yet.',
        'data': {
          'moderation_action': {'id': 'a2', 'action': 'user_banned'},
          'approval': {
            'id': 'g1',
            'action': 'ban',
            'status': 'pending',
            'requires_second': true,
          },
          'applied': false,
        },
      });
      expect(outcome.isApplied, isFalse);
      expect(outcome.isPendingSecondApprover, isTrue);
      expect(outcome.approval?.status, 'pending');
      expect(outcome.message, contains('second approver'));
    });

    test('a body with no data is neither applied nor pending', () {
      final outcome = moderationActionResult({'message': 'OK'}, fallback: 'Done.');
      expect(outcome.isApplied, isFalse);
      expect(outcome.isPendingSecondApprover, isFalse);
      expect(outcome.message, 'OK');
    });
  });

  group('approval rows', () {
    test('the free-form payload yields a reason and a term defensively', () {
      final request = AccountActionRequest.fromJson({
        'id': 'g1',
        'action': 'suspension',
        'status': 'pending',
        'payload': {'reason': 'Abuse threshold', 'duration_days': 14},
      });
      expect(request.reason, 'Abuse threshold');
      expect(request.durationDays, 14);
      expect(request.isPending, isTrue);
      expect(request.isSettled, isFalse);
    });

    test('a payload with no reason or term is not a crash', () {
      final request = AccountActionRequest.fromJson({'id': 'g1'});
      expect(request.reason, '');
      expect(request.durationDays, isNull);
    });

    test('a term arriving as a string still reads as a number of days', () {
      final request = AccountActionRequest.fromJson({
        'id': 'g1',
        'payload': {'duration_days': '30'},
      });
      expect(request.durationDays, 30);
    });

    test('the requester label prefers the snapshot that survives deletion', () {
      final request = AccountActionRequest.fromJson({
        'id': 'g1',
        'requested_by_profile': 'Sam Moderator',
        'requested_by': null,
      });
      expect(request.requesterLabel, 'Sam Moderator');
    });

    test('with no snapshot it falls back to the live user ref', () {
      final request = AccountActionRequest.fromJson({
        'id': 'g1',
        'requested_by': {
          'id': 'u1',
          'email': 'ops@example.com',
          'display_name': '',
        },
      });
      expect(request.requesterLabel, 'ops@example.com');
    });

    test('an `effect` that is not a string does not blank the row', () {
      // Only present on the approve response; a dict here must not throw.
      final request = AccountActionRequest.fromJson({
        'id': 'g1',
        'effect': {'applied': true},
      });
      expect(request.effect, isNotNull);
      expect(request.status, '');
    });
  });

  group('audit rows show what actually moved', () {
    test('changedKeys is the symmetric difference, not both sides', () {
      final row = AdminActionLog.fromJson({
        'id': 'au1',
        'action': 'orders.status_change',
        'before': {'status': 'paid', 'note': 'unchanged'},
        'after': {'status': 'shipped', 'note': 'unchanged'},
      });
      expect(row.changedKeys, ['status']);
    });

    test('an unchanged key is not reported as a change', () {
      final row = AdminActionLog.fromJson({
        'id': 'au1',
        'before': {'role': 'support'},
        'after': {'role': 'support'},
      });
      expect(row.changedKeys, isEmpty);
    });

    test('a key going from null to a value is a change', () {
      // The revoke case: `StaffRoleDetailView` writes
      // `revoked_at: None` before and the ISO timestamp after.
      final row = AdminActionLog.fromJson({
        'id': 'au1',
        'before': {'role': 'finance', 'revoked_at': null},
        'after': {'role': 'finance', 'revoked_at': '2026-03-01T00:00:00Z'},
      });
      expect(row.changedKeys, ['revoked_at']);
      expect(row.valueAt('revoked_at'), '');
      expect(row.valueAt('revoked_at', useAfter: true), '2026-03-01T00:00:00Z');
    });

    test('a key present with null on both sides is not a change', () {
      // Absent and null carry the same meaning, so this must not be reported
      // as a delta — it would fill the panel with noise on every status row.
      final row = AdminActionLog.fromJson({
        'id': 'au1',
        'before': {'revoked_at': null},
        'after': <String, dynamic>{},
      });
      expect(row.changedKeys, isEmpty);
    });

    test('both blocks absent is not a crash and reports no change', () {
      final row = AdminActionLog.fromJson({'id': 'au1'});
      expect(row.changedKeys, isEmpty);
      expect(row.valueAt('anything'), '');
      expect(row.valueAt('anything', useAfter: true), '');
    });

    test('the actor label falls back through email, id, then system', () {
      expect(
        AdminActionLog.fromJson({'actor_email': 'ops@example.com'}).actorLabel,
        'ops@example.com',
      );
      expect(
        AdminActionLog.fromJson({'actor': 'abcdef12-3456'}).actorLabel,
        'abcdef12',
      );
      expect(AdminActionLog.fromJson({}).actorLabel, 'system');
    });
  });

  group('email log', () {
    test('only a failure is resendable', () {
      // The server 409s on any other status: re-sending a `sent` message is a
      // duplicate the user did not ask for.
      expect(EmailLog.fromJson({'id': 'e1', 'status': 'failed'}).canResend, isTrue);
      for (final status in const ['queued', 'sent', 'skipped']) {
        expect(
          EmailLog.fromJson({'id': 'e1', 'status': status}).canResend,
          isFalse,
          reason: '$status must not be resendable',
        );
      }
      expect(EmailLog.fromJson({'id': 'e1'}).canResend, isFalse);
    });
  });

  group('staff roles', () {
    test('a missing is_active must not read as "currently holds it"', () {
      // The field is a read_only property on the model, so an absent one is
      // ambiguous; defaulting false fails safe rather than failing open.
      expect(StaffRole.fromJson({'id': 'sr1'}).isActive, isFalse);
      expect(
        StaffRole.fromJson({'id': 'sr1', 'is_active': true}).isActive,
        isTrue,
      );
    });

    test('a revoked row keeps its role and history but grants nothing', () {
      final role = StaffRole.fromJson({
        'id': 'sr1',
        'role': 'finance',
        'role_display': 'Finance',
        'effective_scopes': ['wallet.read', 'orders.write'],
        'revoked_at': '2026-03-01T00:00:00Z',
        'is_active': false,
      });
      expect(role.isActive, isFalse);
      expect(role.roleDisplay, 'Finance');
      expect(role.effectiveScopes, hasLength(2));
    });

    test('an absent user ref still labels as something readable', () {
      expect(GovernanceUserRef.fromJson({}).label, 'Unknown');
      expect(
        GovernanceUserRef.fromJson({
          'id': '12345678-abcd',
          'email': '',
          'display_name': '',
        }).label,
        '12345678',
      );
      expect(
        GovernanceUserRef.fromJson({'email': 'a@b.com'}).label,
        'a@b.com',
      );
    });
  });

  group('reversibility', () {
    test('a live disciplinary action can be reversed; a reversal cannot', () {
      for (final action in const [
        'warning',
        'content_removed',
        'user_suspended',
        'user_banned',
      ]) {
        expect(
          ModerationAction.fromJson({'id': 'a1', 'action': action}).isReversible,
          isTrue,
          reason: '$action should be reversible',
        );
      }
      for (final action in const [
        'report_dismissed',
        'escalated',
        'action_reversed',
      ]) {
        expect(
          ModerationAction.fromJson({'id': 'a1', 'action': action}).isReversible,
          isFalse,
          reason: '$action is not something to reverse',
        );
      }
    });

    test('an already-reversed action is never reversible again', () {
      final action = ModerationAction.fromJson({
        'id': 'a1',
        'action': 'user_banned',
        'is_reversed': true,
      });
      expect(action.isReversible, isFalse);
    });
  });

  group('the user sees their own record, read out of the notification', () {
    BuddyNotification notice(String type, Map<String, dynamic> metadata) =>
        BuddyNotification.fromJson({
          'id': 'n1',
          'notification_type': type,
          'title': 't',
          'body': 'b',
          'created_at': '2026-03-04T12:00:00Z',
          'metadata': metadata,
        });

    test('a non-moderation notification is not a notice at all', () {
      expect(moderationNoticeFrom(notice('like', {})), isNull);
    });

    test('an internal routing decision is deliberately not appealable', () {
      // `escalated` and `report_dismissed` notify nobody on purpose; showing
      // them as something to challenge would alarm the user for no reason.
      expect(
        moderationNoticeFrom(notice('moderation_escalated', {})),
        isNull,
      );
      expect(moderationNoticeFrom(notice('moderation_dismissed', {})), isNull);
    });

    test('a temporary suspension carries its reason and its end date', () {
      final parsed = moderationNoticeFrom(notice('moderation_suspension', {
        'moderation_action_id': 'act-1',
        'action': 'user_suspended',
        'reason': 'Abuse threshold reached',
        'duration_days': 7,
        'suspended_until': '2026-03-11T12:00:00Z',
        'permanent': false,
      }));
      expect(parsed, isNotNull);
      expect(parsed!.kind, ModerationNoticeKind.suspension);
      expect(parsed.reason, 'Abuse threshold reached');
      expect(parsed.durationDays, 7);
      expect(parsed.endDateLabel, 'Until 2026-03-11');
      expect(parsed.restrictsAccess, isTrue);
      expect(parsed.isAppealable, isTrue);
    });

    test('a ban says so, because a ban has no end date', () {
      final parsed = moderationNoticeFrom(notice('moderation_ban', {
        'moderation_action_id': 'act-2',
        'action': 'user_banned',
        'reason': 'Repeated fraud',
        'permanent': true,
      }));
      expect(parsed!.kind, ModerationNoticeKind.ban);
      expect(parsed.endDateLabel, contains('Permanent'));
      expect(parsed.durationDays, isNull);
    });

    test('a warning changes no access state, so it has no end date', () {
      final parsed = moderationNoticeFrom(notice('moderation_warning', {
        'moderation_action_id': 'act-3',
        'action': 'warning',
        'reason': 'Language in comments',
      }));
      expect(parsed!.kind, ModerationNoticeKind.warning);
      expect(parsed.restrictsAccess, isFalse);
      expect(parsed.endDateLabel, contains('Not applicable'));
    });

    test('a missing metadata.action still reads correctly from the type', () {
      // The metadata is written by a Celery task in another app; a renamed key
      // must degrade, not throw inside a settings screen.
      final parsed = moderationNoticeFrom(notice('moderation_ban', {
        'moderation_action_id': 'act-4',
      }));
      expect(parsed!.kind, ModerationNoticeKind.ban);
      expect(parsed.reason, '');
    });

    test('a notice with no action id is shown but not appealable', () {
      final parsed = moderationNoticeFrom(notice('moderation_warning', {}));
      expect(parsed!.isAppealable, isFalse);
    });

    test('a term arriving as a string still reads as a number of days', () {
      final parsed = moderationNoticeFrom(notice('moderation_suspension', {
        'moderation_action_id': 'act-5',
        'duration_days': '14',
      }));
      expect(parsed!.durationDays, 14);
    });
  });

  group('appeal rows', () {
    test('submitted and under_review are both still open', () {
      for (final status in const ['submitted', 'under_review']) {
        expect(
          ModerationAppeal.fromJson({'id': 'ap1', 'status': status}).isOpen,
          isTrue,
        );
      }
      for (final status in const ['approved', 'denied']) {
        expect(
          ModerationAppeal.fromJson({'id': 'ap1', 'status': status}).isOpen,
          isFalse,
        );
      }
    });
  });

  group('every governance model survives an empty row', () {
    // The rule the whole file exists to hold: a renamed or dropped field
    // must degrade in the UI, never crash a decoding. Each model is decoded
    // from `{}` below, which is the worst case.
    test('a bare id is enough for each serializer shape', () {
      expect(StaffRole.fromJson({'id': 'x'}).id, 'x');
      expect(AccountActionRequest.fromJson({'id': 'x'}).id, 'x');
      expect(AdminActionLog.fromJson({'id': 'x'}).id, 'x');
      expect(EmailLog.fromJson({'id': 'x'}).id, 'x');
      expect(ContentFlag.fromJson({'id': 'x'}).id, 'x');
      expect(ModerationReport.fromJson({'id': 'x'}).id, 'x');
      expect(ModerationAction.fromJson({'id': 'x'}).id, 'x');
      expect(ModerationAppeal.fromJson({'id': 'x'}).id, 'x');
      expect(ModerationCommendation.fromJson({'id': 'x'}).id, 'x');
      expect(ModerationPendingApproval.fromJson({'id': 'x'}).id, 'x');
    });

    test('a content flag with no confidence reads as zero, not a crash', () {
      // The queue orders by confidence descending, so a null here would both
      // throw and silently reorder the queue a moderator is working through.
      expect(ContentFlag.fromJson({'id': 'f1'}).confidence, 0.0);
      expect(
        ContentFlag.fromJson({'id': 'f1', 'confidence': 0.95}).confidence,
        0.95,
      );
    });

    test('a list-valued flag block defaults to empty rather than null', () {
      expect(StaffRole.fromJson({'id': 'x'}).effectiveScopes, isEmpty);
      expect(StaffRole.fromJson({'id': 'x'}).defaultScopes, isEmpty);
      expect(
        ModerationAction.fromJson({'id': 'x'}).reversedByModerator,
        isEmpty,
      );
    });

    test('the stats block reads its nested maps without them', () {
      final stats = ModerationStats.fromJson({});
      expect(stats.total, 0);
      expect(stats.bySeverity, isEmpty);
      expect(stats.byReason, isEmpty);
    });
  });

  group('the filter vocabularies match the server choice lists', () {
    test('a requestable action is only ever one the API accepts', () {
      // ModerationActionCreateSerializer.REQUESTABLE. Offering `content_removed`
      // here would produce a 400, because it is taken through the flag route.
      expect(
        kRequestableModerationActions.map((option) => option.value),
        ['warning', 'user_suspended', 'user_banned'],
      );
    });

    test('staff role choices are the eight the model declares', () {
      expect(kStaffRoleChoices, hasLength(8));
      expect(
        kStaffRoleChoices.map((option) => option.value),
        containsAll(<String>[
          'admin',
          'moderator',
          'support',
          'gym_relations',
          'supplier_relations',
          'logistics',
          'finance',
          'verification_regulator',
        ]),
      );
    });

    test('a grant always carries the needs-a-second-approver badge', () {
      // The flag is what stops an operator reading a 202 as a completed grant.
      expect(
        AccountActionRequest.fromJson({'id': 'x', 'requires_second': true})
            .requiresSecond,
        isTrue,
      );
      expect(
        AccountActionRequest.fromJson({'id': 'x'}).requiresSecond,
        isTrue,
      );
    });
  });

  group('cursor paging on the moderation lists', () {
    test('the cursor comes out of the pagination link the server returned', () {
      expect(
        cursorFromLink(
          'https://api.example.com/api/v1/moderation/reports/?cursor=cD0yMDI2',
        ),
        'cD0yMDI2',
      );
    });

    test('a link with no cursor, or no link at all, means the end', () {
      expect(cursorFromLink(null), isNull);
      expect(cursorFromLink(''), isNull);
      expect(cursorFromLink('https://api.example.com/api/v1/moderation/reports/'),
          isNull);
      expect(cursorFromLink('not a url at all'), isNull);
    });

    test('a stack starts on the first page with no cursor', () {
      final stack = CursorStack();
      expect(stack.page, 1);
      expect(stack.cursor, isNull);
      expect(stack.canGoBack, isFalse);
    });

    test('advance follows the next link and back returns to where it was', () {
      final stack = CursorStack();
      expect(stack.advance('https://x.test/r/?cursor=aaa'), isTrue);
      expect(stack.cursor, 'aaa');
      expect(stack.page, 2);
      expect(stack.advance('https://x.test/r/?cursor=bbb'), isTrue);
      expect(stack.cursor, 'bbb');
      expect(stack.goBack(), isTrue);
      // Back must land on the page the operator was on, not on the newest one.
      expect(stack.cursor, 'aaa');
      expect(stack.page, 2);
    });

    test('the end of the list does not silently restart at page one', () {
      final stack = CursorStack();
      expect(stack.advance(null), isFalse);
      expect(stack.cursor, isNull);
      expect(stack.page, 1);
    });

    test('back at the first page is refused rather than popping the root', () {
      final stack = CursorStack();
      expect(stack.goBack(), isFalse);
      expect(stack.page, 1);
    });

    test('a filter change invalidates every cursor behind it', () {
      final stack = CursorStack()
        ..advance('https://x.test/r/?cursor=aaa')
        ..advance('https://x.test/r/?cursor=bbb');
      stack.reset();
      expect(stack.page, 1);
      expect(stack.cursor, isNull);
    });

    test('the query identity separates cursors from filters', () {
      expect(
        ModerationQuery.of('aaa', {'status': 'open'}) ==
            ModerationQuery.of('aaa', {'status': 'open'}),
        isTrue,
      );
      expect(
        ModerationQuery.of('aaa', {'status': 'open'}) ==
            ModerationQuery.of('bbb', {'status': 'open'}),
        isFalse,
      );
      expect(
        ModerationQuery.of('aaa', {'status': 'open'}) ==
            ModerationQuery.of('aaa', {'status': 'closed'}),
        isFalse,
      );
    });

    test('an `all` filter never reaches the query string', () {
      final query = ModerationQuery.of(null, {'status': 'all', 'reason': ''});
      expect(query.params, isEmpty);
    });
  });

  group('PortalQuery still drives the new screens', () {
    test('the moderation assignment filters travel as the API expects', () {
      // `me` is a literal the server understands; a UUID would filter to nobody.
      expect(PortalQuery.of(1, {'assigned_to': 'me'}).text('assigned_to'), 'me');
      expect(
        PortalQuery.of(1, {'unassigned': 'true'}).text('unassigned'),
        'true',
      );
    });

    test('an empty filter is dropped rather than sent as a blank', () {
      final query = PortalQuery.of(1, {'action': '', 'status': null});
      expect(query.params, isEmpty);
    });
  });
}