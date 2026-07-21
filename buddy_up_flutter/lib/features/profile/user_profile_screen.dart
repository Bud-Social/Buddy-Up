import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/profile.dart';
import '../../data/repositories/profile_repository.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/button.dart';
import '../../shared/widgets/page_loader.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/toast.dart';

class UserProfileScreen extends StatefulWidget {
  final String username;
  const UserProfileScreen({super.key, required this.username});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Profile? _profile;
  bool _isLoading = true;
  String? _error;
  late ProfileRepository _profileRepo;

  @override
  void initState() {
    super.initState();
    _profileRepo = ProfileRepository(ApiClient().dio);
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _profileRepo.getProfile(widget.username);
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'User not found';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleBuddyAction() async {
    if (_profile == null) return;
    try {
      if (_profile!.isBuddy) {
        // unfollow or remove buddy
      } else if (_profile!.buddyStatus == 'pending_sent') {
        // cancel request
      } else {
        await _profileRepo.sendBuddyRequest(widget.username);
        if (mounted) showToast(context, 'Buddy request sent!', type: ToastType.success);
        _load();
      }
    } catch (e) {
      if (mounted) showToast(context, 'Failed to send buddy request.', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const PageLoader();
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_profile == null) return const ErrorView(message: 'Profile not found');

    final p = _profile!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(p),
          SliverToBoxAdapter(child: _buildHeader(p)),
          SliverToBoxAdapter(child: _buildStats(p)),
          SliverToBoxAdapter(child: _buildActions(p)),
          SliverToBoxAdapter(child: _buildBio(p)),
          SliverFillRemaining(child: _buildPlaceholder()),
        ],
      ),
    );
  }

  Widget _buildAppBar(Profile p) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [BuddyColors.surfaceRaised, BuddyColors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Profile p) {
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
          Text(p.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: BuddyColors.textPrimary)),
          Text('@${p.username}', style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 14)),
          if (p.locationCity.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 14, color: BuddyColors.textSecondary),
                const SizedBox(width: 4),
                Text('${p.locationCity}${p.locationCountry.isNotEmpty ? ', ${p.locationCountry}' : ''}',
                    style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStats(Profile p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat('${p.streakDays}', 'Streak'),
          _stat('${p.buddyCount}', 'Buddies'),
          _stat('${p.followerCount}', 'Followers'),
          _stat('${p.followingCount}', 'Following'),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(children: [
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: BuddyColors.textPrimary)),
      Text(label, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
    ]);
  }

  Widget _buildActions(Profile p) {
    String buttonLabel;
    BuddyButtonVariant variant;
    if (p.isBuddy) {
      buttonLabel = 'Buddies';
      variant = BuddyButtonVariant.secondary;
    } else if (p.buddyStatus == 'pending_sent') {
      buttonLabel = 'Pending';
      variant = BuddyButtonVariant.secondary;
    } else if (p.buddyStatus == 'pending_received') {
      buttonLabel = 'Accept Request';
      variant = BuddyButtonVariant.primary;
    } else {
      buttonLabel = 'Add Buddy';
      variant = BuddyButtonVariant.primary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: BuddyButton(label: buttonLabel, onPressed: _handleBuddyAction, variant: variant, size: BuddyButtonSize.sm),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: BuddyColors.surfaceRaised),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(12),
            ),
            child: const Icon(Icons.more_horiz, color: BuddyColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBio(Profile p) {
    if (p.bio.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(p.bio, textAlign: TextAlign.center, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 14)),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dynamic_feed, size: 48, color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          const Text("This user's posts will appear here", style: TextStyle(color: BuddyColors.textSecondary)),
        ],
      ),
    );
  }
}
