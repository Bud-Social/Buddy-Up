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

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _socialTypes = {
    'like', 'post_reaction', 'comment', 'comment_reply',
    'follow', 'new_follower', 'buddy_request', 'buddy_accepted',
    'mention', 'repost', 'post_repost', 'post_quote', 'community_post',
    'community_comment', 'community_reaction',
  };

  static const _liveTypes = {
    'live_start', 'live_starting', 'live_reminder',
  };

  static const _commerceTypes = {
    'event_ticket_purchased', 'order_status_changed', 'payout_processed',
    'payment_received', 'withdrawal_processed', 'new_purchase',
    'session_booked', 'session_reminder', 'session_cancelled',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BuddyNotification> _filterList(List<BuddyNotification> list, int tabIndex) {
    List<BuddyNotification> result;
    switch (tabIndex) {
      case 1:
        result = list.where((n) => _socialTypes.contains(n.notificationType)).toList();
      case 2:
        result = list.where((n) => _liveTypes.contains(n.notificationType)).toList();
      case 3:
        result = list.where((n) => _commerceTypes.contains(n.notificationType)).toList();
      case 0:
      default:
        result = list;
    }
    // Pinned notifications float to the top of each tab.
    result.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return 0;
    });
    return result;
  }

  Map<String, List<BuddyNotification>> _groupByDate(List<BuddyNotification> list) {
    final Map<String, List<BuddyNotification>> groups = {
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final n in list) {
      final dt = DateTime.tryParse(n.createdAt);
      if (dt == null) {
        groups['Earlier']!.add(n);
        continue;
      }
      final dateOnly = DateTime(dt.year, dt.month, dt.day);
      if (dateOnly.isAtSameMomentAs(today)) {
        groups['Today']!.add(n);
      } else if (dateOnly.isAtSameMomentAs(yesterday)) {
        groups['Yesterday']!.add(n);
      } else {
        groups['Earlier']!.add(n);
      }
    }

    // Remove empty groups
    groups.removeWhere((_, items) => items.isEmpty);
    return groups;
  }

  Future<void> _markAllRead() async {
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadCountProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read.')),
        );
      }
    } catch (_) {}
  }

  /// P8 parity with web: pin / unpin, mark read/unread and dismiss (delete)
  /// via PATCH /notifications/{id}/read/ { action }.
  Future<void> _runAction(BuddyNotification n, String action) async {
    try {
      await ref
          .read(notificationRepositoryProvider)
          .notificationAction(n.id, {'action': action});
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadCountProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action failed. Please try again.')),
        );
      }
    }
  }

  void _showActionsSheet(BuddyNotification n) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(n.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  color: cs.onSurface),
              title: Text(n.isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _runAction(n, n.isPinned ? 'unpin' : 'pin');
              },
            ),
            ListTile(
              leading: Icon(n.isRead ? Icons.mark_email_unread : Icons.done_all,
                  color: cs.onSurface),
              title: Text(n.isRead ? 'Mark as unread' : 'Mark as read'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _runAction(n, n.isRead ? 'unread' : 'read');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: BuddyColors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _runAction(n, 'dismiss');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(BuddyNotification n) async {
    await ref.read(notificationRepositoryProvider).markRead(n.id);
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadCountProvider);

    if (!mounted) return;

    final type = n.notificationType;
    final meta = n.metadata ?? {};

    if (type == 'live_starting' || type == 'live_reminder' || type == 'live_start') {
      final liveId = meta['live_id']?.toString() ?? '';
      if (liveId.isNotEmpty) {
        context.push('/lives/$liveId');
        return;
      }
    }

    if (type == 'event_ticket_purchased') {
      final eventId = meta['event_id']?.toString() ?? '';
      if (eventId.isNotEmpty) {
        context.push('/marketplace/events/$eventId');
        return;
      }
    }

    if (type == 'order_status_changed') {
      final orderId = meta['order_id']?.toString() ?? '';
      if (orderId.isNotEmpty) {
        context.push('/marketplace/orders/$orderId');
      } else {
        context.push('/marketplace/orders');
      }
      return;
    }

    if (type == 'payout_processed' || type == 'withdrawal_processed' || type == 'payment_received') {
      context.push('/wallet');
      return;
    }

    if (type == 'community_join_approved' || type == 'community_post') {
      final commId = meta['community_id']?.toString() ?? '';
      if (commId.isNotEmpty) {
        context.push('/communities/$commId');
        return;
      }
    }

    if (type == 'repost' || type == 'post_repost' || type == 'mention' || type == 'post_reaction' || type == 'comment') {
      final postId = meta['post_id']?.toString() ?? '';
      if (postId.isNotEmpty) {
        context.push('/feed/$postId');
        return;
      }
    }

    if (type == 'session_booked' || type == 'session_reminder') {
      context.push('/sessions');
      return;
    }

    // Default to feed
    context.push('/feed');
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: _markAllRead,
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Preferences',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: BuddyColors.green,
          labelColor: cs.onSurface,
          unselectedLabelColor: cs.onSurface.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Social'),
            Tab(text: 'Live'),
            Tab(text: 'Commerce'),
          ],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: notificationsAsync.when(
        data: (allNotifications) {
          final notifications = _filterList(allNotifications, _tabController.index);
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_outlined,
              title: 'No notifications',
            );
          }

          final grouped = _groupByDate(notifications);

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: grouped.length,
            itemBuilder: (context, groupIdx) {
              final groupKey = grouped.keys.elementAt(groupIdx);
              final items = grouped[groupKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Text(
                      groupKey,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface.withValues(alpha: 0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ...items.map((n) {
                    final isLive = n.notificationType == 'live_starting' ||
                        n.notificationType == 'live_reminder';

                    return Dismissible(
                      key: ValueKey(n.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: cs.surfaceContainerHighest,
                        child: Icon(
                          Icons.done,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      onDismissed: (_) async {
                        await ref.read(notificationRepositoryProvider).markRead(n.id);
                        ref.invalidate(notificationsProvider);
                        ref.invalidate(unreadCountProvider);
                      },
                      child: Container(
                        color: n.isRead ? Colors.transparent : BuddyColors.green.withValues(alpha: 0.05),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: n.isRead
                                ? cs.surfaceContainerHighest
                                : BuddyColors.green.withValues(alpha: 0.2),
                            child: Icon(
                              _notificationIcon(n.notificationType),
                              color: n.isRead ? cs.onSurface.withValues(alpha: 0.6) : BuddyColors.green,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            n.title,
                            style: TextStyle(
                              fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: cs.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              if (isLive) ...[
                                const SizedBox(height: 6),
                                _LiveCountdown(
                                  scheduledFor: n.metadata?['scheduled_for'] as String?,
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (n.isPinned)
                                const Icon(Icons.push_pin,
                                    size: 13, color: BuddyColors.gold),
                              const SizedBox(width: 4),
                              Text(
                                _timeAgo(n.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _handleNotificationTap(n),
                          onLongPress: () => _showActionsSheet(n),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
        loading: () => const ShimmerList(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  IconData _notificationIcon(String type) {
    switch (type) {
      case 'like':
      case 'post_reaction':
        return Icons.favorite;
      case 'comment':
      case 'comment_reply':
        return Icons.comment;
      case 'follow':
      case 'new_follower':
        return Icons.person_add;
      case 'buddy_request':
      case 'buddy_accepted':
        return Icons.handshake;
      case 'repost':
      case 'post_repost':
      case 'post_quote':
        return Icons.repeat;
      case 'mention':
        return Icons.alternate_email;
      case 'live_start':
      case 'live_starting':
      case 'live_reminder':
        return Icons.videocam;
      case 'community_invite':
      case 'community_member':
      case 'community_join_request':
      case 'community_join_approved':
        return Icons.groups;
      case 'event_ticket_purchased':
        return Icons.confirmation_number;
      case 'order_status_changed':
      case 'new_purchase':
        return Icons.shopping_bag;
      case 'payout_processed':
      case 'withdrawal_processed':
      case 'payment_received':
        return Icons.payments;
      case 'session_booked':
      case 'session_reminder':
      case 'session_cancelled':
        return Icons.calendar_month;
      case 'streak_milestone':
      case 'streak_reminder':
        return Icons.whatshot;
      case 'gym_update':
      case 'gym_invite':
        return Icons.fitness_center;
      default:
        return Icons.notifications;
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
