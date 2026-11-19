import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/analytics_provider.dart';

/// Shows how many sessions are waiting on this device and lets the user push
/// them now. Renders nothing when nothing is queued.
class ActivityQueueBanner extends ConsumerStatefulWidget {
  const ActivityQueueBanner({super.key});

  @override
  ConsumerState<ActivityQueueBanner> createState() => _ActivityQueueBannerState();
}

class _ActivityQueueBannerState extends ConsumerState<ActivityQueueBanner> {
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final ownerId = ref.read(authProvider).user?.id;
      ref.read(activityQueueServiceProvider).refreshCount(ownerId);
    });
  }

  Future<void> _syncNow() async {
    final ownerId = ref.read(authProvider).user?.id;
    if (_syncing || ownerId == null) return;
    setState(() => _syncing = true);
    try {
      final result = await ref
          .read(activityQueueServiceProvider)
          .flush(ownerId);
      if (result.synced > 0) {
        await ref.read(analyticsSummaryProvider.notifier).refresh();
      }
    } catch (_) {
      // Still offline or storage trouble — the queue stays put.
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(activityQueueServiceProvider);
    return ValueListenableBuilder<int>(
      valueListenable: service.pendingCount,
      builder: (context, count, _) {
        if (count == 0) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: BuddyColors.gold.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: BuddyColors.gold.withValues(alpha: .3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_off, size: 16, color: BuddyColors.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  count == 1
                      ? '1 activity is saved on this device. It uploads when you reconnect.'
                      : '$count activities are saved on this device. They upload when you reconnect.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: BuddyColors.gold,
                  ),
                ),
              ),
              TextButton(
                onPressed: _syncing ? null : _syncNow,
                child: _syncing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sync now', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }
}
