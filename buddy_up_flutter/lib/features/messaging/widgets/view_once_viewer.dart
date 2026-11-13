import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/messaging.dart';

/// Fullscreen viewer for a view-once message — the one and only look the
/// recipient gets. Closing it tombstones the bubble until the next fetch
/// withholds the media URL entirely.
class ViewOnceViewer extends StatefulWidget {
  final Message message;

  const ViewOnceViewer({super.key, required this.message});

  @override
  State<ViewOnceViewer> createState() => _ViewOnceViewerState();
}

class _ViewOnceViewerState extends State<ViewOnceViewer> {
  Player? _player;
  VideoController? _videoController;

  bool get _isVideo {
    final mime = widget.message.mediaMime.toLowerCase();
    if (mime.startsWith('video/')) return true;
    final path = widget.message.mediaUrl.split('?').first.toLowerCase();
    return path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.webm') || path.endsWith('.m4v');
  }

  @override
  void initState() {
    super.initState();
    if (_isVideo) {
      _player = Player();
      _videoController = VideoController(_player!);
      _player!.open(Media(widget.message.mediaUrl), play: true);
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _isVideo
                ? Video(controller: _videoController!)
                : CachedNetworkImage(
                    imageUrl: msg.mediaUrl,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => const Center(
                      child: CircularProgressIndicator(color: BuddyColors.green),
                    ),
                    errorWidget: (_, _, _) => const Center(
                      child: Icon(Icons.broken_image_outlined, size: 56, color: Colors.white54),
                    ),
                  ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            right: 8,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              tooltip: 'Close',
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 20,
            child: const Text(
              'View-once — this can’t be viewed again',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
