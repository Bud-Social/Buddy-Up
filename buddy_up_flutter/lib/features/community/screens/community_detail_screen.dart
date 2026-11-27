import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/messaging.dart';
import '../../feed/widgets/post_card.dart';
import '../../feed/screens/post_composer_screen.dart';
import '../providers/community_provider.dart';
import '../providers/community_activities_provider.dart';
import '../providers/community_gym_requests_provider.dart';
import '../widgets/community_post_card.dart';
import 'community_settings_screen.dart';
import 'community_members_screen.dart';
import 'community_activities_screen.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/toast.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Tab kind for community navigation.
enum _CommunityTabKind { all, single }

/// A tab entry: either "All" (aggregated feed) or a specific community.
class _CommunityTab {
  final _CommunityTabKind kind;
  final CommunityDetail? community;

  _CommunityTab.all() : kind = _CommunityTabKind.all, community = null;
  _CommunityTab.community(this.community) : kind = _CommunityTabKind.single;

  String get label => kind == _CommunityTabKind.all
      ? 'All'
      : (community?.groupName ?? 'Community');
  String? get id => kind == _CommunityTabKind.all ? null : community?.id;
}

class CommunityDetailScreen extends ConsumerStatefulWidget {
  const CommunityDetailScreen({super.key, required this.communityId});

  final String communityId;

  @override
  ConsumerState<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen> {
  int _tab = 0;
  bool _joining = false;
  List<CommunityDetail> _userCommunities = [];
  int _selectedCommunityTab = 0; // 0 = All, 1+ = individual community
  final TextEditingController _memberSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserCommunities();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(
        communityFeedProvider(widget.communityId).notifier,
      );
      notifier.loadPosts();
      // Pre-load the aggregated feed so the "All" tab has data immediately.
      notifier.loadAllPosts();
    });
  }

  @override
  void dispose() {
    _memberSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserCommunities() async {
    try {
      final raw = await ref.read(communityRepositoryProvider).getCommunities();
      // API returns {success, data: {mine: [...], discover: [...]}}
      final data = raw['data'] as Map<String, dynamic>?;
      final mine = data?['mine'] as List? ?? [];
      final communities = mine
          .map((c) => CommunityDetail.fromJson(c as Map<String, dynamic>))
          .toList();
      if (mounted) setState(() => _userCommunities = communities);
    } catch (_) {}
  }

  List<_CommunityTab> get _tabs {
    return [
      _CommunityTab.all(),
      ..._userCommunities.map((c) => _CommunityTab.community(c)),
    ];
  }

  CommunityDetail? get _selectedCommunity {
    if (_selectedCommunityTab == 0) return null;
    final idx = _selectedCommunityTab - 1;
    if (idx >= 0 && idx < _userCommunities.length) return _userCommunities[idx];
    return null;
  }

  void _refresh() {
    final notifier = ref.read(
      communityFeedProvider(widget.communityId).notifier,
    );
    notifier.refresh();
    notifier.loadPosts();
  }

  Future<void> _toggleLike(String communityId, String postId) async {
    await ref
        .read(communityFeedProvider(communityId).notifier)
        .toggleLike(postId);
  }

  Future<void> _toggleRepost(String communityId, String postId) async {
    await ref.read(communityFeedProvider(communityId).notifier).repost(postId);
  }

  Future<void> _toggleSave(String communityId, String postId) async {
    await ref.read(communityFeedProvider(communityId).notifier).save(postId);
  }

  Future<void> _handleReact(
    String communityId,
    String postId,
    String reaction,
  ) async {
    await ref
        .read(communityFeedProvider(communityId).notifier)
        .react(postId, reaction);
  }

  Future<void> _toggleShare(String postId) async {
    await ref
        .read(communityFeedProvider(widget.communityId).notifier)
        .share(postId);
  }

  Future<void> _addComment(
    String communityId,
    String postId,
    String body,
  ) async {
    await ref
        .read(communityFeedProvider(communityId).notifier)
        .addComment(postId, body);
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
            const Text(
              'Enter the community invite code or tap Join to proceed:',
            ),
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
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
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
          await ref
              .read(communityFeedProvider(widget.communityId).notifier)
              .join();
        }
        _refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Join failed: $e')));
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
            const Text(
              'Invite to Community',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Share this code or link with friends to let them join ${detail.groupName}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
              ),
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
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail.inviteCode.isNotEmpty
                        ? detail.inviteCode
                        : 'BUDDY26',
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
                    icon: const Icon(LucideIcons.copy, size: 16),
                    label: const Text('Copy Code'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: detail.inviteCode));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invite code copied to clipboard!'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(LucideIcons.share2, size: 16),
                    label: const Text('Share Link'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: inviteLink));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Community invite link copied!'),
                        ),
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

  Future<void> _commentSheet(String communityId, CommunityPost post) async {
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
            const Text(
              'Comments',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...post.comments.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.userRound,
                      size: 18,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
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
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(LucideIcons.send, color: BuddyColors.green),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      _addComment(communityId, post.id, controller.text.trim());
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
        title: const Text(
          'Community',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton:
          asyncState.value?.detail?.myRole != null && _tab == 0
          ? FloatingActionButton(
              backgroundColor: BuddyColors.green,
              foregroundColor: Theme.of(context).colorScheme.surface,
              onPressed: () => _openPostComposer(
                asyncState.value?.detail?.groupName ?? 'Community',
              ),
              child: const Icon(LucideIcons.plus),
            )
          : null,
      body: asyncState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: BuddyColors.green),
        ),
        error: (e, _) => Center(
          child: Text(
            '$e',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
          ),
        ),
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
                    : const Icon(
                        LucideIcons.usersRound,
                        size: 56,
                        color: BuddyColors.green,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            detail.groupName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        if (canManage)
                          IconButton(
                            icon: const Icon(LucideIcons.settings, size: 20),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CommunitySettingsScreen(
                                  communityId: widget.communityId,
                                  initialName: detail.groupName,
                                  initialDescription: detail.description,
                                  initialIsPublic: detail.isPublic,
                                  initialCoverUrl: detail.coverUrl,
                                  canManage: true,
                                ),
                              ),
                            ),
                          ),
                        if (isMember)
                          IconButton(
                            icon: const Icon(LucideIcons.share2, size: 20),
                            onPressed: () => _showInviteSheet(detail),
                          ),
                      ],
                    ),
                    if (detail.description.isNotEmpty)
                      Text(
                        detail.description,
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
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
                          child: Text(
                            '${detail.memberCount} members · View All',
                            style: const TextStyle(
                              fontSize: 12,
                              color: BuddyColors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (detail.myRole != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: BuddyColors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              detail.myRole!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: BuddyColors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ActionChip(
                          avatar: const Icon(
                            LucideIcons.calendarDays,
                            size: 16,
                            color: BuddyColors.green,
                          ),
                          label: const Text(
                            'Activities',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: BuddyColors.green,
                            ),
                          ),
                          backgroundColor: BuddyColors.green.withValues(
                            alpha: 0.15,
                          ),
                          side: BorderSide(
                            color: BuddyColors.green.withValues(alpha: 0.4),
                          ),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CommunityActivitiesScreen(
                                communityId: widget.communityId,
                                communityName: detail.groupName,
                                canManage: canManage,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isMember) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _joining ? null : _showJoinDialog,
                          child: Text(
                            _joining ? 'Joining...' : 'Join Community',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _CommunityTabBar(
                activeIndex: _effectiveTab(canManage),
                canManage: canManage,
                memberCount: detail.memberCount,
                onChanged: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: switch (_effectiveTab(canManage)) {
                  1 => _gymRequestsTab(),
                  2 => _membersTab(detail, canManage),
                  3 => _eventsTab(detail, canManage),
                  4 => _schedulesTab(detail, canManage),
                  5 => _livesTab(detail, canManage),
                  _ => _feedTab(state, canManage),
                },
              ),
            ],
          );
        },
      ),
    );
  }

  int _effectiveTab(bool canManage) =>
      (!canManage && _tab == 1) ? 0 : _tab;

  static String _fmtWhen(String? iso) {
    if (iso == null || iso.isEmpty) return 'No date set';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return 'No date set';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]}, '
        '$hour12:$minute $ampm';
  }

  Widget _feedTab(CommunityFeedState state, bool canManage) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Community navigation tabs: "All" + individual communities
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _tabs.asMap().entries.map((entry) {
              final idx = entry.key;
              final tab = entry.value;
              final isSelected = _selectedCommunityTab == idx;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tab.kind == _CommunityTabKind.single &&
                          tab.community?.coverUrl.isNotEmpty == true)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: BuddyColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: BuddyColors.border),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              tab.community!.coverUrl,
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      if (tab.kind == _CommunityTabKind.single &&
                          tab.community?.coverUrl.isNotEmpty == true)
                        const SizedBox(width: 6),
                      Text(tab.label),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedCommunityTab = idx),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? BuddyColors.green
                        : cs.onSurface.withValues(alpha: 0.7),
                  ),
                  backgroundColor: isSelected
                      ? BuddyColors.green.withValues(alpha: 0.1)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _selectedCommunityTab == 0
              ? _allCommunitiesTab(state, canManage)
              : _selectedCommunity == null
              ? const Center(child: Text('Community not found'))
              : _singleCommunityTab(
                  _selectedCommunity!,
                  state,
                  canManage,
                ),
        ),
      ],
    );
  }

  Widget _membersTab(CommunityDetail detail, bool canManage) {
    final cs = Theme.of(context).colorScheme;
    final members = detail.members;
    final isMember = (detail.myRole ?? detail.membershipRole) != null;

    // The backend hides the roster from non-members, so an empty list on a
    // community with members means "not yours to see", not "nobody is here".
    if (members.isEmpty && detail.memberCount > 0 && !isMember) {
      return _CommunityNotice(
        icon: LucideIcons.lock,
        title: '${detail.memberCount} members',
        body: detail.isPublic
            ? 'Join this community to see who is here.'
            : 'This community is private — members are only visible to members.',
        actionLabel: detail.isPublic ? 'Join community' : null,
        onAction: detail.isPublic ? _showJoinDialog : null,
      );
    }

    final q = _memberSearchController.text.trim().toLowerCase();
    final filtered = q.isEmpty
        ? members
        : members
              .where(
                (m) =>
                    m.displayName.toLowerCase().contains(q) ||
                    m.username.toLowerCase().contains(q),
              )
              .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _memberSearchController,
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: cs.onSurface, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search members…',
              isDense: true,
              prefixIcon: Icon(LucideIcons.search, size: 17, color: cs.onSurfaceVariant),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
          ),
        ),
        if (canManage)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CommunityMembersScreen(
                      communityId: widget.communityId,
                      canManage: true,
                    ),
                  ),
                ),
                icon: const Icon(LucideIcons.settings2, size: 14),
                label: const Text('Manage members'),
              ),
            ),
          ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    q.isEmpty ? 'No members yet.' : 'No matching members.',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                  itemBuilder: (_, i) {
                    final m = filtered[i];
                    final name = m.displayName.isNotEmpty ? m.displayName : m.username;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 2),
                      leading: Avatar(
                        src: m.avatarUrl.isNotEmpty ? m.avatarUrl : null,
                        alt: name,
                        size: AvatarSize.md,
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        '@${m.username}${m.role != 'member' ? ' · ${m.role}' : ''}',
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _gymRequestsTab() {
    final cs = Theme.of(context).colorScheme;
    final async = ref.watch(communityGymRequestsProvider(widget.communityId));
    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: BuddyColors.green),
      ),
      error: (e, _) => _CommunityNotice(
        icon: LucideIcons.alertCircle,
        title: 'Could not load gym requests',
        body: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () => ref
            .read(communityGymRequestsProvider(widget.communityId).notifier)
            .reload(),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return const _CommunityNotice(
            icon: LucideIcons.dumbbell,
            title: 'No pending requests',
            body: 'When a gym asks to link with this community, the request '
                'appears here for you to approve or decline.',
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                Icon(LucideIcons.dumbbell, size: 12, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'GYM REQUESTS TO LINK WITH THIS COMMUNITY',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.4,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final request in requests) ...[
              _GymRequestCard(
                request: request,
                onDecide: (approve) => _decideGymRequest(request, approve),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }

  Future<void> _decideGymRequest(
    CommunityGymLinkRequest request,
    bool approve,
  ) async {
    try {
      await ref
          .read(communityGymRequestsProvider(widget.communityId).notifier)
          .decide(request.id, approve);
      if (mounted) {
        showToast(
          context,
          approve ? '${request.gymName} linked.' : 'Request declined.',
          type: ToastType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        showToast(context, 'Could not record that decision.',
            type: ToastType.error);
      }
    }
  }

  Widget _eventsTab(CommunityDetail detail, bool canManage) {
    final async = ref.watch(communityActivitiesProvider(widget.communityId));
    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: BuddyColors.green),
      ),
      error: (e, _) => _activityError(),
      data: (state) {
        final events = state.events.where((e) => !e.isCancelled).toList();
        return _activitySection(
          title: 'Events',
          addLabel: 'Add event',
          canManage: canManage,
          onAdd: () => _openActivities(detail.groupName, 0),
          emptyText: 'No upcoming events.',
          children: [
            for (final event in events)
              _ActivityTile(
                icon: LucideIcons.calendarDays,
                color: BuddyColors.green,
                title: event.title,
                subtitle: [
                  _fmtWhen(event.startDatetime),
                  if (event.location.isNotEmpty) event.location,
                  if (event.onlineUrl.isNotEmpty) 'online',
                ].join(' · '),
                body: event.description.isEmpty ? null : event.description,
                badges: [
                  event.eventType.replaceAll('_', ' '),
                  if (event.isFree) 'Free',
                  if (event.capacity > 0)
                    '${event.spotsRemaining ?? event.capacity} spots',
                ],
                onDelete: canManage
                    ? () => _confirmDelete(
                        'Remove this event?',
                        () => ref
                            .read(
                              communityActivitiesProvider(widget.communityId)
                                  .notifier,
                            )
                            .deleteEvent(event.id),
                      )
                    : null,
              ),
          ],
        );
      },
    );
  }

  Widget _schedulesTab(CommunityDetail detail, bool canManage) {
    final async = ref.watch(communityActivitiesProvider(widget.communityId));
    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: BuddyColors.green),
      ),
      error: (e, _) => _activityError(),
      data: (state) {
        return _activitySection(
          title: 'Schedule',
          addLabel: 'Add session',
          canManage: canManage,
          onAdd: () => _openActivities(detail.groupName, 2),
          emptyText: 'No sessions scheduled.',
          children: [
            for (final slot in state.schedules)
              _ActivityTile(
                icon: LucideIcons.clock,
                color: BuddyColors.electric,
                title: slot.title.isNotEmpty
                    ? slot.title
                    : slot.customActivityType.isNotEmpty
                    ? slot.customActivityType
                    : slot.activityType,
                subtitle: [
                  _fmtWhen(slot.startTime),
                  if (slot.recurrence != 'none') slot.recurrence,
                  if (slot.maxSlots > 0) '${slot.maxSlots} slots',
                ].join(' · '),
                body: slot.content.isEmpty ? null : slot.content,
                onDelete: canManage
                    ? () => _confirmDelete(
                        'Remove this session?',
                        () => ref
                            .read(
                              communityActivitiesProvider(widget.communityId)
                                  .notifier,
                            )
                            .deleteSchedule(slot.id),
                      )
                    : null,
              ),
          ],
        );
      },
    );
  }

  Widget _livesTab(CommunityDetail detail, bool canManage) {
    final async = ref.watch(communityActivitiesProvider(widget.communityId));
    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: BuddyColors.green),
      ),
      error: (e, _) => _activityError(),
      data: (state) {
        return _activitySection(
          title: 'Lives',
          addLabel: 'Schedule a live',
          canManage: canManage,
          onAdd: () => _openActivities(detail.groupName, 1),
          emptyText: 'No lives scheduled.',
          children: [
            for (final live in state.lives)
              _ActivityTile(
                icon: LucideIcons.radio,
                color: live.status == 'live'
                    ? BuddyColors.red
                    : BuddyColors.green,
                title: live.title,
                subtitle: live.status == 'live'
                    ? 'Live now'
                    : _fmtWhen(live.scheduledFor),
                badges: [
                  if (live.status == 'live') 'LIVE',
                  live.liveType.replaceAll('_', ' '),
                ],
                onDelete: canManage
                    ? () => _confirmDelete(
                        'Remove this live?',
                        () => ref
                            .read(
                              communityActivitiesProvider(widget.communityId)
                                  .notifier,
                            )
                            .deleteLive(live.id),
                      )
                    : null,
              ),
          ],
        );
      },
    );
  }

  Widget _activityError() {
    return _CommunityNotice(
      icon: LucideIcons.alertCircle,
      title: 'Could not load activities',
      body: 'Check your connection and try again.',
      actionLabel: 'Retry',
      onAction: () =>
          ref.invalidate(communityActivitiesProvider(widget.communityId)),
    );
  }

  Widget _activitySection({
    required String title,
    required String addLabel,
    required bool canManage,
    required VoidCallback onAdd,
    required String emptyText,
    required List<Widget> children,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            if (canManage)
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: Text(addLabel),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (children.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                emptyText,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
            ),
          )
        else
          ...children,
      ],
    );
  }

  Future<void> _openActivities(String communityName, int initialTab) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityActivitiesScreen(
          communityId: widget.communityId,
          communityName: communityName,
          canManage: true,
          initialTab: initialTab,
        ),
      ),
    );
    if (mounted) {
      ref.invalidate(communityActivitiesProvider(widget.communityId));
    }
  }

  Future<void> _confirmDelete(
    String title,
    Future<void> Function() delete,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: BuddyColors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await delete();
    } catch (_) {
      if (mounted) {
        showToast(context, 'Could not remove that.', type: ToastType.error);
      }
    }
  }

  Widget _singleCommunityTab(
    CommunityDetail community,
    CommunityFeedState state,
    bool canManage,
  ) {
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(communityFeedProvider(community.id).notifier).refresh();
        await ref
            .read(communityFeedProvider(community.id).notifier)
            .loadPosts();
      },
      child: state.posts.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                Icon(
                  LucideIcons.messagesSquare,
                  size: 48,
                  color: cs.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'No posts yet in ${community.groupName}',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: state.posts.map((p) {
                return PostCard(
                  post: p.toPost(),
                  onLike: (_) => _toggleLike(community.id, p.id),
                  onComment: (_) => _commentSheet(community.id, p),
                  onRepost: (_) => _toggleRepost(community.id, p.id),
                  onSave: (_) => _toggleSave(community.id, p.id),
                  onShare: (_) => _toggleShare(p.id),
                  onReact: (postId, reaction) =>
                      _handleReact(community.id, postId, reaction),
                  onPin: canManage
                      ? (_) async {
                          await ref
                              .read(
                                communityFeedProvider(community.id).notifier,
                              )
                              .updatePost(p.id, {'is_pinned': !p.isPinned});
                        }
                      : null,
                  onDelete: canManage
                      ? (_) async {
                          await ref
                              .read(
                                communityFeedProvider(community.id).notifier,
                              )
                              .deletePost(p.id);
                        }
                      : null,
                );
              }).toList(),
            ),
    );
  }

  Widget _allCommunitiesTab(CommunityFeedState state, bool canManage) {
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(communityFeedProvider(widget.communityId).notifier)
            .refresh();
        await ref
            .read(communityFeedProvider(widget.communityId).notifier)
            .loadAllPosts();
      },
      child: state.allPosts.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                Icon(
                  LucideIcons.messagesSquare,
                  size: 48,
                  color: cs.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'No posts yet across communities',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: state.allPosts.map((entry) {
                final p = entry.post;
                return CommunityPostCardWithTag(
                  post: p.toPost(),
                  communityName: entry.communityName,
                  communityCoverUrl: entry.communityCoverUrl,
                  onLike: (_) => _toggleLike(entry.communityId, p.id),
                  onComment: (_) => _commentSheet(entry.communityId, p),
                  onRepost: (_) => _toggleRepost(entry.communityId, p.id),
                  onSave: (_) => _toggleSave(entry.communityId, p.id),
                  onShare: (_) => _toggleShare(p.id),
                  onReact: (postId, reaction) =>
                      _handleReact(entry.communityId, postId, reaction),
                  onPin: canManage
                      ? (_) async {
                          await ref
                              .read(
                                communityFeedProvider(
                                  entry.communityId,
                                ).notifier,
                              )
                              .updatePost(p.id, {'is_pinned': !p.isPinned});
                        }
                      : null,
                  onDelete: canManage
                      ? (_) async {
                          await ref
                              .read(
                                communityFeedProvider(
                                  entry.communityId,
                                ).notifier,
                              )
                              .deletePost(p.id);
                        }
                      : null,
                );
              }).toList(),
            ),
    );
  }
}

/// Horizontally scrollable tab rail matching the web CommunityDetail tabs:
/// Feed · Gym requests · Members · Events · Schedules · Lives.
class _CommunityTabBar extends StatelessWidget {
  final int activeIndex;
  final bool canManage;
  final int memberCount;
  final ValueChanged<int> onChanged;

  const _CommunityTabBar({
    required this.activeIndex,
    required this.canManage,
    required this.memberCount,
    required this.onChanged,
  });

  static const _tabs = <({int index, String label, IconData icon})>[
    (index: 0, label: 'Feed', icon: LucideIcons.messagesSquare),
    (index: 1, label: 'Gym requests', icon: LucideIcons.dumbbell),
    (index: 2, label: 'Members', icon: LucideIcons.users),
    (index: 3, label: 'Events', icon: LucideIcons.calendarDays),
    (index: 4, label: 'Schedules', icon: LucideIcons.clock),
    (index: 5, label: 'Lives', icon: LucideIcons.radio),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: SizedBox(
        height: 46,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            for (final tab in _tabs)
              if (tab.index != 1 || canManage)
                InkWell(
                  onTap: () => onChanged(tab.index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: activeIndex == tab.index
                              ? BuddyColors.green
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 15,
                          color: activeIndex == tab.index
                              ? BuddyColors.green
                              : cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: activeIndex == tab.index
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: activeIndex == tab.index
                                ? BuddyColors.green
                                : cs.onSurfaceVariant,
                          ),
                        ),
                        if (tab.index == 2) ...[
                          const SizedBox(width: 4),
                          Text(
                            '$memberCount',
                            style: TextStyle(
                              fontSize: 10,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// Centred empty/error/notice card used by the community tabs.
class _CommunityNotice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CommunityNotice({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One event/session/live row — icon tile, title, when, body and badges.
class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? body;
  final List<String> badges;
  final VoidCallback? onDelete;

  const _ActivityTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.body,
    this.badges = const [],
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
                if (body != null && body!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    body!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ],
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final badge in badges)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(LucideIcons.trash2, size: 16, color: cs.onSurfaceVariant),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

/// Community-side review card for a gym→community link request.
class _GymRequestCard extends StatelessWidget {
  final CommunityGymLinkRequest request;
  final ValueChanged<bool> onDecide;

  const _GymRequestCard({required this.request, required this.onDecide});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final meta = [
      '@${request.gymHandle}',
      if (request.gymCategory.isNotEmpty) request.gymCategory.replaceAll('_', ' '),
      if (request.gymMemberCount > 0) '${request.gymMemberCount} members',
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(
            src: request.gymLogoUrl.isNotEmpty ? request.gymLogoUrl : null,
            alt: request.gymName,
            size: AvatarSize.md,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.gymName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  'Asked by ${request.requestedBy.isNotEmpty ? request.requestedBy : 'the gym owner'}'
                  '${request.createdAt.isNotEmpty ? ' · ${_CommunityDetailScreenState._fmtWhen(request.createdAt)}' : ''}',
                  style: TextStyle(
                    fontSize: 9,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () => onDecide(true),
                      icon: const Icon(LucideIcons.check, size: 12),
                      label: const Text('Approve'),
                      style: FilledButton.styleFrom(
                        backgroundColor: BuddyColors.green,
                        foregroundColor: BuddyColors.black,
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => onDecide(false),
                      icon: const Icon(LucideIcons.x, size: 12),
                      label: const Text('Decline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BuddyColors.red,
                        side: BorderSide(
                          color: BuddyColors.red.withValues(alpha: 0.3),
                        ),
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
