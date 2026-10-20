import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/wallet.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../../../shared/widgets/empty_state.dart';

/// Settings → Subscription & Billing: wallet balance and a shortcut into the
/// full wallet. Mirrors the web billing summary.
final billingBalanceProvider = FutureProvider<BalanceResponse>((ref) async {
  final raw = await ref.watch(walletRepositoryProvider).getBalance();
  return BalanceResponse.fromJson(raw['data'] as Map<String, dynamic>);
});

class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(billingBalanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription & Billing')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(billingBalanceProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            balance.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Could not load billing',
                subtitle: 'Check your connection and pull to refresh.',
              ),
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Wallet balance',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(
                            '${data.fiatCurrency} '
                            '${data.totalFiat.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Spendable: ${data.fiatCurrency} '
                            '${data.regularTotalFiat.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: BuddyColors.textSecondary),
                          ),
                          if (data.creatorTotalFiat > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Creator earnings: ${data.fiatCurrency} '
                              '${data.creatorTotalFiat.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: BuddyColors.textSecondary),
                            ),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => context.push('/wallet'),
                              icon: const Icon(Icons.account_balance_wallet,
                                  size: 16),
                              label: const Text('Open wallet'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.workspace_premium,
                          color: BuddyColors.green),
                      title: const Text('Gym subscriptions'),
                      subtitle: const Text(
                          'Manage memberships from the gym you joined.'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/gyms'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Payments are processed through the wallet. Your '
                    'transaction history, top-ups and withdrawals all live in '
                    'the wallet screen.',
                    style: TextStyle(
                        fontSize: 11, color: BuddyColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
