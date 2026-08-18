import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/messaging.dart';
import '../providers/community_provider.dart';

class CommunityDetailScreen extends ConsumerStatefulWidget {
  const CommunityDetailScreen({super.key, required this.communityId});

  final String communityId;

  @override
  ConsumerState<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen> {
  final _postController = TextEditingController();
  int _tab = 0;
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(communityFeedProvider(widget.communityId).notifier);
      notifier.loadPosts();
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _refresh() {
    final notifier = ref.read(communityFeedProvider(widget.communityId).notifier);
    notifier.refresh();
    notifier.loadPosts();
  }

  Future<void> _toggleLike(String postId) async {
    await ref.read(communityFeedProvider(widget.communityId).notifier).toggleLike(postId);
  }

  Future<void> _addComment(String postId, String body) async {
    await ref.read(communityFeedProvider(widget.communityId).notifier).addComment(postId, body);
  }

  Future<void> _commentSheet(CommunityPost post) async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BuddyColors.surface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...post.comments.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.person_outline, size: 18, color: BuddyColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${c.authorData.displayName}: ${c.body}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Write a comment...'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: BuddyColors.green),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      _addComment(post.id, controller.text.trim());
                      controller.clear();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _postCard(CommunityPost post, bool canManage) {
    return Card(
      color: BuddyColors.surfaceRaised,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: BuddyColors.surface,
                  backgroundImage: post.authorData.avatarUrl.isNotEmpty
                      ? NetworkImage(post.authorData.avatarUrl)
                      : null,
                  child: post.authorData.avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 18, color: BuddyColors.green)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorData.displayName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('@${post.authorData.username}',
                          style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
                    ],
                  ),
                ),
                if (post.isPinned)
                  const Icon(Icons.push_pin, size: 16, color: BuddyColors.gold),
              ],
            ),
            if (post.body.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(post.body, style: const TextStyle(fontSize: 14)),
            ],
            if (post.mediaUrl.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(post.mediaUrl,
                    height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  iconSize: 20,
                  onPressed: () => _toggleLike(post.id),
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? BuddyColors.red : BuddyColors.textSecondary,
                  ),
                ),
                Text('${post.likeCount}'),
                const SizedBox(width: 20),
                IconButton(
                  iconSize: 20,
                  onPressed: () => _commentSheet(post),
                  icon: const Icon(Icons.chat_bubble_outline, color: BuddyColors.textSecondary),
                ),
                Text('${post.commentCount}'),
                const Spacer(),
                if (canManage)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: BuddyColors.textSecondary),
                    onSelected: (v) async {
                      if (v == 'pin') {
                        await ref
                            .read(communityFeedProvider(widget.communityId).notifier)
                            .updatePost(post.id, {'is_pinned': !post.isPinned});
                      } else if (v == 'delete') {
                        await ref
                            .read(communityFeedProvider(widget.communityId).notifier)
                            .deletePost(post.id);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'pin',
                        child: Text(post.isPinned ? 'Unpin' : 'Pin post'),
                      ),
                      const PopupMenuItem(value: 'delete', child: Text('Delete post')),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _settingsSheet(CommunityDetail detail) async {
    final name = TextEditingController(text: detail.groupName);
    final desc = TextEditingController(text: detail.description);
    var isPublic = detail.isPublic;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BuddyColors.surface,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Community Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 12),
                TextField(
                  controller: desc,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: isPublic,
                      onChanged: (v) => setSheetState(() => isPublic = v ?? true),
                    ),
                    const Text('Public community'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: BuddyColors.green, foregroundColor: BuddyColors.black),
                    onPressed: () {
                      ref.read(communityFeedProvider(widget.communityId).notifier).updateSettings(
                            name.text.trim(),
                            desc.text.trim(),
                            isPublic,
                          );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    _refresh();
  }

  Future<void> _inviteSheet(CommunityDetail detail) async {
    final messenger = ScaffoldMessenger.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: BuddyColors.surface,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Invite Members',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: BuddyColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                detail.inviteCode,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Invite code copied')),
                );
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy code'),
            ),
            if (detail.myRole == 'owner' || detail.myRole == 'admin') ...[
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  ref.read(communityFeedProvider(widget.communityId).notifier).rotateInvite();
                  Navigator.pop(ctx);
                },
                child: const Text('Generate new code'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _membersList(CommunityDetail detail) {
    return ListView(
      children: detail.members.map((m) {
        final isOwner = detail.myRole == 'owner';
        return Card(
          color: BuddyColors.surfaceRaised,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: BuddyColors.surface,
              backgroundImage: m.avatarUrl.isNotEmpty ? NetworkImage(m.avatarUrl) : null,
              child: m.avatarUrl.isEmpty
                  ? const Icon(Icons.person, color: BuddyColors.green)
                  : null,
            ),
            title: Text(m.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('@${m.username}', style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (m.role == 'owner')
                  const Icon(Icons.shield_outlined, size: 18, color: BuddyColors.gold)
                else if (m.role == 'admin')
                  const Icon(Icons.shield_outlined, size: 18, color: BuddyColors.green)
                else
                  const Text('Member', style: TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
                if (isOwner && m.role != 'owner')
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: BuddyColors.textSecondary),
                    onSelected: (v) {
                      final n = ref.read(communityFeedProvider(widget.communityId).notifier);
                      if (v == 'promote') n.setRole(m.userId, 'admin');
                      if (v == 'demote') n.setRole(m.userId, 'member');
                      if (v == 'transfer') n.transferOwnership(m.userId);
                      if (v == 'remove') n.removeMember(m.userId);
                    },
                    itemBuilder: (_) => [
                      if (m.role == 'member')
                        const PopupMenuItem(value: 'promote', child: Text('Make admin'))
                      else
                        const PopupMenuItem(value: 'demote', child: Text('Demote to member')),
                      const PopupMenuItem(value: 'transfer', child: Text('Transfer ownership')),
                      const PopupMenuItem(value: 'remove', child: Text('Remove member')),
                    ],
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(communityFeedProvider(widget.communityId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: BuddyColors.green)),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: BuddyColors.textSecondary))),
        data: (state) {
          final detail = state.detail;
          if (detail == null) {
            return const Center(child: Text('Community not found'));
          }
          final role = detail.myRole;
          final canManage = role == 'owner' || role == 'admin';
          final isMember = detail.myRole != null;
          return Column(
            children: [
              Container(
                height: 130,
                width: double.infinity,
                color: BuddyColors.surfaceRaised,
                child: detail.coverUrl.isNotEmpty
                    ? Image.network(detail.coverUrl, fit: BoxFit.cover)
                    : const Icon(Icons.groups_outlined, size: 56, color: BuddyColors.green),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(detail.groupName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        if (canManage)
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, size: 20),
                            onPressed: () => _settingsSheet(detail),
                          ),
                        if (isMember)
                          IconButton(
                            icon: const Icon(Icons.link, size: 20),
                            onPressed: () => _inviteSheet(detail),
                          ),
                      ],
                    ),
                    if (detail.description.isNotEmpty)
                      Text(detail.description,
                          style: const TextStyle(color: BuddyColors.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('${detail.memberCount} members',
                            style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
                        const SizedBox(width: 12),
                        if (detail.myRole != null)
                          Text(detail.myRole!.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 11, color: BuddyColors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (!isMember) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: BuddyColors.green, foregroundColor: BuddyColors.black),
                          onPressed: _joining
                              ? null
                              : () async {
                                  setState(() => _joining = true);
                                  await ref
                                      .read(communityFeedProvider(widget.communityId).notifier)
                                      .join();
                                  if (mounted) setState(() => _joining = false);
                                },
                          child: Text(_joining ? 'Joining...' : 'Join Community'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(color: BuddyColors.surface),
                child: Row(
                  children: [
                    _tabButton(0, 'Feed', detail, canManage),
                    _tabButton(1, 'Members', detail, canManage),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _tab == 0 ? _feedTab(state, canManage) : _membersList(detail),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tabButton(int index, String label, CommunityDetail detail, bool canManage) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _tab == index ? BuddyColors.green : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _tab == index ? BuddyColors.green : BuddyColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _feedTab(CommunityFeedState state, bool canManage) {
    final isMember = state.detail?.myRole != null;
    return Column(
      children: [
        if (isMember)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Share something with the community...',
                      filled: true,
                      fillColor: BuddyColors.surfaceRaised,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: BuddyColors.green, foregroundColor: BuddyColors.black),
                  icon: const Icon(Icons.send, size: 18),
                  onPressed: () async {
                    if (_postController.text.trim().isEmpty) return;
                    await ref
                        .read(communityFeedProvider(widget.communityId).notifier)
                        .createPost(_postController.text.trim());
                    _postController.clear();
                  },
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(communityFeedProvider(widget.communityId).notifier).refresh();
              await ref.read(communityFeedProvider(widget.communityId).notifier).loadPosts();
            },
            child: state.posts.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      Icon(Icons.forum_outlined, size: 48, color: BuddyColors.textSecondary),
                      SizedBox(height: 8),
                      Center(child: Text('No posts yet', style: TextStyle(color: BuddyColors.textSecondary))),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: state.posts.map((p) => _postCard(p, canManage)).toList(),
                  ),
          ),
        ),
      ],
    );
  }
}