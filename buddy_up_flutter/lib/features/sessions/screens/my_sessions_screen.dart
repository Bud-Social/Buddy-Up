import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart' show BuddyInput;
import '../../../shared/widgets/shimmer_loader.dart';

class MySessionsScreen extends ConsumerStatefulWidget {
  const MySessionsScreen({super.key});

  @override
  ConsumerState<MySessionsScreen> createState() => _MySessionsScreenState();
}

class _MySessionsScreenState extends ConsumerState<MySessionsScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(() => ref.read(paginatedSessionsProvider.notifier).loadMore());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(paginatedSessionsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginatedSessionsProvider);
    final sessions = state.sessions;

    return Scaffold(
      appBar: AppBar(title: const Text('My Sessions')),
      body: sessions.isEmpty && state.isLoadingMore
          ? const ShimmerList()
          : sessions.isEmpty
              ? const EmptyState(icon: Icons.calendar_today, title: 'No sessions booked yet')
              : RefreshIndicator(
                  onRefresh: () => ref.read(paginatedSessionsProvider.notifier).refresh(),
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: sessions.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == sessions.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }
                      final s = sessions[i];
                      return Card(
                        color: BuddyColors.surface,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/sessions/${s.id}'),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: s.trainerAvatar.isNotEmpty ? NetworkImage(s.trainerAvatar) : null,
                                    child: s.trainerAvatar.isEmpty ? Text(s.trainerName[0].toUpperCase()) : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(s.trainerName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  _statusChip(s.status),
                                ]),
                                const SizedBox(height: 8),
                                Row(children: [
                                  const Icon(Icons.calendar_today, size: 14, color: BuddyColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(s.scheduledDate, style: const TextStyle(fontSize: 13)),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.access_time, size: 14, color: BuddyColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(s.scheduledTime, style: const TextStyle(fontSize: 13)),
                                  const SizedBox(width: 16),
                                  Text('${s.durationMinutes}min', style: const TextStyle(fontSize: 13)),
                                ]),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'confirmed': color = BuddyColors.green;
      case 'completed': color = BuddyColors.textSecondary;
      case 'cancelled': color = BuddyColors.red;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class SessionDetailScreen extends ConsumerWidget {
  final String bookingId;
  const SessionDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(mySessionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Session Details')),
      body: sessionsAsync.when(
        data: (sessions) {
          final s = sessions.where((s) => s.id == bookingId).firstOrNull;
          if (s == null) return const Center(child: Text('Session not found'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(children: [
                    CircleAvatar(radius: 40, backgroundImage: s.trainerAvatar.isNotEmpty ? NetworkImage(s.trainerAvatar) : null,
                      child: s.trainerAvatar.isEmpty ? Text(s.trainerName[0].toUpperCase(), style: const TextStyle(fontSize: 24)) : null),
                    const SizedBox(height: 8),
                    Text(s.trainerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(height: 24),
                _infoRow(Icons.calendar_today, 'Date', s.scheduledDate),
                _infoRow(Icons.access_time, 'Time', s.scheduledTime),
                _infoRow(Icons.timer, 'Duration', '${s.durationMinutes} minutes'),
                _infoRow(Icons.category, 'Type', s.sessionType.replaceAll('_', ' ')),
                _infoRow(Icons.info, 'Status', s.status),
                if (s.meetingLink != null) ...[
                  const SizedBox(height: 16),
                  BuddyButton(
                    label: 'Join Meeting',
                    fullWidth: true,
                    icon: Icons.videocam,
                    onPressed: () async {
                      final uri = Uri.tryParse(s.meetingLink!);
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ],
                if (s.status == 'completed') ...[
                  const SizedBox(height: 12),
                  BuddyButton(
                    label: 'Leave a Review',
                    variant: BuddyButtonVariant.secondary,
                    fullWidth: true,
                    icon: Icons.rate_review,
                    onPressed: () => context.push('/sessions/${s.id}/review?trainer=${s.trainerUsername}'),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const ShimmerDetail(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, size: 18, color: BuddyColors.textSecondary),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(color: BuddyColors.textSecondary)),
        Text(value),
      ]),
    );
  }
}

class SessionReviewScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String trainerUsername;
  const SessionReviewScreen({super.key, required this.bookingId, required this.trainerUsername});

  @override
  ConsumerState<SessionReviewScreen> createState() => _SessionReviewScreenState();
}

class _SessionReviewScreenState extends ConsumerState<SessionReviewScreen> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.reviewBooking(widget.bookingId, {
        'rating': _rating,
        'comment': _commentCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write a Review')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rate your session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => IconButton(
                icon: Icon(i < _rating ? Icons.star : Icons.star_border, size: 40, color: Colors.amber),
                onPressed: () => setState(() => _rating = i + 1),
              )),
            ),
            const SizedBox(height: 24),
            BuddyInput(label: 'Comment (optional)', controller: _commentCtrl, maxLines: 4),
            const SizedBox(height: 24),
            BuddyButton(
              label: 'Submit Review',
              fullWidth: true,
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
