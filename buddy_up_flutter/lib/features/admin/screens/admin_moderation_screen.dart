import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_portal.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/admin_provider.dart';
import '../providers/governance_provider.dart';
import '../widgets/admin_widgets.dart';

/// `/moderation/**` — the moderator's desk.
///
/// Four peer queues behind tabs rather than four screens: flags, reports, the
/// action ledger and commendations are looked at in the same sitting, and a
/// moderator triaging a report needs the flag that caused it one tap away.
///
/// The console is not a second moderation desk and does not pretend to be one.
/// Where the server enforces separation of duties — a ban is never applied by
/// the person who asked for it — this screen says so on the row rather than
/// reporting success.
class AdminModerationScreen extends ConsumerStatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  ConsumerState<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends ConsumerState<AdminModerationScreen> {
  String _tab = 'flags';

  // Flags
  String _flagReason = '';
  String _flagSeverity = '';
  // Content type is a first-class filter, not a label you read. The queue
  // returned every type in one list, so "what have we flagged in communities"
  // had no query that could answer it.
  String _flagContentType = '';

  // Reports
  String _assignment = 'all';
  String _reportStatus = 'all';
  String _reportReason = 'all';
  final CursorStack _reportCursors = CursorStack();

  // Appeals
  String _appealStatus = 'submitted';
  final CursorStack _appealCursors = CursorStack();

  // Ledger
  String _actionFilter = 'all';
  final CursorStack _actionCursors = CursorStack();

  // Commendations
  final CursorStack _commendationCursors = CursorStack();

  String? _error;
  String? _notice;
  final Set<String> _busyIds = {};

  String get _myUserId => ref.watch(authProvider).user?.id ?? '';

  void _setFilter(void Function() mutate) {
    setState(() {
      mutate();
      _error = null;
      _notice = null;
    });
  }

  /// Run a mutation, surface the server's own wording, refresh what changed.
  Future<void> _act(String busyKey, Future<String> Function() action) async {
    setState(() {
      _busyIds.add(busyKey);
      _error = null;
      _notice = null;
    });
    try {
      final message = await action();
      if (!mounted) return;
      setState(() => _notice = message);
    } catch (e) {
      if (mounted) {
        setState(() => _error = moderationRefusal(e));
      }
    } finally {
      if (mounted) setState(() => _busyIds.remove(busyKey));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isStaffProvider)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin · Moderation')),
        body: const ErrorView(
          message: 'Staff access is required. The moderation queue is not '
              'reachable from a personal account.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Moderation')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(flagQueueProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AdminPageHeader(
              title: 'Moderation',
              description: 'Flag triage, report queue, the action ledger and '
                  'commendations. A ban or suspension you issue here needs a '
                  'second approver before it takes effect.',
            ),
            const SizedBox(height: 16),
            AdminSectionTabs(
              value: _tab,
              options: const [
                (value: 'flags', label: 'Flags'),
                (value: 'reports', label: 'Reports'),
                (value: 'actions', label: 'Actions'),
                (value: 'appeals', label: 'Appeals'),
                (value: 'commendations', label: 'Praise'),
              ],
              onChanged: (v) => setState(() {
                _tab = v;
                _error = null;
                _notice = null;
              }),
            ),
            const SizedBox(height: 14),
            if (_error != null) ...[
              AdminErrorBanner(message: _error!),
              const SizedBox(height: 10),
            ],
            if (_notice != null) ...[
              AdminNoticeBanner(message: _notice!),
              const SizedBox(height: 10),
            ],
            switch (_tab) {
              'flags' => _flagsTab(),
              'reports' => _reportsTab(),
              'actions' => _actionsTab(),
              'appeals' => _appealsTab(),
              _ => _commendationsTab(),
            },
          ],
        ),
      ),
    );
  }

  // -- Flags ----------------------------------------------------------------

  Widget _flagsTab() {
    final queue = ref.watch(flagQueueProvider((
      flagReason: _flagReason,
      severity: _flagSeverity,
      contentType: _flagContentType,
    )));
    final stats = ref.watch(contentFlagStatsProvider).asData?.value;
    final unactioned = stats?.unactioned ?? 0;
    final critical = stats?.bySeverity['critical'] ?? 0;
    final actioned = stats?.actioned ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: AdminStatCard(label: 'Pending review', value: '$unactioned')),
            const SizedBox(width: 8),
            Expanded(child: AdminStatCard(label: 'Critical', value: '$critical')),
            const SizedBox(width: 8),
            Expanded(child: AdminStatCard(label: 'Actioned', value: '$actioned')),
          ],
        ),
        const SizedBox(height: 12),
        AdminFilterChips(
          value: _flagReason,
          options: const [
            (value: '', label: 'Any reason'),
            ...kFlagReasonChoices,
          ],
          onChanged: (v) => _setFilter(() => _flagReason = v),
        ),
        const SizedBox(height: 8),
        AdminFilterChips(
          value: _flagSeverity,
          options: const [
            (value: '', label: 'Any severity'),
            ...kFlagSeverityChoices,
          ],
          onChanged: (v) => _setFilter(() => _flagSeverity = v),
        ),
        const SizedBox(height: 8),
        AdminFilterChips(
          value: _flagContentType,
          options: const [
            (value: '', label: 'Any content type'),
            ...kContentTypeChoices,
          ],
          onChanged: (v) => _setFilter(() => _flagContentType = v),
        ),
        const SizedBox(height: 12),
        ...queue.when(
          loading: () => const [AdminLoadingBlock()],
          error: (e, _) => [
            AdminErrorBanner(message: apiErrorMessage(e, fallback: 'Failed to load the flag queue.')),
          ],
          data: (page) => [
            if (page.items.isEmpty)
              const AdminEmptyState(
                icon: Icons.shield_outlined,
                title: 'No un-actioned flags.',
                hint: 'The queue is ordered worst-severity and highest-confidence first.',
              )
            else
              for (final flag in page.items) _flagRow(flag, page),
          ],
        ),
      ],
    );
  }

  Widget _flagRow(ContentFlag flag, FlagQueuePage page) {
    final busy = _busyIds.contains('flag-${flag.id}');
    final removable = page.isRemovable(flag);
    final guidance = kFlagReasonGuidance[flag.flagReason];
    return AdminRowCard(
      title: flag.flagReason.replaceAll('_', ' '),
      badges: [
        AdminSeverityBadge(severity: flag.severity),
        if (flag.actionTaken.isNotEmpty)
          AdminStatusBadge(status: flag.actionTaken, upper: false),
      ],
      subtitle: flag.contentPreview.isEmpty ? 'No preview available.' : flag.contentPreview,
      meta: '${flag.contentType}:${_shortId(flag.contentId)} · '
          '${(flag.confidence * 100).round()}% confidence · ${flag.source} · '
          '${_shortDateTime(flag.createdAt)}',
      actions: [
        AdminActionButton(
          label: 'Approve',
          icon: Icons.check_circle_outline,
          onPressed: busy ? null : () => _actOnFlag(flag, 'approve'),
        ),
        AdminActionButton(
          label: 'Remove',
          icon: Icons.delete_outline,
          destructive: true,
          onPressed: busy || !removable ? null : () => _actOnFlag(flag, 'remove'),
        ),
        AdminActionButton(
          label: 'Escalate',
          icon: Icons.arrow_upward,
          onPressed: busy ? null : () => _actOnFlag(flag, 'escalate'),
        ),
      ],
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminDataRow(label: 'Flag ID', value: flag.id ?? '—'),
          AdminDataRow(label: 'Content ID', value: flag.contentId.isEmpty ? '—' : flag.contentId),
          // The model's own reasoning, plus an explicit note on what it did
          // *not* assess. A reviewer reading only "82% confidence" cannot act;
          // and an empty bias field would otherwise read as "nothing biased
          // found" when the truth is that no bias model is deployed.
          _FlagExplanation(flag: flag),
          if (guidance != null) ...[
            const SizedBox(height: 6),
            AdminRuleNote(text: 'Guidance: $guidance'),
          ],
          if (!removable) ...[
            const SizedBox(height: 6),
            const AdminHintNote(
              text: 'The server has no takedown handler for this content type, '
                  'so Remove would be refused. Escalate it instead.',
            ),
          ],
          if (flag.actionTaken.isNotEmpty) ...[
            const SizedBox(height: 6),
            AdminHintNote(
              text: flag.isActioned
                  ? 'Already actioned: ${flag.actionTaken}.'
                  : 'Marked "${flag.actionTaken}" — still awaiting review.',
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _actOnFlag(ContentFlag flag, String action) async {
    await _act(
      'flag-${flag.id}',
      () async {
        final raw = await ref
            .read(adminPortalRepositoryProvider)
            .actOnContentFlag(flag.id!, {'action': action});
        ref.invalidate(flagQueueProvider);
        ref.invalidate(contentFlagStatsProvider);
        return portalMessage(
          raw,
          fallback: 'Flag ${action}d.',
        );
      },
    );
  }

  // -- Reports --------------------------------------------------------------

  ModerationQuery get _reportsQuery => ModerationQuery.of(_reportCursors.cursor, {
        'status': _reportStatus,
        'reason': _reportReason,
        if (_assignment == 'mine') 'assigned_to': 'me',
        if (_assignment == 'unassigned') 'unassigned': 'true',
      });

  Widget _reportsTab() {
    final reports = ref.watch(moderationReportsProvider(_reportsQuery));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminFilterChips(
          value: _assignment,
          options: kReportAssignmentChoices,
          onChanged: (v) => _setFilter(() {
            _assignment = v;
            _reportCursors.reset();
          }),
        ),
        const SizedBox(height: 8),
        AdminFilterChips(
          value: _reportStatus,
          options: const [
            (value: 'all', label: 'Any status'),
            ...kReportStatusChoices,
          ],
          onChanged: (v) => _setFilter(() {
            _reportStatus = v;
            _reportCursors.reset();
          }),
        ),
        const SizedBox(height: 8),
        AdminFilterChips(
          value: _reportReason,
          options: const [
            (value: 'all', label: 'Any reason'),
            ...kReportReasonChoices,
          ],
          onChanged: (v) => _setFilter(() {
            _reportReason = v;
            _reportCursors.reset();
          }),
        ),
        const SizedBox(height: 12),
        ...reports.when(
          loading: () => const [AdminLoadingBlock()],
          error: (e, _) => [
            AdminErrorBanner(message: apiErrorMessage(e, fallback: 'Failed to load reports.')),
          ],
          data: (page) => [
            if (page.items.isEmpty)
              const AdminEmptyState(
                icon: Icons.flag_outlined,
                title: 'No reports match this filter.',
                hint: 'Urgent reasons carry a 4-hour response target; everything else carries 24 hours.',
              )
            else ...[
              for (final report in page.items) _reportRow(report),
              AdminCursorPager(
                stack: _reportCursors,
                page: page,
                onChanged: () => setState(() {}),
                busy: reports.isLoading,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _reportRow(ModerationReport report) {
    final busy = _busyIds.contains('report-${report.id}');
    final assignedTo = report.assignedTo;
    final isMine = assignedTo != null && assignedTo == _myUserId;
    final isOpen = report.status == 'open' || report.status == 'investigating';

    return AdminRowCard(
      title: report.reason.replaceAll('_', ' '),
      badges: [
        AdminStatusBadge(status: report.status),
        AdminSlaBadge(report: report),
        if (assignedTo == null)
          const AdminStatusBadge(status: 'unassigned', upper: false)
        else if (isMine)
          const AdminStatusBadge(status: 'assigned to me', upper: false),
      ],
      subtitle: report.description.isEmpty ? '—' : report.description,
      meta: 'target ${_shortId(report.targetUser ?? '')} · due '
          '${_shortDateTime(report.slaDueAt)} · filed ${_shortDateTime(report.createdAt)}',
      actions: [
        AdminActionButton(
          label: isMine ? 'Mine' : 'Assign to me',
          icon: Icons.person_pin_outlined,
          onPressed: busy || isMine || !isOpen
              ? null
              : () => _assignReport(report, _myUserId),
        ),
        AdminActionButton(
          label: 'Unassign',
          icon: Icons.person_remove_outlined,
          onPressed: busy || assignedTo == null || !isOpen
              ? null
              : () => _assignReport(report, null),
        ),
        AdminActionButton(
          label: 'Resolve',
          icon: Icons.task_alt,
          onPressed: busy || !isOpen ? null : () => _handleReport(report, 'resolve'),
        ),
        AdminActionButton(
          label: 'Dismiss',
          icon: Icons.close,
          destructive: true,
          onPressed: busy || !isOpen ? null : () => _handleReport(report, 'dismiss'),
        ),
      ],
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminDataRow(label: 'Report ID', value: report.id ?? '—'),
          AdminDataRow(label: 'Target user', value: report.targetUser ?? '—'),
          AdminDataRow(label: 'Reporter', value: report.reporter ?? '—'),
          AdminDataRow(label: 'Assigned to', value: assignedTo ?? 'Nobody'),
          AdminDataRow(label: 'SLA due', value: _shortDateTime(report.slaDueAt)),
          AdminDataRow(
            label: 'SLA',
            value: report.slaBreached
                ? 'Breached — this report is overdue.'
                : 'Within target.',
          ),
          if (report.contentUrl.isNotEmpty)
            AdminDataRow(label: 'Content', value: report.contentUrl),
          if (report.resolutionNote.isNotEmpty)
            AdminDataRow(label: 'Resolution', value: report.resolutionNote),
        ],
      ),
    );
  }

  Future<void> _assignReport(ModerationReport report, String? assignee) async {
    await _act(
      'report-${report.id}',
      () async {
        // `assigned_to` must be present even when null — omitting it is an
        // error server-side rather than an implicit unassign.
        final raw = await ref
            .read(adminPortalRepositoryProvider)
            .assignModerationReport(report.id!, {'assigned_to': assignee});
        ref.invalidate(moderationReportsProvider);
        return portalMessage(raw, fallback: assignee == null ? 'Unassigned.' : 'Assigned.');
      },
    );
  }

  Future<void> _handleReport(ModerationReport report, String action) async {
    // The note is optional server-side, so it is optional here too — this
    // prompt exists to invite one, not to block a moderator who has none. What
    // it must not do is stand between an overdue report and being closed.
    final note = await _promptForText(
      title: action == 'resolve'
          ? 'Resolve this report. Add a note for the record.'
          : 'Dismiss this report. Add a note if there is one worth keeping.',
      hint: 'Resolution note (optional)',
      confirmLabel: action == 'resolve' ? 'Resolve' : 'Dismiss',
      destructive: action == 'dismiss',
      minLength: 0,
    );
    if (note == null) return;
    await _act(
      'report-${report.id}',
      () async {
        // This route answers with the raw serializer row, not the envelope, so
        // there is no message to show — the row itself is the confirmation.
        await ref.read(adminPortalRepositoryProvider).handleModerationReport(
              report.id!,
              {'action': action, 'resolution_note': note},
            );
        ref.invalidate(moderationReportsProvider);
        return 'Report ${action == 'resolve' ? 'resolved' : 'dismissed'}.';
      },
    );
  }

  // -- Action ledger --------------------------------------------------------

  ModerationQuery get _actionsQuery =>
      ModerationQuery.of(_actionCursors.cursor, {'action': _actionFilter});

  Widget _actionsTab() {
    final actions = ref.watch(moderationActionsProvider(_actionsQuery));
    final pending = ref.watch(pendingModerationApprovalsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          onPressed: () => _openIssueActionSheet(context),
          style: FilledButton.styleFrom(
            backgroundColor: BuddyColors.green,
            foregroundColor: BuddyColors.black,
          ),
          icon: const Icon(Icons.gavel, size: 16),
          label: const Text('Issue a warning, suspension or ban',
              style: TextStyle(fontSize: 13)),
        ),
        const SizedBox(height: 12),
        ...pending.when(
          loading: () => const <Widget>[],
          error: (_, _) => const <Widget>[],
          data: (rows) => [
            if (rows.isNotEmpty) ...[
              AdminRuleNote(
                icon: Icons.hourglass_top,
                text: '${rows.length} ban or suspension request(s) are waiting '
                    'for a second approver in the Approvals queue. Nothing has '
                    'been applied to those accounts yet.',
              ),
              const SizedBox(height: 8),
              for (final row in rows) _pendingApprovalRow(row),
              const SizedBox(height: 8),
            ],
          ],
        ),
        AdminFilterChips(
          value: _actionFilter,
          options: const [
            (value: 'all', label: 'Every action'),
            ...kModerationActionChoices,
          ],
          onChanged: (v) => _setFilter(() {
            _actionFilter = v;
            _actionCursors.reset();
          }),
        ),
        const SizedBox(height: 12),
        ...actions.when(
          loading: () => const [AdminLoadingBlock()],
          error: (e, _) => [
            AdminErrorBanner(message: apiErrorMessage(e, fallback: 'Failed to load the ledger.')),
          ],
          data: (page) => [
            if (page.items.isEmpty)
              const AdminEmptyState(
                icon: Icons.gavel,
                title: 'No moderation actions recorded.',
                hint: 'Warnings apply immediately. Suspensions and bans are '
                    'queued for a second approver.',
              )
            else ...[
              for (final action in page.items) _actionRow(action),
              AdminCursorPager(
                stack: _actionCursors,
                page: page,
                onChanged: () => setState(() {}),
                busy: actions.isLoading,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _pendingApprovalRow(ModerationPendingApproval row) {
    final waiting = _humanDuration(row.waitingSeconds);
    return AdminRowCard(
      title: row.governanceAction.replaceAll('_', ' '),
      badges: const [AdminStatusBadge(status: 'pending second approver', upper: false)],
      subtitle: row.reason.isEmpty ? 'No reason recorded.' : row.reason,
      meta: 'target ${_shortId(row.targetUser ?? '')} · raised by '
          '${row.requestedByProfile.isEmpty ? _shortId(row.requestedBy ?? '') : row.requestedByProfile} '
          '· waiting $waiting'
          '${row.durationDays != null ? ' · ${row.durationDays} day term' : ''}',
    );
  }

  Widget _actionRow(ModerationAction action) {
    final busy = _busyIds.contains('action-${action.id}');
    final term = action.durationDays == null ? '' : ' · ${action.durationDays} day term';
    // `reversed_by` is a self-FK to the reversal row, so the moderator who undid
    // the action lives on *that* row. The serializer hoists it onto this one to
    // save the client a second request; read it defensively since it is a
    // free-form map.
    final reverser = action.reversedByModerator['email'];
    return AdminRowCard(
      title: action.action.replaceAll('_', ' '),
      badges: [
        AdminStatusBadge(status: action.action),
        if (action.isReversed) const AdminStatusBadge(status: 'reversed'),
      ],
      subtitle: action.reason.isEmpty ? '—' : action.reason,
      meta: 'target ${action.targetLabel} · by ${_shortId(action.moderator ?? '')} · '
          '${_shortDateTime(action.createdAt)}$term',
      actions: [
        if (!action.isReversed)
          AdminActionButton(
            label: 'Reverse',
            icon: Icons.undo,
            destructive: true,
            onPressed: busy || !action.isReversible
                ? null
                : () => _reverseAction(action),
          ),
      ],
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminDataRow(label: 'Action ID', value: action.id ?? '—'),
          AdminDataRow(label: 'Target user', value: action.targetUser ?? '—'),
          AdminDataRow(label: 'Moderator', value: action.moderator ?? '—'),
          if (action.durationDays != null)
            AdminDataRow(label: 'Term', value: '${action.durationDays} day(s)'),
          if (action.report != null)
            AdminDataRow(label: 'From report', value: action.report!),
          if (action.isReversed) ...[
            AdminDataRow(label: 'Reversed at', value: _shortDateTime(action.reversedAt)),
            AdminDataRow(label: 'Reversal reason', value: action.reversalReason),
            if (reverser is String && reverser.isNotEmpty)
              AdminDataRow(label: 'Reversed by', value: reverser),
          ],
        ],
      ),
    );
  }

  Future<void> _reverseAction(ModerationAction action) async {
    final reason = await _promptForText(
      title: 'Why is this action being reversed? The reason is written to the '
          'ledger and is what an appeal panel reads.',
      hint: 'Reversal reason (required)',
      confirmLabel: 'Reverse',
      destructive: true,
    );
    if (reason == null) return;
    await _act(
      'action-${action.id}',
      () async {
        final raw = await ref
            .read(adminPortalRepositoryProvider)
            .reverseModerationAction(action.id!, {'reason': reason});
        final data = raw is Map ? raw['data'] : null;
        final effect = data is Map ? data['effect'] : null;
        ref.invalidate(moderationActionsProvider);
        ref.invalidate(pendingModerationApprovalsProvider);
        return effect is String && effect.isNotEmpty
            ? effect
            : portalMessage(raw, fallback: 'Action reversed.');
      },
    );
  }

  Future<void> _openIssueActionSheet(BuildContext context) async {
    final result = await showModalBottomSheet<_IssueActionRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetCtx) => const _IssueActionSheet(),
    );
    if (result == null) return;

    await _act(
      'new-action',
      () async {
        final raw = await ref
            .read(adminPortalRepositoryProvider)
            .createModerationAction(result.toBody());
        final outcome = moderationActionResult(raw);
        ref.invalidate(moderationActionsProvider);
        ref.invalidate(pendingModerationApprovalsProvider);
        return outcome.isPendingSecondApprover
            // The load-bearing sentence: a 202 here means no ban happened.
            ? 'Queued for a second approver. ${result.targetUser} has NOT been '
                'suspended or banned — find it in Approvals and approve it.'
            : outcome.message.isEmpty
                ? 'Warning issued.'
                : outcome.message;
      },
    );
  }

  // -- Appeals --------------------------------------------------------------

  ModerationQuery get _appealsQuery =>
      ModerationQuery.of(_appealCursors.cursor, {'status': _appealStatus});

  Widget _appealsTab() {
    final appeals = ref.watch(appealsProvider(_appealsQuery));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The other end of the user-side appeal form. Without a reviewer here
        // an appeal raised in Settings → Help & Safety would sit open forever,
        // which makes the whole appeal path decorative in the other direction.
        const AdminRuleNote(
          text: 'Approving an appeal reverses the underlying action through the '
              'same path as a manual reversal, so the standing row and the '
              'access state move together. Marking it "under review" is the '
              'honest option when you need more time.',
        ),
        const SizedBox(height: 12),
        AdminFilterChips(
          value: _appealStatus,
          options: const [
            ...kAppealStatusChoices,
            (value: 'all', label: 'Any'),
          ],
          onChanged: (v) => _setFilter(() {
            _appealStatus = v;
            _appealCursors.reset();
          }),
        ),
        const SizedBox(height: 12),
        ...appeals.when(
          loading: () => const [AdminLoadingBlock()],
          error: (e, _) => [
            AdminErrorBanner(
                message: apiErrorMessage(e, fallback: 'Failed to load appeals.')),
          ],
          data: (page) => [
            if (page.items.isEmpty)
              const AdminEmptyState(
                icon: Icons.balance_outlined,
                title: 'No appeals here.',
                hint: 'Users raise these from Settings → Help & Safety.',
              )
            else ...[
              for (final appeal in page.items) _appealRow(appeal),
              AdminCursorPager(
                stack: _appealCursors,
                page: page,
                onChanged: () => setState(() {}),
                busy: appeals.isLoading,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _appealRow(ModerationAppeal appeal) {
    final busy = _busyIds.contains('appeal-${appeal.id}');
    final open = appeal.isOpen;
    // Built from the shared vocabulary so the three buttons on this row and
    // the three the API accepts cannot drift apart.
    final actions = <Widget>[
      if (open)
        for (final decision in kAppealDecisionChoices)
          AdminActionButton(
            label: decision.label.split(' ').first,
            icon: switch (decision.value) {
              'approve' => Icons.check,
              'deny' => Icons.close,
              _ => Icons.hourglass_top,
            },
            destructive: decision.value == 'deny',
            onPressed: busy ? null : () => _reviewAppeal(appeal, decision.value),
          ),
    ];
    return AdminRowCard(
      title: 'Appeal ${_shortId(appeal.id ?? '')}',
      badges: [AdminStatusBadge(status: appeal.status)],
      subtitle: appeal.reason,
      meta: 'against action ${_shortId(appeal.action ?? '')} · '
          'by ${_shortId(appeal.appellant ?? '')} · '
          '${_shortDateTime(appeal.createdAt)}'
          '${appeal.reviewedAt != null ? ' · reviewed ${_shortDateTime(appeal.reviewedAt)}' : ''}',
      actions: actions,
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminDataRow(label: 'Appeal ID', value: appeal.id ?? '—'),
          AdminDataRow(label: 'Action', value: appeal.action ?? '—'),
          AdminDataRow(label: 'Appellant', value: appeal.appellant ?? '—'),
          if (appeal.reviewer != null)
            AdminDataRow(label: 'Reviewer', value: appeal.reviewer!),
          AdminDataRow(label: 'Submitted', value: _shortDateTime(appeal.createdAt)),
          if (appeal.reviewedAt != null)
            AdminDataRow(label: 'Reviewed', value: _shortDateTime(appeal.reviewedAt)),
          if (appeal.resolutionNote.isNotEmpty)
            AdminDataRow(label: 'Resolution note', value: appeal.resolutionNote),
          if (open)
            const AdminHintNote(
              text: 'The user sees your resolution note verbatim. There is one '
                  'appeal per action per user, so this cannot be re-raised.',
            ),
        ],
      ),
    );
  }

  Future<void> _reviewAppeal(ModerationAppeal appeal, String decision) async {
    final note = await _promptForText(
      title: switch (decision) {
        'approve' =>
          'Approving reverses the action against this account. Explain why the '
              'original decision was wrong — the user reads this.',
        'deny' => 'Why is the appeal denied? The user reads this note.',
        _ => 'Note for the record while this stays under review.',
      },
      hint: decision == 'review' ? 'Note (optional)' : 'Resolution note (required)',
      confirmLabel: switch (decision) {
        'approve' => 'Approve & reverse',
        'deny' => 'Deny',
        _ => 'Mark under review',
      },
      destructive: decision == 'deny',
      // `review` is the honest "not yet" and the server permits an empty note.
      minLength: decision == 'review' ? 0 : 1,
    );
    if (note == null) return;
    await _act(
      'appeal-${appeal.id}',
      () async {
        await ref.read(adminPortalRepositoryProvider).reviewModerationAppeal(
              appeal.id!,
              {'decision': decision, 'resolution_note': note},
            );
        ref.invalidate(appealsProvider);
        ref.invalidate(moderationActionsProvider);
        // This route answers with the raw row, not the envelope.
        return 'Appeal $decision.';
      },
    );
  }

  // -- Commendations --------------------------------------------------------

  ModerationQuery get _commendationsQuery =>
      ModerationQuery.of(_commendationCursors.cursor);

  Widget _commendationsTab() {
    final commendations = ref.watch(commendationsProvider(_commendationsQuery));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () => _openCommendationSheet(context),
          icon: const Icon(Icons.workspace_premium_outlined, size: 16),
          label: const Text('Issue a commendation', style: TextStyle(fontSize: 13)),
        ),
        const SizedBox(height: 8),
        const AdminHintNote(
          text: 'A commendation is addressed to a profile, not to a user '
              'account. Paste the profile UUID from the person\'s profile URL.',
        ),
        const SizedBox(height: 12),
        ...commendations.when(
          loading: () => const [AdminLoadingBlock()],
          error: (e, _) => [
            AdminErrorBanner(message: apiErrorMessage(e, fallback: 'Failed to load commendations.')),
          ],
          data: (page) => [
            if (page.items.isEmpty)
              const AdminEmptyState(
                icon: Icons.workspace_premium_outlined,
                title: 'No commendations recorded.',
                hint: 'The positive half of moderation: every other row here '
                    'records what somebody did wrong.',
              )
            else ...[
              for (final commendation in page.items) _commendationRow(commendation),
              AdminCursorPager(
                stack: _commendationCursors,
                page: page,
                onChanged: () => setState(() {}),
                busy: commendations.isLoading,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _commendationRow(ModerationCommendation commendation) {
    final busy = _busyIds.contains('commendation-${commendation.id}');
    return AdminRowCard(
      title: commendation.categoryDisplay.isNotEmpty
          ? commendation.categoryDisplay
          : commendation.category.replaceAll('_', ' '),
      badges: [
        if (!commendation.visibleToRecipient)
          const AdminStatusBadge(status: 'revoked', upper: false),
      ],
      subtitle: commendation.message,
      meta: 'to ${_shortId(commendation.recipient ?? '')} · by '
          '${_shortId(commendation.issuedBy ?? '')} · '
          '${_shortDateTime(commendation.createdAt)}',
      actions: [
        if (commendation.visibleToRecipient)
          AdminActionButton(
            label: 'Revoke',
            icon: Icons.undo,
            destructive: true,
            onPressed: busy ? null : () => _revokeCommendation(commendation),
          ),
      ],
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminDataRow(label: 'Recipient profile', value: commendation.recipient ?? '—'),
          AdminDataRow(label: 'Issued by profile', value: commendation.issuedBy ?? '—'),
          AdminDataRow(
            label: 'Visible to recipient',
            value: commendation.visibleToRecipient ? 'Yes' : 'No — revoked',
          ),
        ],
      ),
    );
  }

  Future<void> _revokeCommendation(ModerationCommendation commendation) async {
    final reason = await _promptForText(
      title: 'Revoke this commendation? The record is kept so it cannot be '
          'quietly un-sent — the recipient simply stops seeing it.',
      hint: 'Reason (optional, kept on the record)',
      confirmLabel: 'Revoke',
      destructive: true,
      minLength: 0,
    );
    if (reason == null) return;
    await _act(
      'commendation-${commendation.id}',
      () async {
        final raw = await ref
            .read(adminPortalRepositoryProvider)
            .revokeModerationCommendation(commendation.id!, {'reason': reason});
        ref.invalidate(commendationsProvider);
        return portalMessage(raw, fallback: 'Commendation revoked.');
      },
    );
  }

  Future<void> _openCommendationSheet(BuildContext context) async {
    final result = await showModalBottomSheet<_CommendationDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetCtx) => const _CommendationSheet(),
    );
    if (result == null) return;
    await _act(
      'new-commendation',
      () async {
        final raw = await ref
            .read(adminPortalRepositoryProvider)
            .createModerationCommendation(result.toBody());
        ref.invalidate(commendationsProvider);
        return portalMessage(raw, fallback: 'Commendation issued.');
      },
    );
  }

  // -- Shared ---------------------------------------------------------------

  /// Modal reason prompt. Returns null when the operator backs out.
  Future<String?> _promptForText({
    required String title,
    required String confirmLabel,
    bool destructive = false,
    String hint = 'Reason (required)',
    int minLength = 1,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(sheetCtx).bottom + 16,
        ),
        child: AdminReasonPrompt(
          title: title,
          hint: hint,
          confirmLabel: confirmLabel,
          destructive: destructive,
          minLength: minLength,
          onSubmit: (value) => Navigator.pop(sheetCtx, value),
          onCancel: () => Navigator.pop(sheetCtx),
        ),
      ),
    );
  }

  static String _shortId(String id) =>
      id.isEmpty ? '—' : id.substring(0, id.length > 8 ? 8 : id.length);

  static String _shortDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    return iso.replaceFirst('T', ' ').split('.').first.split('+').first;
  }

  static String _humanDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m';
    if (seconds < 86400) return '${seconds ~/ 3600}h';
    return '${seconds ~/ 86400}d';
  }
}

/// A validated disciplinary action, ready for the wire.
class _IssueActionRequest {
  final String action;
  final String targetUser;
  final String reason;
  final int? durationDays;

  const _IssueActionRequest({
    required this.action,
    required this.targetUser,
    required this.reason,
    this.durationDays,
  });

  Map<String, dynamic> toBody() => {
        'action': action,
        'target_user': targetUser,
        'reason': reason,
        if (durationDays != null) 'duration_days': durationDays,
      };
}

/// Issue-action form.
///
/// The duration rule is the server's and is stated on the field rather than
/// inferred: a **ban** is permanent and the API refuses a duration on it
/// (sending one is how a moderator ends up banning someone forever believing
/// they set 30 days), while a **suspension** has no default and the API
/// requires a term.
class _IssueActionSheet extends StatefulWidget {
  const _IssueActionSheet();

  @override
  State<_IssueActionSheet> createState() => _IssueActionSheetState();
}

class _IssueActionSheetState extends State<_IssueActionSheet> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String _action = 'warning';

  @override
  void dispose() {
    _targetController.dispose();
    _reasonController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  bool get _needsDuration => _action == 'user_suspended';

  int? get _durationDays {
    if (!_needsDuration) return null;
    return int.tryParse(_durationController.text.trim());
  }

  bool get _ready {
    final target = _targetController.text.trim();
    final reason = _reasonController.text.trim();
    if (target.isEmpty || reason.isEmpty) return false;
    if (_needsDuration) {
      final days = _durationDays;
      if (days == null || days <= 0) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final choice = kRequestableModerationActions.firstWhere(
      (option) => option.value == _action,
      orElse: () => kRequestableModerationActions.first,
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Issue a moderation action',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 4),
          Text(choice.label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          const SizedBox(height: 14),
          for (final option in kRequestableModerationActions)
            InkWell(
              onTap: () => setState(() => _action = option.value),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _action == option.value
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: _action == option.value
                          ? BuddyColors.green
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(option.label,
                          style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _targetController,
            decoration: InputDecoration(
              labelText: 'Target user id',
              helperText: 'The UUID of the account, not a username.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            minLines: 2,
            decoration: InputDecoration(
              labelText: 'Reason',
              helperText: 'Required. The user sees this, and it is what an '
                  'appeal is judged on.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          if (_needsDuration) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Duration in days',
                helperText: 'A suspension must have a term. There is no '
                    'open-ended action here — escalate instead.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ] else if (_action == 'user_banned') ...[
            const SizedBox(height: 12),
            const AdminRuleNote(
              text: 'A ban is permanent and takes no duration. If this should '
                  'end on its own, issue a suspension with a term instead.',
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: !_ready
                  ? null
                  : () => Navigator.pop(
                        context,
                        _IssueActionRequest(
                          action: _action,
                          targetUser: _targetController.text.trim(),
                          reason: _reasonController.text.trim(),
                          durationDays: _durationDays,
                        ),
                      ),
              style: FilledButton.styleFrom(
                backgroundColor: BuddyColors.green,
                foregroundColor: BuddyColors.black,
              ),
              icon: const Icon(Icons.gavel, size: 16),
              label: Text(
                _action == 'warning'
                    ? 'Issue warning'
                    : 'Raise request (needs a second approver)',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// A validated commendation, ready for the wire.
class _CommendationDraft {
  final String recipient;
  final String category;
  final String message;

  const _CommendationDraft({
    required this.recipient,
    required this.category,
    required this.message,
  });

  Map<String, dynamic> toBody() => {
        'recipient': recipient,
        'category': category,
        'message': message,
      };
}

class _CommendationSheet extends StatefulWidget {
  const _CommendationSheet();

  @override
  State<_CommendationSheet> createState() => _CommendationSheetState();
}

class _CommendationSheetState extends State<_CommendationSheet> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _category = 'helpful';

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ready = _recipientController.text.trim().isNotEmpty &&
        _messageController.text.trim().isNotEmpty;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text('Issue a commendation',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final option in kCommendationCategories)
                        ChoiceChip(
                          label: Text(option.label, style: const TextStyle(fontSize: 12)),
                          selected: _category == option.value,
                          onSelected: (_) => setState(() => _category = option.value),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _recipientController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Recipient profile id',
                      helperText: 'A profile UUID — commendations attach to a '
                          'profile, not to a login.',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    minLines: 2,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Message',
                      helperText: 'Up to 500 characters. The recipient is notified.',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: !ready
                          ? null
                          : () => Navigator.pop(
                                context,
                                _CommendationDraft(
                                  recipient: _recipientController.text.trim(),
                                  category: _category,
                                  message: _messageController.text.trim(),
                                ),
                              ),
                      style: FilledButton.styleFrom(
                        backgroundColor: BuddyColors.green,
                        foregroundColor: BuddyColors.black,
                      ),
                      icon: const Icon(Icons.workspace_premium_outlined, size: 16),
                      label: const Text('Issue commendation',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What the model said about a flag, and what it did not look at.
class _FlagExplanation extends StatelessWidget {
  final ContentFlag flag;

  const _FlagExplanation({required this.flag});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasExplanation = flag.aiExplanation.trim().isNotEmpty;

    if (!hasExplanation) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          flag.aiMethod.isEmpty
              ? 'No model explanation was recorded for this flag.'
              : 'This flag was raised by a ${flag.aiMethod} rule with no recorded explanation.',
          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: cs.onSurfaceVariant),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 12, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                flag.aiMethod.isEmpty
                    ? 'Why this was flagged'
                    : 'Why this was flagged · ${flag.aiMethod}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            flag.aiExplanation,
            style: TextStyle(fontSize: 12, height: 1.45, color: cs.onSurface),
          ),
          if (!flag.biasAssessed) ...[
            const SizedBox(height: 6),
            Text(
              'Bias was not assessed for this flag — no bias model is deployed.',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
