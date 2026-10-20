import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../data/models/marketplace.dart';

enum _TicketTab { all, active, used, refunded, cancelled }

/// A ticket lives in this wallet until its event, not until it is scanned.
///
/// The endpoint used to hard-filter to `active`, which made a ticket on a
/// refunded order disappear from the only place it was listed, with no way to
/// follow the refund. Every status is returned now and the filter is local.
class EventTicketsScreen extends ConsumerStatefulWidget {
  const EventTicketsScreen({super.key});

  @override
  ConsumerState<EventTicketsScreen> createState() => _EventTicketsScreenState();
}

class _EventTicketsScreenState extends ConsumerState<EventTicketsScreen> {
  _TicketTab _tab = _TicketTab.all;

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(myTicketsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      body: ticketsAsync.when(
        data: (tickets) {
          final visible = tickets
              .where((t) => _tab == _TicketTab.all || t.status == _tab.name)
              .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: _TicketTab.values
                      .map((tab) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(tab.name[0].toUpperCase() + tab.name.substring(1)),
                              selected: _tab == tab,
                              selectedColor: BuddyColors.green.withValues(alpha: 0.25),
                              labelStyle: TextStyle(
                                color: _tab == tab ? BuddyColors.green : BuddyColors.textSecondary,
                                fontWeight:
                                    _tab == tab ? FontWeight.w600 : FontWeight.w400,
                              ),
                              showCheckmark: false,
                              onSelected: (_) => setState(() => _tab = tab),
                            ),
                          ))
                      .toList(),
                ),
              ),
              Expanded(
                child: tickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.confirmation_number_outlined,
                                size: 64,
                                color:
                                    BuddyColors.textSecondary.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            const Text('No tickets yet',
                                style: TextStyle(color: BuddyColors.textSecondary)),
                          ],
                        ),
                      )
                    : visible.isEmpty
                        ? Center(
                            child: Text(
                              'No ${_tab.name} tickets.',
                              style:
                                  const TextStyle(color: BuddyColors.textSecondary),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.refresh(myTicketsProvider.future),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: visible.length,
                              itemBuilder: (_, i) =>
                                  _TicketCard(ticket: visible[i]),
                            ),
                          ),
              ),
            ],
          );
        },
        loading: () => const PageLoader(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final EventTicket ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final eventName = ticket.eventData?['title'] as String? ?? 'Event';
    final isUsable = ticket.status == 'active';
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
                child: Text(eventName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _statusBadge(ticket.status),
            ]),
            const SizedBox(height: 8),
            Text('Code: ${ticket.ticketCode.substring(0, 8)}...',
                style: const TextStyle(
                    color: BuddyColors.textSecondary, fontSize: 13)),
            if (ticket.tier.isNotEmpty)
              Text('Tier: ${ticket.tier}',
                  style: const TextStyle(
                      color: BuddyColors.textSecondary, fontSize: 13)),
            Text('Purchased: ${_formatDate(ticket.createdAt)}',
                style: const TextStyle(
                    color: BuddyColors.textSecondary, fontSize: 13)),
            // A spent or refunded ticket must not carry a scannable QR: the
            // code would still open the gate, which is exactly what the
            // status is telling the holder it must not do.
            if (isUsable && ticket.qrDataUri != null && ticket.qrDataUri!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: _QrImage(qrDataUri: ticket.qrDataUri!),
              ),
            ] else if (!isUsable) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BuddyColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  ticket.status == 'used' ? 'Already scanned' : 'Not valid for entry',
                  style: const TextStyle(
                      color: BuddyColors.textSecondary, fontSize: 12),
                ),
              ),
            ],
            if (ticket.orderId.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.push('/marketplace/orders/${ticket.orderId}'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('View order',
                      style:
                          TextStyle(color: BuddyColors.green, fontSize: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = BuddyColors.green;
      case 'used':
        color = BuddyColors.gold;
      case 'cancelled':
      case 'refunded':
        color = BuddyColors.red;
      default:
        color = BuddyColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}

class _QrImage extends StatelessWidget {
  final String qrDataUri;
  const _QrImage({required this.qrDataUri});

  @override
  Widget build(BuildContext context) {
    try {
      final base64Part = qrDataUri.split(',').length > 1 ? qrDataUri.split(',')[1] : qrDataUri;
      final bytes = base64Decode(base64Part);
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.memory(bytes, width: 140, height: 140, gaplessPlayback: true),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}
