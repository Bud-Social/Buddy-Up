import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/gym.dart';
import '../providers/gym_provider.dart';
import '../widgets/verified_gym_badge.dart';

/// Every gym the signed-in user owns or co-owns, with a route to its
/// management console. The single "My Gym" link in the drawer only ever
/// reached the first one; this page is the complete list.
class MyGymsScreen extends ConsumerStatefulWidget {
  const MyGymsScreen({super.key});

  @override
  ConsumerState<MyGymsScreen> createState() => _MyGymsScreenState();
}

class _MyGymsScreenState extends ConsumerState<MyGymsScreen> {
  List<Gym> _gyms = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(gymRepositoryProvider);
      final raw = await repo.getGyms(my: true);
      final data = raw is Map<String, dynamic> ? raw['data'] : raw;
      final list = (data is List ? data : const <dynamic>[])
          .map((e) => Gym.fromJson(e as Map<String, dynamic>))
          .toList();
      // Only gyms the viewer can manage — owner or co-owner.
      setState(() {
        _gyms = list
            .where((g) => g.membershipRole == 'owner' || g.membershipRole == 'co_owner')
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not load the gyms you manage right now.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gyms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: BuddyColors.green),
            tooltip: 'Create a gym',
            onPressed: () => context.push('/gyms/create'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: BuddyColors.green))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _gyms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fitness_center, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text("You don't own any gyms yet", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/gyms/create'),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Create a gym'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _gyms.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final gym = _gyms[index];
                          return InkWell(
                            onTap: () => context.push('/gyms/${gym.handle}/manage'),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: BuddyColors.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: gym.logoUrl.isNotEmpty
                                          ? Image.network(gym.logoUrl, fit: BoxFit.cover)
                                          : Container(
                                              color: BuddyColors.green.withValues(alpha: 0.15),
                                              child: const Icon(Icons.fitness_center, color: BuddyColors.green),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                gym.name,
                                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            VerifiedGymBadge(
                                              verified: gym.isVerified,
                                              tier: gym.tier,
                                              capacity: GymTierCapacity(
                                                cap: gym.tier == 'regular' ? 50 : gym.tier == 'midlevel' ? 500 : null,
                                                current: gym.memberCount,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '@${gym.handle} · ${gym.tier} · ${gym.membershipRole == 'owner' ? 'owner' : 'co-owner'}',
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 12,
                                          children: [
                                            Text('${gym.memberCount} members', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                                            if (gym.onlineCapacity > 0) Text('${gym.onlineCapacity} online seats', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                                            if (gym.physicalCapacity > 0) Text('${gym.physicalCapacity} seats', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                                            if (gym.currentlyServing > 0) Text('${gym.currentlyServing} serving', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
