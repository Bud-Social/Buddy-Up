import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';
import '../services/live_socket.dart';

const _reactionEmojis = ['😂', '❤️', '🔥', '👏', '😮', '😢', '👍', '🎉'];

/// The live room's chat — same protocol as the web: newest at the bottom,
/// auto-stick when at the end, jump-to-latest pill with unseen count when
/// not, emoji reactions that hit the float overlay, gift system lines.
class LiveChatOverlay extends ConsumerStatefulWidget {
  final String liveId;
  /// Called with the chosen emoji — the room floats it (and sends).
  final void Function(String emoji) onReaction;

  const LiveChatOverlay({
    super.key,
    required this.liveId,
    required this.onReaction,
  });

  @override
  ConsumerState<LiveChatOverlay> createState() => _LiveChatOverlayState();
}

class _LiveChatOverlayState extends ConsumerState<LiveChatOverlay> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _atBottom = true;
  int _unseen = 0;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final atBottom = _scrollController.offset <= 40;
    if (atBottom != _atBottom) {
      setState(() {
        _atBottom = atBottom;
        if (atBottom) _unseen = 0;
      });
    }
  }

  void _jumpToLatest() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    setState(() => _unseen = 0);
  }

  void _maybeAutoScroll(int messageCount) {
    final grew = messageCount > _lastMessageCount;
    final added = messageCount - _lastMessageCount;
    _lastMessageCount = messageCount;
    if (!grew) return;
    if (_atBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(0,
              duration: const Duration(milliseconds: 180), curve: Curves.easeOut);
        }
      });
    } else {
      setState(() => _unseen += added);
    }
  }

  void _sendChat() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    ref.read(liveSocketProvider(widget.liveId).notifier).sendChat(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final socket = ref.watch(liveSocketProvider(widget.liveId));
    _maybeAutoScroll(socket.chatMessages.length);
    final reversed = socket.chatMessages.reversed.toList(growable: false);

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                itemCount: reversed.length,
                itemBuilder: (_, i) => _buildLine(reversed[i]),
              ),
            ),
            _buildInput(),
          ],
        ),
        if (!_atBottom)
          Positioned(
            right: 10,
            bottom: 64,
            child: _JumpToLatest(unseen: _unseen, onTap: _jumpToLatest),
          ),
      ],
    );
  }

  Widget _buildLine(LiveChatMessage line) {
    // System lines ("X joined the live") render centered and muted.
    if (line.system != null || (line.gift != null && line.userId == null)) {
      final text = line.message.isNotEmpty ? line.message : (line.system ?? '');
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ),
        ),
      );
    }
    if (line.gift != null) {
      final g = line.gift!;
      final artifact = (g['artifact_type'] ?? 'gift').toString();
      final quantity = (g['quantity'] as num?)?.toInt() ?? 1;
      final total = (g['total'] as num?)?.toInt() ?? 0;
      final sender = (g['sender_name'] ?? line.displayName).toString();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: BuddyColors.gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BuddyColors.gold.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.card_giftcard, size: 13, color: BuddyColors.gold),
                const SizedBox(width: 6),
                Text(
                  '$sender sent ${_prettyArtifact(artifact)} ×$quantity'
                  '${total > 0 ? ' (+$total)' : ''}',
                  style: const TextStyle(
                    color: Color(0xFFFDE68A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final mine = line.userId != null && line.userId == ref.read(authProvider).user?.id;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!mine) ...[
            CircleAvatar(
              radius: 11,
              backgroundColor: BuddyColors.surfaceRaised,
              backgroundImage: line.avatarUrl.isNotEmpty ? NetworkImage(line.avatarUrl) : null,
              child: line.avatarUrl.isEmpty
                  ? Text(
                      line.displayName.isNotEmpty ? line.displayName[0].toUpperCase() : '?',
                      style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 10),
                    )
                  : null,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: mine
                    ? BuddyColors.green.withValues(alpha: 0.18)
                    : BuddyColors.surfaceRaised.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 12.5, height: 1.3),
                  children: [
                    if (!mine && line.displayName.isNotEmpty)
                      TextSpan(
                        text: '${line.displayName}  ',
                        style: const TextStyle(
                          color: BuddyColors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    TextSpan(text: line.message),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _prettyArtifact(String artifact) {
    if (artifact.isEmpty) return 'Gift';
    return artifact[0].toUpperCase() + artifact.substring(1).replaceAll('_', ' ');
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      color: Colors.black.withValues(alpha: 0.55),
      child: Row(
        children: [
          _EmojiButton(onPicked: widget.onReaction),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendChat(),
              decoration: InputDecoration(
                hintText: 'Chat…',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
                isDense: true,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _sendChat,
            icon: const Icon(Icons.send_rounded, color: BuddyColors.green, size: 22),
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}

/// Floating "jump to latest" pill — shows how many unseen lines piled up
/// while the viewer was scrolled up.
class _JumpToLatest extends StatelessWidget {
  final int unseen;
  final VoidCallback onTap;

  const _JumpToLatest({required this.unseen, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BuddyColors.green,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.keyboard_arrow_down_rounded, color: BuddyColors.black),
            ),
            if (unseen > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(color: BuddyColors.red, shape: BoxShape.circle),
                  child: Text(
                    '$unseen',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Single reaction button that unfolds the 8-emoji row — one tap to fire.
class _EmojiButton extends StatefulWidget {
  final void Function(String emoji) onPicked;

  const _EmojiButton({required this.onPicked});

  @override
  State<_EmojiButton> createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<_EmojiButton> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_open)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final e in _reactionEmojis)
                  GestureDetector(
                    onTap: () {
                      widget.onPicked(e);
                      setState(() => _open = false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Text(e, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
              ],
            ),
          ),
        IconButton(
          onPressed: () => setState(() => _open = !_open),
          icon: Icon(
            _open ? Icons.close : Icons.emoji_emotions_outlined,
            color: BuddyColors.gold,
            size: 26,
          ),
          tooltip: 'Reactions',
        ),
      ],
    );
  }
}
