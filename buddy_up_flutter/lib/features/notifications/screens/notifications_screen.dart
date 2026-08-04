import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notification_provider.dart';
import '../../../data/models/notification.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loader.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_outlined,
              title: 'No notifications yet',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final n = notifications[i];
              final isLive = n.notificationType == 'live_starting' || n.notificationType == 'live_reminder';
              final liveId = n.metadata?['live_id']?.toString();
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: n.isRead ? BuddyColors.surfaceRaised : BuddyColors.green.withValues(alpha: 0.2),
                  child: Icon(_notificationIcon(n.notificationType), color: n.isRead ? BuddyColors.textSecondary : BuddyColors.green, size: 20),
                ),
                title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                    if (isLive && liveId != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _LiveCountdown(scheduledFor: n.metadata?['scheduled_for'] as String?),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _openLive(context, ref, n),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.videocam, size: 14, color: BuddyColors.green),
                                SizedBox(width: 4),
                                Text(
                                  'Open Live',
                                  style: TextStyle(color: BuddyColors.green, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                trailing: Text(_timeAgo(n.createdAt), style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
                onTap: () async {
                  await ref.read(notificationRepositoryProvider).markRead(n.id);
                  ref.invalidate(notificationsProvider);
                  ref.invalidate(unreadCountProvider);
                },
              );
            },
          );
        },
        loading: () => const ShimmerList(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Future<void> _openLive(BuildContext context, WidgetRef ref, BuddyNotification n) async {
    final liveId = n.metadata?['live_id']?.toString() ?? '';
    await ref.read(notificationRepositoryProvider).markRead(n.id);
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadCountProvider);
    if (liveId.isNotEmpty && context.mounted) {
      context.push('/lives/$liveId');
    }
  }

  IconData _notificationIcon(String type) {
    switch (type) {
      case 'like': return Icons.favorite;
      case 'comment': return Icons.comment;
      case 'follow': return Icons.person_add;
      case 'buddy_request': return Icons.handshake;
      case 'message': return Icons.message;
      case 'live_start':
      case 'live_starting':
      case 'live_reminder': return Icons.videocam;
      case 'gym_update': return Icons.fitness_center;
      case 'tip': return Icons.card_giftcard;
      case 'marketing': return Icons.campaign;
      default: return Icons.notifications;
    }
  }

  String _timeAgo(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.month}/${dt.day}';
  }
}

class _LiveCountdown extends StatefulWidget {
  final String? scheduledFor;

  const _LiveCountdown({this.scheduledFor});

  @override
  State<_LiveCountdown> createState() => _LiveCountdownState();
}

class _LiveCountdownState extends State<_LiveCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduled = widget.scheduledFor;
    final start = DateTime.tryParse(scheduled ?? '');
    if (start == null) return const SizedBox.shrink();
    final diff = start.difference(DateTime.now());
    if (diff.isNegative) {
      return const Text(
        'Live now — join!',
        style: TextStyle(color: BuddyColors.red, fontSize: 12, fontWeight: FontWeight.w600),
      );
    }
    final mins = math.max(1, (diff.inSeconds / 60).ceil());
    final label = mins >= 60 ? '${mins ~/ 60}h ${mins % 60}m' : '${mins}m';
    return Text(
      'Starts in $label',
      style: const TextStyle(color: BuddyColors.green, fontSize: 12, fontWeight: FontWeight.w600),
    );
  }
}

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPreferencesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: prefsAsync.when(
        data: (prefs) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _switchTile('Likes', prefs.likes, (v) => _update(ref, {..._toMap(prefs), 'likes': v})),
            _switchTile('Comments', prefs.comments, (v) => _update(ref, {..._toMap(prefs), 'comments': v})),
            _switchTile('Follows', prefs.follows, (v) => _update(ref, {..._toMap(prefs), 'follows': v})),
            _switchTile('Buddy Requests', prefs.buddyRequests, (v) => _update(ref, {..._toMap(prefs), 'buddy_requests': v})),
            _switchTile('Messages', prefs.messages, (v) => _update(ref, {..._toMap(prefs), 'messages': v})),
            _switchTile('Live Starts', prefs.liveStarts, (v) => _update(ref, {..._toMap(prefs), 'live_starts': v})),
            _switchTile('Gym Updates', prefs.gymUpdates, (v) => _update(ref, {..._toMap(prefs), 'gym_updates': v})),
            _switchTile('Tips & Gifts', prefs.tips, (v) => _update(ref, {..._toMap(prefs), 'tips': v})),
            _switchTile('Marketing', prefs.marketing, (v) => _update(ref, {..._toMap(prefs), 'marketing': v})),
          ]),
        loading: () => const ShimmerList(itemHeight: 56),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Widget _switchTile(String label, bool value, void Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      activeThumbColor: BuddyColors.green,
    );
  }

  Map<String, dynamic> _toMap(NotificationPreference p) => {
    'likes': p.likes,
    'comments': p.comments,
    'follows': p.follows,
    'buddy_requests': p.buddyRequests,
    'messages': p.messages,
    'live_starts': p.liveStarts,
    'gym_updates': p.gymUpdates,
    'tips': p.tips,
    'marketing': p.marketing,
  };

  Future<void> _update(WidgetRef ref, Map<String, dynamic> data) async {
    await ref.read(notificationRepositoryProvider).updatePreferences(data);
    ref.invalidate(notificationPreferencesProvider);
  }
}
