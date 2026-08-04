import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/profile_repository.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/input.dart';
import '../../shared/widgets/page_loader.dart';
import '../../shared/widgets/toast.dart';

class DiscoverPeopleScreen extends StatefulWidget {
  const DiscoverPeopleScreen({super.key});

  @override
  State<DiscoverPeopleScreen> createState() => _DiscoverPeopleScreenState();
}

class _DiscoverPeopleScreenState extends State<DiscoverPeopleScreen> {
  final _searchController = TextEditingController();
  List _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _roleFilter = '';
  Map<String, dynamic>? _trending;
  late ProfileRepository _profileRepo;

  final _roles = ['', 'user', 'trainer', 'practitioner'];
  final _roleLabels = {'': 'All', 'user': 'Users', 'trainer': 'Trainers', 'practitioner': 'Practitioners'};

  @override
  void initState() {
    super.initState();
    _profileRepo = ProfileRepository(ApiClient().dio);
    _loadTrending();
  }

  Future<void> _loadTrending() async {
    try {
      final raw = await _profileRepo.getDiscoverTrending();
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        if (mounted) setState(() => _trending = data);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.length < 2) return;
    setState(() => _isLoading = true);
    try {
      final result = await _profileRepo.searchProfiles(query, _roleFilter.isNotEmpty ? _roleFilter : null, 1);
      setState(() {
        _results = result['data'] as List? ?? result['results'] as List? ?? [];
        _hasSearched = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) showToast(context, 'Search failed.', type: ToastType.error);
    }
  }

  void _sendBuddyRequest(String username) async {
    try {
      await _profileRepo.sendBuddyRequest(username);
      if (mounted) showToast(context, 'Buddy request sent!', type: ToastType.success);
    } catch (e) {
      if (mounted) showToast(context, 'Failed.', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover People')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                BuddyInput(
                  controller: _searchController,
                  hint: 'Search by name or username...',
                  prefixIcon: Icons.search,
                  onChanged: (_) {},
                  suffixIcon: Icons.send,
                  onSuffixTap: _search,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _roles.map((role) {
                      final selected = _roleFilter == role;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_roleLabels[role]!),
                          selected: selected,
                          onSelected: (v) {
                            setState(() => _roleFilter = role);
                            if (_searchController.text.trim().length >= 2) _search();
                          },
                          selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                          backgroundColor: BuddyColors.surface,
                          side: BorderSide(color: selected ? BuddyColors.green : BuddyColors.surfaceRaised),
                          labelStyle: TextStyle(color: selected ? BuddyColors.green : BuddyColors.textSecondary),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const PageLoader(fullScreen: false)
                : !_hasSearched
                    ? _buildTrending()
                    : _results.isEmpty
                        ? const Center(child: Text('No results found', style: TextStyle(color: BuddyColors.textSecondary)))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _results.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final user = _results[i];
                              final name = user['display_name'] ?? user['username'] ?? '';
                              final username = user['username'] ?? '';
                              final avatarUrl = user['avatar_url'] as String?;
                              return ListTile(
                                leading: Avatar(src: avatarUrl, alt: name, size: AvatarSize.md),
                                title: Text(name, style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w500)),
                                subtitle: Text('@$username', style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.person_add, color: BuddyColors.green),
                                  onPressed: () => _sendBuddyRequest(username),
                                ),
                                onTap: () => Navigator.of(context).pushNamed('/$username'),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrending() {
    final t = _trending;
    final hashtags = (t?['hashtags'] as List? ?? []).cast<Map<String, dynamic>>();
    final posts = (t?['posts'] as List? ?? []).cast<Map<String, dynamic>>();
    final offers = (t?['offers'] as List? ?? []).cast<Map<String, dynamic>>();

    if (hashtags.isEmpty && posts.isEmpty && offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 48, color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            const Text('Search for people to connect with', style: TextStyle(color: BuddyColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (hashtags.isNotEmpty) ...[
          const _SectionHeader(icon: Icons.local_fire_department, title: 'Trending Challenges'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: hashtags.take(8).map((h) {
              final tag = (h['tag'] as String? ?? '').replaceAll('#', '');
              final count = (h['count'] as num?)?.toInt() ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: BuddyColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text.rich(
                  TextSpan(
                    text: '#$tag ',
                    style: const TextStyle(color: BuddyColors.green, fontWeight: FontWeight.w600, fontSize: 13),
                    children: [
                      TextSpan(
                        text: '$count',
                        style: const TextStyle(color: BuddyColors.textSecondary, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
        if (posts.isNotEmpty) ...[
          const _SectionHeader(icon: Icons.trending_up, title: 'Trending Posts'),
          const SizedBox(height: 4),
          ...posts.take(3).map((p) => _trendingPostTile(p)),
          const SizedBox(height: 20),
        ],
        if (offers.isNotEmpty) ...[
          const _SectionHeader(icon: Icons.local_offer, title: 'Trending Giveaways & Offers'),
          const SizedBox(height: 4),
          ...offers.map((o) => _offerTile(o)),
        ],
      ],
    );
  }

  Widget _trendingPostTile(Map<String, dynamic> p) {
    final author = p['author_data'] as Map<String, dynamic>? ?? const {};
    final reactions = (p['reaction_counts'] as Map<String, dynamic>? ?? const {})
        .values
        .fold<int>(0, (sum, v) => sum + ((v as num?)?.toInt() ?? 0));
    final body = p['body'] as String? ?? '';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Avatar(
        src: author['avatar_url'] as String?,
        alt: author['display_name'] as String? ?? '',
        size: AvatarSize.sm,
      ),
      title: Text(
        author['display_name'] as String? ?? '',
        style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (body.isNotEmpty)
            Text(body, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 2),
          Text('$reactions reactions', style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _offerTile(Map<String, dynamic> offer) {
    final type = offer['type'] as String? ?? '';
    final d = offer['data'] as Map<String, dynamic>? ?? const {};
    if (type == 'discount_code') {
      final discount = d['discount_type'] == 'percentage' ? '${d['discount_pct']}% off' : 'Discount';
      final code = d['code'] as String? ?? '';
      final desc = d['description'] as String? ?? '';
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: BuddyColors.surface,
        child: ListTile(
          leading: const Icon(Icons.confirmation_number, color: BuddyColors.gold),
          title: Text(
            '$discount  "$code"',
            style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: desc.isNotEmpty
              ? Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13))
              : null,
          trailing: const Text('Use offer', style: TextStyle(color: BuddyColors.green, fontSize: 12)),
        ),
      );
    }
    final title = d['title'] as String? ?? '';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: BuddyColors.surface,
      child: ListTile(
        leading: const Icon(Icons.event_available, color: BuddyColors.green),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: const Text('Free event', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
        trailing: const Text('View', style: TextStyle(color: BuddyColors.green, fontSize: 12)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: BuddyColors.green),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
