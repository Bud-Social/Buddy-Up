import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_portal.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/admin_provider.dart';
import '../providers/governance_provider.dart';
import '../widgets/admin_widgets.dart';

/// `/governance/staff-roles/**` — who may use the admin console, and how much.
///
/// The row's job is to answer "what can this person actually do", so the
/// expanded view shows `effective_scopes` — the role's defaults plus their own
/// extras, computed server-side — rather than the stored `scopes` alone, which
/// on its own looks like a much smaller grant than it is.
///
/// Two rules are visible on the rows that trigger them rather than buried in a
/// failure: revoking a role is not deleting it (the row is the audit trail), and
/// granting one normally needs a second approver.
class AdminStaffScreen extends ConsumerStatefulWidget {
  const AdminStaffScreen({super.key});

  @override
  ConsumerState<AdminStaffScreen> createState() => _AdminStaffScreenState();
}

class _AdminStaffScreenState extends ConsumerState<AdminStaffScreen> {
  String _role = 'all';
  String _revoked = 'all';
  int _page = 1;

  bool _granting = false;
  bool _busyGrant = false;
  String? _expandedId;
  String? _error;
  String? _notice;
  String? _pendingRevokeId;

  PortalQuery get _query =>
      PortalQuery.of(_page, {'role': _role, 'revoked': _revoked});

  void _setFilter(void Function() mutate) {
    setState(() {
      mutate();
      _page = 1;
      _error = null;
      _notice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isStaffProvider)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin · Staff Roles')),
        body: const ErrorView(
          message: 'Staff access is required. The role table is not readable '
              'from a personal account.',
        ),
      );
    }

    final roles = ref.watch(staffRolesProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Staff Roles')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(staffRolesProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AdminPageHeader(
              title: 'Staff roles',
              description: 'A role sets a floor of scopes; the stored extras '
                  'add to it. Narrowing a role is a code change, so the floor '
                  'cannot be edited away from here.',
            ),
            const SizedBox(height: 14),
            const AdminRuleNote(
              text: 'A grant is queued for a second approver by default and '
                  'applies nothing on its own. Revoking keeps the row — it is '
                  'the record of who held what, and by whom.',
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => setState(() => _granting = !_granting),
              icon: const Icon(Icons.person_add_alt_outlined, size: 16),
              label: Text(
                _granting ? 'Close grant form' : 'Grant a staff role',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            if (_granting) ...[
              const SizedBox(height: 12),
              _grantPanel(),
            ],
            const SizedBox(height: 14),
            AdminFilterChips(
              value: _role,
              options: const [
                (value: 'all', label: 'Any role'),
                (value: 'moderator', label: 'Moderator'),
                (value: 'support', label: 'Support'),
                (value: 'gym_relations', label: 'Gym'),
                (value: 'supplier_relations', label: 'Supplier'),
                (value: 'logistics', label: 'Logistics'),
                (value: 'finance', label: 'Finance'),
                (value: 'verification_regulator', label: 'Regulator'),
                (value: 'admin', label: 'Admin'),
              ],
              onChanged: (v) => _setFilter(() => _role = v),
            ),
            const SizedBox(height: 8),
            AdminFilterChips(
              value: _revoked,
              options: const [
                (value: 'all', label: 'Any state'),
                (value: 'false', label: 'Active'),
                (value: 'true', label: 'Revoked'),
              ],
              onChanged: (v) => _setFilter(() => _revoked = v),
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
            ...roles.when(
              loading: () => const [AdminLoadingBlock()],
              error: (e, _) => [
                AdminErrorBanner(
                    message: apiErrorMessage(e, fallback: 'Failed to load staff roles.')),
              ],
              data: (page) => [
                if (page.items.isEmpty)
                  const AdminEmptyState(
                    icon: Icons.badge_outlined,
                    title: 'No role assignments match.',
                    hint: 'A staff account with no role row keeps unrestricted '
                        'access — that is the deliberate back-compat rule.',
                  )
                else
                  for (final role in page.items) _roleRow(role),
                AdminPager(
                  page: page,
                  currentPage: _page,
                  busy: roles.isLoading,
                  onPage: (next) => setState(() => _page = next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _grantPanel() {
    return _GrantPanel(
      busy: _busyGrant,
      onGranted: (queued, message) {
        setState(() => _busyGrant = false);
        setState(() {
          _error = null;
          // A 202 here means an approval request, not a role. Saying
          // "granted" here would be the one message that is simply untrue.
          _notice = queued
              ? '$message Nothing is active yet — it needs a second approver '
                  'in the Approvals queue.'
              : message;
        });
        ref.invalidate(staffRolesProvider);
      },
      onFailed: (message) {
        setState(() {
          _busyGrant = false;
          _error = message;
        });
      },
    );
  }

  Widget _roleRow(StaffRole role) {
    final expanded = _expandedId == role.id;
    final badges = <Widget>[
      AdminStatusBadge(status: role.roleDisplay.isNotEmpty
          ? role.roleDisplay
          : role.role),
      if (!role.isActive) const AdminStatusBadge(status: 'revoked'),
    ];
    final actions = <Widget>[
      AdminActionButton(
        label: expanded ? 'Hide' : 'Scopes',
        icon: Icons.vpn_key_outlined,
        onPressed: () =>
            setState(() => _expandedId = expanded ? null : role.id),
      ),
      if (role.isActive)
        AdminActionButton(
          label: 'Revoke',
          icon: Icons.block,
          destructive: true,
          onPressed: () => setState(
              () => _pendingRevokeId = _pendingRevokeId == role.id ? null : role.id),
        ),
    ];

    return AdminRowCard(
      title: role.user.label,
      badges: badges,
      subtitle: role.user?.email ?? '—',
      meta: '${role.effectiveScopes.length} effective scope(s) · '
          'granted by ${role.grantedBy.label} · ${_shortDateTime(role.grantedAt)}'
          '${role.revokedAt != null ? ' · revoked ${_shortDateTime(role.revokedAt)}' : ''}',
      actions: actions,
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminDataRow(label: 'Role id', value: role.id ?? '—'),
          AdminDataRow(label: 'Holder', value: role.user.label),
          AdminDataRow(label: 'Email', value: role.user?.email ?? '—'),
          AdminDataRow(label: 'Granted by', value: role.grantedBy.label),
          AdminDataRow(label: 'Granted at', value: _shortDateTime(role.grantedAt)),
          if (role.notes.isNotEmpty)
            AdminDataRow(label: 'Notes', value: role.notes),
          if (role.revokedAt != null)
            AdminDataRow(label: 'Revoked at', value: _shortDateTime(role.revokedAt)),
          if (expanded) ...[
            const SizedBox(height: 8),
            Text('Effective scopes (what this person can actually do)',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 6),
            if (role.effectiveScopes.isEmpty)
              const AdminRuleNote(
                text: 'No effective scopes. A revoked row grants nothing; a '
                    'role whose defaults are empty would too.',
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final scope in role.effectiveScopes)
                    _scopeChip(scope, role.defaultScopes.contains(scope)),
                ],
              ),
            if (role.scopes.isNotEmpty) ...[
              const SizedBox(height: 8),
              AdminHintNote(
                text: 'Extra scopes on top of the role\'s defaults: '
                    '${role.scopes.join(', ')}',
              ),
            ],
            if (role.revokedAt != null) ...[
              const SizedBox(height: 8),
              const AdminHintNote(
                text: 'This row is kept for the audit trail. Re-grant the role '
                    'to restore access — the same POST that creates it will '
                    'clear the revocation.',
              ),
            ],
            if (_pendingRevokeId == role.id) ...[
              const SizedBox(height: 10),
              AdminRuleNote(
                icon: Icons.warning_amber_outlined,
                text: 'Revoke ${role.user.label}\'s role? They lose every '
                    'scope immediately. The row is kept with a revocation '
                    'timestamp, and the audit trail records the change — the '
                    'endpoint takes no reason field, so there is nowhere to '
                    'put one.',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _pendingRevokeId = null);
                      _revoke(role);
                    },
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: BuddyColors.red,
                    ),
                    icon: const Icon(Icons.block, size: 14),
                    label: const Text('Revoke', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: () => setState(() => _pendingRevokeId = null),
                    style:
                        TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: const Text('Keep the role', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _scopeChip(String scope, bool isDefault) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: BuddyColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: BuddyColors.green.withValues(alpha: isDefault ? 0.3 : 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            scope,
            style: const TextStyle(
              fontSize: 11,
              color: BuddyColors.green,
              fontFamily: 'monospace',
            ),
          ),
          // A scope the role grants anyway is shown differently from one added
          // by hand, because "delete this from their list" does nothing to the
          // former and that is a genuinely surprising thing to discover.
          if (!isDefault)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('+', style: TextStyle(fontSize: 11, color: BuddyColors.gold)),
            ),
        ],
      ),
    );
  }

  Future<void> _revoke(StaffRole role) async {
    setState(() {
      _error = null;
      _notice = null;
    });
    try {
      final raw =
          await ref.read(adminPortalRepositoryProvider).revokeStaffRole(role.id!);
      if (!mounted) return;
      setState(() => _notice = portalMessage(raw));
      ref.invalidate(staffRolesProvider);
    } catch (e) {
      if (mounted) setState(() => _error = moderationRefusal(e));
    }
  }

  static String _shortDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    return iso.replaceFirst('T', ' ').split('.').first.split('+').first;
  }
}

/// The grant form.
///
/// Two things it must not get wrong:
///
/// * **A queued grant is not a grant.** `requires_second` defaults to true and
///   the endpoint answers 202 with an `AccountActionRequest` rather than a
///   role. The success message says so explicitly, because "Staff role
///   granted" on a 202 would tell an operator their colleague has access when
///   they do not.
/// * **Self-grant is refused server-side** before the approval path is even
///   considered, so the field help says it rather than letting the operator
///   discover the 403.
///
/// Scope strings are validated against the server's known set at write time and
/// a typo is a 400 naming the bad value, so the field takes a comma-separated
/// list and lets the server be the authority on what exists.
class _GrantPanel extends ConsumerStatefulWidget {
  final bool busy;
  final void Function(bool queued, String message) onGranted;
  final void Function(String message) onFailed;

  const _GrantPanel({
    required this.busy,
    required this.onGranted,
    required this.onFailed,
  });

  @override
  ConsumerState<_GrantPanel> createState() => _GrantPanelState();
}

class _GrantPanelState extends ConsumerState<_GrantPanel> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _scopesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _role = 'moderator';

  /// Off by default, matching the server. Turning it off applies the role
  /// immediately with no second pair of eyes, so the toggle says which.
  bool _requiresSecond = true;

  @override
  void dispose() {
    _userController.dispose();
    _scopesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<String> get _scopes => _scopesController.text
      .split(',')
      .map((scope) => scope.trim())
      .where((scope) => scope.isNotEmpty)
      .toList();

  bool get _ready => _userController.text.trim().isNotEmpty && !widget.busy;

  Future<void> _submit() async {
    if (!_ready) return;
    try {
      final raw = await ref.read(adminPortalRepositoryProvider).grantStaffRole({
            'user': _userController.text.trim(),
            'role': _role,
            'scopes': _scopes,
            'notes': _notesController.text.trim(),
            'requires_second': _requiresSecond,
          });
      _userController.clear();
      _scopesController.clear();
      _notesController.clear();
      setState(() => _requiresSecond = true);
      // Same discriminator the moderation side uses: a 201 returns a role, a
      // 202 returns an approval.
      final data = raw is Map ? raw['data'] : null;
      final queued = data is Map<String, dynamic> &&
          (data['status'] == 'pending' || data['requires_second'] == true);
      if (!mounted) return;
      widget.onGranted(queued, portalMessage(raw, fallback: 'Staff role granted.'));
    } catch (e) {
      if (!mounted) return;
      widget.onFailed(moderationRefusal(e, fallback: 'Failed to grant the role.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Grant a staff role',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
          const SizedBox(height: 12),
          TextField(
            controller: _userController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Staff user id',
              helperText: 'A user UUID, and it must already be is_staff. '
                  'You cannot grant yourself a role.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          Text('Role', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
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
          const SizedBox(height: 12),
          TextField(
            controller: _scopesController,
            decoration: InputDecoration(
              labelText: 'Extra scopes (comma separated)',
              helperText: 'Added on top of the role defaults. Leave empty to '
                  'grant exactly what the role gives. An unknown scope is '
                  'refused by name.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 6),
          SwitchListTile(
            value: _requiresSecond,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) => setState(() => _requiresSecond = value),
            title: const Text('Require a second approver',
                style: TextStyle(fontSize: 13)),
            subtitle: Text(
              _requiresSecond
                  ? 'The grant is raised as a request and applies nothing until '
                      'someone else approves it.'
                  : 'The grant applies immediately with no second pair of eyes.',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _ready ? _submit : null,
              style: FilledButton.styleFrom(
                backgroundColor: BuddyColors.green,
                foregroundColor: BuddyColors.black,
              ),
              icon: widget.busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add_alt_outlined, size: 16),
              label: Text(
                _requiresSecond ? 'Raise grant request' : 'Grant immediately',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}