import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_kit/media_kit.dart';
import '../../../data/models/messaging.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';
import 'message_reaction_bar.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMine;
  final bool showSender;
  final void Function()? onReply;
  final void Function(String emoji)? onReact;
  final void Function()? onDelete;
  final void Function()? onForward;
  final void Function(Message message)? onOpenViewOnce;
  final Color? senderBubbleColor;
  final Color? receiverBubbleColor;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.showSender = true,
    this.onReply,
    this.onReact,
    this.onDelete,
    this.onForward,
    this.onOpenViewOnce,
    this.senderBubbleColor,
    this.receiverBubbleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Column(
        crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSender && !isMine)
            Padding(
              padding: const EdgeInsets.only(left: 44, bottom: 2),
              child: Text(
                message.senderData.displayName,
                style: const TextStyle(color: BuddyColors.green, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMine && showSender)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Avatar(src: message.senderData.avatarUrl, alt: message.senderData.displayName, size: AvatarSize.xs),
                ),
              if (!isMine && !showSender) const SizedBox(width: 36),
              Flexible(
                child: GestureDetector(
                  onLongPress: () => _showActions(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMine
                          ? (senderBubbleColor ?? BuddyColors.green.withValues(alpha: 0.15))
                          : (receiverBubbleColor ?? BuddyColors.surface),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMine ? 16 : 4),
                        bottomRight: Radius.circular(isMine ? 4 : 16),
                      ),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.replyToId != null && message.replyData != null)
                          _buildReplyPreview(),
                        _buildContent(),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.createdAt),
                              style: TextStyle(color: isMine ? BuddyColors.textSecondary.withValues(alpha: 0.7) : BuddyColors.textSecondary, fontSize: 10),
                            ),
                            if (isMine) ...[
                              const SizedBox(width: 4),
                              Icon(
                                message.isRead ? Icons.check_circle : Icons.check_circle_outline,
                                size: 12,
                                color: message.isRead ? BuddyColors.green : BuddyColors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                        if (message.reactions.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Align(
                            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                            child: MessageReactionBar(reactions: message.reactions),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMine ? BuddyColors.green.withValues(alpha: 0.1) : BuddyColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: BuddyColors.green, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.replyData!.senderName,
            style: const TextStyle(color: BuddyColors.green, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Text(
            message.replyData!.body.isNotEmpty ? message.replyData!.body : '📎 ${message.replyData!.messageType}',
            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// View-once, recipient side: a pill until opened; a tombstone after. The
  /// sender always sees the media itself with a 1× badge.
  Widget? _buildViewOnceGate() {
    if (isMine || !message.viewOnce) return null;
    final opened = message.viewOnceOpenedAt != null;
    if (opened) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_off_outlined,
              size: 17, color: BuddyColors.textSecondary.withValues(alpha: 0.75)),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Opened',
                  style: TextStyle(
                      color: BuddyColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
              Text('View-once · media no longer available',
                  style: TextStyle(color: BuddyColors.textSecondary, fontSize: 10)),
            ],
          ),
        ],
      );
    }
    return InkWell(
      onTap: onOpenViewOnce == null ? null : () => onOpenViewOnce!(message),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0x264ADE80), // buddy green ~15%
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.visibility_outlined, color: BuddyColors.green, size: 18),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('View once',
                    style: TextStyle(
                        color: BuddyColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                Text('Tap to view',
                    style: TextStyle(color: BuddyColors.textSecondary, fontSize: 10)),
              ],
            ),
            const SizedBox(width: 10),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: BuddyColors.green, shape: BoxShape.circle),
              child: const Center(
                child: Text('1×', style: TextStyle(color: BuddyColors.black, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        message.mediaUrl,
        fit: BoxFit.cover,
        width: 200,
        height: 200,
        errorBuilder: (_, _, _) => Container(
          width: 200, height: 200,
          color: BuddyColors.surfaceRaised,
          child: const Icon(Icons.broken_image, color: BuddyColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildVideo() {
    final thumb = message.mediaUrl.isNotEmpty ? message.mediaUrl : null;
    return Container(
      width: 200, height: 150,
      decoration: BoxDecoration(
        color: BuddyColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (thumb != null)
            Image.network(thumb, fit: BoxFit.cover, width: 200, height: 150,
              errorBuilder: (_, _, _) => Container(color: BuddyColors.surfaceRaised),
            ),
          Container(
            decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  /// Sender's own view-once media: normal media + a 1× badge + the state.
  Widget _withViewOnceBadge(Widget child) {
    if (!message.viewOnce || !isMine) return child;
    final opened = message.viewOnceOpenedAt != null;
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        child,
        Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '1× · ${opened ? 'Opened' : 'Not opened'}',
              style: const TextStyle(color: BuddyColors.green, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final gated = _buildViewOnceGate();
    if (gated != null) return gated;

    switch (message.messageType) {
      case 'text':
        return Text(
          message.body,
          style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 15),
        );
      case 'image':
      case 'photo':
        return _withViewOnceBadge(_buildPhoto());
      case 'video':
        return _withViewOnceBadge(_buildVideo());
      case 'file':
      case 'document':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file, color: BuddyColors.green, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message.fileName.isNotEmpty ? message.fileName : 'File',
                    style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  if (message.mediaMime.isNotEmpty)
                    Text(message.mediaMime, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        );
      case 'voice':
        final durMs = (message.metadata['duration_ms'] as num?)?.toInt()
            ?? (message.metadata['duration'] as num?)?.toInt()
            ?? 0;
        return _withViewOnceBadge(_VoiceBubble(message: message, durationMs: durMs, isMine: isMine));
      case 'location':
        return Container(
          width: 200,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: BuddyColors.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: BuddyColors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message.body.isNotEmpty ? message.body : 'Location',
                  style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14)),
              ),
            ],
          ),
        );
      case 'poll':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: BuddyColors.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.poll, color: BuddyColors.green, size: 18),
              const SizedBox(height: 4),
              Text(message.body, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14)),
            ],
          ),
        );
      default:
        return Text(message.body, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 15));
    }
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply, color: BuddyColors.textSecondary),
              title: const Text('Reply', style: TextStyle(color: BuddyColors.textPrimary)),
              onTap: () { Navigator.pop(context); onReply?.call(); },
            ),
            ListTile(
              leading: const Icon(Icons.forward, color: BuddyColors.textSecondary),
              title: const Text('Forward', style: TextStyle(color: BuddyColors.textPrimary)),
              onTap: () { Navigator.pop(context); onForward?.call(); },
            ),
            if (isMine)
              ListTile(
                leading: const Icon(Icons.delete, color: BuddyColors.red),
                title: const Text('Delete', style: TextStyle(color: BuddyColors.red)),
                onTap: () { Navigator.pop(context); onDelete?.call(); },
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return DateFormat.jm().format(dt);
  }
}

/// Compact voice bubble: play/pause + duration. Tap once to play.
class _VoiceBubble extends StatefulWidget {
  final Message message;
  final int durationMs;
  final bool isMine;

  const _VoiceBubble({required this.message, required this.durationMs, required this.isMine});

  @override
  State<_VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<_VoiceBubble> {
  Player? _player;
  bool _playing = false;
  bool _loading = false;
  StreamSubscription<bool>? _playingSub;

  @override
  void dispose() {
    _playingSub?.cancel();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_loading) return;
    if (_player != null) {
      if (_playing) {
        await _player!.pause();
      } else {
        await _player!.play();
      }
      return;
    }
    setState(() => _loading = true);
    final player = Player();
    _playingSub = player.stream.playing.listen((playing) {
      if (mounted) setState(() => _playing = playing);
    });
    await player.setVolume(100);
    await player.open(Media(widget.message.mediaUrl), play: true);
    if (!mounted) {
      await player.dispose();
      return;
    }
    setState(() {
      _player = player;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dur = widget.durationMs ~/ 1000;
    final formatted =
        '${(dur ~/ 60).toString().padLeft(2, '0')}:${(dur % 60).toString().padLeft(2, '0')}';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggle,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: BuddyColors.green),
                )
              : Icon(
                  _playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: BuddyColors.green,
                  size: 26,
                ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 100,
          height: 6,
          decoration: BoxDecoration(
            color: BuddyColors.surfaceRaised,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(formatted,
            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}
