import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/messaging.dart';
import '../../../shared/widgets/error_view.dart';
import '../messaging/providers/messaging_provider.dart';
import '../messaging/widgets/conversation_tile.dart';

/// Buddy messages — the threads that came out of Find a Buddy.
///
/// Same provider, same [ConversationTile] and same thread screen as the main
/// Messages tab; the only difference is [ConversationFilter.discovery], which
/// narrows the list client-side so both screens read one server payload.
class BuddyMessagesScreen extends ConsumerStatefulWidget {
  const BuddyMessagesScreen({super.key});

  @override
  ConsumerState<BuddyMessagesScreen> createState() => _BuddyMessagesScreenState();
}

class _BuddyMessagesScreenState extends ConsumerState<BuddyMessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsProvider.notifier).load(filter: ConversationFilter.discovery);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationsProvider);
    final conversations = state.conversations;
    final pending = conversations.where((c) => c.promotionStatus == 'pending').length;
    final myUserId = ref.read(authProvider).user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buddy messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.person_search, size: 15, color: BuddyColors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pending > 0
                        ? 'You asked $pending ${pending == 1 ? 'buddy' : 'buddies'} to make it official — waiting on them.'
                        : 'Chats you started from Find a Buddy. Promote one to become buddies.',
                    style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.isLoading && conversations.isEmpty
                ? const Center(child: CircularProgressIndicator(color: BuddyColors.green))
                : state.error != null
                    ? ErrorView(
                        message: state.error!,
                        onRetry: () => ref
                            .read(conversationsProvider.notifier)
                            .load(filter: ConversationFilter.discovery),
                      )
                    : conversations.isEmpty
                        ? const _Empty()
                        : RefreshIndicator(
                            onRefresh: () => ref
                                .read(conversationsProvider.notifier)
                                .load(filter: ConversationFilter.discovery),
                            child: ListView.builder(
                              itemCount: conversations.length,
                              itemBuilder: (_, i) => _BuddyConversationTile(
                                conversation: conversations[i],
                                myUserId: myUserId,
                                onTap: () => context.push('/buddies/messages/${conversations[i].id}'),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

/// [ConversationTile] plus the promotion state, so a request you sent (or one
/// they sent you) is visible in the list and not only inside the thread.
class _BuddyConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String? myUserId;
  final VoidCallback onTap;

  const _BuddyConversationTile({
    required this.conversation,
    required this.myUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConversationTile(
          conversation: conversation,
          myUserId: myUserId,
          onTap: onTap,
        ),
        _PromotionStrip(conversation: conversation),
      ],
    );
  }
}

class _PromotionStrip extends StatelessWidget {
  final Conversation conversation;

  const _PromotionStrip({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final status = conversation.promotionStatus;
    if (status == 'accepted') {
      return const _Strip(
        icon: Icons.check_circle_outline,
        color: BuddyColors.green,
        label: 'Now buddies',
      );
    }
    if (status == 'declined') {
      return const _Strip(
        icon: Icons.remove_circle_outline,
        color: BuddyColors.textSecondary,
        label: 'Buddy request declined',
      );
    }
    if (status == 'pending') {
      return const _Strip(
        icon: Icons.hourglass_top,
        color: BuddyColors.gold,
        label: 'Buddy request pending — waiting on them',
      );
    }
    if (!conversation.promotable) return const SizedBox.shrink();
    return const _Strip(
      icon: Icons.handshake_outlined,
      color: BuddyColors.textSecondary,
      label: 'Tap to promote to buddies',
    );
  }
}

class _Strip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _Strip({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(84, 0, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 56, color: BuddyColors.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              'No buddy chats yet',
              style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Message someone from Find a Buddy and the conversation lands here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/buddies/nearby'),
              child: const Text('Find a buddy'),
            ),
          ],
        ),
      ),
    );
  }
}