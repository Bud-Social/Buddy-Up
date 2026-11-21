import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/gym_provider.dart';
import '../widgets/gym_tab_bar.dart';
import '../widgets/schedule_post_card.dart';
import '../widgets/review_card.dart';
import '../widgets/verified_gym_badge.dart';
import '../widgets/gym_contact_sheet.dart';
import '../widgets/member_tile.dart';
import '../../../core/api/api_error.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/badge.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/input.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/emoji_utils.dart';
import '../../live/providers/live_provider.dart';
import '../../feed/providers/feed_provider.dart';
import '../../feed/widgets/share_sheet.dart';
import '../../feed/widgets/post_card.dart';
import '../../../data/models/gym.dart';
import '../../../data/models/post.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class GymDetailScreen extends ConsumerStatefulWidget {
  final String slug;
  const GymDetailScreen({super.key, required this.slug});

  @override
  ConsumerState<GymDetailScreen> createState() => _GymDetailScreenState();
}

/// Roles the server treats as gym partner staff (`PARTNER_ROLES` in
/// `backend/apps/gyms/views.py`). Mirrored rather than imported so the client
/// can hide controls it knows would be refused.
const _partnerRoles = {'owner', 'co_owner', 'moderator'};

/// Roles nobody may edit in place -- ownership changes go through transfer,
/// and the endpoint refuses them outright.
const _unmanageableRoles = {'owner', 'co_owner'};

/// The roles a member can be moved between.
const _assignableRoles = ['member', 'trainer', 'moderator'];

Future<String?> _pickRole(BuildContext context, String current) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: BuddyColors.surface,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Change role',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          for (final role in _assignableRoles)
            ListTile(
              key: Key('gym-role-$role'),
              // The current role stays selectable but is marked, so the sheet
              // does not silently discard the member's existing assignment.
              trailing: role == current
                  ? const Icon(
                      LucideIcons.check,
                      size: 18,
                      color: BuddyColors.green,
                    )
                  : null,
              title: Text(
                role.replaceAll('_', ' '),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              onTap: () => Navigator.of(sheetContext).pop(role),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Future<bool?> _confirmRemove(BuildContext context, String userId) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: BuddyColors.surface,
      title: Text(
        'Remove member',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      content: Text(
        'They lose access to this gym immediately and are notified.',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
        TextButton(
          key: const Key('gym-remove-confirm'),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Remove', style: TextStyle(color: BuddyColors.red)),
        ),
      ],
    ),
  );
}

class _GymDetailScreenState extends ConsumerState<GymDetailScreen> {
  int _tabIndex = 0;
  final _reviewController = TextEditingController();
  double _reviewRating = 5;
  Future<List<Post>>? _gymFeedFuture;
  List<Post>? _gymFeedPosts;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<List<Post>> _loadGymFeed() {
    return _gymFeedFuture ??= ref
        .read(gymRepositoryProvider)
        .getGymFeed(widget.slug)
        .then(
          (raw) => (raw['data'] as List? ?? [])
              .map((e) => Post.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
  }

  void _updateGymPost(Post updated) {
    setState(() {
      _gymFeedPosts = [
        for (final p in _gymFeedPosts ?? const <Post>[])
          p.id == updated.id ? updated : p,
      ];
    });
  }

  Future<void> _handleGymReact(String postId, String reaction) async {
    final repo = ref.read(feedRepositoryProvider);
    if (reaction.isEmpty) {
      // PostCard signals un-react with an empty reaction.
      try {
        await repo.unreact(postId);
      } catch (_) {}
      return;
    }
    try {
      final raw = await repo.react(
        postId,
        ReactionInput(reactionType: toReactionEmoji(reaction)),
      );
      _updateGymPost(Post.fromJson(raw['data'] as Map<String, dynamic>));
    } catch (_) {}
  }

  Future<void> _handleGymSave(String postId) async {
    final posts = _gymFeedPosts;
    if (posts == null || !posts.any((p) => p.id == postId)) return;
    final post = posts.firstWhere((p) => p.id == postId);
    final repo = ref.read(feedRepositoryProvider);
    try {
      if (post.isSaved) {
        await repo.unsave(postId);
      } else {
        await repo.save(postId, const SavePayload());
      }
      _updateGymPost(post.copyWith(isSaved: !post.isSaved));
    } catch (_) {}
  }

  /// Pin or unpin a post on this gym's feed.
  ///
  /// The widget supported `onPin` all along but this tab never passed it, so
  /// the moderation control existed on community feeds and was absent here.
  Future<void> _handleGymPin(String postId) async {
    final posts = _gymFeedPosts;
    if (posts == null || !posts.any((p) => p.id == postId)) return;
    try {
      final raw = await ref.read(feedRepositoryProvider).pin(postId);
      final updated = Post.fromJson(raw['data'] as Map<String, dynamic>);
      _updateGymPost(updated);
    } catch (_) {
      // Leave the row as it was; a failed pin is not worth an error dialog.
    }
  }

  /// Remove a post from this gym's feed.
  ///
  /// Gym owners, co-owners and moderators can do this to anybody's post; every
  /// other user can only do it to their own, which the server decides.
  Future<void> _handleGymDelete(String postId) async {
    try {
      await ref.read(feedRepositoryProvider).deletePost(postId);
      final remaining = (_gymFeedPosts ?? const <Post>[])
          .where((p) => p.id != postId)
          .toList();
      _gymFeedPosts = remaining;
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final gymAsync = ref.watch(gymDetailProvider(widget.slug));

    return Scaffold(
      body: gymAsync.when(
        loading: () => const Scaffold(body: PageLoader()),
        error: (e, _) => Scaffold(
          body: ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(gymDetailProvider(widget.slug)),
          ),
        ),
        data: (gym) => NestedScrollView(
          headerSliverBuilder: (_, _) => [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (gym.coverUrl.isNotEmpty)
                      Image.network(
                        gym.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _coverPlaceholder(),
                      )
                    else
                      _coverPlaceholder(),
                    // Always-dark scrim so the back button and any overlaid
                    // text stay legible on bright covers.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black54,
                            Color(0x33000000),
                            Colors.black87,
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (gym.isMember)
                  PopupMenuButton<String>(
                    color: BuddyColors.surface,
                    icon: const Icon(LucideIcons.ellipsis),
                    onSelected: (v) async {
                      if (v == 'leave') {
                        final repo = ref.read(gymRepositoryProvider);
                        await repo.leaveGym(widget.slug);
                        ref.invalidate(gymDetailProvider(widget.slug));
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'leave',
                        child: Text(
                          'Leave Gym',
                          style: TextStyle(color: BuddyColors.red),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            SliverToBoxAdapter(child: _buildHeader(gym)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                _tabIndex,
                (i) => setState(() => _tabIndex = i),
              ),
            ),
          ],
          body: _buildTabContent(gym),
        ),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      color: BuddyColors.surfaceRaised,
      child: Center(
        child: Icon(
          LucideIcons.dumbbell,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildHeader(Gym gym) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(
                src: gym.logoUrl.isNotEmpty ? gym.logoUrl : null,
                alt: gym.name,
                size: AvatarSize.xl,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            gym.name,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (gym.isVerified)
                          VerifiedGymBadge(
                            verified: true,
                            tier: gym.tier,
                            size: 20,
                            capacity: GymTierCapacity(
                              cap: gym.tier == 'regular'
                                  ? 50
                                  : gym.tier == 'midlevel'
                                  ? 500
                                  : null,
                              current: gym.memberCount,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${gym.handle}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _statItem('${gym.memberCount}', 'members'),
                        const SizedBox(width: 16),
                        if (gym.averageRating != null)
                          _statItem(
                            gym.averageRating!.toStringAsFixed(1),
                            'rating',
                          ),
                        const SizedBox(width: 16),
                        _statItem('${gym.activeToday}', 'active'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (gym.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              gym.description,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
          if (gym.locationCity.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  LucideIcons.mapPin,
                  size: 14,
                  color: BuddyColors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  '${gym.locationCity}${gym.locationCountry.isNotEmpty ? ', ${gym.locationCountry}' : ''}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (!gym.isMember)
                ElevatedButton(
                  onPressed: () async {
                    final repo = ref.read(gymRepositoryProvider);
                    await repo.joinGym(widget.slug, {});
                    ref.invalidate(gymDetailProvider(widget.slug));
                  },
                  child: const Text('Join Gym'),
                ),
              // The management surface exists for anyone, but only an owner,
              // co-owner or moderator is offered it — same rule as the web.
              if (isGymAdminRole(gym.membershipRole)) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => context.push('/gyms/${gym.handle}/manage'),
                  icon: const Icon(LucideIcons.shieldCheck, size: 16),
                  label: const Text('Manage'),
                ),
              ],
              // Message the gym — creates a gym-owned conversation, not a DM
              // to the owner; the owner/team answer from their side.
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => GymContactSheet(
                    gymName: gym.name,
                    gymLogo: gym.logoUrl,
                    gymSlug: widget.slug,
                  ),
                ),
                icon: const Icon(LucideIcons.messagesSquare, size: 16),
                label: const Text('Message gym'),
              ),
              if (gym.isDonationsEnabled) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _showDonateDialog(gym),
                  icon: const Icon(LucideIcons.heart, size: 16),
                  label: const Text('Donate'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(Gym gym) {
    switch (_tabIndex) {
      case 0:
        return _buildFeedTab(gym);
      case 1:
        return _buildScheduleTab(gym);
      case 2:
        return _buildLivesTab(gym);
      case 3:
        return _buildMembersTab(gym);
      case 4:
        return _buildReviewsTab(gym);
      case 5:
        return _buildAboutTab(gym);
      case 6:
        return _buildEventsTab(gym);
      default:
        return const SizedBox();
    }
  }

  Widget _buildFeedTab(Gym gym) {
    return FutureBuilder<List<Post>>(
      future: _loadGymFeed(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting &&
            _gymFeedPosts == null) {
          return const PageLoader();
        }
        if (snap.hasError && _gymFeedPosts == null) {
          return ErrorView(
            message: snap.error.toString(),
            onRetry: () => setState(() {
              _gymFeedFuture = null;
              _gymFeedPosts = null;
            }),
          );
        }
        final posts = _gymFeedPosts ?? snap.data ?? const <Post>[];
        if (posts.isEmpty) {
          return Center(
            child: Text(
              'No gym posts yet',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: posts.length,
          itemBuilder: (_, i) => PostCard(
            post: posts[i],
            onComment: (id) => context.push('/feed/$id'),
            onShare: (id) => ShareSheet.show(context, posts[i]),
            onReact: _handleGymReact,
            onSave: _handleGymSave,
            // Gated on the same partner roles the server accepts, so the
            // control is offered exactly where it would succeed.
            onPin: isGymAdminRole(gym.membershipRole)
                ? (id) => _handleGymPin(id)
                : null,
            // Managers only, matching the community feed: a member removes
            // their own post from the post detail screen instead.
            onDelete: isGymAdminRole(gym.membershipRole)
                ? (id) => _handleGymDelete(id)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildScheduleTab(Gym gym) {
    final schedule = ref.watch(schedulePostsProvider(widget.slug));
    return schedule.when(
      loading: () => const PageLoader(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(schedulePostsProvider(widget.slug)),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: Text(
              'No schedule posts',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: posts.length,
          itemBuilder: (_, i) => SchedulePostCard(
            post: posts[i],
            onEnroll: () async {
              final repo = ref.read(gymRepositoryProvider);
              await repo.enrollSlot(widget.slug, posts[i].id);
              ref.invalidate(schedulePostsProvider(widget.slug));
            },
          ),
        );
      },
    );
  }

  Widget _buildLivesTab(Gym gym) {
    final livesAsync = ref.watch(gymScheduleLivesProvider(gym.id));
    return livesAsync.when(
      loading: () => const PageLoader(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(gymScheduleLivesProvider(gym.id)),
      ),
      data: (lives) {
        if (lives.isEmpty) {
          return Center(
            child: Text(
              'No scheduled lives',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: lives.length,
          itemBuilder: (_, i) => ListTile(
            leading: Avatar(
              src: lives[i].host.avatarUrl,
              alt: lives[i].host.displayName,
            ),
            title: Text(
              lives[i].title,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            subtitle: Text(
              lives[i].status,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            onTap: () => context.push('/lives/${lives[i].id}'),
          ),
        );
      },
    );
  }

  Widget _buildMembersTab(Gym gym) {
    final members = ref.watch(membersProvider(widget.slug));
    // `owner_data` / `recent_reviewers` are member-only on a non-public gym and
    // `members/` answers 403 there, so an error is a legitimate state, not a
    // failure to report: show the count the server *does* expose and say what
    // unlocks the rest.
    final rosterHidden = gym.accessType != 'public' && !gym.isMember;
    if (rosterHidden) return _rosterGate(gym);
    return members.when(
      loading: () => const PageLoader(),
      error: (e, _) {
        if (apiStatusCode(e) == 403) return _rosterGate(gym);
        return ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(membersProvider(widget.slug)),
        );
      },
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Text(
              gym.memberCount > 0
                  ? 'No members to show yet.'
                  : 'No members yet.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: list.length,
          itemBuilder: (_, i) => MemberTile(
            membership: list[i],
            // Partner staff, not "owner": the server lets co-owners and
            // moderators manage members too, and gating the UI to owners
            // hid actions that would have succeeded.
            canManage:
                _partnerRoles.contains(gym.membershipRole) &&
                !_unmanageableRoles.contains(list[i].role),
            onManage: (uid, action) async {
              final repo = ref.read(gymRepositoryProvider);
              if (action == 'remove') {
                final ok = await _confirmRemove(context, uid);
                if (ok != true) return;
                await repo.removeMember(widget.slug, uid);
                ref.invalidate(membersProvider(widget.slug));
                return;
              }
              if (action == 'change_role') {
                // This branch used to be missing: the menu offered "Change
                // role" and the handler fell through it, so tapping it did
                // nothing at all.
                final role = await _pickRole(context, list[i].role);
                if (role == null) return;
                await repo.manageMember(widget.slug, uid, {'role': role});
                ref.invalidate(membersProvider(widget.slug));
              }
            },
          ),
        );
      },
    );
  }

  /// Count-only state for a private gym the viewer has not joined.
  Widget _rosterGate(Gym gym) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.lock, size: 40, color: cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              '${gym.memberCount} member${gym.memberCount == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This gym is ${gym.accessType}. Join to see who is in it.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab(Gym gym) {
    final reviews = ref.watch(reviewsProvider(widget.slug));
    return Column(
      children: [
        Expanded(
          child: reviews.when(
            loading: () => const PageLoader(),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(reviewsProvider(widget.slug)),
            ),
            data: (list) {
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'No reviews',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: list.length,
                itemBuilder: (_, i) => ReviewCard(review: list[i]),
              );
            },
          ),
        ),
        if (gym.isReviewsEnabled)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: const Border(top: BorderSide(color: BuddyColors.border)),
            ),
            child: Row(
              children: [
                Row(
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      icon: Icon(
                        i < _reviewRating ? LucideIcons.star : LucideIcons.star,
                        color: BuddyColors.green,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _reviewRating = i + 1),
                    ),
                  ),
                ),
                Expanded(
                  child: BuddyInput(
                    controller: _reviewController,
                    hint: 'Write a review...',
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.send, color: BuddyColors.green),
                  onPressed: () async {
                    if (_reviewController.text.trim().isEmpty) return;
                    final repo = ref.read(gymRepositoryProvider);
                    await repo.createReview(widget.slug, {
                      'rating': _reviewRating.toInt(),
                      'comment': _reviewController.text.trim(),
                    });
                    _reviewController.clear();
                    ref.invalidate(reviewsProvider(widget.slug));
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAboutTab(Gym gym) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Roster-backed blocks are member-only on a non-public gym, so they are
        // rendered only when the server actually sent them — an absent list is
        // never rendered as "no owners" / "no reviews".
        if (gym.ownerData.isNotEmpty) ...[
          Text(
            'Ownership',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...gym.ownerData.map(
            (owner) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Avatar(
                    src: owner.avatarUrl.isEmpty ? null : owner.avatarUrl,
                    alt: owner.displayName,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          owner.displayName.isEmpty
                              ? owner.username
                              : owner.displayName,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '@${owner.username} · ${owner.role.replaceAll('_', ' ')}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          const SizedBox(height: 16),
        ],
        if (gym.recentReviewers.isNotEmpty) ...[
          Text(
            'Reviewed by',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: gym.recentReviewers
                .map(
                  (reviewer) => SizedBox(
                    width: 72,
                    child: Column(
                      children: [
                        Avatar(
                          src: reviewer.avatarUrl.isEmpty
                              ? null
                              : reviewer.avatarUrl,
                          alt: reviewer.displayName,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reviewer.displayName.isEmpty
                              ? reviewer.username
                              : reviewer.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (gym.rules.isNotEmpty) ...[
          Text(
            'Rules',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...gym.rules.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: BuddyColors.green)),
                  Expanded(
                    child: Text(
                      r,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (gym.tags.isNotEmpty) ...[
          Text(
            'Tags',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: gym.tags
                .map(
                  (t) => Chip(
                    label: Text(
                      t,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: BuddyColors.surface,
                    side: const BorderSide(color: BuddyColors.border),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 16),
        _infoRow('Access', gym.accessType),
        _infoRow('Subscription', gym.subscriptionType.replaceAll('_', ' ')),
        _infoRow('Created', gym.createdAt.split('T')[0]),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildEventsTab(Gym gym) {
    final events = ref.watch(gymEventsProvider(widget.slug));
    return events.when(
      loading: () => const PageLoader(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(gymEventsProvider(widget.slug)),
      ),
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Text(
              'No events',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          );
        }

        // Members-only roll: the server only sends media URLs for active members,
        // so `gymPhotoRoll` being populated is the member gate itself.
        final roll = list
            .map((e) => e.gymPhotoRoll)
            .expand((urls) => urls)
            .toList();
        final deduped = {
          for (final url in roll)
            if (url.isNotEmpty) url,
        }.toList();

        return ListView(
          padding: const EdgeInsets.only(top: 8),
          children: [
            if (deduped.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: BuddyColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: BuddyColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: deduped.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            deduped[i],
                            width: 150,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 150,
                              height: 110,
                              color: BuddyColors.surfaceRaised,
                              alignment: Alignment.center,
                              child: Icon(
                                LucideIcons.image,
                                size: 22,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.badgeCheck,
                          size: 11,
                          color: BuddyColors.green,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Members-only roll — visible because you\'re an active member.',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            for (final event in list) _GymEventCard(event: event),
          ],
        );
      },
    );
  }

  void _showDonateDialog(Gym gym) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: BuddyColors.surface,
        title: Text(
          'Donate',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: BuddyInput(
          controller: controller,
          hint: 'Amount',
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount == null) return;
              final repo = ref.read(gymRepositoryProvider);
              await repo.donate(widget.slug, {'amount': amount});
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Donate'),
          ),
        ],
      ),
    );
  }
}

/// One gym event card — mirrors the web's GymDetail events tab card:
/// cover chip, badges, price split, capacity bar and a direct maps link.
class _GymEventCard extends StatelessWidget {
  final GymEvent event;

  const _GymEventCard({required this.event});

  static const _artifactLabel = {
    'dumbbell': 'dumbbells',
    'barbell': 'barbells',
    'burpee': 'burpees',
    'squat': 'squats',
    'sprint': 'sprints',
    'pr': 'PRs',
    'champion': 'champions',
  };

  String _fmtSplit(Map<String, int>? m) {
    if (m == null || m.isEmpty) return 'Free';
    return m.entries
        .map((e) => '${e.value} ${_artifactLabel[e.key] ?? e.key}')
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final start = event.startTime == null
        ? null
        : DateTime.tryParse(event.startTime!)?.toLocal();
    final formatter = DateFormat('EEE, MMM d · HH:mm');
    final capacity = event.capacity;
    final attending = event.attendeeCount;
    final pct = capacity > 0 ? (attending / capacity).clamp(0.0, 1.0) : 0.0;
    final spotsLeft = capacity > 0
        ? (capacity - attending).clamp(0, capacity)
        : null;
    final memberSplit = event.memberPriceArtifacts;
    final nonMemberSplit = event.nonMemberPriceArtifacts;
    final hasSplit = memberSplit != null || nonMemberSplit != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        decoration: BoxDecoration(
          color: BuddyColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BuddyColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/marketplace/events/${event.id}'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover chip — same muted fallback as web when there is no cover.
              Container(
                width: 88,
                height: 88,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BuddyColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                  image: event.coverImageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(event.coverImageUrl),
                          fit: BoxFit.cover,
                          onError: (_, _) {},
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: event.coverImageUrl.isNotEmpty
                    ? null
                    : Icon(
                        LucideIcons.calendarDays,
                        size: 28,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge row — members-only goes in blue, type in gold, same
                      // hierarchy as the web card.
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          BuddyBadge(
                            label: event.eventType.replaceAll('_', ' '),
                            color: BuddyColors.gold,
                          ),
                          if (event.visibility == 'gym_members')
                            const BuddyBadge(
                              label: 'Members only',
                              color: BuddyColors.blue,
                            ),
                          if (event.category.isNotEmpty)
                            BuddyBadge(
                              label: event.category,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (event.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            event.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (start != null)
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.calendarDays,
                              size: 11,
                              color: BuddyColors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatter.format(start),
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      if (event.location.isNotEmpty)
                        InkWell(
                          onTap:
                              event.locationLat != null &&
                                  event.locationLng != null
                              ? () => launchUrl(
                                  Uri.parse(
                                    'https://maps.google.com/?q=${event.locationLat},${event.locationLng}',
                                  ),
                                )
                              : null,
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.mapPin,
                                size: 11,
                                color: BuddyColors.blue,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  event.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        event.locationLat != null &&
                                            event.locationLng != null
                                        ? BuddyColors.blue
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                    decoration:
                                        event.locationLat != null &&
                                            event.locationLng != null
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 6),
                      // Capacity — the spec asks for the pin-point alongside the count.
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: capacity > 0 ? pct : null,
                                minHeight: 4,
                                backgroundColor: BuddyColors.surfaceRaised,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  pct >= 1
                                      ? BuddyColors.red
                                      : BuddyColors.green,
                                ),
                              ),
                            ),
                          ),
                          if (capacity > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '$attending/$capacity · $spotsLeft left',
                              style: TextStyle(
                                fontSize: 9,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Persona prices — member vs everyone else.
                      if (hasSplit)
                        Wrap(
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(
                              'Member: ${_fmtSplit(memberSplit)}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: BuddyColors.green,
                              ),
                            ),
                            Text(
                              'Others: ${_fmtSplit(nonMemberSplit)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        )
                      else if (event.isFree)
                        const Text(
                          'Free',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: BuddyColors.green,
                          ),
                        )
                      else
                        const Text(
                          'Paid',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: BuddyColors.green,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  _TabBarDelegate(this.tabIndex, this.onTabChanged);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: GymTabBar(activeIndex: tabIndex, onTabChanged: onTabChanged),
    );
  }

  @override
  double get maxExtent => 44;

  @override
  double get minExtent => 44;

  @override
  bool shouldRebuild(covariant _TabBarDelegate old) => old.tabIndex != tabIndex;
}
