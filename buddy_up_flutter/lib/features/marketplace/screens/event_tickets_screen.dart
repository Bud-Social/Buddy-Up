import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_loader.dart';

class EventTicketsScreen extends ConsumerWidget {
  const EventTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(myTicketsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      body: ticketsAsync.when(
        data: (tickets) => tickets.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.confirmation_number_outlined, size: 64, color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    const Text('No tickets yet', style: TextStyle(color: BuddyColors.textSecondary)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tickets.length,
                itemBuilder: (_, i) {
                  final ticket = tickets[i];
                  final eventName = ticket.eventData?['title'] as String? ?? 'Event';
                  return Card(
                    color: BuddyColors.surface,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(eventName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            _statusBadge(ticket.status),
                          ]),
                          const SizedBox(height: 8),
                          Text('Code: ${ticket.ticketCode.substring(0, 8)}...', style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
                          if (ticket.tier.isNotEmpty) Text('Tier: ${ticket.tier}', style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
                          Text('Purchased: ${_formatDate(ticket.createdAt)}', style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                },
              ),
        loading: () => const PageLoader(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = BuddyColors.green;
      case 'used':
        color = BuddyColors.textSecondary;
      case 'cancelled':
      case 'refunded':
        color = BuddyColors.red;
      default:
        color = BuddyColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
