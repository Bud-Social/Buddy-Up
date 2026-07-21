import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/gym_provider.dart';
import '../widgets/gym_tab_bar.dart';
import '../widgets/schedule_post_card.dart';
import '../widgets/review_card.dart';
import '../widgets/member_tile.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/input.dart';
import '../../../core/theme/app_theme.dart';
import '../../live/providers/live_provider.dart';
import '../../../data/models/gym.dart';

class GymDetailScreen extends ConsumerStatefulWidget {
  final String slug;
  const GymDetailScreen({super.key, required this.slug});

  @override
  ConsumerState<GymDetailScreen> createState() => _GymDetailScreenState();
}

class _GymDetailScreenState extends ConsumerState<GymDetailScreen> {
  int _tabIndex = 0;
  final _reviewController = TextEditingController();
  double _reviewRating = 5;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gymAsync = ref.watch(gymDetailProvider(widget.slug));

    return Scaffold(
      body: gymAsync.when(
        loading: () => const Scaffold(body: PageLoader()),
        error: (e, _) => Scaffold(body: ErrorView(message: e.toString(), onRetry: () => ref.invalidate(gymDetailProvider(widget.slug)))),
        data: (gym) => NestedScrollView(
          headerSliverBuilder: (_, _) => [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: gym.coverUrl.isNotEmpty
                    ? Image.network(gym.coverUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => _coverPlaceholder())
                    : _coverPlaceholder(),
              ),
              actions: [
                if (gym.isMember)
                  PopupMenuButton<String>(
                    color: BuddyColors.surface,
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (v) async {
                      if (v == 'leave') {
                        final repo = ref.read(gymRepositoryProvider);
                        await repo.leaveGym(widget.slug);
                        ref.invalidate(gymDetailProvider(widget.slug));
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'leave', child: Text('Leave Gym', style: TextStyle(color: BuddyColors.red))),
                    ],
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: _buildHeader(gym),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(_tabIndex, (i) => setState(() => _tabIndex = i)),
            ),
          ],
          body: _buildTabContent(gym),
        ),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(color: BuddyColors.surfaceRaised, child: const Center(
      child: Icon(Icons.fitness_center, color: BuddyColors.textSecondary, size: 64),
    ));
  }

  Widget _buildHeader(Gym gym) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(src: gym.logoUrl.isNotEmpty ? gym.logoUrl : null, alt: gym.name, size: AvatarSize.xl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(gym.name, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        if (gym.isVerified) const Icon(Icons.verified, color: BuddyColors.green, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('@${gym.handle}', style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _statItem('${gym.memberCount}', 'members'),
                        const SizedBox(width: 16),
                        if (gym.averageRating != null) _statItem(gym.averageRating!.toStringAsFixed(1), 'rating'),
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
            Text(gym.description, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 14)),
          ],
          if (gym.locationCity.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: BuddyColors.green),
                const SizedBox(width: 4),
                Text('${gym.locationCity}${gym.locationCountry.isNotEmpty ? ', ${gym.locationCountry}' : ''}',
                    style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
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
              if (gym.isDonationsEnabled) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _showDonateDialog(gym),
                  icon: const Icon(Icons.favorite, size: 16),
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
        Text(value, style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildTabContent(Gym gym) {
    switch (_tabIndex) {
      case 0: return _buildFeedTab(gym);
      case 1: return _buildScheduleTab(gym);
      case 2: return _buildLivesTab(gym);
      case 3: return _buildMembersTab(gym);
      case 4: return _buildReviewsTab(gym);
      case 5: return _buildAboutTab(gym);
      case 6: return _buildEventsTab(gym);
      default: return const SizedBox();
    }
  }

  Widget _buildFeedTab(Gym gym) {
    return FutureBuilder(
      future: ref.read(gymRepositoryProvider).getGymFeed(widget.slug),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const PageLoader();
        if (snap.hasError) return ErrorView(message: snap.error.toString(), onRetry: () => setState(() {}));
        return const Center(
          child: Text('Gym feed coming soon', style: TextStyle(color: BuddyColors.textSecondary)),
        );
      },
    );
  }

  Widget _buildScheduleTab(Gym gym) {
    final schedule = ref.watch(schedulePostsProvider(widget.slug));
    return schedule.when(
      loading: () => const PageLoader(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(schedulePostsProvider(widget.slug))),
      data: (posts) {
        if (posts.isEmpty) return const Center(child: Text('No schedule posts', style: TextStyle(color: BuddyColors.textSecondary)));
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
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(gymScheduleLivesProvider(gym.id))),
      data: (lives) {
        if (lives.isEmpty) return const Center(child: Text('No scheduled lives', style: TextStyle(color: BuddyColors.textSecondary)));
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: lives.length,
          itemBuilder: (_, i) => ListTile(
            leading: Avatar(src: lives[i].host.avatarUrl, alt: lives[i].host.displayName),
            title: Text(lives[i].title, style: const TextStyle(color: BuddyColors.textPrimary)),
            subtitle: Text(lives[i].status, style: const TextStyle(color: BuddyColors.textSecondary)),
            onTap: () => context.push('/lives/${lives[i].id}'),
          ),
        );
      },
    );
  }

  Widget _buildMembersTab(Gym gym) {
    final members = ref.watch(membersProvider(widget.slug));
    return members.when(
      loading: () => const PageLoader(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(membersProvider(widget.slug))),
      data: (list) => ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: list.length,
        itemBuilder: (_, i) => MemberTile(
          membership: list[i],
          isOwner: gym.membershipRole == 'owner',
          onManage: (uid, action) async {
            final repo = ref.read(gymRepositoryProvider);
            if (action == 'remove') {
              await repo.removeMember(widget.slug, uid);
            }
            ref.invalidate(membersProvider(widget.slug));
          },
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
            error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(reviewsProvider(widget.slug))),
            data: (list) {
              if (list.isEmpty) return const Center(child: Text('No reviews', style: TextStyle(color: BuddyColors.textSecondary)));
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
            decoration: const BoxDecoration(
              color: BuddyColors.black,
              border: Border(top: BorderSide(color: BuddyColors.border)),
            ),
            child: Row(
              children: [
                Row(
                  children: List.generate(5, (i) => IconButton(
                    icon: Icon(i < _reviewRating ? Icons.star : Icons.star_border,
                        color: BuddyColors.green, size: 20),
                    onPressed: () => setState(() => _reviewRating = i + 1),
                  )),
                ),
                Expanded(
                  child: BuddyInput(controller: _reviewController, hint: 'Write a review...'),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: BuddyColors.green),
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
        if (gym.rules.isNotEmpty) ...[
          const Text('Rules', style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          ...gym.rules.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: BuddyColors.green)),
                Expanded(child: Text(r, style: const TextStyle(color: BuddyColors.textSecondary))),
              ],
            ),
          )),
          const SizedBox(height: 16),
        ],
        if (gym.tags.isNotEmpty) ...[
          const Text('Tags', style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: gym.tags.map((t) => Chip(
              label: Text(t, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 12)),
              backgroundColor: BuddyColors.surface,
              side: const BorderSide(color: BuddyColors.border),
            )).toList(),
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
          Text(label, style: const TextStyle(color: BuddyColors.textSecondary)),
          Text(value, style: const TextStyle(color: BuddyColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildEventsTab(Gym gym) {
    final events = ref.watch(gymEventsProvider(widget.slug));
    return events.when(
      loading: () => const PageLoader(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(gymEventsProvider(widget.slug))),
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('No events', style: TextStyle(color: BuddyColors.textSecondary)));
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: list.length,
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.event, color: BuddyColors.green),
            title: Text(list[i].title, style: const TextStyle(color: BuddyColors.textPrimary)),
            subtitle: Text(list[i].startTime ?? '', style: const TextStyle(color: BuddyColors.textSecondary)),
          ),
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
        title: const Text('Donate', style: TextStyle(color: BuddyColors.textPrimary)),
        content: BuddyInput(
          controller: controller,
          hint: 'Amount',
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  _TabBarDelegate(this.tabIndex, this.onTabChanged);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: BuddyColors.black,
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
