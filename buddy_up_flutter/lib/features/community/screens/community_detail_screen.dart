import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/messaging.dart';
import '../../../data/models/post.dart';
import '../../feed/widgets/post_card.dart';
import '../../feed/screens/post_composer_screen.dart';
import '../providers/community_provider.dart';
import 'community_settings_screen.dart';
import 'community_members_screen.dart';

extension CommunityPostToPost on CommunityPost {
  Post toPost() {
    return Post(
      id: id,
      authorData: AuthorData(
        userId: authorId,
        username: authorData.username,
        displayName: authorData.displayName.isNotEmpty ? authorData.displayName : authorData.username,
        avatarUrl: authorData.avatarUrl,
        verificationStatus: authorData.role,
      ),
      body: body,
      mediaUrls: mediaUrl.isNotEmpty ? [mediaUrl] : const [],
      reactionCounts: isLiked ? {'heart': likeCount} : (likeCount > 0 ? {'heart': likeCount} : const {}),
      userReaction: isLiked ? 'heart' : null,
      commentCount: commentCount,
      isPinned: isPinned,
      createdAt: createdAt,
    );
  }
}

class CommunityDetailScreen extends ConsumerStatefulWidget {
  const CommunityDetailScreen({super.key, required this.communityId});

  final String communityId;

  @override
  ConsumerState<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen> {
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

  Future<void> _openPostComposer(String communityName) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostComposerScreen(
          communityId: widget.communityId,
          communityName: communityName,
          onPostCreated: _refresh,
        ),
      ),
    );
  }

  Future<void> _showJoinDialog() async {
    final codeController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join Community'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the community invite code or tap Join to proceed:'),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'Invite Code (e.g. FIT99X)',
                labelText: 'Invite Code',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Join'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      setState(() => _joining = true);
      try {
        final code = codeController.text.trim();
        if (code.isNotEmpty) {
          await ref.read(communitiesListProvider.notifier).joinByCode(code);
        } else {
          await ref.read(communityFeedProvider(widget.communityId).notifier).join();
        }
        _refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Join failed: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _joining = false);
      }
    }
  }

  Future<void> _showInviteSheet(CommunityDetail detail) async {
    final inviteLink = 'buddyup://join/community/${widget.communityId}';
    final cs = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Invite to Community', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Share this code or link with friends to let them join ${detail.groupName}.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Large 6-8 Char Monospace Code Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: [
                  Text(
                    'INVITE CODE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail.inviteCode.isNotEmpty ? detail.inviteCode : 'BUDDY26',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      fontFamily: 'monospace',
                      color: BuddyColors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Copy Link & Copy Code buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Code'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: detail.inviteCode));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invite code copied to clipboard!')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Share Link'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: inviteLink));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Community invite link copied!')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _commentSheet(CommunityPost post) async {
    final controller = TextEditingController();
    final cs = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
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
            const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...post.comments.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.person_outline, size: 18, color: cs.onSurface.withValues(alpha: 0.6)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${c.authorData.displayName}: ${c.body}',
                        style: TextStyle(fontSize: 13, color: cs.onSurface),
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
                      Navigator.pop(ctx);
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

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(communityFeedProvider(widget.communityId));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: asyncState.value?.detail?.myRole != null && _tab == 0
          ? FloatingActionButton(
              backgroundColor: BuddyColors.green,
              foregroundColor: BuddyColors.black,
              onPressed: () => _openPostComposer(asyncState.value?.detail?.groupName ?? 'Community'),
              child: const Icon(Icons.add),
            )
          : null,
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: BuddyColors.green)),
        error: (e, _) => Center(child: Text('$e', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)))),
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
                color: cs.surfaceContainerHighest,
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
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface)),
                        ),
                        if (canManage)
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, size: 20),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CommunitySettingsScreen(
                                  communityId: widget.communityId,
                                  initialName: detail.groupName,
                                  initialDescription: detail.description,
                                  initialIsPublic: detail.isPublic,
                                  initialCoverUrl: detail.coverUrl,
                                ),
                              ),
                            ),
                          ),
                        if (isMember)
                          IconButton(
                            icon: const Icon(Icons.share_outlined, size: 20),
                            onPressed: () => _showInviteSheet(detail),
                          ),
                      ],
                    ),
                    if (detail.description.isNotEmpty)
                      Text(detail.description,
                          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CommunityMembersScreen(
                                communityId: widget.communityId,
                                canManage: canManage,
                              ),
                            ),
                          ),
                          child: Text('${detail.memberCount} members · View All',
                              style: const TextStyle(fontSize: 12, color: BuddyColors.green, fontWeight: FontWeight.w600)),
                        ),
                        const Spacer(),
                        if (detail.myRole != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: BuddyColors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(detail.myRole!.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 10, color: BuddyColors.green, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    if (!isMember) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _joining ? null : _showJoinDialog,
                          child: Text(_joining ? 'Joining...' : 'Join Community'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(color: cs.surface),
                child: Row(
                  children: [
                    _tabButton(0, 'Feed', detail, canManage),
                    _tabButton(1, 'Members', detail, canManage),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _tab == 0
                    ? _feedTab(state, canManage)
                    : CommunityMembersScreen(
                        communityId: widget.communityId,
                        canManage: canManage,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tabButton(int index, String label, CommunityDetail detail, bool canManage) {
    final cs = Theme.of(context).colorScheme;
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
                color: _tab == index ? BuddyColors.green : cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _feedTab(CommunityFeedState state, bool canManage) {
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(communityFeedProvider(widget.communityId).notifier).refresh();
        await ref.read(communityFeedProvider(widget.communityId).notifier).loadPosts();
      },
      child: state.posts.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                Icon(Icons.forum_outlined, size: 48, color: cs.onSurface.withValues(alpha: 0.4)),
                const SizedBox(height: 8),
                Center(child: Text('No posts yet in this community', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)))),
              ],
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: state.posts.map((p) {
                return PostCard(
                  post: p.toPost(),
                  onLike: (_) => _toggleLike(p.id),
                  onComment: (_) => _commentSheet(p),
                  onPin: canManage
                      ? (_) async {
                          await ref
                              .read(communityFeedProvider(widget.communityId).notifier)
                              .updatePost(p.id, {'is_pinned': !p.isPinned});
                        }
                      : null,
                  onDelete: canManage
                      ? (_) async {
                          await ref
                              .read(communityFeedProvider(widget.communityId).notifier)
                              .deletePost(p.id);
                        }
                      : null,
                );
              }).toList(),
            ),
    );
  }
}