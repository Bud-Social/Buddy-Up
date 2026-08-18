import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/messaging.dart';
import '../providers/community_provider.dart';

class CommunitiesScreen extends ConsumerStatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  ConsumerState<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends ConsumerState<CommunitiesScreen> {
  final _inviteCode = TextEditingController();

  @override
  void dispose() {
    _inviteCode.dispose();
    super.dispose();
  }

  Future<void> _showCreateSheet() async {
    final name = TextEditingController();
    final desc = TextEditingController();
    var isPublic = true;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BuddyColors.surface,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create Community',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: desc,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: isPublic,
                      onChanged: (v) => setSheetState(() => isPublic = v ?? true),
                    ),
                    const Text('Public community'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: BuddyColors.green, foregroundColor: BuddyColors.black),
                    onPressed: () {
                      if (name.text.trim().isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Enter a community name')),
                        );
                        return;
                      }
                      Navigator.pop(ctx, true);
                    },
                    child: const Text('Create'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (ok != true || !mounted) return;
    try {
      final created = await ref
          .read(communitiesListProvider.notifier)
          .create(name.text.trim(), description: desc.text.trim(), isPublic: isPublic);
      if (created != null && mounted) context.push('/communities/${created.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Future<void> _showJoinSheet() async {
    _inviteCode.clear();
    final code = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: BuddyColors.surface,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Join by Invite Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _inviteCode,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Invite code'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: BuddyColors.green, foregroundColor: BuddyColors.black),
                onPressed: () => Navigator.pop(ctx, _inviteCode.text.trim()),
                child: const Text('Join'),
              ),
            ),
          ],
        ),
      ),
    );
    if (code == null || code.isEmpty || !mounted) return;
    try {
      final joined = await ref.read(communitiesListProvider.notifier).joinByCode(code);
      if (joined != null && mounted) context.push('/communities/${joined.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid invite code')),
        );
      }
    }
  }

  Widget _communityCard(Conversation c) {
    final isManager = c.membershipRole == 'owner' || c.membershipRole == 'admin';
    return Card(
      color: BuddyColors.surfaceRaised,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: c.coverUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(c.coverUrl, width: 48, height: 48, fit: BoxFit.cover),
              )
            : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: BuddyColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.groups_outlined, color: BuddyColors.green),
              ),
        title: Row(
          children: [
            Expanded(
              child: Text(c.groupName,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (isManager)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(c.membershipRole!.toUpperCase(),
                    style: const TextStyle(fontSize: 9, color: BuddyColors.green, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Text(
          c.description.isEmpty ? '${c.participantsData.length} members' : c.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
        ),
        onTap: () => context.push('/communities/${c.id}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(communitiesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Join by invite code',
            onPressed: _showJoinSheet,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create community',
            onPressed: _showCreateSheet,
          ),
        ],
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: BuddyColors.green)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: BuddyColors.textSecondary),
              const SizedBox(height: 12),
              Text('$e', style: const TextStyle(color: BuddyColors.textSecondary)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.read(communitiesListProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (state) {
          final mine = state.mine;
          final discover = state.discover;
          return RefreshIndicator(
            onRefresh: () => ref.read(communitiesListProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('MY COMMUNITIES',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: BuddyColors.textSecondary, letterSpacing: 0.5)),
                const SizedBox(height: 10),
                if (mine.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No communities yet — create one or join with a code',
                          style: TextStyle(color: BuddyColors.textSecondary)),
                    ),
                  )
                else
                  ...mine.map(_communityCard),
                if (discover.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text('DISCOVER',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: BuddyColors.textSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  ...discover.map(_communityCard),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}