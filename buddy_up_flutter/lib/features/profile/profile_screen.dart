import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/post.dart';
import '../../data/models/profile.dart';
import '../../data/models/live.dart';
import '../../data/models/gym.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/live_repository.dart';
import '../../data/repositories/gym_repository.dart';
import '../../shared/navigation/app_nav.dart';
import '../../shared/navigation/main_header.dart';
import 'widgets/buddy_search_card.dart';
import 'widgets/achievements_tab.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/button.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/page_loader.dart';
import '../feed/providers/feed_provider.dart';
import '../feed/widgets/post_card.dart';
import 'edit_profile_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  Profile? _profile;
  bool _isLoading = true;
  String? _error;
  late ProfileRepository _profileRepo;

  List<Post> _posts = [];
  List<Post> _reposts = [];
  bool _postsLoading = true;

  List<BuddyLive> _lives = [];
  List<Gym> _gyms = [];
  bool _livesLoading = false;
  bool _gymsLoading = false;
  bool _livesLoaded = false;
  bool _gymsLoaded = false;
  late LiveRepository _liveRepo;
  late GymRepository _gymRepo;

  late final TabController _tabController;

  static const _kCoverHeight = 180.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _tabController.addListener(_onTabChanged);
    _profileRepo = ProfileRepository(ApiClient().dio);
    _liveRepo = LiveRepository(ApiClient().dio);
    _gymRepo = GymRepository(ApiClient().dio);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  /// Lazy-load the Lives and Gyms tabs the first time they are selected,
  /// mirroring the web profile's `activeTab` effects.
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final index = _tabController.index;
    if (index == 3 && !_livesLoaded) _loadLives();
    if (index == 4 && !_gymsLoaded) _loadGyms();
  }

  List<dynamic> _asList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      final results = raw['results'] ?? raw['data'];
      if (results is List) return results;
    }
    return const [];
  }

  Future<void> _loadLives() async {
    final p = _profile;
    if (p == null) return;
    setState(() => _livesLoading = true);
    try {
      final raw = await _liveRepo.getUserLives(p.username, tab: 'all');
      final list = _asList(raw)
          .whereType<Map<String, dynamic>>()
          .map((j) => BuddyLive.fromJson(j))
          .toList();
      if (!mounted) return;
      setState(() {
        _lives = list;
        _livesLoading = false;
        _livesLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _livesLoading = false;
        _livesLoaded = true;
      });
    }
  }

  Future<void> _loadGyms() async {
    setState(() => _gymsLoading = true);
    try {
      final raw = await _gymRepo.getGyms(my: true);
      final list = _asList(raw)
          .whereType<Map<String, dynamic>>()
          .map((j) => Gym.fromJson(j))
          .toList();
      if (!mounted) return;
      setState(() {
        _gyms = list;
        _gymsLoading = false;
        _gymsLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _gymsLoading = false;
        _gymsLoaded = true;
      });
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _profileRepo.getMyProfile();
      await ref.read(authProvider.notifier).updateProfile(profile);
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
      _loadPosts(profile.username);
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPosts(String username) async {
    setState(() => _postsLoading = true);
    try {
      final raw = await _profileRepo.getUserPosts(username, null);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const PageLoader();
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _loadProfile);
    }
    if (_profile == null) return const ErrorView(message: 'Profile not found');

    final p = _profile!;
    // Watched here so the tab label carries a live count rather than a count
    // that is only right on first build.
    final savedAsync = ref.watch(savedPostsProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          _buildAppBar(p),
          SliverToBoxAdapter(child: _buildProfileHeader(p)),
          SliverToBoxAdapter(child: _buildStats(p)),
          if (p.bio.isNotEmpty) SliverToBoxAdapter(child: _buildBio(p)),
          SliverToBoxAdapter(child: _buildDetails(p)),
          const SliverToBoxAdapter(child: BuddySearchCard()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _ProfileStickyTabBar(
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
                  Tab(text: 'Saved (${savedAsync.value?.length ?? 0})'),
                  Tab(text: 'Lives (${_lives.length})'),
                  Tab(text: 'Gyms (${_gyms.length})'),
                  const Tab(text: 'Achievements'),
                  const Tab(text: 'Interests'),
                  const Tab(text: 'Shortcuts'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsList(_posts, isReposts: false),
            _buildPostsList(_reposts, isReposts: true),
            _buildSavedTab(),
            _buildLivesTab(),
            _buildGymsTab(),
            const AchievementsTab(),
            _buildInterestsTab(p),
            _buildQuickLinks(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(Profile p) {
    return SliverAppBar(
      expandedHeight: _kCoverHeight,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: IconButton(
        icon: const Icon(LucideIcons.menu),
        tooltip: 'Menu',
        onPressed: () => AppNav.open(context),
      ),
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
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.search),
          tooltip: 'Search',
          onPressed: () => context.go('/discover'),
        ),
        const NotificationBellButton(),
        IconButton(
          icon: const Icon(LucideIcons.settings),
          tooltip: 'Settings',
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }

  Widget _coverGradient() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xFF132e20),
          Theme.of(context).colorScheme.surface,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  );

  Widget _buildProfileHeader(Profile p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Column(
        children: [
          Transform.translate(
            offset: const Offset(0, -32),
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
          Transform.translate(
            offset: const Offset(0, -20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        p.displayName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (p.role != 'user') ...[
                      const SizedBox(width: 8),
                      _roleBadge(p.role),
                    ],
                  ],
                ),
                if (p.pronouns.isNotEmpty)
                  Text(
                    p.pronouns,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  '@${p.username}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BuddyButton(
                      label: 'Add story',
                      icon: LucideIcons.camera,
                      onPressed: () => context.push('/messages/story/create'),
                      variant: BuddyButtonVariant.primary,
                      size: BuddyButtonSize.sm,
                    ),
                    const SizedBox(width: 10),
                    BuddyButton(
                      label: 'Edit Profile',
                      icon: LucideIcons.pencil,
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(profile: p),
                          ),
                        );
                        _loadProfile();
                      },
                      variant: BuddyButtonVariant.outline,
                      size: BuddyButtonSize.sm,
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/post/new'),
                      icon: const Icon(
                        LucideIcons.plus,
                        size: 16,
                        color: BuddyColors.green,
                      ),
                      label: const Text(
                        'New Post',
                        style: TextStyle(
                          color: BuddyColors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: BuddyColors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
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

  Widget _buildStats(Profile p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('${p.streakDays}🔥', 'Day Streak', null),
          _divider(),
          _statItem(
            '${p.buddyCount}',
            'Buddies',
            () => context.push('/buddies'),
          ),
          _divider(),
          _statItem(
            '${p.followerCount}',
            'Followers',
            () => context.push('/buddies'),
          ),
          _divider(),
          _statItem(
            '${p.followingCount}',
            'Following',
            () => context.push('/buddies'),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(height: 28, width: 1, color: BuddyColors.border);

  Widget _statItem(String value, String label, VoidCallback? onTap) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: content,
      ),
    );
  }

  Widget _buildBio(Profile p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        p.bio,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

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

    if (items.isEmpty) return const SizedBox(height: 4);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Center(
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: items,
        ),
      ),
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

  // ── Posts & Reposts Lists ─────────────────────────────────────────────────

  Widget _buildPostsList(List<Post> posts, {required bool isReposts}) {
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
              isReposts
                  ? 'You haven\'t reposted anything yet'
                  : 'You haven\'t posted anything yet',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 15,
              ),
            ),
            if (!isReposts) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.push('/post/new'),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Create First Post'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BuddyColors.green,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
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
        // Both are optional on PostCard and their handlers end in `?.call()`.
        // Without these the comment and bookmark buttons fire analytics and do
        // nothing at all.
        onComment: (id) => _openPostDetail(id),
        onProfileTap: (username) {
          if (username != null && username != _profile?.username) {
            context.push('/profile/$username');
          }
        },
      ),
    );
  }

  // ── Interests Tab ─────────────────────────────────────────────────────────

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

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (p.streakDays > 0) ...[
          _interestSection('Workout Streak', [
            _interestBadge(
              LucideIcons.flame,
              '${p.streakDays} Day Active Streak',
              BuddyColors.gold,
            ),
          ]),
          const SizedBox(height: 20),
        ],
        if (workoutTypes.isNotEmpty) ...[
          _interestSection(
            'Your Activities & Workouts',
            workoutTypes
                .map(
                  (t) => _interestBadge(
                    LucideIcons.dumbbell,
                    t.replaceAll('_', ' ').toUpperCase(),
                    BuddyColors.green,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
        if (gymNames.isNotEmpty) ...[
          _interestSection(
            'Your Gyms',
            gymNames
                .map(
                  (g) => _interestBadge(
                    LucideIcons.building2,
                    g,
                    BuddyColors.gold,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
        if (allTags.isNotEmpty) ...[
          _interestSection(
            'Frequent Topics & Tags',
            allTags
                .map(
                  (t) => _interestBadge(
                    LucideIcons.tag,
                    t,
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
        _interestSection('Profile Privacy & Content', [
          _interestBadge(
            LucideIcons.shield,
            'Privacy: ${p.privacyLevel.toUpperCase()}',
            Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          _interestBadge(
            LucideIcons.eye,
            'Content Rating: ${p.contentRating.toUpperCase()}',
            Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ]),
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

  Widget _interestBadge(IconData icon, String label, Color color) {
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
          Icon(icon, size: 14, color: color),
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

  // ── Quick Links Tab ───────────────────────────────────────────────────────

  void _openPostDetail(String postId) {
    if (postId.isEmpty) return;
    context.push('/feed/$postId');
  }

  /// Lives the profile owner has hosted. Mirrors the web profile's Lives tab.
  Widget _buildLivesTab() {
    if (_livesLoading) return const PageLoader();
    if (_lives.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.radio,
              size: 36,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              'No lives yet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            BuddyButton(
              label: 'Start a Live',
              variant: BuddyButtonVariant.outline,
              size: BuddyButtonSize.sm,
              onPressed: () => context.push('/lives'),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _lives.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final live = _lives[i];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/lives/${live.id}'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.radio, color: BuddyColors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        live.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${live.liveType.replaceAll('_', ' ')} · ${live.status}',
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
        );
      },
    );
  }

  /// Gyms the profile owner belongs to. Mirrors the web profile's Gyms tab.
  Widget _buildGymsTab() {
    if (_gymsLoading) return const PageLoader();
    if (_gyms.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.dumbbell,
              size: 36,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              'No gyms joined yet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            BuddyButton(
              label: 'Browse Gyms',
              variant: BuddyButtonVariant.outline,
              size: BuddyButtonSize.sm,
              onPressed: () => context.push('/gyms'),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _gyms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final gym = _gyms[i];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/gyms/${gym.handle}'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: BuddyColors.green.withValues(alpha: 0.15),
                  backgroundImage: gym.logoUrl.isNotEmpty
                      ? CachedNetworkImageProvider(gym.logoUrl)
                      : null,
                  child: gym.logoUrl.isEmpty
                      ? const Icon(LucideIcons.dumbbell, color: BuddyColors.green)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gym.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [gym.locationCity, gym.locationCountry]
                            .where((s) => s.isNotEmpty)
                            .join(', '),
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
        );
      },
    );
  }

  /// Saved posts. Reads the endpoint that has always existed but was never
  /// called, so the Saved set could be written and never surfaced.
  Widget _buildSavedTab() {
    final async = ref.watch(savedPostsProvider);
    return async.when(
      loading: () => const Center(child: PageLoader()),
      error: (_, _) => const Center(
        child: ErrorView(message: 'Could not load saved posts.'),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.bookmark,
                    size: 40,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No saved posts yet',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap the bookmark on any post to keep it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
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
            onComment: (id) => _openPostDetail(id),
            onSave: (id) async {
              await ref.read(feedProvider.notifier).toggleSaveById(id);
              ref.invalidate(savedPostsProvider);
            },
            onProfileTap: (username) {
              if (username != null && username != _profile?.username) {
                context.push('/profile/$username');
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickLinks() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _linkTile(
          LucideIcons.store,
          'Marketplace',
          'Explore shop items & programmes',
          () => context.push('/marketplace'),
        ),
        const SizedBox(height: 8),
        _linkTile(
          LucideIcons.wallet,
          'Wallet',
          'Manage payments, earnings & balance',
          () => context.push('/wallet'),
        ),
        const SizedBox(height: 8),
        _linkTile(
          LucideIcons.chartNoAxesCombined,
          'Analytics',
          'View your activity and engagement stats',
          () => context.push('/analytics'),
        ),
        const SizedBox(height: 8),
        _linkTile(
          LucideIcons.chartNoAxesColumnIncreasing,
          'Content Insights',
          'Analyze post performance and reach',
          () => context.push('/insights'),
        ),
        const SizedBox(height: 8),
        _linkTile(
          LucideIcons.usersRound,
          'Buddies & Community',
          'Manage your workout connections',
          () => context.push('/buddies'),
        ),
      ],
    );
  }

  Widget _linkTile(
    IconData icon,
    String label,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      color: BuddyColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: BuddyColors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: BuddyColors.green, size: 20),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          LucideIcons.chevronRight,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

class _ProfileStickyTabBar extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _ProfileStickyTabBar(this.tabBar);

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
  bool shouldRebuild(_ProfileStickyTabBar oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}
