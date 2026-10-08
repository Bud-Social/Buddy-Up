import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_portal.dart';
import '../../../features/marketplace/utils/delivery_vehicles.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';

/// `/portal/delivery-personnel/` and `/portal/delivery-personnel-applications/`.
///
/// The courier PATCH accepts only `is_active`: a courier's rating and service
/// zones are earned, not typed in, so this screen never offers them.
class AdminDeliveryScreen extends ConsumerStatefulWidget {
  const AdminDeliveryScreen({super.key});

  @override
  ConsumerState<AdminDeliveryScreen> createState() =>
      _AdminDeliveryScreenState();
}

class _AdminDeliveryScreenState extends ConsumerState<AdminDeliveryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  int _page = 1;
  String _query = '';
  String _vehicle = 'all';
  String _active = 'all';
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

  PortalQuery get _courierQuery => PortalQuery.of(_page, {
        'q': _query,
        'vehicle_type': _vehicle,
        'is_active': _active == 'all' ? null : _active == 'true',
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
        setState(() =>
            _error = apiErrorMessage(e, fallback: 'Action failed.'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin · Delivery'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: BuddyColors.green,
          labelColor: Theme.of(context).colorScheme.onSurface,
          tabs: const [
            Tab(text: 'Couriers'),
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
                hintText: 'Username or display name…',
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
                          value: _vehicle,
                          options: [
                            const (value: 'all', label: 'Any vehicle'),
                            for (final entry in kDeliveryVehicleTypes)
                              (value: entry.value, label: entry.label),
                          ],
                          onChanged: (v) => setState(() {
                            _vehicle = v;
                            _page = 1;
                          }),
                        ),
                        const SizedBox(height: 8),
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
            child:
                TabBarView(controller: _tabs, children: [_couriersTab(), _applicationsTab()]),
          ),
        ],
      ),
    );
  }

  Widget _couriersTab() {
    final async = ref.watch(adminDeliveryProvider(_courierQuery));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminDeliveryProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AdminPageHeader(
            title: 'Delivery personnel',
            description: 'Liveness only — rating and zones are earned, not '
                'typed in.',
          ),
          const SizedBox(height: 12),
          ...async.when(
            loading: () => [const SizedBox(height: 80)],
            error: (e, _) => [
              AdminErrorBanner(
                message: apiErrorMessage(
                  e,
                  fallback: 'Failed to load couriers.',
                ),
                onRetry: () => ref.invalidate(adminDeliveryProvider),
              ),
            ],
            data: (result) => [
              if (result.items.isEmpty)
                const AdminEmptyState(
                  icon: Icons.local_shipping_outlined,
                  title: 'No couriers match the current filters.',
                )
              else
                for (final courier in result.items) _courierRow(courier),
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

  Widget _courierRow(PortalDeliveryPersonnel courier) {
    final pending = _pendingId == courier.id;
    return AdminRowCard(
      title: courier.displayName.isEmpty ? courier.username : courier.displayName,
      badges: [
        AdminStatusBadge(status: courier.vehicleType),
        AdminStatusBadge(
            status: courier.isActive ? 'active' : 'inactive', upper: false),
      ],
      subtitle: (courier.email ?? '').isEmpty ? null : courier.email,
      meta: [
        serviceZonesLabel(courier.serviceZones),
        if (courier.rating != null) '★ ${courier.rating!.toStringAsFixed(1)}',
        '${courier.activeOrderCount} active order(s)',
      ].join(' · '),
      actions: [
        AdminActionButton(
          label: courier.isActive ? 'Deactivate' : 'Activate',
          icon: courier.isActive
              ? Icons.pause_circle_outline
              : Icons.play_circle_outline,
          destructive: courier.isActive,
          onPressed: () => _act(
            () => ref
                .read(adminPortalRepositoryProvider)
                .updateDeliveryPersonnel(
                    courier.id, {'is_active': !courier.isActive}),
            () => ref.invalidate(adminDeliveryProvider),
          ),
        ),
        AdminActionButton(
          label: pending ? 'Close' : 'Details',
          icon: Icons.info_outline,
          onPressed: () => setState(() => _pendingId = pending ? null : courier.id),
        ),
      ],
      expanded: pending
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminDataRow(label: 'Courier ID', value: courier.id),
                AdminDataRow(
                    label: 'Username',
                    value: courier.username.isEmpty ? '—' : courier.username),
                AdminDataRow(
                    label: 'Vehicle',
                    value: deliveryVehicleLabel(courier.vehicleType)),
                AdminDataRow(
                    label: 'Service zones',
                    value: serviceZonesLabel(courier.serviceZones)),
                if (courier.bio.isNotEmpty)
                  AdminDataRow(label: 'Bio', value: courier.bio),
              ],
            )
          : null,
    );
  }

  Widget _applicationsTab() {
    final async = ref.watch(adminDeliveryApplicationsProvider(_applicationQuery));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminDeliveryApplicationsProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AdminPageHeader(
            title: 'Courier applications',
            description: 'Approving is what creates the assignable courier row.',
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
                onRetry: () => ref.invalidate(adminDeliveryApplicationsProvider),
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

  Widget _applicationRow(PortalDeliveryApplication application) {
    final open = _pendingId == application.id;
    return AdminRowCard(
      title: application.displayName.isEmpty
          ? (application.username.isEmpty ? 'Applicant' : application.username)
          : application.displayName,
      badges: [
        AdminStatusBadge(status: application.status),
        AdminStatusBadge(status: application.vehicleType),
      ],
      subtitle: application.phone.isEmpty ? null : application.phone,
      meta: serviceZonesLabel(application.serviceZones),
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
            AdminDataRow(
                label: 'ID document',
                value: application.idDocumentUrl.isEmpty
                    ? 'Not provided'
                    : 'Provided'),
            AdminDataRow(
                label: 'Licence',
                value: application.licenceDocumentUrl.isEmpty
                    ? 'Not provided'
                    : 'Provided'),
            if (application.bio.isNotEmpty)
              AdminDataRow(label: 'Bio', value: application.bio),
            if (application.rejectionReason.isNotEmpty)
              AdminDataRow(
                  label: 'Rejection', value: application.rejectionReason),
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
                      .reviewDeliveryApplication(application.id, {
                    'status': payload.status,
                    if (payload.status == 'rejected')
                      'rejection_reason': payload.reason,
                    if (payload.status != 'rejected' && payload.reason.isNotEmpty)
                      'reviewer_notes': payload.reason,
                  }),
                  () => ref.invalidate(adminDeliveryApplicationsProvider),
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