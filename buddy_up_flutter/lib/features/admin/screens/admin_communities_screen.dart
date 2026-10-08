import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../data/models/admin_portal.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';

/// `/portal/communities/` — group triage, private ones included.
///
/// `member_count` and `post_count` are counts; `participants` is not part of the
/// portal serializer at all, so a roster is not reachable from this screen.
class AdminCommunitiesScreen extends ConsumerStatefulWidget {
  const AdminCommunitiesScreen({super.key});

  @override
  ConsumerState<AdminCommunitiesScreen> createState() =>
      _AdminCommunitiesScreenState();
}

class _AdminCommunitiesScreenState extends ConsumerState<AdminCommunitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  int _page = 1;
  String _query = '';
  String _visibility = 'all';
  String? _expandedId;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  PortalQuery get _query_ => PortalQuery.of(_page, {
        'q': _query,
        'is_public': _visibility == 'all' ? null : _visibility == 'true',
      });

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminCommunitiesProvider(_query_));
    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Communities')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminCommunitiesProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AdminPageHeader(
              title: 'Communities',
              description: 'Triage across every community, including private '
                  'ones. Counts only — no roster is exposed here.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Name or description…',
                prefixIcon: const Icon(Icons.search, size: 18),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), () {
                  if (mounted) {
                    setState(() {
                      _query = value.trim();
                      _page = 1;
                    });
                  }
                });
              },
            ),
            const SizedBox(height: 10),
            AdminFilterChips(
              value: _visibility,
              options: const [
                (value: 'all', label: 'Any visibility'),
                (value: 'true', label: 'Public'),
                (value: 'false', label: 'Private'),
              ],
              onChanged: (v) => setState(() {
                _visibility = v;
                _page = 1;
              }),
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              AdminErrorBanner(
                message: _error!,
                onRetry: () => ref.invalidate(adminCommunitiesProvider),
              ),
              const SizedBox(height: 10),
            ],
            ...async.when(
              loading: () => [const SizedBox(height: 80)],
              error: (e, _) => [
                AdminErrorBanner(
                  message: apiErrorMessage(
                    e,
                    fallback: 'Failed to load communities.',
                  ),
                  onRetry: () => ref.invalidate(adminCommunitiesProvider),
                ),
              ],
              data: (result) => [
                Row(
                  children: [
                    Expanded(
                      child: AdminStatCard(
                        label: 'Matching communities',
                        value: '${result.count}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AdminStatCard(
                        label: 'Members on this page',
                        value: '${result.items.fold<int>(0, (sum, c) => sum + c.memberCount)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (result.items.isEmpty)
                  const AdminEmptyState(
                    icon: Icons.groups_outlined,
                    title: 'No communities match the current filters.',
                  )
                else
                  for (final community in result.items) _communityRow(community),
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

  Widget _communityRow(PortalCommunity community) {
    final expanded = _expandedId == community.id;
    return AdminRowCard(
      title: community.groupName.isEmpty ? 'Untitled community' : community.groupName,
      badges: [
        AdminStatusBadge(
            status: community.isPublic ? 'public' : 'private'),
        if (!community.isCommunity)
          const AdminStatusBadge(status: 'group'),
      ],
      subtitle: community.description.isEmpty ? null : community.description,
      meta: '${community.memberCount} member(s) · ${community.postCount} post(s)'
          '${community.gymHandle == null ? '' : ' · gym @${community.gymHandle}'}',
      actions: [
        AdminActionButton(
          label: expanded ? 'Hide' : 'Details',
          icon: Icons.info_outline,
          onPressed: () =>
              setState(() => _expandedId = expanded ? null : community.id),
        ),
      ],
      expanded: expanded
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminDataRow(label: 'Community ID', value: community.id),
                AdminDataRow(
                    label: 'Created by',
                    value: community.createdByUsername ?? '—'),
                AdminDataRow(label: 'Origin', value: community.origin),
                AdminDataRow(
                    label: 'Invite code',
                    value:
                        community.inviteCode.isEmpty ? '—' : community.inviteCode),
                AdminDataRow(
                    label: 'Last message',
                    value: _shortDate(community.lastMessageAt)),
                AdminDataRow(
                    label: 'Created',
                    value: _shortDate(community.createdAt)),
              ],
            )
          : null,
    );
  }

  static String _shortDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    return iso.split('T').first;
  }
}