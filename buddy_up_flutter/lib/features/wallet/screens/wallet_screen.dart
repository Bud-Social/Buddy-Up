import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallet_provider.dart';
import '../../../data/models/wallet.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart' show BuddyInput;

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

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _artifactTypeCtrl.dispose();
    _qtyCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(bool isGift) async {
    final username = _usernameCtrl.text.trim();
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
          BuddyInput(label: 'Username', controller: _usernameCtrl),
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
    if (state.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text('No transactions yet', style: TextStyle(color: BuddyColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.builder(
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
            leading: Icon(isCredit ? Icons.arrow_upward : Icons.arrow_downward,
              color: isCredit ? BuddyColors.green : BuddyColors.red, size: 20),
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
  bool _isWithdrawing = false;

  @override
  void dispose() {
    _artifactTypeCtrl.dispose();
    _qtyCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _withdraw() async {
    final type = _artifactTypeCtrl.text.trim();
    final qty = int.tryParse(_qtyCtrl.text.trim());
    final phone = _phoneCtrl.text.trim();
    if (type.isEmpty || qty == null || qty <= 0 || phone.isEmpty) return;
    setState(() => _isWithdrawing = true);
    try {
      final repo = ref.read(walletRepositoryProvider);
      await repo.withdraw({
        'artifact_type': type,
        'quantity': qty,
        'phone': phone,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Withdrawal request submitted!')),
        );
        _artifactTypeCtrl.clear();
        _qtyCtrl.text = '1';
        _phoneCtrl.clear();
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Withdraw Artifacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          BuddyInput(label: 'Artifact Type', controller: _artifactTypeCtrl, hint: 'e.g. dumbbell, burpee, sprint'),
          const SizedBox(height: 12),
          BuddyInput(label: 'Quantity', controller: _qtyCtrl, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          BuddyInput(label: 'Phone number (Flutterwave)', controller: _phoneCtrl, hint: '+254...'),
          const SizedBox(height: 24),
          BuddyButton(label: 'Withdraw', fullWidth: true, isLoading: _isWithdrawing, onPressed: _withdraw),
          const SizedBox(height: 12),
          const Text('Note: Withdrawals are processed via Flutterwave within 24-48 hours.',
            style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
        ],
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
    default:
      icon = Icons.circle; color = BuddyColors.textSecondary;
  }
  return Container(
    width: 40, height: 40,
    decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
    child: Icon(icon, color: color, size: 22),
  );
}
