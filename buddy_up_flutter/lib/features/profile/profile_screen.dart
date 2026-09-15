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
import '../../data/repositories/profile_repository.dart';
import '../../shared/navigation/app_nav.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/button.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/page_loader.dart';
import '../feed/widgets/post_card.dart';
import 'edit_profile_screen.dart';

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

  late final TabController _tabController;

  static const _kCoverHeight = 180.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _profileRepo = ProfileRepository(ApiClient().dio);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    if (_error != null) return ErrorView(message: _error!, onRetry: _loadProfile);
    if (_profile == null) return const ErrorView(message: 'Profile not found');

    final p = _profile!;
    return Scaffold(
      backgroundColor: BuddyColors.black,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          _buildAppBar(p),
          SliverToBoxAdapter(child: _buildProfileHeader(p)),
          SliverToBoxAdapter(child: _buildStats(p)),
          if (p.bio.isNotEmpty) SliverToBoxAdapter(child: _buildBio(p)),
          SliverToBoxAdapter(child: _buildDetails(p)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _ProfileStickyTabBar(
              TabBar(
                controller: _tabController,
                labelColor: BuddyColors.green,
                unselectedLabelColor: BuddyColors.textSecondary,
                indicatorColor: BuddyColors.green,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(text: 'Posts (${_posts.length})'),
                  Tab(text: 'Reposts (${_reposts.length})'),
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
      backgroundColor: BuddyColors.black,
      leading: IconButton(
        icon: const Icon(Icons.menu),
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
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }

  Widget _coverGradient() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF132e20), BuddyColors.black],
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
                border: Border.all(color: BuddyColors.black, width: 4),
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
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: BuddyColors.textPrimary,
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
                    style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                  ),
                const SizedBox(height: 2),
                Text(
                  '@${p.username}',
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BuddyButton(
                      label: 'Edit Profile',
                      icon: Icons.edit_outlined,
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
                      icon: const Icon(Icons.add_rounded, size: 16, color: BuddyColors.green),
                      label: const Text(
                        'New Post',
                        style: TextStyle(color: BuddyColors.green, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: BuddyColors.green),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
          _statItem('${p.buddyCount}', 'Buddies', () => context.push('/buddies')),
          _divider(),
          _statItem('${p.followerCount}', 'Followers', () => context.push('/buddies')),
          _divider(),
          _statItem('${p.followingCount}', 'Following', () => context.push('/buddies')),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 28, width: 1, color: BuddyColors.border);

  Widget _statItem(String value, String label, VoidCallback? onTap) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: BuddyColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
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
        style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 14, height: 1.4),
      ),
    );
  }

  Widget _buildDetails(Profile p) {
    final items = <Widget>[];

    if (p.locationCity.isNotEmpty) {
      items.add(_detailChip(
        icon: Icons.location_on_outlined,
        label: [p.locationCity, p.locationCountry].where((s) => s.isNotEmpty).join(', '),
      ));
    }

    if (p.externalLink != null && p.externalLink!.isNotEmpty) {
      items.add(_detailChip(
        icon: Icons.link_rounded,
        label: p.externalLink!.replaceFirst(RegExp(r'https?://'), '').split('/').first,
        onTap: () async {
          final uri = Uri.tryParse(p.externalLink!);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        color: BuddyColors.green,
      ));
    }

    if (p.gymCount > 0) {
      items.add(_detailChip(
        icon: Icons.fitness_center_rounded,
        label: '${p.gymCount} gym${p.gymCount > 1 ? 's' : ''}',
      ));
    }

    if (items.isEmpty) return const SizedBox(height: 4);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Center(
        child: Wrap(spacing: 8, runSpacing: 6, alignment: WrapAlignment.center, children: items),
      ),
    );
  }

  Widget _detailChip({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
  }) {
    final fg = color ?? BuddyColors.textSecondary;
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
      return const Center(child: CircularProgressIndicator(color: BuddyColors.green));
    }
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isReposts ? Icons.repeat_rounded : Icons.dynamic_feed_rounded,
              size: 48,
              color: BuddyColors.textSecondary.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            Text(
              isReposts ? 'You haven\'t reposted anything yet' : 'You haven\'t posted anything yet',
              style: TextStyle(
                color: BuddyColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 15,
              ),
            ),
            if (!isReposts) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.push('/post/new'),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Create First Post'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BuddyColors.green,
                  foregroundColor: BuddyColors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      separatorBuilder: (_, _) => const Divider(color: BuddyColors.border, height: 1),
      itemBuilder: (_, i) => PostCard(
        post: posts[i],
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
          _interestSection(
            'Workout Streak',
            [
              _interestBadge(
                Icons.local_fire_department_rounded,
                '${p.streakDays} Day Active Streak',
                BuddyColors.gold,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        if (workoutTypes.isNotEmpty) ...[
          _interestSection(
            'Your Activities & Workouts',
            workoutTypes
                .map((t) => _interestBadge(
                      Icons.fitness_center_rounded,
                      t.replaceAll('_', ' ').toUpperCase(),
                      BuddyColors.green,
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
        if (gymNames.isNotEmpty) ...[
          _interestSection(
            'Your Gyms',
            gymNames
                .map((g) => _interestBadge(
                      Icons.location_city_rounded,
                      g,
                      BuddyColors.gold,
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
        if (allTags.isNotEmpty) ...[
          _interestSection(
            'Frequent Topics & Tags',
            allTags
                .map((t) => _interestBadge(
                      Icons.tag_rounded,
                      t,
                      BuddyColors.textSecondary,
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
        _interestSection(
          'Profile Privacy & Content',
          [
            _interestBadge(
              Icons.shield_outlined,
              'Privacy: ${p.privacyLevel.toUpperCase()}',
              BuddyColors.textSecondary,
            ),
            _interestBadge(
              Icons.visibility_outlined,
              'Content Rating: ${p.contentRating.toUpperCase()}',
              BuddyColors.textSecondary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _interestSection(String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: BuddyColors.textPrimary,
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
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Quick Links Tab ───────────────────────────────────────────────────────

  Widget _buildQuickLinks() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _linkTile(Icons.storefront, 'Marketplace', 'Explore shop items & programmes', () => context.push('/marketplace')),
        const SizedBox(height: 8),
        _linkTile(Icons.account_balance_wallet, 'Wallet', 'Manage payments, earnings & balance', () => context.push('/wallet')),
        const SizedBox(height: 8),
        _linkTile(Icons.insights, 'Analytics', 'View your activity and engagement stats', () => context.push('/analytics')),
        const SizedBox(height: 8),
        _linkTile(Icons.query_stats, 'Content Insights', 'Analyze post performance and reach', () => context.push('/insights')),
        const SizedBox(height: 8),
        _linkTile(Icons.people_outline, 'Buddies & Community', 'Manage your workout connections', () => context.push('/buddies')),
      ],
    );
  }

  Widget _linkTile(IconData icon, String label, String subtitle, VoidCallback onTap) {
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
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: BuddyColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: BuddyColors.textSecondary),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: BuddyColors.black,
      child: Column(
        children: [
          tabBar,
          const Divider(color: BuddyColors.border, height: 1, thickness: 1),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_ProfileStickyTabBar oldDelegate) => tabBar != oldDelegate.tabBar;
}
