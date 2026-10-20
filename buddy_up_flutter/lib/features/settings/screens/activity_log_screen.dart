import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../shared/widgets/empty_state.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository(ref.watch(activityApiClientProvider).dio);
});

final activityApiClientProvider = Provider<ApiClient>((_) => ApiClient());

final activityLogProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, type) async {
  final raw = await ref
      .watch(activityRepositoryProvider)
      .getActivityLog(type: type.isEmpty ? null : type);
  return ((raw['data'] as List?) ?? const [])
      .map((e) => (e as Map).cast<String, dynamic>())
      .toList();
});

const _activityTypes = <(String, String)>[
  ('', 'All activity'),
  ('login', 'Logins'),
  ('password_changed', 'Password changes'),
  ('2fa_enabled', '2FA enabled'),
  ('2fa_disabled', '2FA disabled'),
  ('profile_updated', 'Profile updates'),
  ('avatar_updated', 'Avatar changes'),
  ('post_created', 'Posts created'),
  ('buddy_request_sent', 'Buddy requests'),
  ('account_deactivated', 'Account deactivated'),
];

class ActivityLogScreen extends ConsumerStatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  ConsumerState<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends ConsumerState<ActivityLogScreen> {
  String _type = '';

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(activityLogProvider(_type));

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Log')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(activityLogProvider(_type)),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                  labelText: 'Filter activity', isDense: true),
              items: [
                for (final (value, label) in _activityTypes)
                  DropdownMenuItem(value: value, child: Text(label)),
              ],
              onChanged: (value) => setState(() => _type = value ?? ''),
            ),
            const SizedBox(height: 12),
            events.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    apiErrorMessage(e,
                        fallback: 'Could not load your activity.'),
                    style: const TextStyle(
                        fontSize: 12, color: BuddyColors.textSecondary),
                  ),
                ),
              ),
              data: (rows) => rows.isEmpty
                  ? const EmptyState(
                      icon: Icons.history,
                      title: 'No activity yet',
                      subtitle: 'Account events will appear here as they happen.',
                    )
                  : Column(
                      children: [
                        for (final event in rows)
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.history,
                                  color: BuddyColors.green, size: 20),
                              title: Text(
                                _prettyType(event['event_type']?.toString() ?? ''),
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                [
                                  _prettyDate(event['created_at']?.toString()),
                                  if ((event['ip_address'] as String?)?.isNotEmpty ??
                                      false)
                                    event['ip_address'] as String,
                                ].join(' · '),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _prettyType(String raw) => raw
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  String _prettyDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    final local = parsed.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
