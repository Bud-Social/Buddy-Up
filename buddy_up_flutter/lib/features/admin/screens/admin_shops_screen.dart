import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_portal.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';

/// `/portal/shops/` and `/portal/shop-certifications/`.
///
/// The certification queue is the reason this screen exists in the app at all:
/// the web console has no page for it, and staff approving a Buddy Up shop from
/// a phone is exactly the case a mobile review queue is for. Approving mirrors
/// onto the shop's own `verification_status` server-side.
class AdminShopsScreen extends ConsumerStatefulWidget {
  const AdminShopsScreen({super.key});

  @override
  ConsumerState<AdminShopsScreen> createState() => _AdminShopsScreenState();
}

class _AdminShopsScreenState extends ConsumerState<AdminShopsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  int _page = 1;
  String _query = '';
  String _verification = 'all';
  String _certStatus = 'all';
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

  PortalQuery get _shopQuery => PortalQuery.of(_page, {
        'q': _query,
        'verification_status': _verification,
      });

  PortalQuery get _certQuery =>
      PortalQuery.of(_page, {'status': _certStatus, 'q': _query});

  Future<void> _act(Future<dynamic> Function() action, VoidCallback invalidate) async {
    setState(() {
      _error = null;
      _notice = null;
    });
    try {
      final raw = await action();
      if (!mounted) return;
      setState(() => _notice = portalMessage(raw));
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
        title: const Text('Admin · Shops'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: BuddyColors.green,
          labelColor: Theme.of(context).colorScheme.onSurface,
          tabs: const [
            Tab(text: 'Shops'),
            Tab(text: 'Certification queue'),
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
                hintText: 'Search shops or applicants…',
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
              builder: (context, _) {
                if (_tabs.index == 0) {
                  return AdminFilterChips(
                    value: _verification,
                    options: const [
                      (value: 'all', label: 'Any verification'),
                      (value: 'unverified', label: 'Unverified'),
                      (value: 'pending', label: 'Pending'),
                      (value: 'verified', label: 'Verified'),
                      (value: 'rejected', label: 'Rejected'),
                    ],
                    onChanged: (v) => setState(() {
                      _verification = v;
                      _page = 1;
                    }),
                  );
                }
                return AdminFilterChips(
                  value: _certStatus,
                  options: const [
                    (value: 'all', label: 'All'),
                    (value: 'submitted', label: 'Submitted'),
                    (value: 'under_review', label: 'Under review'),
                    (value: 'approved', label: 'Approved'),
                    (value: 'rejected', label: 'Rejected'),
                    (value: 'more_info_needed', label: 'More info needed'),
                  ],
                  onChanged: (v) => setState(() {
                    _certStatus = v;
                    _page = 1;
                  }),
                );
              },
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
            child: TabBarView(
              controller: _tabs,
              children: [_shopsTab(), _certificationsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shopsTab() {
    final async = ref.watch(adminShopsProvider(_shopQuery));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminShopsProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdminPageHeader(
            title: 'Shops',
            description: 'Verification state, product and member counts.',
            onRefresh: () => ref.invalidate(adminShopsProvider),
            refreshing: async.isLoading,
          ),
          const SizedBox(height: 12),
          ...async.when(
            loading: () => [const SizedBox(height: 80)],
            error: (e, _) => [
              AdminErrorBanner(
                message: apiErrorMessage(e, fallback: 'Failed to load shops.'),
                onRetry: () => ref.invalidate(adminShopsProvider),
              ),
            ],
            data: (result) => [
              Row(
                children: [
                  Expanded(
                    child: AdminStatCard(
                      label: 'Matching shops',
                      value: '${result.count}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AdminStatCard(
                      label: 'Products listed',
                      value: '${result.items.fold<int>(0, (sum, s) => sum + s.productCount)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (result.items.isEmpty)
                const AdminEmptyState(
                  icon: Icons.storefront_outlined,
                  title: 'No shops match the current filters.',
                )
              else
                for (final shop in result.items)
                  AdminRowCard(
                    title: shop.name ?? '—',
                    badges: [
                      AdminStatusBadge(status: shop.verificationStatus),
                      if (!shop.isActive)
                        const AdminStatusBadge(status: 'inactive'),
                    ],
                    subtitle: '@${shop.handle ?? ''} · ${shop.category ?? 'uncategorised'}',
                    meta: '${shop.productCount} product(s) · ${shop.memberCount} member(s) · '
                        '${shop.ownerCount} owner(s)',
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdminDataRow(label: 'Shop ID', value: shop.id),
                        AdminDataRow(
                            label: 'Contact email',
                            value: shop.contactEmail.isEmpty
                                ? '—'
                                : shop.contactEmail),
                        AdminDataRow(
                            label: 'Applied at',
                            value: _shortDate(shop.verificationAppliedAt)),
                        AdminDataRow(
                            label: 'Verified at',
                            value: _shortDate(shop.verifiedAt)),
                        if (shop.rejectionReason.isNotEmpty)
                          AdminDataRow(
                              label: 'Rejection', value: shop.rejectionReason),
                      ],
                    ),
                  ),
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

  Widget _certificationsTab() {
    final async = ref.watch(adminShopCertificationsProvider(_certQuery));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminShopCertificationsProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdminPageHeader(
            title: 'Certification queue',
            description: 'Buddy Up certification applications. Approving '
                'mirrors onto the shop server-side.',
            onRefresh: () => ref.invalidate(adminShopCertificationsProvider),
            refreshing: async.isLoading,
          ),
          const SizedBox(height: 12),
          ...async.when(
            loading: () => [const SizedBox(height: 80)],
            error: (e, _) => [
              AdminErrorBanner(
                message: apiErrorMessage(
                  e,
                  fallback: 'Failed to load certifications.',
                ),
                onRetry: () => ref.invalidate(adminShopCertificationsProvider),
              ),
            ],
            data: (result) => [
              if (result.items.isEmpty)
                const AdminEmptyState(
                  icon: Icons.how_to_reg,
                  title: 'Nothing waiting for review.',
                )
              else
                for (final app in result.items) _certRow(app),
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

  Widget _certRow(PortalShopCertification app) {
    final open = _pendingId == app.id;
    return AdminRowCard(
      title: app.shopName ?? app.shopHandle ?? 'Application',
      badges: [AdminStatusBadge(status: app.status)],
      subtitle: app.submittedByUsername == null
          ? null
          : 'Submitted by @${app.submittedByUsername}',
      meta: [
        if (app.serviceType.isNotEmpty) app.serviceType.replaceAll('_', ' '),
        if (app.businessRegistrationNumber.isNotEmpty)
          'Reg ${app.businessRegistrationNumber}',
        if (app.country.isNotEmpty) app.country,
      ].join(' · '),
      actions: [
        AdminActionButton(
          label: open ? 'Close' : 'Review',
          icon: Icons.badge_outlined,
          onPressed: () => setState(() => _pendingId = open ? null : app.id),
        ),
      ],
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (open) ...[
            AdminDataRow(label: 'Application ID', value: app.id),
            AdminDataRow(label: 'Legal name',
                value: app.legalName.isEmpty ? '—' : app.legalName),
            AdminDataRow(label: 'Phone',
                value: app.phone.isEmpty ? '—' : app.phone),
            AdminDataRow(
                label: 'Years of experience',
                value: app.yearsOfExperience?.toString() ?? '—'),
            AdminDataRow(
                label: 'Specialisations',
                value: app.specializations.isEmpty
                    ? '—'
                    : app.specializations.join(', ')),
            AdminDataRow(label: 'Website',
                value: app.websiteUrl.isEmpty ? '—' : app.websiteUrl),
            if (app.bioStatement.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(app.bioStatement,
                  style: const TextStyle(fontSize: 12, height: 1.35)),
            ],
            AdminDataRow(label: 'ID document',
                value: app.idDocumentUrl.isEmpty ? '—' : 'Provided'),
            AdminDataRow(
                label: 'Professional cert',
                value: app.professionalCertUrl.isEmpty ? '—' : 'Provided'),
            if (app.rejectionReason.isNotEmpty)
              AdminDataRow(label: 'Rejection', value: app.rejectionReason),
            const SizedBox(height: 10),
            AdminReviewPrompt(
              title: 'Reason (a rejection needs one; otherwise it is an internal note)',
              open: true,
              busy: false,
              onSubmit: (payload) {
                setState(() => _pendingId = null);
                _act(
                  () => ref
                      .read(adminPortalRepositoryProvider)
                      .reviewShopCertification(app.id, {
                    'status': payload.status,
                    if (payload.status == 'rejected')
                      'rejection_reason': payload.reason,
                    if (payload.status != 'rejected' && payload.reason.isNotEmpty)
                      'reviewer_notes': payload.reason,
                  }),
                  () => ref.invalidate(adminShopCertificationsProvider),
                );
              },
              onCancel: () => setState(() => _pendingId = null),
            ),
          ],
        ],
      ),
    );
  }

  static String _shortDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    return iso.split('T').first;
  }
}