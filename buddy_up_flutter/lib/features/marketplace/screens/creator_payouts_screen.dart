import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../wallet/providers/wallet_provider.dart';

class CreatorPayoutsScreen extends ConsumerStatefulWidget {
  const CreatorPayoutsScreen({super.key});

  @override
  ConsumerState<CreatorPayoutsScreen> createState() => _CreatorPayoutsScreenState();
}

class _CreatorPayoutsScreenState extends ConsumerState<CreatorPayoutsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(balanceProvider.notifier).loadBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(balanceProvider);
    final payoutsAsync = ref.watch(creatorPayoutsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? BuddyColors.surface : theme.colorScheme.surface;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(balanceProvider.notifier).loadBalance();
        ref.invalidate(creatorPayoutsProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            balanceAsync.when(
              data: (balance) {
                final creatorFiat = balance?.creatorTotalFiat ?? 0.0;
                final totalFiat = balance?.totalFiat ?? 0.0;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _BalanceCard(
                            title: 'Creator Balance',
                            amount: '\$${creatorFiat.toStringAsFixed(2)}',
                            subtitle: 'Available to withdraw',
                            color: Colors.purple,
                            cardBg: cardBg,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BalanceCard(
                            title: 'Total Balance',
                            amount: '\$${totalFiat.toStringAsFixed(2)}',
                            subtitle: 'All wallets combined',
                            color: BuddyColors.green,
                            cardBg: cardBg,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: creatorFiat >= 5.0 ? () => _showRequestPayoutDialog(context, creatorFiat) : null,
                        icon: const Icon(Icons.account_balance_wallet, size: 18),
                        label: const Text('Request Payout', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.purple.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Card(child: SizedBox(height: 120, child: PageLoader())),
              error: (err, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading balance: $err'),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Payout History',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),

            // Payouts List
            payoutsAsync.when(
              data: (payouts) {
                if (payouts.isEmpty) {
                  return Card(
                    color: cardBg,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.history, size: 36, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                            const SizedBox(height: 8),
                            Text('No payout requests yet', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: payouts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tx = payouts[index];
                    final isCompleted = tx.status == 'completed';
                    final isPending = tx.status == 'pending';
                    final statusColor = isCompleted ? BuddyColors.green : (isPending ? Colors.orange : Colors.red);

                    return Card(
                      color: cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withValues(alpha: 0.15),
                          child: Icon(
                            isCompleted ? Icons.check : (isPending ? Icons.access_time : Icons.close),
                            color: statusColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          (tx.description != null && tx.description!.isNotEmpty)
                              ? tx.description!
                              : 'Payout Withdrawal',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        subtitle: Text(
                          '${tx.createdAt.length >= 10 ? tx.createdAt.substring(0, 10) : tx.createdAt} · Ref: ${tx.referenceId.isNotEmpty ? tx.referenceId : tx.id.substring(0, 8)}',
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${(tx.fiatAmount != null && tx.fiatAmount!.isNotEmpty) ? (double.tryParse(tx.fiatAmount!)?.toStringAsFixed(2) ?? tx.fiatAmount!) : (tx.quantity * 1.0).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tx.status.toUpperCase(),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const PageLoader(),
              error: (err, _) => Center(child: Text('Error loading history: $err')),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestPayoutDialog(BuildContext context, double maxAmount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _RequestPayoutSheet(
        maxAmount: maxAmount,
        onPayoutRequested: () {
          ref.read(balanceProvider.notifier).loadBalance();
          ref.invalidate(creatorPayoutsProvider);
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final Color color;
  final Color cardBg;

  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.color,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.12),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 8),
            Text(amount, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }
}

class _RequestPayoutSheet extends ConsumerStatefulWidget {
  final double maxAmount;
  final VoidCallback onPayoutRequested;

  const _RequestPayoutSheet({
    required this.maxAmount,
    required this.onPayoutRequested,
  });

  @override
  ConsumerState<_RequestPayoutSheet> createState() => _RequestPayoutSheetState();
}

class _RequestPayoutSheetState extends ConsumerState<_RequestPayoutSheet> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  String _method = 'mpesa';
  String? _selectedBankCode;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banksAsync = ref.watch(banksProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Request Payout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (USD)',
                hintText: 'Min \$5.00 · Max \$${widget.maxAmount.toStringAsFixed(2)}',
                prefixText: '\$ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Payout Method', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('M-Pesa')),
                    selected: _method == 'mpesa',
                    selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                    onSelected: (val) => setState(() => _method = 'mpesa'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Bank Transfer')),
                    selected: _method == 'bank_transfer',
                    selectedColor: Colors.purple.withValues(alpha: 0.2),
                    onSelected: (val) => setState(() => _method = 'bank_transfer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_method == 'mpesa') ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'M-Pesa Phone Number',
                  hintText: '+254 7XX XXX XXX',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ] else ...[
              banksAsync.when(
                data: (banks) => DropdownButtonFormField<String>(
                  initialValue: _selectedBankCode,
                  decoration: InputDecoration(
                    labelText: 'Bank',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: banks.map((b) => DropdownMenuItem(value: b.code, child: Text(b.name))).toList(),
                  onChanged: (val) => setState(() => _selectedBankCode = val),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text('Could not load banks'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _accountNameController,
                decoration: InputDecoration(
                  labelText: 'Account Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPayout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Payout Request', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPayout() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount < 5.0 || amount > widget.maxAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount between \$5 and your available balance.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(walletRepositoryProvider).requestPayout({
        'amount': amount,
        'method': _method,
        'phone_number': _method == 'mpesa' ? _phoneController.text.trim() : null,
        'bank_account': _method == 'bank_transfer' ? _accountNumberController.text.trim() : null,
        'bank_code': _method == 'bank_transfer' ? _selectedBankCode : null,
        'account_name': _method == 'bank_transfer' ? _accountNameController.text.trim() : null,
      });

      widget.onPayoutRequested();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payout request of \$${amount.toStringAsFixed(2)} submitted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payout request failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
