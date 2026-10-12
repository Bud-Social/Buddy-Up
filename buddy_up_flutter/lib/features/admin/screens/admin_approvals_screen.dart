import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_portal.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/admin_provider.dart';
import '../providers/governance_provider.dart';
import '../widgets/admin_widgets.dart';

/// `/governance/approvals/**` — the two-person queue.
///
/// The whole point of this screen is that a request never applies itself. The
/// person who raised it cannot decide it (403), a settled request cannot be
/// decided twice (409), and a ban's effect is applied by the *approve* call, not
/// the *request* call. Each of those is a refusal the operator will hit, so
/// each is surfaced with the server's own sentence rather than a generic
/// failure — the message is what tells them whether to wait, ask someone else,
/// or raise a fresh request.
class AdminApprovalsScreen extends ConsumerStatefulWidget {
  const AdminApprovalsScreen({super.key});

  @override
  ConsumerState<AdminApprovalsScreen> createState() => _AdminApprovalsScreenState();
}

class _AdminApprovalsScreenState extends ConsumerState<AdminApprovalsScreen> {
  String _status = 'pending';
  String _action = 'all';
  String _mine = 'all';
  int _page = 1;

  String? _error;
  String? _notice;

  PortalQuery get _query => PortalQuery.of(_page, {
        'status': _status,
        'action': _action,
        'mine': _mine,
      });

  void _setFilter(void Function() mutate) {
    setState(() {
      mutate();
      _page = 1;
      _error = null;
      _notice = null;
    });
  }

  Future<void> _decide(
    AccountActionRequest request,
    String decision,
  ) async {
    setState(() {
      _error = null;
      _notice = null;
    });
    // Approve takes an optional note; reject and cancel require one, so they
    // open a dialog that will not let the operator send without typing.
    if (decision != 'approve') {
      final note = await _collectNote(decision);
      if (note == null || note.trim().isEmpty) return;
      await _send(request, decision, note.trim());
      return;
    }
    await _send(request, decision, '');
  }

  Future<void> _send(
    AccountActionRequest request,
    String decision,
    String note,
  ) async {
    try {
      final repo = ref.read(adminPortalRepositoryProvider);
      final body = <String, dynamic>{'note': note};
      final raw = switch (decision) {
        'approve' => await repo.approveApproval(request.id!, body),
        'reject' => await repo.rejectApproval(request.id!, body),
        _ => await repo.cancelApproval(request.id!, body),
      };
      if (!mounted) return;
      final data = raw is Map ? raw['data'] : null;
      final effect = data is Map ? data['effect'] : null;
      setState(() {
        _notice = effect is String && effect.isNotEmpty
            ? '${portalMessage(raw, fallback: 'Request approved.')} $effect'
            : portalMessage(raw, fallback: 'Request $decision.');
      });
      ref.invalidate(approvalsProvider);
      ref.invalidate(pendingModerationApprovalsProvider);
    } catch (e) {
      if (mounted) setState(() => _error = moderationRefusal(e));
    }
  }

  /// Approve tolerates an empty note; reject and cancel do not — the server
  /// 400s, and the note is the record the target reads in an appeal.
  Future<String?> _collectNote(String decision) {
    return showDialog<String>(
      context: context,
      builder: (_) => _DecisionNoteDialog(decision: decision),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isStaffProvider)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin · Approvals')),
        body: const ErrorView(
          message: 'Staff access is required. The approvals queue is not '
              'reachable from a personal account.',
        ),
      );
    }

    final approvals = ref.watch(approvalsProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Approvals')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(approvalsProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AdminPageHeader(
              title: 'Approvals',
              description: 'A request never applies itself. The person who '
                  'raised it cannot decide it, and approving a ban is what '
                  'actually suspends or bans the account.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _openRequestSheet(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Request an action', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 14),
            AdminFilterChips(
              value: _status,
              options: const [
                (value: 'pending', label: 'Pending'),
                ...kApprovalStatusChoices,
                (value: 'all', label: 'Any status'),
              ],
              onChanged: (v) => _setFilter(() => _status = v),
            ),
            const SizedBox(height: 8),
            AdminFilterChips(
              value: _action,
              options: const [
                (value: 'all', label: 'Any action'),
                ...kApprovalActionChoices,
              ],
              onChanged: (v) => _setFilter(() => _action = v),
            ),
            const SizedBox(height: 8),
            AdminFilterChips(
              value: _mine,
              options: const [
                (value: 'all', label: 'Raised by anyone'),
                (value: 'true', label: 'Raised by me'),
                (value: 'false', label: 'Raised by someone else'),
              ],
              onChanged: (v) => _setFilter(() => _mine = v),
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
            ...approvals.when(
              loading: () => const [AdminLoadingBlock()],
              error: (e, _) => [
                AdminErrorBanner(
                    message: apiErrorMessage(e, fallback: 'Failed to load approvals.')),
              ],
              data: (page) => [
                Row(
                  children: [
                    Expanded(
                      child: AdminStatCard(
                        label: 'Matching requests',
                        value: '${page.count}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AdminStatCard(
                        label: 'Pending here',
                        value: '${page.items.where((r) => r.isPending).length}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (page.items.isEmpty)
                  const AdminEmptyState(
                    icon: Icons.how_to_reg_outlined,
                    title: 'No requests match these filters.',
                    hint: 'A ban or suspension starts as a request here. '
                        'Nothing is applied until someone else approves it.',
                  )
                else
                  for (final request in page.items) _requestRow(request),
                AdminPager(
                  page: page,
                  currentPage: _page,
                  busy: approvals.isLoading,
                  onPage: (next) => setState(() => _page = next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestRow(AccountActionRequest request) {
    final title = request.actionDisplay.isNotEmpty
        ? request.actionDisplay
        : request.action.replaceAll('_', ' ');
    final badges = <Widget>[
      AdminStatusBadge(status: request.status),
      if (request.requiresSecond) const AdminStatusBadge(status: 'needs a second approver'),
    ];
    final actions = <Widget>[];
    if (request.isPending) {
      actions.addAll([
        AdminActionButton(
          label: 'Approve',
          icon: Icons.check,
          onPressed: () => _decide(request, 'approve'),
        ),
        AdminActionButton(
          label: 'Reject',
          icon: Icons.close,
          destructive: true,
          onPressed: () => _decide(request, 'reject'),
        ),
        AdminActionButton(
          label: 'Cancel',
          icon: Icons.undo,
          destructive: true,
          onPressed: () => _decide(request, 'cancel'),
        ),
      ]);
    }

    return AdminRowCard(
      title: title,
      badges: badges,
      subtitle: 'Target: ${request.targetUser.label}',
      meta: 'requested by ${request.requesterLabel} · '
          '${_shortDateTime(request.createdAt)}'
          '${request.requiredScope.isEmpty ? '' : ' · approver needs ${request.requiredScope}'}',
      actions: actions,
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminDataRow(label: 'Request ID', value: request.id ?? '—'),
          AdminDataRow(label: 'Action', value: request.action),
          AdminDataRow(label: 'Target', value: request.targetUser.label),
          AdminDataRow(
              label: 'Target email', value: request.targetUser?.email ?? '—'),
          AdminDataRow(label: 'Requested by', value: request.requesterLabel),
          if (request.decidedBy != null)
            AdminDataRow(label: 'Decided by', value: request.decidedBy.label),
          if (request.decidedAt != null)
            AdminDataRow(label: 'Decided at', value: _shortDateTime(request.decidedAt)),
          if (request.appliedAt != null)
            AdminDataRow(label: 'Applied at', value: _shortDateTime(request.appliedAt)),
          if (request.reason.isNotEmpty)
            AdminDataRow(label: 'Reason', value: request.reason),
          if (request.durationDays != null)
            AdminDataRow(label: 'Term', value: '${request.durationDays} day(s)'),
          if (request.decisionNote.isNotEmpty)
            AdminDataRow(label: 'Decision note', value: request.decisionNote),
          if (request.effect != null && request.effect!.isNotEmpty)
            AdminDataRow(label: 'Effect', value: request.effect!),
          // The honest state: "approved" with no applied_at means the effect
          // was never carried out, and the row would otherwise read as done.
          if (request.status == 'approved' && request.appliedAt == null)
            const AdminRuleNote(
              text: 'This request is marked approved but records no applied '
                  'time. Nothing was applied to the account.',
            ),
          if (request.isPending && request.requiresSecond) ...[
            const SizedBox(height: 6),
            const AdminHintNote(
              text: 'Approving applies the effect immediately and only once. '
                  'You cannot approve a request you raised yourself.',
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openRequestSheet(BuildContext context) async {
    final result = await showModalBottomSheet<_ApprovalDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetCtx) => const _RequestApprovalSheet(),
    );
    if (result == null) return;
    setState(() {
      _error = null;
      _notice = null;
    });
    try {
      final raw = await ref
          .read(adminPortalRepositoryProvider)
          .requestApproval(result.toBody());
      if (!mounted) return;
      setState(() => _notice = portalMessage(raw));
      ref.invalidate(approvalsProvider);
      ref.invalidate(pendingModerationApprovalsProvider);
    } catch (e) {
      if (mounted) setState(() => _error = moderationRefusal(e));
    }
  }

  static String _shortDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    return iso.replaceFirst('T', ' ').split('.').first.split('+').first;
  }
}

/// The note dialog for a reject or cancel.
///
/// Owns its own controller and disables the confirm button while the note is
/// empty, which is the same rule the server enforces — the difference is that
/// here the operator learns it before the round trip rather than after.
class _DecisionNoteDialog extends StatefulWidget {
  final String decision;

  const _DecisionNoteDialog({required this.decision});

  @override
  State<_DecisionNoteDialog> createState() => _DecisionNoteDialogState();
}

class _DecisionNoteDialogState extends State<_DecisionNoteDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isReject => widget.decision == 'reject';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ready = _controller.text.trim().isNotEmpty;
    return AlertDialog(
      backgroundColor: cs.surface,
      title: Text(
        _isReject ? 'Reject request' : 'Withdraw request',
        style: const TextStyle(fontSize: 16),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isReject
                  ? 'Why is this request being rejected? This is the record '
                      'the target will see in an appeal.'
                  : 'Why is this request being withdrawn? An operator who '
                      'raised a request in error should leave a reason.',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              maxLines: 3,
              minLines: 2,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Note (required)',
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
          onPressed:
              ready ? () => Navigator.pop(context, _controller.text.trim()) : null,
          style: TextButton.styleFrom(foregroundColor: BuddyColors.red),
          child: Text(
            _isReject ? 'Reject' : 'Withdraw',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// A validated approval request, ready for the wire.
class _ApprovalDraft {
  final String action;
  final String targetUser;
  final String reason;
  final int? durationDays;
  final String? role;

  const _ApprovalDraft({
    required this.action,
    required this.targetUser,
    this.reason = '',
    this.durationDays,
    this.role,
  });

  Map<String, dynamic> toBody() => {
        'action': action,
        'target_user': targetUser,
        'payload': {
          if (reason.isNotEmpty) 'reason': reason,
          if (durationDays != null) 'duration_days': durationDays,
          if (role != null) 'role': role,
        },
      };
}

/// "Request an action" form.
///
/// A ban or suspension here does nothing at all: the endpoint answers 201 with
/// a pending request and no effect. The form says that before the operator
/// presses send, because the natural misreading of "ban account" filed from
/// this screen is that the account has just been banned.
class _RequestApprovalSheet extends StatefulWidget {
  const _RequestApprovalSheet();

  @override
  State<_RequestApprovalSheet> createState() => _RequestApprovalSheetState();
}

class _RequestApprovalSheetState extends State<_RequestApprovalSheet> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String _action = 'suspension';
  String _role = 'moderator';

  @override
  void dispose() {
    _targetController.dispose();
    _reasonController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  /// Only ban and suspension demand a reason — it is written to the moderation
  /// log, so an empty one would produce an unusable audit row.
  bool get _needsReason => _action == 'ban' || _action == 'suspension';

  bool get _needsDuration => _action == 'suspension';

  int? get _durationDays {
    if (!_needsDuration) return null;
    return int.tryParse(_durationController.text.trim());
  }

  bool get _ready {
    if (_targetController.text.trim().isEmpty) return false;
    if (_needsReason && _reasonController.text.trim().isEmpty) return false;
    if (_needsDuration) {
      final days = _durationDays;
      if (days == null || days <= 0) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Request an action',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: 8),
            const AdminRuleNote(
              text: 'This raises a request. It applies nothing. A different '
                  'member of staff has to approve it before the account is '
                  'touched.',
            ),
            const SizedBox(height: 14),
            AdminFilterChips(
              value: _action,
              options: const [
                (value: 'suspension', label: 'Suspension'),
                (value: 'ban', label: 'Ban'),
                (value: 'staff_role_grant', label: 'Role grant'),
                (value: 'verification_decision', label: 'Verification'),
                (value: 'payout', label: 'Payout'),
              ],
              onChanged: (v) => setState(() => _action = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Target user id',
                helperText: 'The UUID of the account.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (_needsReason) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                minLines: 2,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Reason',
                  helperText: 'Required. Written to the moderation log and '
                      'read by whoever approves this.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
            if (_needsDuration) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Duration in days',
                  helperText: 'Whole days, greater than zero.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
            if (_action == 'staff_role_grant') ...[
              const SizedBox(height: 12),
              Text('Role to grant', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final option in kStaffRoleChoices)
                    ChoiceChip(
                      label: Text(option.label, style: const TextStyle(fontSize: 12)),
                      selected: _role == option.value,
                      onSelected: (_) => setState(() => _role = option.value),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: !_ready
                    ? null
                    : () => Navigator.pop(
                          context,
                          _ApprovalDraft(
                            action: _action,
                            targetUser: _targetController.text.trim(),
                            reason: _reasonController.text.trim(),
                            durationDays: _durationDays,
                            role: _action == 'staff_role_grant' ? _role : null,
                          ),
                        ),
                style: FilledButton.styleFrom(
                  backgroundColor: BuddyColors.green,
                  foregroundColor: BuddyColors.black,
                ),
                icon: const Icon(Icons.how_to_reg, size: 16),
                label: const Text('Raise request', style: TextStyle(fontSize: 13)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}