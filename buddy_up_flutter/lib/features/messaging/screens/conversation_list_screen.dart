import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_provider.dart';
import '../providers/messaging_provider.dart';
import '../widgets/conversation_tile.dart';
import '../utils/conversation_identity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/messaging.dart';
import '../../../shared/navigation/app_nav.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends ConsumerState<ConversationListScreen> {
  final _searchController = TextEditingController();

  String? get _myUserId => ref.read(authProvider).user?.id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationsProvider);
    final conversations = state.conversations;
    final query = _searchController.text.toLowerCase().trim();

    final filtered = query.isEmpty
        ? conversations
        : conversations.where((c) => conversationSearchText(c).contains(query)).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
          onPressed: () => AppNav.open(context),
        ),
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showNewConversationSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search, size: 20, color: BuddyColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: BuddyColors.green))
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: BuddyColors.textSecondary),
                            const SizedBox(height: 12),
                            Text(state.error!, style: const TextStyle(color: BuddyColors.textSecondary)),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => ref.read(conversationsProvider.notifier).load(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 64, color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  query.isEmpty ? 'No conversations yet' : 'No conversations found',
                                  style: const TextStyle(color: BuddyColors.textSecondary),
                                ),
                                if (query.isEmpty) ...[
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () => _showNewConversationSheet(context),
                                    child: const Text('Start a conversation'),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.read(conversationsProvider.notifier).load(),
                            child: ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final convo = filtered[i];
                                return ConversationTile(
                                  conversation: convo,
                                  myUserId: _myUserId,
                                  onTap: () => context.push('/messages/${convo.id}'),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  void _showNewConversationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: BuddyColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'New Conversation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: BuddyColors.textPrimary),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter username...',
                prefixIcon: Icon(Icons.person_outline, size: 20),
              ),
              onSubmitted: (value) async {
                if (value.trim().isEmpty) return;
                Navigator.pop(context);
                try {
                  final repo = ref.read(messagingRepositoryProvider);
                  final result = await repo.startConversation({'participant_usernames': [value.trim()]});
                  final data = result['data'] as Map<String, dynamic>;
                  final convo = Conversation.fromJson(data);
                  ref.read(conversationsProvider.notifier).updateConversation(convo);
                  if (context.mounted) context.push('/messages/${convo.id}');
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: ${e.toString()}')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
