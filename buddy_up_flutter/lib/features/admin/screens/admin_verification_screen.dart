import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/verification.dart';
import '../../../shared/widgets/error_view.dart';
import '../../verification/providers/verification_provider.dart';
import '../providers/admin_provider.dart';
import '../providers/verification_provider.dart';
import '../widgets/admin_widgets.dart';

/// `/api/v1/verification/**` — the staff review queue.
///
/// **This screen exists because the old one was lying.** `POST
/// /verification/submissions/{id}/review/` used to approve in one call: one
/// member of staff decided, wrote `Profile.verification_status`, granted
/// `Profile.role`, flipped `Gym.is_verified`, and could be the applicant. It now
/// raises `AccountActionRequest(action='verification_decision')` and answers
/// **202**, having applied nothing. A client that treated that 202 as success
/// would tell a reviewer they had verified somebody when they had only asked a
/// colleague to — and the submission would sit at `under_review` forever with
/// nobody aware a decision was owed.
///
/// So the two calls are two different buttons with two different consequences
/// printed on them:
///
/// * **Send for decision** → [VerificationReviewQueued]. The notice says
///   *awaiting a second approver* and names who must act. Nothing about the
///   applicant changed.
/// * **Approve / reject** → [VerificationDecisionApplied]. This is the only call
///   that applies, and it refuses when the caller raised the request — that 403
///   is shown with the server's own sentence, because the operator's next move
///   is "find a different colleague", not "retry".
class AdminVerificationScreen extends ConsumerStatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  ConsumerState<AdminVerificationScreen> createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState
    extends ConsumerState<AdminVerificationScreen> {
  String _status = 'all';
  String? _error;
  String? _notice;
  bool _busy = false;

  static const List<({String value, String label})> _statusFilters = [
    (value: 'all', label: 'All'),
    (value: 'submitted', label: 'Submitted'),
    (value: 'under_review', label: 'Awaiting decision'),
    (value: 'approved', label: 'Approved'),
    (value: 'rejected', label: 'Rejected'),
    (value: 'draft', label: 'Drafts'),
  ];

  List<VerificationSubmission> _filter(List<VerificationSubmission> rows) =>
      _status == 'all' ? rows : rows.where((s) => s.status == _status).toList();

  /// Step one: ask for a decision. Applies nothing.
  Future<void> _sendForDecision(VerificationSubmission submission) async {
    final decision = await _askDecision();
    if (decision == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      final raw = await ref
          .read(verificationAdminRepositoryProvider)
          .reviewSubmission(submission.id, {
            'action': decision.action,
            if (decision.reason.isNotEmpty) 'rejection_reason': decision.reason,
          });
      if (!mounted) return;
      setState(() {
        _busy = false;
        // Not "Approved." Not "Reviewed." The queued outcome's own message.
        _notice = verificationReviewQueued(raw).message;
      });
      invalidateVerificationQueues(ref);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = verificationRefusal(e);
      });
    }
  }

  /// Step two: the second approver settles it. The only call that applies.
  Future<void> _decide(VerificationSubmission submission, String action) async {
    final note = await _askNote(action);
    if (note == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      final raw = await ref
          .read(verificationAdminRepositoryProvider)
          .decideSubmission(submission.id, {
        'action': action,
        if (note.isNotEmpty) 'note': note,
      });
      if (!mounted) return;
      final outcome = verificationDecisionApplied(raw);
      setState(() {
        _busy = false;
        _notice = outcome.outcome?.appliedEffect == false
            // A settled request with no applied_at means nothing was written to
            // the profile. Say that rather than reporting a decision.
            ? 'The request was settled but records no applied time. Nothing was '
                'written to the profile — see the deployment note in '
                'apps/verification/decisions.py.'
            : outcome.message;
      });
      invalidateVerificationQueues(ref);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = verificationRefusal(e);
      });
    }
  }

  /// The review call's action. A rejection needs its reason *now*, because the
  /// reason travels on the request and is what the second approver reads.
  Future<({String action, String reason})?> _askDecision() {
    return showDialog<({String action, String reason})>(
      context: context,
      builder: (_) => const _DecisionDialog(
        title: 'Send this application for a decision',
        blurb: 'This does not approve anything. It asks a second, independent '
            'member of staff to decide. You will not be able to be that person.',
        confirmLabel: 'Request decision',
        requireNote: false,
        choices: [
          ('approve', 'Ask them to approve'),
          ('reject', 'Ask them to reject'),
        ],
      ),
    );
  }

  /// The decide call's note. Required on a rejection, because it is the record
  /// the applicant will read.
  Future<String?> _askNote(String action) async {
    final result = await showDialog<({String action, String reason})>(
      context: context,
      builder: (_) => _DecisionDialog(
        title: action == 'approve' ? 'Approve and apply' : 'Reject',
        blurb: action == 'approve'
            ? 'This writes the verification status, grants any role the type '
                'implies, and applies the decision once. It cannot be applied '
                'again.'
            : 'The note is the record the applicant reads. The server refuses '
                'a rejection without one.',
        confirmLabel: action == 'approve' ? 'Approve and apply' : 'Reject',
        requireNote: action == 'reject',
      ),
    );
    return result?.reason;
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isStaffProvider)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin · Verification')),
        body: const ErrorView(
          message: 'Staff access is required. The verification review queue is '
              'not reachable from a personal account.',
        ),
      );
    }

    final submissions = ref.watch(verificationSubmissionsProvider);
    final awaiting = ref.watch(submissionsAwaitingDecisionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Verification')),
      body: RefreshIndicator(
        onRefresh: () async => invalidateVerificationQueues(ref),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AdminPageHeader(
              title: 'Verification queue',
              description: 'A decision needs two people. Sending an '
                  'application for decision changes nothing on the applicant; '
                  'only a second approver\'s call writes the status, grants a '
                  'role, or verifies a gym.',
            ),
            const SizedBox(height: 14),
            const AdminRuleNote(
              text: 'You cannot decide your own application, and you cannot '
                  'decide a request you raised. Both are refused server-side '
                  'with 403 — nothing on this screen can waive that.',
            ),
            const SizedBox(height: 14),
            AdminFilterChips(
              value: _status,
              options: _statusFilters,
              onChanged: (value) => setState(() {
                _status = value;
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
            ...awaiting.when(
              loading: () => const [AdminLoadingBlock()],
              error: (e, _) => [
                AdminErrorBanner(
                  message: apiErrorMessage(
                    e,
                    fallback: 'Could not read the pending-decision list.',
                  ),
                ),
              ],
              data: (pending) => [
                Row(
                  children: [
                    Expanded(
                      child: AdminStatCard(
                        label: 'Awaiting a second approver',
                        value: '${pending.length}',
                        sub: 'decided by nobody yet',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AdminStatCard(
                        label: 'Matching this filter',
                        value:
                            '${_filter(submissions.value ?? const <VerificationSubmission>[]).length}',
                        sub: _status == 'all' ? 'all statuses' : _status,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
            ...submissions.when(
              loading: () => const [AdminLoadingBlock()],
              error: (e, _) => [
                AdminErrorBanner(
                  message: apiErrorMessage(
                    e,
                    fallback: 'Could not load verification submissions.',
                  ),
                ),
              ],
              data: (rows) {
                final visible = _filter(rows);
                if (visible.isEmpty) {
                  return [
                    const AdminEmptyState(
                      icon: Icons.verified_user_outlined,
                      title: 'No applications match this filter.',
                      hint: 'An applicant files from their own Verification '
                          'screen. Nothing here means none have.',
                    ),
                  ];
                }
                return [for (final submission in visible) _row(submission)];
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _row(VerificationSubmission submission) {
    final pending = submission.awaitsSecondApprover;
    final actions = <Widget>[];
    if (canRequestVerificationDecision(submission)) {
      actions.add(AdminActionButton(
        label: 'Send for decision',
        icon: Icons.how_to_reg_outlined,
        onPressed: _busy ? null : () => _sendForDecision(submission),
      ));
    }
    if (canDecideVerification(submission)) {
      actions.addAll([
        AdminActionButton(
          label: 'Approve',
          icon: Icons.check,
          onPressed: _busy ? null : () => _decide(submission, 'approve'),
        ),
        AdminActionButton(
          label: 'Reject',
          icon: Icons.close,
          destructive: true,
          onPressed: _busy ? null : () => _decide(submission, 'reject'),
        ),
      ]);
    }

    return AdminRowCard(
      title: submission.typeLabel,
      badges: [
        AdminStatusBadge(status: submission.status),
        if (pending)
          const AdminStatusBadge(status: 'awaiting a second approver', upper: false),
      ],
      subtitle: submission.gymName == null || submission.gymName!.isEmpty
          ? null
          : 'Gym: ${submission.gymName}',
      meta: [
        _shortDateTime(submission.submittedAt ?? submission.createdAt),
        if (submission.credentialId.isNotEmpty)
          'credential ${submission.credentialId}',
        if (submission.scopeOfPractice.isNotEmpty)
          submission.scopeLabel,
      ].join(' · '),
      actions: actions,
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminDataRow(label: 'Submission ID', value: submission.id),
          AdminDataRow(label: 'Type', value: submission.verificationType),
          AdminDataRow(label: 'Status', value: submission.status),
          if (submission.credentialTitle.isNotEmpty)
            AdminDataRow(label: 'Credential', value: submission.credentialTitle),
          if (submission.credentialIssuer.isNotEmpty)
            AdminDataRow(label: 'Issuer', value: submission.credentialIssuer),
          if (submission.credentialId.isNotEmpty)
            AdminDataRow(label: 'Credential number', value: submission.credentialId),
          if (submission.issuedDate != null)
            AdminDataRow(label: 'Issued', value: submission.issuedDate!),
          if (submission.scopeOfPractice.isNotEmpty)
            AdminDataRow(label: 'Scope of practice', value: submission.scopeLabel),
          if (submission.notes.trim().isNotEmpty)
            AdminDataRow(label: 'Applicant notes', value: submission.notes),
          AdminDataRow(
            label: 'Documents',
            value: submission.documents.isEmpty
                ? 'None attached'
                : submission.documents
                    .map((d) => '${d.typeLabel} (${d.status})')
                    .join(', '),
          ),
          if (submission.documents.any((d) => d.rejectionReason.isNotEmpty))
            AdminDataRow(
              label: 'Document rejection',
              value: submission.documents
                  .where((d) => d.rejectionReason.isNotEmpty)
                  .map((d) => '${d.typeLabel}: ${d.rejectionReason}')
                  .join('\n'),
            ),
          if (submission.reviewedBy != null)
            AdminDataRow(label: 'Reviewed by', value: submission.reviewedBy!),
          if (submission.reviewedAt != null)
            AdminDataRow(label: 'Reviewed at', value: submission.reviewedAt!),
          if (submission.reviewerNote.trim().isNotEmpty)
            AdminDataRow(label: 'Decision note', value: submission.reviewerNote),
          _approvalStatePanel(submission),
        ],
      ),
    );
  }

  /// The pending-request block.
  ///
  /// Printed in full because the three facts an operator needs are all in it:
  /// who asked, who still has to act, and whether anything has been applied
  /// yet. A request reading `approved` with no `applied_at` gets the explicit
  /// warning — that combination means the effect was never carried out.
  Widget _approvalStatePanel(VerificationSubmission submission) {
    final state = submission.pendingApproval ?? submission.approvalState;
    if (state == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          submission.canRequestDecision
              ? const AdminHintNote(
                  text: 'No decision has been requested for this application. '
                      'Sending it for decision will not approve it — a second '
                      'member of staff still has to agree.',
                )
              : const AdminHintNote(
                  text: 'This application has not been sent for a decision.',
                ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        AdminDataRow(label: 'Request ID', value: state.id ?? '—'),
        AdminDataRow(
          label: 'Requested by',
          value: state.requestedByProfile.isEmpty ? '—' : state.requestedByProfile,
        ),
        AdminDataRow(
          label: 'Request is for',
          value: state.requestedDecisionLabel,
        ),
        if (state.requiredScope.isNotEmpty)
          AdminDataRow(label: 'Approver needs', value: state.requiredScope),
        if (state.decidedBy != null)
          AdminDataRow(label: 'Decided by', value: state.decidedBy!),
        if (state.decidedAt != null)
          AdminDataRow(label: 'Decided at', value: state.decidedAt!),
        AdminDataRow(
          label: 'Applied at',
          value: state.appliedAt ?? 'nothing applied yet',
        ),
        if (state.isPending) ...[
          const SizedBox(height: 6),
          const AdminRuleNote(
            text: 'Awaiting a second approver. Nothing has been applied to the '
                'applicant — no status, no role, no gym verification. The '
                'person who raised this cannot be the one who decides it.',
          ),
        ] else if (state.isSettledWithoutEffect) ...[
          const SizedBox(height: 6),
          const AdminRuleNote(
            text: 'This request is settled but records no applied time, so the '
                'effect was never carried out. Approving it through the '
                'verification decide endpoint is the only path that applies it.',
          ),
        ] else ...[
          const SizedBox(height: 6),
          const AdminHintNote(
            text: 'Decided and applied. The applicant reads the decision note '
                'above on their own My applications screen.',
          ),
        ],
      ],
    );
  }

  static String _shortDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    return iso.replaceFirst('T', ' ').split('.').first.split('+').first;
  }
}

/// The dialog behind both calls.
///
/// Shared because both are "an action plus a note", and because the one rule
/// they share is that a rejection cannot go out without a note — enforced in the
/// widget so the operator learns it before the round trip rather than from a
/// 400 afterwards.
class _DecisionDialog extends StatefulWidget {
  final String title;
  final String blurb;
  final String confirmLabel;
  final bool requireNote;
  final List<(String, String)>? choices;

  const _DecisionDialog({
    required this.title,
    required this.blurb,
    required this.confirmLabel,
    required this.requireNote,
    this.choices,
  });

  @override
  State<_DecisionDialog> createState() => _DecisionDialogState();
}

class _DecisionDialogState extends State<_DecisionDialog> {
  final _controller = TextEditingController();
  String _action = 'approve';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _ready => !widget.requireNote || _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: cs.surface,
      title: Text(widget.title, style: const TextStyle(fontSize: 16)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.blurb,
              style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.4),
            ),
            if (widget.choices != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: [
                  for (final choice in widget.choices!)
                    ChoiceChip(
                      label: Text(choice.$2, style: const TextStyle(fontSize: 11)),
                      selected: _action == choice.$1,
                      onSelected: (_) => setState(() => _action = choice.$1),
                      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                      backgroundColor: cs.surface,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 3,
              minLines: 2,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.requireNote
                    ? 'Reason (required — this is what the applicant reads)'
                    : 'Note (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back', style: TextStyle(fontSize: 12)),
        ),
        TextButton(
          onPressed: !_ready
              ? null
              : () => Navigator.pop(context, (action: _action, reason: _controller.text.trim())),
          style: TextButton.styleFrom(
            foregroundColor: _action == 'reject' ? BuddyColors.red : BuddyColors.green,
          ),
          child: Text(widget.confirmLabel, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}