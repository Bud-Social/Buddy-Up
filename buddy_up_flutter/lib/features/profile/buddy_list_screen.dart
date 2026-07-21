import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/profile_repository.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/page_loader.dart';
import '../../shared/widgets/error_view.dart';

class BuddyListScreen extends StatefulWidget {
  final String username;
  const BuddyListScreen({super.key, required this.username});

  @override
  State<BuddyListScreen> createState() => _BuddyListScreenState();
}

class _BuddyListScreenState extends State<BuddyListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProfileRepository _profileRepo;
  bool _isLoading = true;
  String? _error;
  List _buddies = [];
  List _followers = [];
  List _following = [];

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

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final buddies = await _profileRepo.getBuddies(widget.username);
      final followers = await _profileRepo.getFollowers(widget.username, 1);
      final following = await _profileRepo.getFollowing(widget.username, 1);
      setState(() {
        _buddies = buddies['data'] as List? ?? buddies['results'] as List? ?? [];
        _followers = followers['data'] as List? ?? followers['results'] as List? ?? [];
        _following = following['data'] as List? ?? following['results'] as List? ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: BuddyColors.green,
          labelColor: BuddyColors.green,
          unselectedLabelColor: BuddyColors.textSecondary,
          tabs: const [
            Tab(text: 'Buddies'),
            Tab(text: 'Followers'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: _isLoading
          ? const PageLoader()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(_buddies),
                    _buildList(_followers),
                    _buildList(_following),
                  ],
                ),
    );
  }

  Widget _buildList(List items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 48, color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            const Text('Nothing here yet', style: TextStyle(color: BuddyColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final item = items[i];
        final name = item['display_name'] ?? item['username'] ?? 'Unknown';
        final username = item['username'] ?? '';
        final avatarUrl = item['avatar_url'] as String?;
        return ListTile(
          leading: Avatar(src: avatarUrl, alt: name, size: AvatarSize.md),
          title: Text(name, style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w500)),
          subtitle: Text('@$username', style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
          onTap: () => Navigator.of(context).pushNamed('/$username'),
        );
      },
    );
  }
}
