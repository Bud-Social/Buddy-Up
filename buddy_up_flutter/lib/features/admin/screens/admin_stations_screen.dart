import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_portal.dart';
import '../../../features/marketplace/utils/stations.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';

/// `/portal/stations/` plus `/portal/station-applications/`.
///
/// The station PATCH accepts only `is_active` and `is_primary` — a station's
/// address, hours and owner are the operator's to change through
/// `/marketplace/stations/<id>/`, which is why those fields are read-only here.
class AdminStationsScreen extends ConsumerStatefulWidget {
  const AdminStationsScreen({super.key});

  @override
  ConsumerState<AdminStationsScreen> createState() =>
      _AdminStationsScreenState();
}

class _AdminStationsScreenState extends ConsumerState<AdminStationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  int _page = 1;
  String _query = '';
  String _active = 'all';
  String _ownerType = 'all';
  String _applicationStatus = 'all';
  String? _pendingId;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _tabs.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  PortalQuery get _stationQuery => PortalQuery.of(_page, {
        'q': _query,
        'is_active': _active == 'all' ? null : _active == 'true',
        'owner_type': _ownerType,
      });

  PortalQuery get _applicationQuery =>
      PortalQuery.of(_page, {'status': _applicationStatus, 'q': _query});

  Future<void> _act(Future<dynamic> Function() action, VoidCallback invalidate) async {
    setState(() {
      _error = null;
      _notice = null;
    });
    try {
      final raw = await action();
      if (!mounted) return;
      setState(() {
        _notice = portalMessage(raw);
        _pendingId = null;
      });
      invalidate();
    } catch (e) {
      if (mounted) {
        setState(() => _error = apiErrorMessage(e, fallback: 'Action failed.'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin · Stations'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: BuddyColors.green,
          labelColor: Theme.of(context).colorScheme.onSurface,
          tabs: const [
            Tab(text: 'Stations'),
            Tab(text: 'Applications'),
          ],
          onTap: (_) => setState(() => _page = 1),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Name, city, address or registration…',
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: AnimatedBuilder(
              animation: _tabs,
              builder: (context, _) => _tabs.index == 0
                  ? Column(
                      children: [
                        AdminFilterChips(
                          value: _active,
                          options: const [
                            (value: 'all', label: 'Any state'),
                            (value: 'true', label: 'Active'),
                            (value: 'false', label: 'Inactive'),
                          ],
                          onChanged: (v) => setState(() {
                            _active = v;
                            _page = 1;
                          }),
                        ),
                        const SizedBox(height: 8),
                        AdminFilterChips(
                          value: _ownerType,
                          options: const [
                            (value: 'all', label: 'Any owner'),
                            (value: 'shop', label: 'Shop-owned'),
                            (value: 'gym', label: 'Gym-owned'),
                          ],
                          onChanged: (v) => setState(() {
                            _ownerType = v;
                            _page = 1;
                          }),
                        ),
                      ],
                    )
                  : AdminFilterChips(
                      value: _applicationStatus,
                      options: const [
                        (value: 'all', label: 'All'),
                        (value: 'submitted', label: 'Submitted'),
                        (value: 'under_review', label: 'Under review'),
                        (value: 'approved', label: 'Approved'),
                        (value: 'rejected', label: 'Rejected'),
                        (value: 'more_info_needed', label: 'More info needed'),
                      ],
                      onChanged: (v) => setState(() {
                        _applicationStatus = v;
                        _page = 1;
                      }),
                    ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: AdminErrorBanner(message: _error!),
            ),
          if (_notice != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: AdminNoticeBanner(message: _notice!),
            ),
          Expanded(
            child: TabBarView(controller: _tabs, children: [_stationsTab(), _applicationsTab()]),
          ),
        ],
      ),
    );
  }

  Widget _stationsTab() {
    final async = ref.watch(adminStationsProvider(_stationQuery));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminStationsProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AdminPageHeader(
            title: 'Pickup stations',
            description: 'Liveness and primary flag. Address, hours and owner '
                'belong to the operator, not to this console.',
          ),
          const SizedBox(height: 12),
          ...async.when(
            loading: () => [const SizedBox(height: 80)],
            error: (e, _) => [
              AdminErrorBanner(
                message:
                    apiErrorMessage(e, fallback: 'Failed to load stations.'),
                onRetry: () => ref.invalidate(adminStationsProvider),
              ),
            ],
            data: (result) => [
              if (result.items.isEmpty)
                const AdminEmptyState(
                  icon: Icons.store_outlined,
                  title: 'No stations match the current filters.',
                )
              else
                for (final station in result.items) _stationRow(station),
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
    );
  }

  Widget _stationRow(PortalStation station) {
    final pending = _pendingId == station.id;
    final area = [
      station.address,
      station.city,
      station.country,
    ].where((v) => v.isNotEmpty).join(', ');
    return AdminRowCard(
      title: station.name.isEmpty ? 'Pickup station' : station.name,
      badges: [
        AdminStatusBadge(status: station.ownerType),
        if (station.isPrimary) const AdminStatusBadge(status: 'primary'),
        AdminStatusBadge(
            status: station.isActive ? 'active' : 'inactive', upper: false),
      ],
      subtitle: area.isEmpty ? 'Address not listed' : area,
      meta: stationOpeningHoursLabel(station.openingHours),
      actions: [
        AdminActionButton(
          label: pending ? 'Close' : 'Actions',
          icon: Icons.tune,
          onPressed: () => setState(() => _pendingId = pending ? null : station.id),
        ),
      ],
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminDataRow(label: 'Station ID', value: station.id),
          AdminDataRow(label: 'Owner', value: station.ownerName ?? '—'),
          AdminDataRow(label: 'Phone',
              value: station.phone == null || station.phone!.isEmpty
                  ? '—'
                  : station.phone!),
          if (station.latitude != null && station.longitude != null)
            AdminDataRow(
              label: 'Coordinates',
              value: '${station.latitude}, ${station.longitude}',
            ),
          if (pending) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: Text(
                    station.isActive ? 'Deactivate' : 'Activate',
                    style: const TextStyle(fontSize: 11),
                  ),
                  onPressed: () => _act(
                    () => ref
                        .read(adminPortalRepositoryProvider)
                        .updateStation(station.id,
                            {'is_active': !station.isActive}),
                    () => ref.invalidate(adminStationsProvider),
                  ),
                ),
                ActionChip(
                  label: Text(
                    station.isPrimary ? 'Clear primary' : 'Make primary',
                    style: const TextStyle(fontSize: 11),
                  ),
                  onPressed: station.isPrimary
                      ? () => _act(
                            () => ref
                                .read(adminPortalRepositoryProvider)
                                .updateStation(station.id,
                                    {'is_primary': false}),
                            () => ref.invalidate(adminStationsProvider),
                          )
                      : () => _act(
                            () => ref
                                .read(adminPortalRepositoryProvider)
                                .updateStation(station.id,
                                    {'is_primary': true}),
                            () => ref.invalidate(adminStationsProvider),
                          ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _applicationsTab() {
    final async = ref.watch(adminStationApplicationsProvider(_applicationQuery));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminStationApplicationsProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AdminPageHeader(
            title: 'Station applications',
            description: 'A shop or gym applying to become a pickup point.',
          ),
          const SizedBox(height: 12),
          ...async.when(
            loading: () => [const SizedBox(height: 80)],
            error: (e, _) => [
              AdminErrorBanner(
                message: apiErrorMessage(
                  e,
                  fallback: 'Failed to load applications.',
                ),
                onRetry: () => ref.invalidate(adminStationApplicationsProvider),
              ),
            ],
            data: (result) => [
              if (result.items.isEmpty)
                const AdminEmptyState(
                  icon: Icons.how_to_reg,
                  title: 'Nothing waiting for review.',
                )
              else
                for (final application in result.items)
                  _applicationRow(application),
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
    );
  }

  Widget _applicationRow(PortalStationApplication application) {
    final open = _pendingId == application.id;
    return AdminRowCard(
      title: application.shopHandle ??
          application.gymHandle ??
          'Station application',
      badges: [AdminStatusBadge(status: application.status)],
      subtitle: application.submittedByUsername == null
          ? null
          : 'Submitted by @${application.submittedByUsername}',
      meta: [
        if (application.city.isNotEmpty) application.city,
        if (application.businessRegistrationNumber.isNotEmpty)
          'Reg ${application.businessRegistrationNumber}',
        if (application.contactPhone.isNotEmpty) application.contactPhone,
      ].join(' · '),
      actions: [
        AdminActionButton(
          label: open ? 'Close' : 'Review',
          icon: Icons.badge_outlined,
          onPressed: () => setState(() => _pendingId = open ? null : application.id),
        ),
      ],
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (open) ...[
            AdminDataRow(label: 'Application ID', value: application.id),
            AdminDataRow(label: 'Address',
                value: application.address.isEmpty ? '—' : application.address),
            AdminDataRow(label: 'Country',
                value: application.country.isEmpty ? '—' : application.country),
            AdminDataRow(
                label: 'Policy agreed',
                value: application.agreedToPolicy ? 'Yes' : 'No'),
            AdminDataRow(
                label: 'Documents',
                value: application.documents.isEmpty
                    ? 'None attached'
                    : '${application.documents.length} attached'),
            if (application.rejectionReason.isNotEmpty)
              AdminDataRow(label: 'Rejection',
                  value: application.rejectionReason),
            const SizedBox(height: 10),
            AdminReviewPrompt(
              title: 'Reason (a rejection needs one)',
              open: true,
              busy: false,
              onSubmit: (payload) {
                setState(() => _pendingId = null);
                _act(
                  () => ref
                      .read(adminPortalRepositoryProvider)
                      .reviewStationApplication(application.id, {
                    'status': payload.status,
                    if (payload.status == 'rejected')
                      'rejection_reason': payload.reason,
                    if (payload.status != 'rejected' && payload.reason.isNotEmpty)
                      'reviewer_notes': payload.reason,
                  }),
                  () => ref.invalidate(adminStationApplicationsProvider),
                );
              },
              onCancel: () => setState(() => _pendingId = null),
            ),
          ],
        ],
      ),
    );
  }
}