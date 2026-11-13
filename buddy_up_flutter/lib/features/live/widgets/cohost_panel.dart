import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../data/models/live.dart';
import '../providers/live_provider.dart';
import '../services/live_socket.dart';

/// Crown + avatars strip of the current co-hosts, shown above the chat like
/// the web's roster row. Renders nothing when nobody has joined as a co-host.
class CoHostStrip extends StatelessWidget {
  final List<CoHost> coHosts;

  const CoHostStrip({super.key, required this.coHosts});

  @override
  Widget build(BuildContext context) {
    if (coHosts.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 6, top: 7),
            child: Icon(Icons.workspace_premium, size: 14, color: BuddyColors.gold),
          ),
          for (final host in coHosts)
            Padding(
              padding: const EdgeInsets.only(right: 6, top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Avatar(src: host.avatarUrl, alt: host.displayName, size: AvatarSize.xs),
                  const SizedBox(width: 4),
                  Text(
                    host.displayName,
                    style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Host-side co-host ladder: invite by username + approve/deny the pending
/// "request to speak" queue. Approvals notify the requester over the room
/// socket so their mic unlocks live.
class CoHostRequestsSheet extends ConsumerStatefulWidget {
  final String liveId;

  const CoHostRequestsSheet({super.key, required this.liveId});

  @override
  ConsumerState<CoHostRequestsSheet> createState() => _CoHostRequestsSheetState();
}

class _CoHostRequestsSheetState extends ConsumerState<CoHostRequestsSheet> {
  final _inviteController = TextEditingController();
  List<Map<String, dynamic>>? _requests;
  bool _loading = true;
  bool _inviting = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _inviteController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final raw = await ref.read(liveRepositoryProvider).getCohostRequests(widget.liveId);
      final data = raw['data'] as List? ?? const [];
      if (!mounted) return;
      setState(() {
        _requests = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load requests';
      });
    }
  }

  Future<void> _invite() async {
    final username = _inviteController.text.trim();
    if (username.isEmpty || _inviting) return;
    setState(() => _inviting = true);
    try {
      await ref.read(liveRepositoryProvider).inviteCohost(widget.liveId, {'username': username});
      ref.read(liveSocketProvider(widget.liveId).notifier).sendCohostEvent(
            'cohost_invite',
            {'username': username, 'display_name': username},
          );
      _inviteController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invited @$username to co-host')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invite failed — is that username right?')),
        );
      }
    } finally {
      if (mounted) setState(() => _inviting = false);
    }
  }

  Future<void> _respond(Map<String, dynamic> request, String action) async {
    final username = (request['username'] ?? '') as String;
    final displayName = (request['display_name'] ?? username) as String;
    try {
      await ref.read(liveRepositoryProvider).respondToSpeakRequest(
            widget.liveId,
            {'username': username, 'action': action},
          );
      ref.read(liveSocketProvider(widget.liveId).notifier).sendCohostEvent(
            'cohost_response',
            {'username': username, 'display_name': displayName, 'action': action},
          );
      setState(() => _requests = _requests?.where((r) => r['username'] != username).toList());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(action == 'approve' ? '@$username can speak now' : 'Denied @$username')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send the response')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Co-hosts',
                style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inviteController,
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Invite by username...',
                      hintStyle: TextStyle(color: BuddyColors.textSecondary),
                      prefixIcon: Icon(Icons.person_add_alt_1, size: 20),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _invite(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _invite,
                  style: FilledButton.styleFrom(
                    backgroundColor: BuddyColors.green,
                    foregroundColor: BuddyColors.black,
                    minimumSize: const Size(0, 42),
                  ),
                  child: _inviting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Invite'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.mic_none, size: 16, color: BuddyColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Speaker requests (${_requests?.length ?? 0})',
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(18),
                child: Center(child: CircularProgressIndicator(color: BuddyColors.green)),
              )
            else if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: BuddyColors.red))
            else if (_requests == null || _requests!.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No pending requests.',
                    style: TextStyle(color: BuddyColors.textSecondary)),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _requests!.length,
                  itemBuilder: (_, i) {
                    final req = _requests![i];
                    final name = (req['display_name'] ?? '') as String;
                    final username = (req['username'] ?? '') as String;
                    final avatar = (req['avatar_url'] ?? '') as String;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Avatar(src: avatar, alt: name, size: AvatarSize.sm),
                      title: Text(name.isNotEmpty ? name : username,
                          style: const TextStyle(color: BuddyColors.textPrimary)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _respond(req, 'approve'),
                            child: const Text('Approve', style: TextStyle(color: BuddyColors.green)),
                          ),
                          TextButton(
                            onPressed: () => _respond(req, 'deny'),
                            child: const Text('Deny', style: TextStyle(color: BuddyColors.textSecondary)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
