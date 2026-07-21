import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/page_loader.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));
    return eventAsync.when(
      data: (event) => Scaffold(
        appBar: AppBar(title: Text(event.title)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  event.coverImageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 200, color: BuddyColors.surfaceRaised,
                    child: const Center(child: Icon(Icons.event, size: 48, color: BuddyColors.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(event.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.videocam, size: 16, color: BuddyColors.textSecondary),
                const SizedBox(width: 4),
                Text(event.eventType.replaceAll('_', ' '), style: const TextStyle(color: BuddyColors.textSecondary)),
                if (event.gymData != null) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.fitness_center, size: 16, color: BuddyColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(event.gymData!.name, style: const TextStyle(color: BuddyColors.textSecondary)),
                ],
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.calendar_today, size: 16, color: BuddyColors.textSecondary),
                const SizedBox(width: 4),
                Text(_formatDate(event.startDatetime), style: const TextStyle(color: BuddyColors.textSecondary)),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: BuddyColors.textSecondary),
                const SizedBox(width: 4),
                Text(_formatTime(event.startDatetime), style: const TextStyle(color: BuddyColors.textSecondary)),
              ]),
              if (event.location.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.location_on, size: 16, color: BuddyColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(child: Text(event.location, style: const TextStyle(color: BuddyColors.textSecondary))),
                ]),
              ],
              const SizedBox(height: 16),
              Text(event.description, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 16),
              Row(children: [
                Text('Capacity: ${event.capacity}', style: const TextStyle(color: BuddyColors.textSecondary)),
                const SizedBox(width: 16),
                Text('Attendees: ${event.attendeeCount}', style: const TextStyle(color: BuddyColors.textSecondary)),
                if (event.spotsRemaining != null) ...[
                  const SizedBox(width: 16),
                  Text('${event.spotsRemaining} spots left', style: const TextStyle(color: BuddyColors.green, fontWeight: FontWeight.w600)),
                ],
              ]),
              if (event.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 4, children: event.tags.map((t) =>
                  Chip(label: Text(t), backgroundColor: BuddyColors.surfaceRaised, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ).toList()),
              ],
              const SizedBox(height: 24),
              BuddyButton(
                label: event.isRegistered ? 'Registered' : 'Get Ticket',
                fullWidth: true,
                onPressed: event.isRegistered ? null : () async {
                  await ref.read(marketplaceRepositoryProvider).purchaseEventTicket(eventId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ticket purchased!')),
                    );
                    ref.invalidate(eventDetailProvider(eventId));
                  }
                },
              ),
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(body: PageLoader()),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}
