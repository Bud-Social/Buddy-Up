import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/theme/app_theme.dart';

/// Fullscreen viewer for a view-once payload. The URL is handed over by the
/// consumption endpoint (not stored in the conversation payload), and the
/// viewer closes itself so the media is not left on screen indefinitely.
class ViewOnceViewer extends StatefulWidget {
  final String mediaUrl;
  final String mediaMime;
  final bool isAudio;

  const ViewOnceViewer({
    super.key,
    required this.mediaUrl,
    required this.mediaMime,
    this.isAudio = false,
  });

  @override
  State<ViewOnceViewer> createState() => _ViewOnceViewerState();
}

class _ViewOnceViewerState extends State<ViewOnceViewer> {
  Player? _player;
  VideoController? _videoController;
  Timer? _closeTimer;
  int _remaining = 15;

  bool get _isVideo {
    if (!widget.isAudio && widget.mediaMime.toLowerCase().startsWith('video/')) return true;
    final path = widget.mediaUrl.split('?').first.toLowerCase();
    return path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.webm') ||
        path.endsWith('.m4v');
  }

  @override
  void initState() {
    super.initState();
    if (widget.isAudio || _isVideo) {
      _player = Player();
      if (_isVideo) _videoController = VideoController(_player!);
      _player!.open(Media(widget.mediaUrl), play: true);
    }
    _closeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: widget.isAudio
                ? _buildAudio()
                : _isVideo
                    ? Video(controller: _videoController!)
                    : CachedNetworkImage(
                        imageUrl: widget.mediaUrl,
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
            child: Text(
              'View once · closes in $_remaining s',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudio() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.graphic_eq, color: BuddyColors.green, size: 64),
          const SizedBox(height: 24),
          StreamBuilder<bool>(
            stream: _player!.stream.playing,
            initialData: false,
            builder: (context, snapshot) => IconButton(
              onPressed: () => _player!.playOrPause(),
              iconSize: 48,
              color: Colors.white,
              icon: Icon(snapshot.data == true ? Icons.pause_circle : Icons.play_circle),
            ),
          ),
          const SizedBox(height: 12),
          const Text('View-once voice note', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
