import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/messaging.dart';
import '../providers/community_provider.dart';

class CommunityMembersScreen extends ConsumerStatefulWidget {
  final String communityId;
  final bool canManage;

  const CommunityMembersScreen({
    super.key,
    required this.communityId,
    this.canManage = false,
  });

  @override
  ConsumerState<CommunityMembersScreen> createState() => _CommunityMembersScreenState();
}

class _CommunityMembersScreenState extends ConsumerState<CommunityMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMemberActions(CommunityMember member) {
    if (!widget.canManage) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.shield_outlined, color: BuddyColors.green),
              title: Text(member.role == 'admin' ? 'Demote to Member' : 'Promote to Admin'),
              onTap: () async {
                Navigator.pop(ctx);
                final newRole = member.role == 'admin' ? 'member' : 'admin';
                await ref.read(communityFeedProvider(widget.communityId).notifier).setRole(member.userId, newRole);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove_outlined, color: BuddyColors.red),
              title: const Text('Remove from Community', style: TextStyle(color: BuddyColors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(communityFeedProvider(widget.communityId).notifier).removeMember(member.userId);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(communityFeedProvider(widget.communityId));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: stateAsync.when(
        data: (state) {
          final members = state.detail?.members ?? [];
          final filtered = members.where((m) {
            final query = _searchQuery.toLowerCase();
            return m.displayName.toLowerCase().contains(query) ||
                m.username.toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search members…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty ? 'No members found.' : 'No matching members.',
                          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final m = filtered[index];
                          final isOwner = m.role == 'owner';
                          final isAdmin = m.role == 'admin';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: cs.surfaceContainerHighest,
                              backgroundImage: m.avatarUrl.isNotEmpty ? NetworkImage(m.avatarUrl) : null,
                              child: m.avatarUrl.isEmpty
                                  ? Icon(Icons.person, color: cs.onSurface.withValues(alpha: 0.6))
                                  : null,
                            ),
                            title: Text(
                              m.displayName.isEmpty ? m.username : m.displayName,
                              style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface),
                            ),
                            subtitle: Text(
                              '@${m.username}',
                              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isOwner)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: BuddyColors.gold.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Owner',
                                      style: TextStyle(color: BuddyColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else if (isAdmin)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: BuddyColors.green.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Admin',
                                      style: TextStyle(color: BuddyColors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                if (widget.canManage && !isOwner)
                                  IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () => _showMemberActions(m),
                                  ),
                              ],
                            ),
                            onLongPress: isOwner ? null : () => _showMemberActions(m),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
