import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../data/models/admin_portal.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';

/// `/portal/gyms/` — verification and access.
///
/// `member_count` only. The gym roster is deliberately not part of the portal
/// serializer, so there is nothing here that *could* leak one.
class AdminGymsScreen extends ConsumerStatefulWidget {
  const AdminGymsScreen({super.key});

  @override
  ConsumerState<AdminGymsScreen> createState() => _AdminGymsScreenState();
}

class _AdminGymsScreenState extends ConsumerState<AdminGymsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  int _page = 1;
  String _query = '';
  String _access = 'all';
  String _verified = 'all';
  String? _pendingId;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  PortalQuery get _query_ => PortalQuery.of(_page, {
        'q': _query,
        'access_type': _access,
        'is_verified': _verified == 'all' ? null : _verified == 'true',
      });

  Future<void> _patch(PortalGym gym, Map<String, dynamic> payload) async {
    setState(() {
      _error = null;
      _notice = null;
    });
    try {
      final raw = await ref
          .read(adminPortalRepositoryProvider)
          .updateGym(gym.id, payload);
      if (!mounted) return;
      setState(() {
        _notice = portalMessage(raw);
        _pendingId = null;
      });
      ref.invalidate(adminGymsProvider);
    } catch (e) {
      if (mounted) {
        setState(() =>
            _error = apiErrorMessage(e, fallback: 'Could not update the gym.'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminGymsProvider(_query_));
    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Gyms')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminGymsProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AdminPageHeader(
              title: 'Gyms',
              description: 'Verification, access type and liveness. Member '
                  'count only — the portal never exposes a roster.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Name, handle or city…',
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
              value: _access,
              options: const [
                (value: 'all', label: 'Any access'),
                (value: 'public', label: 'Public'),
                (value: 'private', label: 'Private'),
                (value: 'secret', label: 'Secret'),
              ],
              onChanged: (v) => setState(() {
                _access = v;
                _page = 1;
              }),
            ),
            const SizedBox(height: 8),
            AdminFilterChips(
              value: _verified,
              options: const [
                (value: 'all', label: 'Any verification'),
                (value: 'true', label: 'Verified'),
                (value: 'false', label: 'Unverified'),
              ],
              onChanged: (v) => setState(() {
                _verified = v;
                _page = 1;
              }),
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              AdminErrorBanner(
                message: _error!,
                onRetry: () => ref.invalidate(adminGymsProvider),
              ),
              const SizedBox(height: 10),
            ],
            if (_notice != null) ...[
              AdminNoticeBanner(message: _notice!),
              const SizedBox(height: 10),
            ],
            ...async.when(
              loading: () => [const SizedBox(height: 80)],
              error: (e, _) => [
                AdminErrorBanner(
                  message: apiErrorMessage(e, fallback: 'Failed to load gyms.'),
                  onRetry: () => ref.invalidate(adminGymsProvider),
                ),
              ],
              data: (result) => [
                if (result.items.isEmpty)
                  const AdminEmptyState(
                    icon: Icons.fitness_center_outlined,
                    title: 'No gyms match the current filters.',
                  )
                else
                  for (final gym in result.items) _gymRow(gym),
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

  Widget _gymRow(PortalGym gym) {
    final pending = _pendingId == gym.id;
    return AdminRowCard(
      title: gym.name ?? '—',
      badges: [
        AdminStatusBadge(status: gym.accessType),
        if (gym.isVerified)
          const AdminStatusBadge(status: 'verified')
        else
          const AdminStatusBadge(status: 'unverified'),
        if (gym.isDeleted) const AdminStatusBadge(status: 'deleted'),
      ],
      subtitle: '@${gym.handle ?? ''} · ${gym.category ?? 'uncategorised'}',
      meta: '${gym.memberCount} member(s)'
          '${gym.locationCity.isEmpty ? '' : ' · ${gym.locationCity}'}',
      actions: [
        AdminActionButton(
          label: pending ? 'Close' : 'Update',
          icon: Icons.tune,
          onPressed: () => setState(() => _pendingId = pending ? null : gym.id),
        ),
      ],
      expanded: pending
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminDataRow(label: 'Gym ID', value: gym.id),
                AdminDataRow(
                    label: 'Subscription',
                    value: (gym.subscriptionType ?? '—').replaceAll('_', ' ')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      label: Text(
                        gym.isVerified ? 'Unverify' : 'Verify',
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () =>
                          _patch(gym, {'is_verified': !gym.isVerified}),
                    ),
                    for (final access in const ['public', 'private', 'secret'])
                      ActionChip(
                        label: Text(access,
                            style: const TextStyle(fontSize: 11)),
                        onPressed: gym.accessType == access
                            ? null
                            : () => _patch(gym, {'access_type': access}),
                      ),
                    ActionChip(
                      label: Text(
                        gym.isDeleted ? 'Restore' : 'Soft delete',
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () =>
                          _patch(gym, {'is_deleted': !gym.isDeleted}),
                    ),
                  ],
                ),
              ],
            )
          : null,
    );
  }
}