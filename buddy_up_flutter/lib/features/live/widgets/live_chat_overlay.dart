import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/env/env.dart';

class LiveChatOverlay extends StatefulWidget {
  final String liveId;
  final String token;

  const LiveChatOverlay({super.key, required this.liveId, required this.token});

  @override
  State<LiveChatOverlay> createState() => _LiveChatOverlayState();
}

class _LiveChatOverlayState extends State<LiveChatOverlay> {
  late WebSocketChannel _channel;
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    final wsUrl = '${Env.wsBaseUrl}/ws/live/${widget.liveId}/?token=${widget.token}';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel.stream.listen((data) {
      setState(() {
        _messages.add(_ChatMessage(text: data.toString(), isMine: false));
      });
      _scrollToBottom();
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    _channel.sink.add(_controller.text.trim());
    setState(() {
      _messages.add(_ChatMessage(text: _controller.text.trim(), isMine: true));
    });
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: _messages.length,
            itemBuilder: (_, i) {
              final msg = _messages[i];
              return Align(
                alignment: msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: msg.isMine ? BuddyColors.green.withValues(alpha: 0.2) : BuddyColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    msg.text,
                    style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 13),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: BuddyColors.black,
            border: Border(top: BorderSide(color: BuddyColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Chat...',
                    hintStyle: const TextStyle(color: BuddyColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: BuddyColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: BuddyColors.green, size: 20),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMine;
  _ChatMessage({required this.text, required this.isMine});
}
