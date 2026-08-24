import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallet_provider.dart';
import '../../../data/models/wallet.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/api/api_client.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart' show BuddyInput;

final _walletProfileRepoProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ApiClient().dio);
});

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    Future.microtask(() => ref.read(balanceProvider.notifier).loadBalance());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _BalanceHeader(),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Buy'),
              Tab(text: 'Send'),
              Tab(text: 'History'),
              Tab(text: 'Withdraw'),
            ],
            indicatorColor: BuddyColors.green,
            labelColor: BuddyColors.green,
            unselectedLabelColor: BuddyColors.textSecondary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const _OverviewTab(),
                const _BuyTab(),
                _SendTab(),
                const _HistoryTab(),
                _WithdrawTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balanceProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      color: BuddyColors.surface,
      child: balanceAsync.when(
        data: (balance) {
          if (balance == null) return const SizedBox.shrink();
          return Column(
            children: [
              Text('\$${balance.totalFiat.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text(balance.totalLabel, style: const TextStyle(color: BuddyColors.textSecondary)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: balance.balance.map((item) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Chip(
                      backgroundColor: BuddyColors.surfaceRaised,
                      label: Text('${item.quantity} ${item.label}', style: const TextStyle(fontSize: 13)),
                    ),
                  )).toList(),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Text('Error loading balance'),
      ),
    );
  }
}

class _OverviewTab extends ConsumerStatefulWidget {
  const _OverviewTab();

  @override
  ConsumerState<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends ConsumerState<_OverviewTab> {
  void _openTransfer(BalanceItem item) {
    showDialog(
      context: context,
      builder: (ctx) => _TransferDialog(item: item),
    ).then((_) {
      if (mounted) ref.read(balanceProvider.notifier).loadBalance();
    });
  }

  void _openCreatorNameEdit(String current) {
    showDialog(
      context: context,
      builder: (ctx) => _CreatorNameEditDialog(current: current),
    ).then((_) {
      if (mounted) ref.read(balanceProvider.notifier).loadBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(balanceProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Artifact Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          balanceAsync.when(
            data: (balance) {
              if (balance == null) return const SizedBox.shrink();
              return Column(
                children: balance.balance.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    color: BuddyColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: _artifactIcon(item.artifactType),
                      title: Text(item.label),
                      trailing: Text('${item.quantity} (\$${item.usdValue.toStringAsFixed(2)})',
                        style: const TextStyle(color: BuddyColors.green)),
                    ),
                  ),
                )).toList(),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('$e'),
          ),
          const SizedBox(height: 24),
          balanceAsync.when(
            data: (balance) {
              if (balance == null) return const SizedBox.shrink();
              final hasCreatorBalance = balance.creatorBalance.any((i) => i.quantity > 0);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Wallet Balance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...balance.regularBalance.where((i) => i.quantity > 0).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${item.quantity} × ${item.label}', style: const TextStyle(fontSize: 13)),
                  )),
                  if (balance.regularBalance.where((i) => i.quantity > 0).isEmpty)
                    const Text('No tokens in wallet.', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
                  Text('\$${balance.regularTotalFiat.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
                  const SizedBox(height: 16),
                  if (hasCreatorBalance || balance.creatorDisplayName.isNotEmpty) ...[
                    Row(children: [
                      Icon(Icons.star, size: 18, color: Colors.amber.withValues(alpha: 0.8)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          balance.creatorDisplayName.isNotEmpty
                            ? '${balance.creatorDisplayName}\'s Creator Wallet'
                            : 'Creator Wallet',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16, color: BuddyColors.textSecondary),
                        onPressed: () => _openCreatorNameEdit(balance.creatorDisplayName),
                        tooltip: 'Edit creator name',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    ...balance.creatorBalance.where((i) => i.quantity > 0).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: InkWell(
                        onTap: () => _openTransfer(item),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          child: Row(children: [
                            Icon(Icons.star, size: 14, color: Colors.amber.withValues(alpha: 0.5)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text('${item.quantity} × ${item.label}',
                                style: TextStyle(fontSize: 13, color: Colors.amber.withValues(alpha: 0.8))),
                            ),
                            Icon(Icons.swap_horiz, size: 14, color: BuddyColors.textSecondary.withValues(alpha: 0.7)),
                          ]),
                        ),
                      ),
                    )),
                    if (balance.creatorBalance.where((i) => i.quantity > 0).isEmpty)
                      const Text('No marketplace earnings yet.', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
                    Text('\$${balance.creatorTotalFiat.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text('Tap an item to transfer to your wallet.',
                      style: TextStyle(fontSize: 10, color: BuddyColors.textSecondary.withValues(alpha: 0.7))),
                    const SizedBox(height: 16),
                  ],
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: BuddyButton(label: 'Buy', variant: BuddyButtonVariant.secondary, icon: Icons.add, onPressed: () {})),
            const SizedBox(width: 12),
            Expanded(child: BuddyButton(label: 'Send', variant: BuddyButtonVariant.secondary, icon: Icons.send, onPressed: () {})),
            const SizedBox(width: 12),
            Expanded(child: BuddyButton(label: 'Withdraw', variant: BuddyButtonVariant.secondary, icon: Icons.download, onPressed: () {})),
          ]),
        ],
      ),
    );
  }
}

class _BuyTab extends ConsumerWidget {
  const _BuyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundlesAsync = ref.watch(bundlesProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Purchase Artifacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          bundlesAsync.when(
            data: (bundles) => Column(
              children: bundles.map((bundle) => Card(
                color: BuddyColors.surface,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: _artifactIcon(bundle.artifactType),
                  title: Text('${bundle.quantity} × ${bundle.artifactLabel}'),
                  subtitle: Text('Save ${bundle.savings.toStringAsFixed(0)}%'),
                  trailing: Text('\$${bundle.priceUsd.toStringAsFixed(2)}', style: const TextStyle(color: BuddyColors.green, fontWeight: FontWeight.bold)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => _PurchaseDialog(bundle: bundle),
                    );
                  },
                ),
              )).toList(),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('$e'),
          ),
        ],
      ),
    );
  }
}

class _PurchaseDialog extends ConsumerWidget {
  final BundleInfo bundle;
  const _PurchaseDialog({required this.bundle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: BuddyColors.surface,
      title: Text('Buy ${bundle.quantity} ${bundle.artifactLabel}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Price: \$${bundle.priceUsd.toStringAsFixed(2)}'),
          if (bundle.savings > 0) Text('You save ${bundle.savings.toStringAsFixed(0)}%!', style: const TextStyle(color: BuddyColors.green)),
          const SizedBox(height: 16),
          const Text('Payment method:'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: BuddyColors.green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(children: [
              Icon(Icons.phone_android, color: BuddyColors.green),
              SizedBox(width: 8),
              Text('Flutterwave'),
            ]),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          BuddyButton(label: 'Pay', onPressed: () async {
          final repo = ref.read(walletRepositoryProvider);
          try {
            await repo.initializePurchase({
              'bundle_id': bundle.id,
              'quantity': 1,
            });
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Purchase initiated! Check your email for payment instructions.')),
              );
              Navigator.pop(context);
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Purchase failed: $e')),
              );
            }
          }
        }),
      ],
    );
  }
}

class _SendTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SendTab> createState() => _SendTabState();
}

class _SendTabState extends ConsumerState<_SendTab> {
  final _usernameCtrl = TextEditingController();
  final _artifactTypeCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _msgCtrl = TextEditingController();
  bool _isSending = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  String? _selectedUsername;
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _usernameCtrl.dispose();
    _artifactTypeCtrl.dispose();
    _qtyCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    setState(() {
      _selectedUsername = null;
      _searchResults = [];
    });
    _searchDebounce?.cancel();
    final query = value.trim().replaceAll('@', '');
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _isSearching = true);
      try {
        final repo = ref.read(_walletProfileRepoProvider);
        final result = await repo.searchProfiles(query, null, 1);
        final data = result['data'] as List? ?? result['results'] as List? ?? [];
        if (mounted) setState(() => _searchResults = data.cast<Map<String, dynamic>>());
      } catch (_) {
        if (mounted) setState(() => _searchResults = []);
      } finally {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  void _selectRecipient(Map<String, dynamic> p) {
    setState(() {
      _selectedUsername = (p['username'] as String?) ?? '';
      _usernameCtrl.text = p['username'] as String? ?? '';
      _searchResults = [];
    });
  }

  Future<void> _send(bool isGift) async {
    final username = (_selectedUsername ?? _usernameCtrl.text.trim()).replaceAll('@', '');
    final type = _artifactTypeCtrl.text.trim();
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;
    if (username.isEmpty || type.isEmpty) return;
    setState(() => _isSending = true);
    try {
      final repo = ref.read(walletRepositoryProvider);
      final data = {
        'username': username,
        'artifact_type': type,
        'quantity': qty,
        if (_msgCtrl.text.trim().isNotEmpty) 'message': _msgCtrl.text.trim(),
      };
      if (isGift) {
        await repo.gift(data);
      } else {
        await repo.tip(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isGift ? 'Gift sent!' : 'Tip sent!')),
        );
        _usernameCtrl.clear();
        _artifactTypeCtrl.clear();
        _qtyCtrl.text = '1';
        _msgCtrl.clear();
        setState(() {
          _selectedUsername = null;
          _searchResults = [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Send Artifacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            _selectedUsername != null ? 'To: @$_selectedUsername' : 'Search for a recipient or type a @username',
            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 6),
          BuddyInput(
            label: 'Recipient',
            controller: _usernameCtrl,
            hint: '@username',
            suffixIcon: _isSearching ? Icons.sync : Icons.search,
            onChanged: _onUsernameChanged,
          ),
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: BuddyColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BuddyColors.surfaceRaised),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length.clamp(0, 5),
                separatorBuilder: (_, _) => const Divider(height: 1, color: BuddyColors.surfaceRaised),
                itemBuilder: (_, i) {
                  final p = _searchResults[i];
                  final name = p['display_name'] ?? p['username'] ?? '';
                  final username = p['username'] as String? ?? '';
                  return ListTile(
                    dense: true,
                    leading: Avatar(
                      src: p['avatar_url'] as String?,
                      alt: name,
                      size: AvatarSize.sm,
                    ),
                    title: Text(name, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                    subtitle: Text('@$username', style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
                    onTap: () => _selectRecipient(p),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          BuddyInput(label: 'Artifact Type', controller: _artifactTypeCtrl, hint: 'e.g. dumbbell, burpee, sprint'),
          const SizedBox(height: 12),
          BuddyInput(label: 'Quantity', controller: _qtyCtrl, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          BuddyInput(label: 'Message (optional)', controller: _msgCtrl),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: BuddyButton(
              label: 'Send Tip',
              variant: BuddyButtonVariant.secondary,
              isLoading: _isSending,
              onPressed: () => _send(false),
            )),
            const SizedBox(width: 12),
            Expanded(child: BuddyButton(
              label: 'Send Gift',
              isLoading: _isSending,
              onPressed: () => _send(true),
            )),
          ]),
        ],
      ),
    );
  }
}

class _HistoryTab extends ConsumerStatefulWidget {
  const _HistoryTab();

  @override
  ConsumerState<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends ConsumerState<_HistoryTab> {
  static const _typeFilters = <(String, String)>[
    ('', 'All'),
    ('purchase', 'Purchases'),
    ('tip_sent', 'Tips Sent'),
    ('tip_received', 'Tips'),
    ('live_fee', 'Live'),
    ('gym_subscription', 'Gym'),
    ('session_fee', 'Sessions'),
    ('marketplace', 'Marketplace'),
    ('creator_transfer', 'Creator'),
    ('withdrawal', 'Withdrawals'),
    ('gift_sent', 'Gifts'),
    ('platform_cut', 'Fees'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(transactionHistoryProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionHistoryProvider);
    if (state.isLoading && state.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            scrollDirection: Axis.horizontal,
            itemCount: _typeFilters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final (value, label) = _typeFilters[i];
              final selected = state.typeFilter == value;
              return ChoiceChip(
                label: Text(label, style: const TextStyle(fontSize: 12)),
                selected: selected,
                onSelected: (_) {
                  if (state.typeFilter == value) return;
                  ref.read(transactionHistoryProvider.notifier).load(type: value.isEmpty ? null : value);
                },
                selectedColor: BuddyColors.green.withValues(alpha: 0.25),
                backgroundColor: BuddyColors.surfaceRaised,
                side: BorderSide(
                  color: selected ? BuddyColors.green : Colors.transparent,
                  width: 1,
                ),
                showCheckmark: false,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? BuddyColors.green : BuddyColors.textSecondary,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: state.transactions.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 64, color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    const Text('No transactions yet', style: TextStyle(color: BuddyColors.textSecondary)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.transactions.length,
                itemBuilder: (_, i) {
                  final tx = state.transactions[i];
                  final isCredit = tx.direction == 'credit';
                  return Card(
                    color: BuddyColors.surface,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: _artifactIcon(tx.artifactType),
                      title: Text((tx.description?.isNotEmpty ?? false) ? tx.description! : tx.transactionType.replaceAll('_', ' ')),
                      subtitle: Text(tx.artifactType, style: const TextStyle(fontSize: 12)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${isCredit ? '+' : '-'}${tx.quantity} ${tx.artifactType}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isCredit ? BuddyColors.green : BuddyColors.red,
                            )),
                          if (tx.fiatAmount != null)
                            Text('\$${tx.fiatAmount}', style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}

class _WithdrawTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_WithdrawTab> createState() => _WithdrawTabState();
}

class _WithdrawTabState extends ConsumerState<_WithdrawTab> {
  final _artifactTypeCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _phoneCtrl = TextEditingController();
  final _bankAccountCtrl = TextEditingController();
  String _source = 'regular';
  String _method = 'mpesa';
  String _bankCode = '';
  bool _isWithdrawing = false;

  @override
  void dispose() {
    _artifactTypeCtrl.dispose();
    _qtyCtrl.dispose();
    _phoneCtrl.dispose();
    _bankAccountCtrl.dispose();
    super.dispose();
  }

  Future<void> _withdraw() async {
    final type = _artifactTypeCtrl.text.trim();
    final qty = int.tryParse(_qtyCtrl.text.trim());
    if (type.isEmpty || qty == null || qty <= 0) return;
    if (_method == 'mpesa' && _phoneCtrl.text.trim().isEmpty) return;
    if (_method == 'bank_transfer' && (_bankCode.isEmpty || _bankAccountCtrl.text.trim().isEmpty)) return;

    setState(() => _isWithdrawing = true);
    try {
      final repo = ref.read(walletRepositoryProvider);
      await repo.withdraw({
        'artifact_type': type,
        'quantity': qty,
        'phone': _phoneCtrl.text.trim(),
        'source': _source,
        'method': _method,
        'bank_code': _bankCode,
        'bank_account': _bankAccountCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Withdrawal request submitted!')),
        );
        _artifactTypeCtrl.clear();
        _qtyCtrl.text = '1';
        _phoneCtrl.clear();
        _bankAccountCtrl.clear();
        ref.read(balanceProvider.notifier).loadBalance();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Withdrawal failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isWithdrawing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(balanceProvider);
    final balances = _source == 'creator'
        ? (balance.value?.creatorBalance ?? const [])
        : (balance.value?.regularBalance ?? const []);
    final available = balances
        .where((b) => b.artifactType == _artifactTypeCtrl.text.trim())
        .fold<int>(0, (sum, b) => sum + b.quantity);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Withdraw Artifacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Withdraw from',
              style: TextStyle(fontSize: 13, color: BuddyColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _sourceChip('regular', 'Regular Wallet'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _sourceChip('creator', 'Creator Wallet'),
              ),
            ],
          ),
          if (available > 0) ...[
            const SizedBox(height: 8),
            Text('Available: $available ${_artifactTypeCtrl.text.trim()}',
                style: const TextStyle(fontSize: 12, color: BuddyColors.green)),
          ],
          const SizedBox(height: 16),
          BuddyInput(label: 'Artifact Type', controller: _artifactTypeCtrl, hint: 'e.g. dumbbell, burpee, sprint'),
          const SizedBox(height: 12),
          BuddyInput(label: 'Quantity', controller: _qtyCtrl, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          const Text('Payout method',
              style: TextStyle(fontSize: 13, color: BuddyColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _methodChip('mpesa', 'M-Pesa')),
              const SizedBox(width: 8),
              Expanded(child: _methodChip('bank_transfer', 'Bank Transfer')),
            ],
          ),
          const SizedBox(height: 16),
          if (_method == 'mpesa') ...[
            BuddyInput(label: 'Phone number (Flutterwave)', controller: _phoneCtrl, hint: '+254...'),
          ] else ...[
            FutureBuilder<dynamic>(
              future: ref.read(walletRepositoryProvider).getBanks(),
              builder: (context, snapshot) {
                final banks = ((snapshot.data?['data'] ?? snapshot.data?['banks']) as List?) ?? const [];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bank',
                        style: TextStyle(fontSize: 13, color: BuddyColors.textSecondary)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _bankCode.isEmpty ? null : _bankCode,
                      dropdownColor: BuddyColors.surface,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: BuddyColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        hintText: 'Select bank',
                      ),
                      items: banks.map<DropdownMenuItem<String>>((b) {
                        final m = b as Map<String, dynamic>;
                        return DropdownMenuItem(
                          value: m['code'] as String,
                          child: Text('${m['name']}', overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _bankCode = v ?? ''),
                    ),
                    const SizedBox(height: 12),
                    BuddyInput(label: 'Account number', controller: _bankAccountCtrl, keyboardType: TextInputType.number),
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: 24),
          BuddyButton(label: 'Withdraw', fullWidth: true, isLoading: _isWithdrawing, onPressed: _withdraw),
          const SizedBox(height: 12),
          const Text('Note: Withdrawals are processed via Flutterwave within 24-48 hours. Creator wallet funds require clearance before withdrawal.',
            style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sourceChip(String value, String label) {
    final active = _source == value;
    return InkWell(
      onTap: () => setState(() => _source = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? BuddyColors.green.withValues(alpha: 0.15) : BuddyColors.surface,
          border: Border.all(color: active ? BuddyColors.green : BuddyColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? BuddyColors.green : BuddyColors.textSecondary,
            )),
      ),
    );
  }

  Widget _methodChip(String value, String label) {
    final active = _method == value;
    const accent = BuddyColors.green;
    return InkWell(
      onTap: () => setState(() => _method = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? accent.withValues(alpha: 0.15) : BuddyColors.surface,
          border: Border.all(color: active ? accent : BuddyColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? accent : BuddyColors.textSecondary,
            )),
      ),
    );
  }
}

Widget _artifactIcon(String type) {
  IconData icon;
  Color color;
  switch (type) {
    case 'dumbbell':
      icon = Icons.fitness_center; color = BuddyColors.green;
    case 'barbell':
      icon = Icons.emoji_events; color = Colors.amber;
    case 'burpee':
      icon = Icons.local_fire_department; color = BuddyColors.red;
    case 'squat':
      icon = Icons.accessibility; color = Colors.blue;
    case 'sprint':
      icon = Icons.directions_run; color = Colors.purple;
    case 'pr':
      icon = Icons.diamond; color = Colors.cyan;
    case 'champion':
      icon = Icons.star; color = Colors.amber;
    case 'event':
      icon = Icons.event; color = Colors.teal;
    case 'meal_plan':
      icon = Icons.restaurant; color = Colors.orange;
    case 'training_programme':
      icon = Icons.fitness_center; color = Colors.indigo;
    case 'product':
      icon = Icons.shopping_bag; color = Colors.pink;
    default:
      icon = Icons.receipt_long; color = BuddyColors.textSecondary;
  }
  return Container(
    width: 40, height: 40,
    decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
    child: Icon(icon, color: color, size: 22),
  );
}

class _TransferDialog extends ConsumerStatefulWidget {
  final BalanceItem item;
  const _TransferDialog({required this.item});

  @override
  ConsumerState<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends ConsumerState<_TransferDialog> {
  late final TextEditingController _qtyCtrl;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    if (qty <= 0 || qty > widget.item.quantity) {
      setState(() => _error = 'Enter 1-${widget.item.quantity}.');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      final repo = ref.read(walletRepositoryProvider);
      await repo.transferFromCreator({
        'artifact_type': widget.item.artifactType,
        'quantity': qty,
      });
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: BuddyColors.surface,
      title: Row(children: [
        Icon(Icons.swap_horiz, color: Colors.amber.shade700),
        const SizedBox(width: 8),
        const Text('Transfer to Wallet'),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Move ${widget.item.label} from your creator wallet to your regular wallet so you can withdraw them.',
            style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          BuddyInput(
            label: 'Quantity (available: ${widget.item.quantity})',
            keyboardType: TextInputType.number,
            controller: _qtyCtrl,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: BuddyColors.red, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: _submitting ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        BuddyButton(label: _submitting ? 'Transferring...' : 'Transfer', onPressed: _submitting ? null : _submit),
      ],
    );
  }
}

class _CreatorNameEditDialog extends ConsumerStatefulWidget {
  final String current;
  const _CreatorNameEditDialog({required this.current});

  @override
  ConsumerState<_CreatorNameEditDialog> createState() => _CreatorNameEditDialogState();
}

class _CreatorNameEditDialogState extends ConsumerState<_CreatorNameEditDialog> {
  late final TextEditingController _nameCtrl;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.current);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final trimmed = _nameCtrl.text.trim();
    if (trimmed.isNotEmpty && (trimmed.length < 3 || trimmed.length > 50)) {
      setState(() => _error = 'Display name must be 3-50 characters.');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      final repo = ref.read(walletRepositoryProvider);
      await repo.updateCreatorProfile({'creator_display_name': trimmed});
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: BuddyColors.surface,
      title: const Text('Creator Display Name'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Shown to buyers alongside your marketplace services. Leave empty to clear.',
            style: TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          BuddyInput(
            label: 'Display name',
            hint: 'e.g. Coach Imani',
            controller: _nameCtrl,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: BuddyColors.red, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: _submitting ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        BuddyButton(label: _submitting ? 'Saving...' : 'Save', onPressed: _submitting ? null : _submit),
      ],
    );
  }
}
