import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_client.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/profile.dart';
import '../../data/repositories/profile_repository.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/button.dart';
import '../../shared/widgets/page_loader.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/navigation/app_nav.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Profile? _profile;
  bool _isLoading = true;
  String? _error;
  late ProfileRepository _profileRepo;

  @override
  void initState() {
    super.initState();
    _profileRepo = ProfileRepository(ApiClient().dio);
    _loadProfile();
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
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const PageLoader();
    if (_error != null) return ErrorView(message: _error!, onRetry: _loadProfile);
    if (_profile == null) return const ErrorView(message: 'Profile not found');

    final p = _profile!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(p),
          SliverToBoxAdapter(child: _buildProfileHeader(p)),
          SliverToBoxAdapter(child: _buildStats(p)),
          SliverToBoxAdapter(child: _buildBio(p)),
          SliverToBoxAdapter(child: _buildQuickLinks()),
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.dynamic_feed, size: 48, color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 8),
                  const Text('Your posts will appear here', style: TextStyle(color: BuddyColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Profile p) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Menu',
        onPressed: () => AppNav.open(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                BuddyColors.surfaceRaised,
                BuddyColors.black,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(Profile p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        children: [
          Avatar(
            src: p.avatarUrl.isNotEmpty ? p.avatarUrl : null,
            alt: p.displayName,
            size: AvatarSize.xl,
            verificationStatus: p.verificationStatus,
          ),
          const SizedBox(height: 12),
          Text(
            p.displayName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: BuddyColors.textPrimary),
          ),
          if (p.pronouns.isNotEmpty)
            Text(
              p.pronouns,
              style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
            ),
          const SizedBox(height: 4),
          Text(
            '@${p.username}',
            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
          ),
          if (p.locationCity.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 14, color: BuddyColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${p.locationCity}${p.locationCountry.isNotEmpty ? ', ${p.locationCountry}' : ''}',
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          BuddyButton(
            label: 'Edit Profile',
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
        ],
      ),
    );
  }

  Widget _buildStats(Profile p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('${p.streakDays}', 'Day Streak'),
          // Parity with web P7: stats are tappable.
          _statItem('${p.buddyCount}', 'Buddies',
              onTap: () => context.push('/buddies')),
          _statItem('${p.followerCount}', 'Followers',
              onTap: () => context.push('/buddies')),
          _statItem('${p.followingCount}', 'Following',
              onTap: () => context.push('/buddies')),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, {VoidCallback? onTap}) {
    final content = Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: BuddyColors.textPrimary)),
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
    if (p.bio.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        p.bio,
        textAlign: TextAlign.center,
        style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
      ),
    );
  }

  Widget _buildQuickLinks() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        children: [
          _linkTile(Icons.storefront, 'Marketplace', () => context.push('/marketplace')),
          const SizedBox(height: 4),
          _linkTile(Icons.account_balance_wallet, 'Wallet', () => context.push('/wallet')),
          const SizedBox(height: 4),
          _linkTile(Icons.insights, 'Analytics', () => context.push('/analytics')),
        ],
      ),
    );
  }

  Widget _linkTile(IconData icon, String label, VoidCallback onTap) {
    return Card(
      color: BuddyColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: BuddyColors.green),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, color: BuddyColors.textSecondary),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }
}
