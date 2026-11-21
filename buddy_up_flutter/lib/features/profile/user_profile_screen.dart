import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/buddy.dart';
import '../../data/models/post.dart';
import '../../data/models/profile.dart';
import '../../data/repositories/profile_repository.dart';
import '../messaging/widgets/story_strip.dart';
import '../messaging/widgets/story_viewer.dart';
import '../messaging/providers/messaging_provider.dart';
import '../../data/models/messaging.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/page_loader.dart';
import '../../shared/widgets/toast.dart';
import '../../shared/widgets/button.dart';
import '../feed/widgets/post_card.dart';
import 'widgets/buddy_search_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ---------------------------------------------------------------------------
// Animated Action Button with Spring & Morph Animation
// ---------------------------------------------------------------------------

class AnimatedProfileButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isHighlighted;

  const AnimatedProfileButton({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    this.onPressed,
    this.isLoading = false,
    this.isHighlighted = false,
  });

  @override
  State<AnimatedProfileButton> createState() => _AnimatedProfileButtonState();
}

class _AnimatedProfileButtonState extends State<AnimatedProfileButton>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  late final AnimationController _highlightController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeInOut),
    );

    if (widget.isHighlighted) {
      _highlightController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedProfileButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted != oldWidget.isHighlighted) {
      if (widget.isHighlighted) {
        _highlightController.repeat(reverse: true);
      } else {
        _highlightController.stop();
        _highlightController.reset();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _highlightController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.onPressed == null || widget.isLoading) return;
    HapticFeedback.mediumImpact();
    await _scaleController.forward();
    await _scaleController.reverse();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final hasBorder = widget.borderColor != null;

    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) => _scaleController.forward(),
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final scale = widget.isHighlighted ? _pulseAnimation.value : 1.0;
            return Transform.scale(scale: scale, child: child);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: hasBorder
                  ? Border.all(color: widget.borderColor!, width: 1.5)
                  : null,
              boxShadow: widget.isHighlighted
                  ? [
                      BoxShadow(
                        color: BuddyColors.green.withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: widget.isLoading
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.foregroundColor,
                        ),
                      )
                    : Row(
                        key: ValueKey(
                          '${widget.label}_${widget.icon.codePoint}',
                        ),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.icon,
                            size: 16,
                            color: widget.foregroundColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: widget.foregroundColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main Screen
// ---------------------------------------------------------------------------

class UserProfileScreen extends ConsumerStatefulWidget {
  final String username;
  const UserProfileScreen({super.key, required this.username});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  Profile? _profile;
  bool _isLoading = true;
  bool _profileLocked = false;
  String? _error;

  // Action loading states
  bool _followLoading = false;
  bool _buddyLoading = false;

  // Post lists per tab
  List<Post> _posts = [];
  List<Post> _reposts = [];
  bool _postsLoading = true;

  late final TabController _tabController;
  late final ProfileRepository _profileRepo;

  static const _kCoverHeight = 200.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _profileRepo = ProfileRepository(ApiClient().dio);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Raw envelope read — the locked payload for private accounts is
      // recognisable by its message, which the typed model drops.
      final raw = await ref
          .read(apiClientProvider4)
          .dio
          .get('/profiles/${widget.username}/');
      final envelope = raw.data is Map<String, dynamic>
          ? raw.data as Map<String, dynamic>
          : <String, dynamic>{};
      final locked = envelope['message'] == 'This profile is private.';
      final data = envelope['data'];
      final profile = Profile.fromJson(Map<String, dynamic>.from(data as Map));
      setState(() {
        _profileLocked = locked;
        _profile = profile;
        _isLoading = false;
      });
      if (!locked) _loadPosts();
    } catch (_) {
      setState(() {
        _error = 'User not found';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPosts() async {
    setState(() => _postsLoading = true);
    try {
      final raw = await _profileRepo.getUserPosts(widget.username, null);
      final list = _parsePosts(raw);
      setState(() {
        _posts = list.where((p) => !p.isRepost).toList();
        _reposts = list.where((p) => p.isRepost).toList();
        _postsLoading = false;
      });
    } catch (_) {
      setState(() => _postsLoading = false);
    }
  }

  List<Post> _parsePosts(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map((j) => Post.fromJson(j))
          .toList();
    }
    if (raw is Map<String, dynamic>) {
      final results = raw['results'];
      if (results is List) {
        return results
            .whereType<Map<String, dynamic>>()
            .map((j) => Post.fromJson(j))
            .toList();
      }
    }
    return [];
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _handleFollow() async {
    if (_profile == null || _followLoading) return;
    setState(() => _followLoading = true);
    try {
      if (_profile!.isFollowing) {
        await _profileRepo.unfollowUser(widget.username);
        setState(() {
          _profile = _profile!.copyWith(
            isFollowing: false,
            followerCount: (_profile!.followerCount - 1).clamp(0, 9999999),
          );
        });
        if (mounted) {
          showToast(
            context,
            'Unfollowed @${widget.username}',
            type: ToastType.info,
          );
        }
      } else {
        await _profileRepo.followUser(widget.username);
        setState(() {
          _profile = _profile!.copyWith(
            isFollowing: true,
            followerCount: _profile!.followerCount + 1,
          );
        });
        if (mounted) {
          showToast(
            context,
            'Following @${widget.username}! 🎉',
            type: ToastType.success,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        showToast(
          context,
          'Action failed. Please try again.',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  Future<void> _handleBuddy() async {
    if (_profile == null || _buddyLoading) return;
    setState(() => _buddyLoading = true);
    try {
      final status = _profile!.buddyStatus;
      if (_profile!.isBuddy) {
        if (mounted) {
          showToast(
            context,
            'You are workout buddies with @${widget.username}!',
            type: ToastType.info,
          );
        }
      } else if (status == 'pending_sent') {
        if (mounted) {
          showToast(
            context,
            'Buddy request already pending.',
            type: ToastType.info,
          );
        }
      } else if (status == 'pending_received') {
        await _profileRepo.acceptBuddyRequest(widget.username);
        setState(() {
          _profile = _profile!.copyWith(
            isBuddy: true,
            buddyStatus: 'accepted',
            buddyCount: _profile!.buddyCount + 1,
          );
        });
        if (mounted) {
          showToast(
            context,
            'Buddy request accepted! 🎉 You are now workout buddies!',
            type: ToastType.success,
          );
        }
      } else {
        await _profileRepo.sendBuddyRequest(widget.username);
        setState(() {
          _profile = _profile!.copyWith(buddyStatus: 'pending_sent');
        });
        if (mounted) {
          showToast(
            context,
            'Buddy request sent to @${widget.username}! 💪',
            type: ToastType.success,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        showToast(
          context,
          'Action failed. Please try again.',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _buddyLoading = false);
    }
  }

  Future<void> _handlePing() async {
    if (_profile == null) return;
    try {
      await _profileRepo.pingUser(
        widget.username,
        const PingPayload(message: '👋'),
      );
      if (mounted) {
        showToast(
          context,
          'Ping sent to @${widget.username}! 👋',
          type: ToastType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        showToast(
          context,
          'Failed to ping. Try again later.',
          type: ToastType.error,
        );
      }
    }
  }

  void _openMessage() => context.push('/messages/${widget.username}');

  // ── UI helpers ────────────────────────────────────────────────────────────

  ({
    String label,
    IconData icon,
    Color bg,
    Color fg,
    Color? border,
    bool isHighlighted,
  })
  _buddyButtonProps(Profile p) {
    if (p.isBuddy) {
      return (
        label: 'Buddies',
        icon: LucideIcons.handshake,
        bg: BuddyColors.green.withValues(alpha: 0.15),
        fg: BuddyColors.green,
        border: BuddyColors.green,
        isHighlighted: false,
      );
    }
    if (p.buddyStatus == 'pending_sent') {
      return (
        label: 'Pending',
        icon: LucideIcons.hourglass,
        bg: BuddyColors.surfaceRaised,
        fg: Theme.of(context).colorScheme.onSurfaceVariant,
        border: BuddyColors.border,
        isHighlighted: false,
      );
    }
    if (p.buddyStatus == 'pending_received') {
      return (
        label: 'Accept Buddy',
        icon: LucideIcons.circleCheck,
        bg: BuddyColors.green,
        fg: Theme.of(context).colorScheme.surface,
        border: null,
        isHighlighted: true,
      );
    }
    return (
      label: 'Buddy Up',
      icon: LucideIcons.userRoundPlus,
      bg: BuddyColors.green,
      fg: Theme.of(context).colorScheme.surface,
      border: null,
      isHighlighted: false,
    );
  }

  Widget _buildLockedCard(Profile p) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: BuddyColors.green.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Avatar(
                src: p.avatarUrl,
                alt: p.displayName,
                size: AvatarSize.xl,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              p.displayName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '@${p.username}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: BuddyColors.green.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: BuddyColors.green.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.lock,
                    color: BuddyColors.green,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This account is private',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Only buddies can see @${p.username}\'s posts and stories.',
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
            const SizedBox(height: 22),
            BuddyButton(
              label: 'Send buddy request',
              icon: LucideIcons.userRoundPlus,
              onPressed: _handleBuddy,
              variant: BuddyButtonVariant.primary,
              size: BuddyButtonSize.md,
              isLoading: _buddyLoading,
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const PageLoader();
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_profile == null) return const ErrorView(message: 'Profile not found');
    if (_profileLocked) return _buildLockedCard(_profile!);

    final p = _profile!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          _buildSliverAppBar(p),
          SliverToBoxAdapter(child: _buildProfileInfo(p)),
          SliverToBoxAdapter(child: _buildStats(p)),
          SliverToBoxAdapter(child: _buildActions(p)),
          if (p.bio.isNotEmpty) SliverToBoxAdapter(child: _buildBio(p)),
          SliverToBoxAdapter(child: _buildDetails(p)),
          SliverToBoxAdapter(child: BuddySearchCard(username: p.username)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBar(
              TabBar(
                controller: _tabController,
                labelColor: BuddyColors.green,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
                indicatorColor: BuddyColors.green,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(text: 'Posts (${_posts.length})'),
                  Tab(text: 'Reposts (${_reposts.length})'),
                  const Tab(text: 'Interests & Info'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsTab(_posts),
            _buildPostsTab(_reposts, isReposts: true),
            _buildInterestsTab(p),
          ],
        ),
      ),
    );
  }

  // ── Sliver App Bar with Cover Photo ────────────────────────────────────────

  Widget _buildSliverAppBar(Profile p) {
    return SliverAppBar(
      expandedHeight: _kCoverHeight,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, size: 20),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.ellipsisVertical),
          onPressed: () => _showMoreOptions(p),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (p.coverUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: p.coverUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => _coverGradient(),
                errorWidget: (_, _, _) => _coverGradient(),
              )
            else
              _coverGradient(),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.55, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverGradient() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xFF1a3a2a),
          Theme.of(context).colorScheme.surface,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  );

  // ── Profile Info ──────────────────────────────────────────────────────────

  Widget _buildProfileInfo(Profile p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Transform.translate(
            offset: const Offset(0, -36),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 4,
                ),
              ),
              child: Avatar(
                src: p.avatarUrl.isNotEmpty ? p.avatarUrl : null,
                alt: p.displayName,
                size: AvatarSize.xl,
                verificationStatus: p.verificationStatus,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          p.displayName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (p.role != 'user') ...[
                        const SizedBox(width: 6),
                        _roleBadge(p.role),
                      ],
                    ],
                  ),
                  Text(
                    '@${p.username}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  if (p.pronouns.isNotEmpty)
                    Text(
                      p.pronouns,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleBadge(String role) {
    final label = switch (role) {
      'trainer' => 'Trainer',
      'coach' => 'Coach',
      'gym_owner' => 'Gym Owner',
      'creator' => 'Creator',
      _ => role,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: BuddyColors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: BuddyColors.green.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: BuddyColors.green,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────────────────

  Widget _buildStats(Profile p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('${p.postCount}', 'Posts', null),
          _divider(),
          _statItem(
            '${p.buddyCount}',
            'Buddies',
            () => context.push('/profile/${p.username}/buddies'),
          ),
          _divider(),
          _statItem(
            '${p.followerCount}',
            'Followers',
            () => context.push('/profile/${p.username}/followers'),
          ),
          _divider(),
          _statItem(
            '${p.followingCount}',
            'Following',
            () => context.push('/profile/${p.username}/following'),
          ),
          _divider(),
          _statItem('${p.streakDays}🔥', 'Streak', null),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(height: 28, width: 1, color: BuddyColors.border);

  Widget _statItem(String value, String label, VoidCallback? onTap) {
    final col = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
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
    if (onTap == null) return col;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: col,
      ),
    );
  }

  // ── Action Buttons ────────────────────────────────────────────────────────

  Future<void> _viewStory() async {
    final repo = ref.read(messagingRepositoryProvider);
    try {
      final res = await repo.getStories();
      final reels = (res['data'] as List? ?? const []);
      final match = reels.cast<Map<String, dynamic>>().firstWhere(
        (r) =>
            (r['user']?['username'] ?? '').toString() == widget.username &&
            ((r['stories'] as List?)?.isNotEmpty ?? false),
        orElse: () => const <String, dynamic>{},
      );
      if (match.isEmpty) {
        if (!mounted) return;
        showToast(context, 'No story in the last 24h', type: ToastType.info);
        return;
      }
      // Build a lightweight viewer payload; reuse the existing StoryViewer.
      final parsed = reels
          .map((r) => StoryReel.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
      final index = parsed.indexWhere(
        (r) => r.user.username == widget.username,
      );
      if (index < 0) return;
      if (!mounted) return;
      final nav = Navigator.of(context);
      final ids = await loadSeenStories();
      nav.push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) =>
              StoryViewer(reels: parsed, initialReelIndex: index, seenIds: ids),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      showToast(context, 'Could not load story', type: ToastType.error);
    }
  }

  Widget _buildActions(Profile p) {
    final buddy = _buddyButtonProps(p);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        children: [
          // Follow / Unfollow Button
          Expanded(
            child: AnimatedProfileButton(
              label: p.isFollowing ? 'Following' : 'Follow',
              icon: p.isFollowing
                  ? LucideIcons.check
                  : LucideIcons.userRoundPlus,
              backgroundColor: p.isFollowing
                  ? BuddyColors.surfaceRaised
                  : BuddyColors.green,
              foregroundColor: p.isFollowing
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.surface,
              borderColor: p.isFollowing ? BuddyColors.border : null,
              onPressed: _handleFollow,
              isLoading: _followLoading,
            ),
          ),
          const SizedBox(width: 8),
          // Buddy Up Button
          Expanded(
            child: AnimatedProfileButton(
              label: buddy.label,
              icon: buddy.icon,
              backgroundColor: buddy.bg,
              foregroundColor: buddy.fg,
              borderColor: buddy.border,
              onPressed: _handleBuddy,
              isLoading: _buddyLoading,
              isHighlighted: buddy.isHighlighted,
            ),
          ),
          const SizedBox(width: 8),
          // Message Button
          AnimatedProfileButton(
            label: 'Message',
            icon: LucideIcons.messageCircle,
            backgroundColor: BuddyColors.surfaceRaised,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            borderColor: BuddyColors.border,
            onPressed: _openMessage,
          ),
          const SizedBox(width: 8),
          // View Story Button
          AnimatedProfileButton(
            label: 'Story',
            icon: LucideIcons.sparkles,
            backgroundColor: BuddyColors.surfaceRaised,
            foregroundColor: BuddyColors.green,
            borderColor: BuddyColors.border,
            onPressed: _viewStory,
          ),
          const SizedBox(width: 8),
          // Ping Button
          _squareButton(
            icon: LucideIcons.hand,
            onTap: _handlePing,
            tooltip: 'Ping @${p.username}',
          ),
        ],
      ),
    );
  }

  Widget _squareButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: BuddyColors.surfaceRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: BuddyColors.border),
          ),
          child: Icon(icon, size: 18, color: BuddyColors.gold),
        ),
      ),
    );
  }

  // ── Bio ───────────────────────────────────────────────────────────────────

  Widget _buildBio(Profile p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Text(
        p.bio,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  // ── Details (Location, Link, Joined, Gyms) ────────────────────────────────

  Widget _buildDetails(Profile p) {
    final items = <Widget>[];

    if (p.locationCity.isNotEmpty) {
      items.add(
        _detailChip(
          icon: LucideIcons.mapPin,
          label: [
            p.locationCity,
            p.locationCountry,
          ].where((s) => s.isNotEmpty).join(', '),
        ),
      );
    }

    if (p.externalLink != null && p.externalLink!.isNotEmpty) {
      items.add(
        _detailChip(
          icon: LucideIcons.link,
          label: p.externalLink!
              .replaceFirst(RegExp(r'https?://'), '')
              .split('/')
              .first,
          onTap: () async {
            final uri = Uri.tryParse(p.externalLink!);
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          color: BuddyColors.green,
        ),
      );
    }

    if (p.gymCount > 0) {
      items.add(
        _detailChip(
          icon: LucideIcons.dumbbell,
          label: '${p.gymCount} gym${p.gymCount > 1 ? 's' : ''}',
        ),
      );
    }

    if (p.createdAt != null) {
      try {
        final dt = DateTime.parse(p.createdAt!);
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        items.add(
          _detailChip(
            icon: LucideIcons.calendarDays,
            label: 'Joined ${months[dt.month - 1]} ${dt.year}',
          ),
        );
      } catch (_) {}
    }

    if (items.isEmpty) return const SizedBox(height: 8);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Wrap(spacing: 8, runSpacing: 6, children: items),
    );
  }

  Widget _detailChip({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
  }) {
    final fg = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BuddyColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: fg, fontSize: 12)),
        ],
      ),
    );
    if (onTap == null) return chip;
    return GestureDetector(onTap: onTap, child: chip);
  }

  // ── More Options Sheet ────────────────────────────────────────────────────

  void _showMoreOptions(Profile p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: BuddyColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _sheetTile(
              LucideIcons.ban,
              'Block @${p.username}',
              BuddyColors.red,
              () async {
                Navigator.pop(context);
                await _profileRepo.blockUser(p.username);
                if (mounted) {
                  showToast(
                    context,
                    '@${p.username} blocked',
                    type: ToastType.info,
                  );
                }
              },
            ),
            _sheetTile(
              LucideIcons.flag,
              'Report profile',
              Theme.of(context).colorScheme.onSurfaceVariant,
              () => Navigator.pop(context),
            ),
            _sheetTile(
              LucideIcons.share2,
              'Share profile',
              Theme.of(context).colorScheme.onSurfaceVariant,
              () {
                Navigator.pop(context);
                Clipboard.setData(
                  ClipboardData(text: 'https://buddyup.app/@${p.username}'),
                );
                if (mounted) {
                  showToast(
                    context,
                    'Profile link copied to clipboard!',
                    type: ToastType.info,
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sheetTile(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

  // ── Posts Tab ─────────────────────────────────────────────────────────────

  Widget _buildPostsTab(List<Post> posts, {bool isReposts = false}) {
    if (_postsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: BuddyColors.green),
      );
    }
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isReposts ? LucideIcons.repeat2 : LucideIcons.rss,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            Text(
              isReposts ? 'No reposts yet' : 'No posts yet',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: posts.length,
      separatorBuilder: (_, _) =>
          const Divider(color: BuddyColors.border, height: 1),
      itemBuilder: (_, i) => PostCard(
        post: posts[i],
        // Optional on PostCard and the handler ends in `?.call()` -- without
        // this the comment button on someone else's profile is a dead control.
        onComment: (id) {
          if (id.isNotEmpty) context.push('/feed/$id');
        },
        onProfileTap: (username) {
          if (username != null) context.push('/profile/$username');
        },
      ),
    );
  }

  // ── Interests & Info Tab ──────────────────────────────────────────────────

  Widget _buildInterestsTab(Profile p) {
    final allTags = _posts.expand((post) => post.tags).toSet().toList()..sort();

    final workoutTypes = _posts
        .where((post) => post.workoutLogData != null)
        .map((post) => post.workoutLogData!['workout_type'] as String?)
        .whereType<String>()
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();

    final gymNames = _posts
        .where((post) => post.gymTagName != null && post.gymTagName!.isNotEmpty)
        .map((post) => post.gymTagName!)
        .toSet()
        .toList();

    final hasAnyData =
        allTags.isNotEmpty ||
        workoutTypes.isNotEmpty ||
        gymNames.isNotEmpty ||
        p.role != 'user' ||
        p.streakDays > 0;

    if (!hasAnyData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.puzzle,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            Text(
              'No fitness interests or tags found yet',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (p.streakDays > 0) ...[
          _interestSection('Activity & Streak', [
            _statBadge(
              LucideIcons.flame,
              '${p.streakDays} Day Workout Streak',
              BuddyColors.gold,
            ),
          ]),
          const SizedBox(height: 20),
        ],
        if (p.role != 'user') ...[
          _interestSection('Community Role', [_rolePill(p.role)]),
          const SizedBox(height: 20),
        ],
        if (workoutTypes.isNotEmpty) ...[
          _interestSection(
            'Favorite Workouts',
            workoutTypes
                .map(
                  (t) => _interestPill(
                    LucideIcons.dumbbell,
                    _prettify(t),
                    BuddyColors.green,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
        if (gymNames.isNotEmpty) ...[
          _interestSection(
            'Tagged Gyms',
            gymNames
                .map(
                  (g) =>
                      _interestPill(LucideIcons.building2, g, BuddyColors.gold),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
        if (allTags.isNotEmpty) ...[
          _interestSection(
            'Tags & Interests',
            allTags
                .map(
                  (t) => _interestPill(
                    LucideIcons.tag,
                    t,
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _interestSection(String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }

  Widget _statBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rolePill(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: BuddyColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BuddyColors.green.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.star, size: 14, color: BuddyColors.green),
          const SizedBox(width: 6),
          Text(
            _prettify(role),
            style: const TextStyle(
              color: BuddyColors.green,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _interestPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _prettify(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

// ---------------------------------------------------------------------------
// Sticky Tab Bar Delegate
// ---------------------------------------------------------------------------

class _StickyTabBar extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _StickyTabBar(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          tabBar,
          const Divider(color: BuddyColors.border, height: 1, thickness: 1),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBar oldDelegate) => tabBar != oldDelegate.tabBar;
}
