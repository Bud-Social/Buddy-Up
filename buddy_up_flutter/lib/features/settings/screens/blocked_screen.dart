import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/settings_providers.dart';

/// Blocked accounts: list + unblock (DELETE /profiles/{username}/block/).
class BlockedScreen extends ConsumerStatefulWidget {
  const BlockedScreen({super.key});

  @override
  ConsumerState<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends ConsumerState<BlockedScreen> {
  bool _isLoading = true;
  List<String> _blocked = [];
  String? _error;
  final Set<String> _unblocking = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Handles both plain-username lists and object lists from the API.
  List<String> _parseBlocked(dynamic raw) {
    dynamic data = raw;
    if (raw is Map<String, dynamic>) data = raw['data'];
    if (data is List) {
      return data
          .map((item) {
            if (item is String) return item;
            if (item is Map<String, dynamic>) {
              final u = item['username'] ?? item['blocked_username'];
              return u?.toString() ?? '';
            }
            return '';
          })
          .where((u) => u.isNotEmpty)
          .toList();
    }
    return const [];
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final raw = await ref.read(settingsProfileRepoProvider).getBlockedList();
      if (mounted) setState(() => _blocked = _parseBlocked(raw));
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _unblock(String username) async {
    setState(() => _unblocking.add(username));
    try {
      await ref.read(settingsProfileRepoProvider).unblockUser(username);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$username unblocked')),
        );
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _unblocking.remove(username));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked Accounts')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Could not load blocked accounts.',
                              style: TextStyle(color: BuddyColors.textSecondary)),
                          TextButton(onPressed: _load, child: const Text('Retry')),
                        ],
                      ),
                )
              : _blocked.isEmpty
                  ? const Center(
                      child: Text(
                        'You have not blocked anyone.',
                        style: TextStyle(color: BuddyColors.textSecondary),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _blocked.length,
                        itemBuilder: (context, i) {
                          final username = _blocked[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.block, size: 20, color: BuddyColors.red),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(username,
                                      style: const TextStyle(fontSize: 14)),
                                ),
                                TextButton(
                                  onPressed: _unblocking.contains(username)
                                      ? null
                                      : () => _unblock(username),
                                  child: _unblocking.contains(username)
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Unblock'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

