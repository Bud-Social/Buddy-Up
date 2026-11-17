import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_loader.dart';
import '../providers/gym_insights_provider.dart';
import '../../messaging/providers/messaging_provider.dart';

/// Member ↔ gym contact seeker. The gym owns the conversation — the owner
/// and team answer it from their side, the member from theirs, nothing
/// leaks into anyone's personal DMs.
class GymContactSheet extends StatelessWidget {
  final String gymName;
  final String gymLogo;
  final String gymSlug;
  const GymContactSheet({super.key, required this.gymName, required this.gymLogo, required this.gymSlug});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: BuddyColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: _GymContactBody(gymName: gymName, gymSlug: gymSlug),
    );
  }
}

class _GymContactBody extends ConsumerStatefulWidget {
  final String gymName;
  final String gymSlug;
  const _GymContactBody({required this.gymName, required this.gymSlug});

  @override
  ConsumerState<_GymContactBody> createState() => _GymContactBodyState();
}

class _GymContactBodyState extends ConsumerState<_GymContactBody> {
  final _draft = TextEditingController();
  final _scroll = ScrollController();
  GymInboxConversation? _conversation;
  final List<GymInboxMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrCreate();
  }

  @override
  void dispose() {
    _draft.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadOrCreate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final conv = await gymInboxOpenConversation(widget.gymSlug);
      if (!mounted) return;
      final dio = ref.read(apiClientProvider4).dio;
      final res = await dio.get('/gyms/${widget.gymSlug}/inbox/${conv.id}/messages/');
      final payload = res.data is Map<String, dynamic>
          ? (res.data as Map<String, dynamic>)['data']
          : res.data;
      final rows = payload is Map<String, dynamic> ? payload['messages'] : null;
      final messages = rows is List
          ? rows.whereType<Map>().map((row) => GymInboxMessage.fromJson(Map<String, dynamic>.from(row))).toList()
          : <GymInboxMessage>[];
      final me = await dio.get('/profiles/me/');
      final mePayload = me.data is Map<String, dynamic>
          ? (me.data as Map<String, dynamic>)['data']
          : me.data;
      final myUsername = mePayload is Map<String, dynamic> ? mePayload['username'] as String? : null;
      if (!mounted) return;
      setState(() {
        _conversation = conv;
        _messages
          ..clear()
          ..addAll(messages.map((m) => GymInboxMessage(
                id: m.id,
                senderUsername: m.senderUsername,
                senderDisplay: m.senderDisplay,
                body: m.body,
                createdAt: m.createdAt,
                isMine: myUsername != null && m.senderUsername == myUsername,
              )));
        _loading = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not open the chat with ${widget.gymName}.';
        _loading = false;
      });
    }
  }

  Future<void> _send() async {
    final body = _draft.text.trim();
    final conv = _conversation;
    if (body.isEmpty || _sending || conv == null) return;
    setState(() => _sending = true);
    _draft.clear();
    try {
      final message = await gymInboxSendMessage(widget.gymSlug, conv.id, body);
      setState(() {
        _messages.add(GymInboxMessage(
          id: message.id,
          senderUsername: message.senderUsername,
          senderDisplay: message.senderDisplay,
          body: message.body,
          createdAt: message.createdAt,
          isMine: true,
        ));
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send that message.')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 560,
      width: double.maxFinite,
      child: Column(
        children: [
          AppBar(
            backgroundColor: BuddyColors.surfaceRaised,
            title: const Text('Message the gym', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
          ),
          Expanded(
            child: _loading
                ? const Center(child: PageLoader(fullScreen: false))
                : _error != null
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
                      )
                    : _messages.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 28),
                              child: Text(
                                'Say hello — the owner and the team see this from their gym inbox, not your DMs.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.all(12),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final mine = message.isMine;
                              return Align(
                                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  constraints: const BoxConstraints(maxWidth: 260),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: mine ? BuddyColors.green.withValues(alpha: 0.14) : BuddyColors.surfaceRaised,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(message.body, style: const TextStyle(fontSize: 12)),
                                ),
                              );
                            },
                          ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _draft,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Message ${widget.gymName}…',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : _send,
                  tooltip: 'Send',
                  icon: _sending
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send_rounded, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
