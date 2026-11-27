import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_provider.dart';
import '../providers/messaging_provider.dart';
import '../providers/inbox_providers.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/story_strip.dart';
import '../widgets/story_viewer.dart';
import '../utils/conversation_identity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/messaging.dart';
import '../../../shared/navigation/app_nav.dart';
import '../../../shared/widgets/avatar.dart';

/// Messages surface — four tabs: Messages (real threads), Community threads,
/// Calls (history with Rejoin), Stories (buddies + followed moments).
class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  final _searchController = TextEditingController();
  String _listTab = 'messages';
  Set<String> _seenStories = {};
  bool _communitiesLoaded = false;
  bool _callsLoaded = false;

  String? get _myUserId => ref.read(authProvider).user?.id;

  static const _tabs = [
    ('messages', 'Messages'),
    ('archived', 'Archived'),
    ('communities', 'Community'),
    ('calls', 'Calls'),
    ('stories', 'Stories'),
  ];

  @override
  void initState() {
    super.initState();
    ref.listenManual<AuthState>(authProvider, (previous, next) {
      if (previous?.isLoading == true &&
          !next.isLoading &&
          next.isAuthenticated) {
        _loadInbox();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(authProvider).isLoading) _loadInbox();
      loadSeenStories().then((ids) {
        if (mounted) setState(() => _seenStories = ids);
      });
    });
  }

  void _loadInbox() {
    if (!ref.read(authProvider).isAuthenticated) return;
    ref.read(conversationsProvider.notifier).load(clearFilter: true);
    ref.read(storiesProvider.notifier).load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openTab(String tab) {
    setState(() => _listTab = tab);
    if (tab == 'messages' || tab == 'archived') {
      ref
          .read(conversationsProvider.notifier)
          .load(clearFilter: true, archived: tab == 'archived');
    } else if (tab == 'communities' && !_communitiesLoaded) {
      _communitiesLoaded = true;
      ref.read(communityConversationsProvider.notifier).load();
    } else if (tab == 'calls' && !_callsLoaded) {
      _callsLoaded = true;
      ref.read(callHistoryProvider.notifier).load();
    } else if (tab == 'stories') {
      // Refresh the strip every time the tab opens — stories expire in 24h.
      ref.read(storiesProvider.notifier).load();
    }
  }

  Future<void> _openStory(int reelIndex) async {
    final reels = ref.read(storiesProvider).reels;
    if (reelIndex < 0 || reelIndex >= reels.length) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => StoryViewer(
          reels: reels,
          initialReelIndex: reelIndex,
          seenIds: Set<String>.from(_seenStories),
        ),
      ),
    );
    // The viewer mutates the seen set passed to it; re-read it so the ring
    // turns grey for what was watched.
    final ids = await loadSeenStories();
    if (mounted) setState(() => _seenStories = ids);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase().trim();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
          onPressed: () => AppNav.open(context),
        ),
        title: Text(
          _listTab == 'archived' ? 'Archived' : 'Messages',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'New conversation',
            onPressed: () => _showNewConversationSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar: messages / communities / calls / stories
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: BuddyColors.surface,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Row(
                children: [
                  for (final (key, label) in _tabs)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openTab(key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _listTab == key
                                ? Theme.of(context).colorScheme.surface
                                : Colors.transparent,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _listTab == key
                                  ? BuddyColors.green
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_listTab != 'stories')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: _listTab == 'calls'
                      ? 'Search calls...'
                      : _listTab == 'communities'
                      ? 'Search communities...'
                      : 'Search conversations...',
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          if (_listTab == 'messages')
            Consumer(
              builder: (context, ref, _) {
                final stories = ref.watch(storiesProvider);
                return StoryStrip(
                  reels: stories.reels,
                  seenIds: _seenStories,
                  onOpen: _openStory,
                  onAddStory: () => context.go('/messages/story/create'),
                );
              },
            ),
          Expanded(
            child: switch (_listTab) {
              'communities' => _CommunityTab(query: query, myUserId: _myUserId),
              'calls' => _CallsTab(query: query),
              'stories' => _StoriesTab(
                seenIds: _seenStories,
                onOpen: _openStory,
                onAddStory: () => context.go('/messages/story/create'),
              ),
              _ => _MessagesTab(
                query: query,
                myUserId: _myUserId,
                onNewConversation: () => _showNewConversationSheet(context),
              ),
            },
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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'New Conversation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
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
                  final result = await repo.startConversation({
                    'participants': [value.trim()],
                  });
                  final data = result['data'] as Map<String, dynamic>;
                  final convo = Conversation.fromJson(data);
                  ref
                      .read(conversationsProvider.notifier)
                      .updateConversation(convo);
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

/// ── Messages tab ─────────────────────────────────────────────────────────────

class _MessagesTab extends ConsumerWidget {
  final String query;
  final String? myUserId;
  final VoidCallback onNewConversation;

  const _MessagesTab({
    required this.query,
    required this.myUserId,
    required this.onNewConversation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversationsProvider);
    final conversations = state.conversations;
    final filtered = query.isEmpty
        ? conversations
        : conversations
              .where((c) => conversationSearchText(c).contains(query))
              .toList();

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: BuddyColors.green),
      );
    }
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref
                  .read(conversationsProvider.notifier)
                  .load(clearFilter: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              query.isEmpty ? 'No conversations yet' : 'No conversations found',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (query.isEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onNewConversation,
                child: const Text('Start a conversation'),
              ),
            ],
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: BuddyColors.green,
      onRefresh: () =>
          ref.read(conversationsProvider.notifier).load(clearFilter: true),
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final convo = filtered[i];
          return ConversationTile(
            conversation: convo,
            myUserId: myUserId,
            onTap: () => context.push('/messages/${convo.id}'),
          );
        },
      ),
    );
  }
}

/// ── Community tab ────────────────────────────────────────────────────────────

class _CommunityTab extends ConsumerWidget {
  final String query;
  final String? myUserId;

  const _CommunityTab({required this.query, required this.myUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(communityConversationsProvider);
    final filtered = query.isEmpty
        ? state.conversations
        : state.conversations
              .where((c) => conversationSearchText(c).contains(query))
              .toList();

    if (state.isLoading && state.conversations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: BuddyColors.green),
      );
    }
    if (state.error != null && state.conversations.isEmpty) {
      return Center(
        child: TextButton(
          onPressed: () =>
              ref.read(communityConversationsProvider.notifier).load(),
          child: const Text('Retry loading communities'),
        ),
      );
    }
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 56,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 12),
            Text(
              'No communities yet. Join one from the Communities page.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: BuddyColors.green,
      onRefresh: () => ref.read(communityConversationsProvider.notifier).load(),
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final convo = filtered[i];
          return ConversationTile(
            conversation: convo,
            myUserId: myUserId,
            onTap: () => context.push('/messages/${convo.id}'),
          );
        },
      ),
    );
  }
}

/// ── Calls tab ────────────────────────────────────────────────────────────────

class _CallsTab extends ConsumerWidget {
  final String query;

  const _CallsTab({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callHistoryProvider);
    final entries = query.isEmpty
        ? state.entries
        : state.entries
              .where(
                (c) => '${c.conversationLabel} ${c.counterpartName}'
                    .toLowerCase()
                    .contains(query),
              )
              .toList();

    if (state.isLoading && state.entries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: BuddyColors.green),
      );
    }
    if (state.error != null && state.entries.isEmpty) {
      return Center(
        child: TextButton(
          onPressed: () => ref.read(callHistoryProvider.notifier).load(),
          child: const Text('Retry loading calls'),
        ),
      );
    }
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.phone_outlined,
              size: 56,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 12),
            Text(
              'No calls yet. Start one from any chat.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: BuddyColors.green,
      onRefresh: () => ref.read(callHistoryProvider.notifier).load(),
      child: ListView.separated(
        itemCount: entries.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 0.5, color: BuddyColors.border),
        itemBuilder: (_, i) => _CallRow(entry: entries[i]),
      ),
    );
  }
}

class _CallRow extends StatelessWidget {
  final CallHistoryEntry entry;

  const _CallRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final missed = entry.status == 'missed' || entry.status == 'declined';
    final isVideo = entry.callType == 'video';
    final when = DateTime.tryParse(entry.createdAt)?.toLocal();
    final now = DateTime.now();
    final sameDay =
        when != null &&
        when.year == now.year &&
        when.month == now.month &&
        when.day == now.day;
    final whenLabel = when == null
        ? ''
        : sameDay
        ? TimeOfDay.fromDateTime(when).format(context)
        : '${when.month}/${when.day}';
    final dur =
        '${entry.durationSeconds ~/ 60}:${(entry.durationSeconds % 60).toString().padLeft(2, '0')}';
    final active = entry.activeCall;
    final canRejoin =
        active != null &&
        (active['status'] == 'ringing' || active['status'] == 'active');

    return InkWell(
      onTap: () => context.push('/messages/${entry.conversationId}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: missed
                  ? BuddyColors.red.withValues(alpha: 0.12)
                  : BuddyColors.green.withValues(alpha: 0.12),
              child: Icon(
                isVideo ? Icons.videocam_outlined : Icons.phone_outlined,
                color: missed ? BuddyColors.red : BuddyColors.green,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.counterpartName.isNotEmpty
                              ? entry.counterpartName
                              : entry.conversationLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (canRejoin)
                        GestureDetector(
                          onTap: () {
                            final type = active['call_type'] == 'video'
                                ? 'video'
                                : 'audio';
                            context.push(
                              '/messages/${entry.conversationId}?call=$type',
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: BuddyColors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 11,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Rejoin',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        whenLabel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        entry.isOutgoing
                            ? Icons.call_made
                            : Icons.call_received,
                        size: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${missed ? (entry.status == 'declined' ? 'Declined' : 'Missed') : 'Answered'} · $dur',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entry.conversationLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
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

/// ── Stories tab ─────────────────────────────────────────────────────────────

class _StoriesTab extends ConsumerWidget {
  final Set<String> seenIds;
  final void Function(int reelIndex) onOpen;
  final VoidCallback? onAddStory;

  const _StoriesTab({
    required this.seenIds,
    required this.onOpen,
    this.onAddStory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storiesProvider);

    if (state.isLoading && state.reels.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: BuddyColors.green),
      );
    }
    if (state.reels.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: BuddyColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                size: 26,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No stories right now.\nBuddies and people you follow show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: BuddyColors.green,
      onRefresh: () => ref.read(storiesProvider.notifier).load(),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 3 / 4,
        ),
        itemCount: state.reels.length + (onAddStory != null ? 1 : 0),
        itemBuilder: (_, i) {
          if (onAddStory != null && i == 0) {
            return Semantics(
              label: 'Add your story',
              button: true,
              child: GestureDetector(
                onTap: onAddStory,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: BuddyColors.surface),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: const BoxDecoration(
                                color: BuddyColors.surfaceRaised,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 28,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add story',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          final reel = state.reels[onAddStory != null ? i - 1 : i];
          final first = reel.stories.first;
          final thumb = first.mediaUrls.isNotEmpty ? first.mediaUrls.first : '';
          return GestureDetector(
            onTap: () => onOpen(i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumb.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: thumb,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) =>
                          const ColoredBox(color: BuddyColors.surface),
                    )
                  else
                    const ColoredBox(color: BuddyColors.surface),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: BuddyColors.green,
                      ),
                      child: Avatar(
                        src: reel.user.avatarUrl,
                        alt: reel.user.displayName,
                        size: AvatarSize.xs,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 6,
                    right: 6,
                    bottom: 5,
                    child: Text(
                      reel.user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
