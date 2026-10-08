import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../data/models/admin_portal.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';

/// `/portal/users/` — search, inspect and suspend accounts.
///
/// Counts only, never profile content, exactly as the web console. Privilege
/// fields are readable but not writable: the portal refuses a PATCH that tries,
/// and this screen never sends one.
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  int _page = 1;
  String _query = '';
  String _role = 'all';
  String _active = 'all';
  String _verification = 'all';
  String _searchProfile = 'all';
  String? _expandedId;
  String? _error;
  String? _notice;
  String? _pendingSuspendId;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  PortalQuery get _query_ => PortalQuery.of(_page, {
        'q': _query,
        'role': _role,
        'is_active': _active == 'all' ? null : _active == 'true',
        'verification_status': _verification,
        'has_search_profile':
            _searchProfile == 'all' ? null : _searchProfile == 'true',
      });

  void _setFilter(void Function() mutate) {
    setState(() {
      mutate();
      _page = 1;
      _error = null;
      _notice = null;
    });
  }

  Future<void> _act(String id, Future<dynamic> Function() action) async {
    setState(() {
      _error = null;
      _notice = null;
    });
    try {
      final raw = await action();
      if (!mounted) return;
      setState(() => _notice = portalMessage(raw));
      ref.invalidate(adminUsersProvider);
    } catch (e) {
      if (mounted) {
        setState(() => _error = apiErrorMessage(e, fallback: 'Action failed.'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminUsersProvider(_query_));
    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Users')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminUsersProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AdminPageHeader(
              title: 'Users',
              description: 'Search, inspect and suspend accounts. Counts only — '
                  'no profile content is loaded.',
              onRefresh: () => ref.invalidate(adminUsersProvider),
              refreshing: async.isLoading,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Email, username or id…',
                prefixIcon: const Icon(Icons.search, size: 18),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), () {
                  if (mounted) _setFilter(() => _query = value.trim());
                });
              },
            ),
            const SizedBox(height: 10),
            AdminFilterChips(
              value: _role,
              options: const [
                (value: 'all', label: 'Any role'),
                (value: 'user', label: 'User'),
                (value: 'trainer', label: 'Trainer'),
                (value: 'practitioner', label: 'Practitioner'),
              ],
              onChanged: (v) => _setFilter(() => _role = v),
            ),
            const SizedBox(height: 8),
            AdminFilterChips(
              value: _active,
              options: const [
                (value: 'all', label: 'Any account state'),
                (value: 'true', label: 'Active'),
                (value: 'false', label: 'Inactive'),
              ],
              onChanged: (v) => _setFilter(() => _active = v),
            ),
            const SizedBox(height: 8),
            AdminFilterChips(
              value: _verification,
              options: const [
                (value: 'all', label: 'Any verification'),
                (value: 'none', label: 'None'),
                (value: 'email', label: 'Email'),
                (value: 'id', label: 'ID'),
                (value: 'trainer', label: 'Trainer'),
                (value: 'practitioner', label: 'Practitioner'),
                (value: 'shop', label: 'Shop'),
                (value: 'gym', label: 'Gym'),
              ],
              onChanged: (v) => _setFilter(() => _verification = v),
            ),
            const SizedBox(height: 8),
            AdminFilterChips(
              value: _searchProfile,
              options: const [
                (value: 'all', label: 'Search profile: any'),
                (value: 'true', label: 'Has search profile'),
                (value: 'false', label: 'No search profile'),
              ],
              onChanged: (v) => _setFilter(() => _searchProfile = v),
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              AdminErrorBanner(
                message: _error!,
                onRetry: () => ref.invalidate(adminUsersProvider),
              ),
              const SizedBox(height: 10),
            ],
            if (_notice != null) ...[
              AdminNoticeBanner(message: _notice!),
              const SizedBox(height: 10),
            ],
            ...async.when(
              loading: () => [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ],
              error: (e, _) => [
                AdminErrorBanner(
                  message: apiErrorMessage(e, fallback: 'Failed to load users.'),
                  onRetry: () => ref.invalidate(adminUsersProvider),
                ),
              ],
              data: (result) => [
                Row(
                  children: [
                    Expanded(
                      child: AdminStatCard(
                        label: 'Matching users',
                        value: '${result.count}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AdminStatCard(
                        label: 'On this page',
                        value: '${result.items.length}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AdminStatCard(
                        label: 'Inactive here',
                        value: '${result.items.where((u) => !u.isActive).length}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (result.items.isEmpty)
                  const AdminEmptyState(
                    icon: Icons.search,
                    title: 'No users match the current filters.',
                    hint: 'Adjust the filters above, or clear them to see everyone.',
                  )
                else
                  for (final user in result.items) _userRow(user),
                const SizedBox(height: 4),
                AdminPager(
                  page: result,
                  currentPage: _page,
                  busy: async.isLoading,
                  onPage: (next) => setState(() => _page = next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _userRow(PortalUser user) {
    final expanded = _expandedId == user.id;
    final label = user.username ?? user.displayName ?? '';
    return AdminRowCard(
      title: label.isEmpty ? 'Unnamed user' : label,
      badges: [
        AdminStatusBadge(status: user.role),
        AdminStatusBadge(status: user.verificationStatus),
        if (user.isStaff)
          const AdminStatusBadge(status: 'staff'),
      ],
      subtitle: (user.email ?? '').isEmpty ? '—' : user.email,
      meta: '${user.id.substring(0, user.id.length > 8 ? 8 : user.id.length)} · '
          '${user.orderCount} order(s) · joined ${_shortDate(user.createdAt)}',
      actions: [
        AdminActionButton(
          label: expanded ? 'Hide' : 'Details',
          icon: Icons.person_outline,
          onPressed: () =>
              setState(() => _expandedId = expanded ? null : user.id),
        ),
        if (user.isActive)
          AdminActionButton(
            label: 'Suspend',
            icon: Icons.person_off_outlined,
            destructive: true,
            onPressed: () =>
                setState(() => _pendingSuspendId = _pendingSuspendId == user.id ? null : user.id),
          )
        else
          AdminActionButton(
            label: 'Reinstate',
            icon: Icons.check_circle_outline,
            onPressed: () => _act(
              user.id,
              () => ref
                  .read(adminPortalRepositoryProvider)
                  .reinstateUser(user.id, const {}),
            ),
          ),
      ],
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (expanded) ...[
            AdminDataRow(label: 'User ID', value: user.id),
            AdminDataRow(
                label: 'Display name',
                value: user.displayName ?? '—'),
            AdminDataRow(label: 'Phone', value: user.phone ?? '—'),
            AdminDataRow(label: 'Staff', value: user.isStaff ? 'Yes' : 'No'),
            AdminDataRow(label: 'Superuser',
                value: user.isSuperuser ? 'Yes' : 'No'),
            AdminDataRow(label: 'Adult account',
                value: user.isAdult ? 'Yes' : 'No'),
            AdminDataRow(label: 'Search profile',
                value: user.hasBuddySearch ? 'Present' : 'Absent'),
            AdminDataRow(label: 'Last login',
                value: _shortDate(user.lastLogin)),
          ],
          if (_pendingSuspendId == user.id)
            AdminReviewPrompt(
              title: 'Why is this account being suspended? The user sees this reason.',
              open: true,
              busy: false,
              onSubmit: (payload) {
                setState(() => _pendingSuspendId = null);
                _act(
                  user.id,
                  () => ref
                      .read(adminPortalRepositoryProvider)
                      .suspendUser(user.id, {'reason': payload.reason}),
                );
              },
              onCancel: () => setState(() => _pendingSuspendId = null),
            ),
        ],
      ),
    );
  }

  static String _shortDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    return iso.split('T').first;
  }
}