import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_portal.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';

/// `/portal/transactions/` and `/portal/wallet/reconciliation/`.
///
/// Read-only, permanently. A transaction row is evidence that a balance
/// movement already happened, so there is no write affordance anywhere on this
/// screen — corrections go through the ledger's own posting path.
class AdminWalletScreen extends ConsumerStatefulWidget {
  const AdminWalletScreen({super.key});

  @override
  ConsumerState<AdminWalletScreen> createState() => _AdminWalletScreenState();
}

class _AdminWalletScreenState extends ConsumerState<AdminWalletScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  int _page = 1;
  String _query = '';
  String _status = 'all';
  String _direction = 'all';
  String? _expandedId;
  String? _error;

  @override
  void dispose() {
    _tabs.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  PortalQuery get _query_ => PortalQuery.of(_page, {
        'q': _query,
        'status': _status,
        'direction': _direction,
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin · Wallet'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: BuddyColors.green,
          labelColor: Theme.of(context).colorScheme.onSurface,
          tabs: const [
            Tab(text: 'Transactions'),
            Tab(text: 'Reconciliation'),
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
                hintText: 'Reference, tx ref or username…',
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
                          value: _direction,
                          options: const [
                            (value: 'all', label: 'Any direction'),
                            (value: 'credit', label: 'Credit'),
                            (value: 'debit', label: 'Debit'),
                          ],
                          onChanged: (v) => setState(() {
                            _direction = v;
                            _page = 1;
                          }),
                        ),
                        const SizedBox(height: 8),
                        AdminFilterChips(
                          value: _status,
                          options: const [
                            (value: 'all', label: 'Any status'),
                            (value: 'pending', label: 'Pending'),
                            (value: 'completed', label: 'Completed'),
                            (value: 'failed', label: 'Failed'),
                          ],
                          onChanged: (v) => setState(() {
                            _status = v;
                            _page = 1;
                          }),
                        ),
                      ],
                    )
                  : const SizedBox(height: 8),
            ),
          ),
          Expanded(
            child: TabBarView(
                controller: _tabs, children: [_transactionsTab(), _reconciliationTab()]),
          ),
        ],
      ),
    );
  }

  Widget _transactionsTab() {
    final async = ref.watch(adminTransactionsProvider(_query_));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminTransactionsProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AdminPageHeader(
            title: 'Wallet transactions',
            description: 'Read only. The ledger is never written from here.',
          ),
          const SizedBox(height: 12),
          if (_error != null) ...[
            AdminErrorBanner(
              message: _error!,
              onRetry: () => ref.invalidate(adminTransactionsProvider),
            ),
            const SizedBox(height: 10),
          ],
          ...async.when(
            loading: () => [const SizedBox(height: 80)],
            error: (e, _) => [
              AdminErrorBanner(
                message: apiErrorMessage(
                  e,
                  fallback: 'Failed to load transactions.',
                ),
                onRetry: () => ref.invalidate(adminTransactionsProvider),
              ),
            ],
            data: (result) => [
              if (result.items.isEmpty)
                const AdminEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No transactions match the current filters.',
                )
              else
                for (final tx in result.items) _transactionRow(tx),
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

  Widget _transactionRow(PortalTransaction tx) {
    final expanded = _expandedId == tx.id;
    return AdminRowCard(
      title: tx.description.isEmpty ? tx.transactionType : tx.description,
      badges: [
        AdminStatusBadge(status: tx.direction, upper: false),
        AdminStatusBadge(status: tx.status, upper: false),
      ],
      subtitle: '${tx.artifactType} · ${tx.quantity}',
      meta: [
        if (tx.userUsername.isNotEmpty) '@${tx.userUsername}',
        if (tx.txRef.isNotEmpty) tx.txRef,
        if (tx.createdAt != null) tx.createdAt!.split('T').first,
      ].join(' · '),
      actions: [
        AdminActionButton(
          label: expanded ? 'Hide' : 'Details',
          icon: Icons.info_outline,
          onPressed: () =>
              setState(() => _expandedId = expanded ? null : tx.id),
        ),
      ],
      expanded: expanded
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminDataRow(label: 'Transaction ID', value: tx.id),
                AdminDataRow(
                    label: 'User', value: tx.userEmail.isEmpty ? '—' : tx.userEmail),
                AdminDataRow(
                    label: 'Counterparty',
                    value: tx.counterpartyUsername ?? '—'),
                AdminDataRow(label: 'Reference',
                    value: tx.referenceId.isEmpty ? '—' : tx.referenceId),
                AdminDataRow(
                  label: 'Fiat',
                  value: tx.fiatAmount == null || tx.fiatCurrency.isEmpty
                      ? '—'
                      : '${tx.fiatAmount} ${tx.fiatCurrency}',
                ),
                AdminDataRow(label: 'Provider',
                    value: tx.paymentProvider.isEmpty ? '—' : tx.paymentProvider),
                AdminDataRow(label: 'Journal entry',
                    value: tx.journalEntry ?? '—'),
                AdminDataRow(label: 'Clearance',
                    value: tx.clearanceAt ?? '—'),
              ],
            )
          : null,
    );
  }

  Widget _reconciliationTab() {
    final async = ref.watch(adminReconciliationProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminReconciliationProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AdminPageHeader(
            title: 'Reconciliation',
            description: 'Provider-vs-ledger drift. Reads and logs only — it '
                'never posts a ledger entry.',
            onRefresh: null,
          ),
          const SizedBox(height: 12),
          ...async.when(
            loading: () => [const SizedBox(height: 80)],
            error: (e, _) => [
              AdminErrorBanner(
                message: apiErrorMessage(
                  e,
                  fallback: 'Reconciliation failed.',
                ),
                onRetry: () => ref.invalidate(adminReconciliationProvider),
              ),
            ],
            data: (report) => [
              Row(
                children: [
                  Expanded(
                    child: AdminStatCard(
                      label: 'Window',
                      value: '${report.windowDays}d',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AdminStatCard(
                      label: 'Writes ledger',
                      value: report.writesLedger ? 'Yes' : 'No',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AdminStatCard(
                      label: 'Mismatched',
                      value: '${_int(report.local['mismatched'])}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Block(
                title: 'Provider',
                rows: report.provider.entries
                    .map((e) => AdminDataRow(
                        label: e.key.replaceAll('_', ' '),
                        value: '${e.value}'))
                    .toList(),
              ),
              const SizedBox(height: 12),
              _Block(
                title: 'Local drift checks',
                rows: report.local.entries
                    .map((e) => AdminDataRow(
                        label: e.key.replaceAll('_', ' '),
                        value: '${e.value}'))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static int _int(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}

class _Block extends StatelessWidget {
  final String title;
  final List<Widget> rows;

  const _Block({required this.title, required this.rows});

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
          Text(title,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }
}
