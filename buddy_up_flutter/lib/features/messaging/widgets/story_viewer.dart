import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/messaging.dart';
import '../../../shared/widgets/avatar.dart';
import 'story_strip.dart';

/// Fullscreen story viewer for the messages surface. Auto-advances every
/// 5s per story; tap zones navigate; marks stories seen on view.
class StoryViewer extends StatefulWidget {
  final List<StoryReel> reels;
  final int initialReelIndex;
  final Set<String> seenIds;

  const StoryViewer({
    super.key,
    required this.reels,
    required this.initialReelIndex,
    required this.seenIds,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  late int _reelIndex;
  late int _storyIndex;
  Timer? _advanceTimer;
  late AnimationController _segmentController;
  Player? _player;
  VideoController? _videoController;

  StoryReel get _reel => widget.reels[_reelIndex];
  Story get _story => _reel.stories[_storyIndex];

  @override
  void initState() {
    super.initState();
    _reelIndex = widget.initialReelIndex.clamp(0, widget.reels.length - 1);
    _storyIndex = 0;
    _segmentController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();
    _openCurrent();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _segmentController.dispose();
    _disposeVideo();
    super.dispose();
  }

  Future<void> _disposeVideo() async {
    _advanceTimer?.cancel();
    final player = _player;
    _player = null;
    _videoController = null;
    await player?.dispose();
  }

  void _openCurrent() {
    _advanceTimer?.cancel();
    widget.seenIds.add(_story.id);
    saveSeenStories(widget.seenIds);
    _maybeLoadVideo();
    _segmentController
      ..reset()
      ..forward();
    _advanceTimer = Timer(const Duration(seconds: 5), _next);
    if (mounted) setState(() {});
  }

  void _maybeLoadVideo() {
    final url = _story.mediaUrls.isNotEmpty ? _story.mediaUrls.first : '';
    if (!_isVideo(url)) {
      _disposeVideo();
      return;
    }
    _player = Player();
    _videoController = VideoController(_player!);
    _player!.setVolume(100);
    _player!.open(Media(url), play: true);
  }

  bool _isVideo(String url) {
    final path = url.split('?').first.toLowerCase();
    return path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.webm') || path.endsWith('.m4v');
  }

  void _next() {
    if (_storyIndex + 1 < _reel.stories.length) {
      setState(() => _storyIndex++);
      _openCurrent();
      return;
    }
    if (_reelIndex + 1 < widget.reels.length) {
      setState(() {
        _reelIndex++;
        _storyIndex = 0;
      });
      _openCurrent();
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _previous() {
    if (_storyIndex > 0) {
      setState(() => _storyIndex--);
      _openCurrent();
      return;
    }
    if (_reelIndex > 0) {
      setState(() {
        _reelIndex--;
        _storyIndex = _reel.stories.length - 1;
      });
      _openCurrent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = _story;
    final mediaUrl = story.mediaUrls.isNotEmpty ? story.mediaUrls.first : '';
    final isVideo = _isVideo(mediaUrl);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Media — image fills the frame, squarish bodies degrade to a caption card.
            Positioned.fill(
              child: mediaUrl.isEmpty
                  ? _buildTextCard(story)
                  : isVideo && _videoController != null
                      ? Video(controller: _videoController!)
                      : CachedNetworkImage(
                          imageUrl: mediaUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              const Center(child: CircularProgressIndicator(color: BuddyColors.green)),
                          errorWidget: (_, _, _) => _buildTextCard(story),
                        ),
            ),
            // Soft top/bottom scrims so chrome text stays legible.
            const Positioned(top: 0, left: 0, right: 0, height: 110, child: _TopScrim()),
            if (story.body.isNotEmpty)
              const Positioned(bottom: 0, left: 0, right: 0, height: 140, child: _BottomScrim()),
            // Tap zones: left third = previous, right third = next.
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Semantics(
                      button: true,
                      label: 'Previous story',
                      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _previous),
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                  Expanded(
                    flex: 1,
                    child: Semantics(
                      button: true,
                      label: 'Next story',
                      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _next),
                    ),
                  ),
                ],
              ),
            ),
            // Progress segments — the current one sweeps left→right over 5s.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: List<Widget>.generate(_reel.stories.length, (i) {
                  final filled = i < _storyIndex;
                  final current = i == _storyIndex;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: AnimatedBuilder(
                        animation: _segmentController,
                        builder: (_, _) {
                          final factor = filled
                              ? 1.0
                              : current
                                  ? _segmentController.value
                                  : 0.0;
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: factor,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Header: avatar, name, time, close.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 22, 8, 0),
              child: Row(
                children: [
                  Avatar(
                    src: _reel.user.avatarUrl,
                    alt: _reel.user.displayName,
                    size: AvatarSize.sm,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _reel.user.displayName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_story.createdAt.isNotEmpty)
                          Text(
                            _timeAgo(_story.createdAt),
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            // Caption.
            if (story.body.isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 28,
                child: Text(
                  story.body,
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.35),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextCard(Story story) {
    if (story.body.isEmpty) {
      return const Center(
        child: Icon(Icons.auto_stories_outlined, color: BuddyColors.textSecondary, size: 56),
      );
    }
    return Container(
      color: BuddyColors.surface,
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      child: Text(
        story.body,
        textAlign: TextAlign.center,
        style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 22, height: 1.4),
      ),
    );
  }

  String _timeAgo(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat.MMMd().format(dt);
  }
}

class _TopScrim extends StatelessWidget {
  const _TopScrim();
  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
      );
}

class _BottomScrim extends StatelessWidget {
  const _BottomScrim();
  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
      );
}
