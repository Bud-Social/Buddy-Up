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
  late ProfileRepository _profileRepo;

  final _roles = ['', 'user', 'trainer', 'practitioner'];
  final _roleLabels = {'': 'All', 'user': 'Users', 'trainer': 'Trainers', 'practitioner': 'Practitioners'};

  @override
  void initState() {
    super.initState();
    _profileRepo = ProfileRepository(ApiClient().dio);
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
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search, size: 48, color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
                            const SizedBox(height: 8),
                            const Text('Search for people to connect with', style: TextStyle(color: BuddyColors.textSecondary)),
                          ],
                        ),
                      )
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
}
