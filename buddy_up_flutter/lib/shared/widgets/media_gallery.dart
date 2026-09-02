import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/post.dart';
import 'caption_overlay.dart';

class MediaGallery extends StatelessWidget {
  final List<String> urls;
  final List<String>? types;

  /// Typed media objects (video/image with poster, trim, captions). When
  /// present, renders a PageView carousel with dots; otherwise the legacy
  /// url-based layouts are used.
  final List<PostMedia>? media;

  /// Owning post id, used to deep link into Bud Press for full playback.
  final String? postId;

  const MediaGallery({
    super.key,
    required this.urls,
    this.types,
    this.media,
    this.postId,
  });

  @override
  Widget build(BuildContext context) {
    if (media != null && media!.isNotEmpty) {
      return _MediaCarousel(media: media!, postId: postId);
    }
    if (urls.isEmpty) return const SizedBox.shrink();
    if (urls.length == 1) return _buildSingle(context, urls.first);
    if (urls.length == 2) return _buildPair(context);
    if (urls.length == 3) return _buildTriplet(context);
    return _buildGrid(context);
  }

  Widget _buildSingle(BuildContext context, String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: _buildMedia(url, context, height: 300),
    );
  }

  Widget _buildPair(BuildContext context) {
    return Row(
      children: urls.map((url) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            left: urls.indexOf(url) == 1 ? 4 : 0,
            right: urls.indexOf(url) == 0 ? 4 : 0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildMedia(url, context, height: 200),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildTriplet(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildMedia(urls[0], context, height: 200),
        ),
        const SizedBox(height: 4),
        Row(
          children: urls.sublist(1).map((url) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: urls.indexOf(url) == 2 ? 4 : 0,
                right: urls.indexOf(url) == 1 ? 4 : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildMedia(url, context, height: 120),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: urls.take(9).map((url) {
        final index = urls.indexOf(url);
        return GestureDetector(
          onTap: () => _openLightbox(context, index),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildMedia(url, context, height: 120),
              ),
              if (index == 8 && urls.length > 9)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+${urls.length - 9}',
                      style: const TextStyle(
                        color: BuddyColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMedia(String url, BuildContext context, {double? height}) {
    final isVideo = url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.webm');
    return SizedBox(
      height: height,
      width: double.infinity,
      child: isVideo
          ? _videoPlaceholder(url)
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: BuddyColors.surfaceRaised),
              errorWidget: (_, _, _) => Container(
                color: BuddyColors.surfaceRaised,
                child: const Icon(Icons.broken_image, color: BuddyColors.textSecondary),
              ),
            ),
    );
  }

  Widget _videoPlaceholder(String url) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, _) => Container(color: BuddyColors.surfaceRaised),
          errorWidget: (_, _, _) => Container(color: BuddyColors.surfaceRaised),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.black38,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
        ),
      ],
    );
  }

  void _openLightbox(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => _LightboxPage(urls: urls, initialIndex: index),
    );
  }
}

/// Carousel over typed media objects with dots, inline (muted) video
/// playback and a Bud Press hand-off for full-screen sound-on playback.
class _MediaCarousel extends StatefulWidget {
  final List<PostMedia> media;
  final String? postId;

  const _MediaCarousel({required this.media, this.postId});

  @override
  State<_MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<_MediaCarousel> {
  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openInBudPress() {
    if (widget.postId == null) return;
    context.push('/feed/bud-press?post=${widget.postId}');
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.media;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 300,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) {
                final item = items[i];
                if (item.isVideo) {
                  return _InlineVideoPage(
                    media: item,
                    onOpenFullscreen: _openInBudPress,
                  );
                }
                return GestureDetector(
                  child: CachedNetworkImage(
                    imageUrl: item.url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (_, _) =>
                        Container(color: BuddyColors.surfaceRaised),
                    errorWidget: (_, _, _) => Container(
                      color: BuddyColors.surfaceRaised,
                      child: const Icon(
                        Icons.broken_image,
                        color: BuddyColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (items.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(items.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? BuddyColors.green : BuddyColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

/// Lazy inline video: shows poster + play overlay until tapped, then plays
/// muted via media_kit. Tap toggles play/pause; the corner button hands off
/// to Bud Press for full-screen playback.
class _InlineVideoPage extends StatefulWidget {
  final PostMedia media;
  final VoidCallback onOpenFullscreen;

  const _InlineVideoPage({
    required this.media,
    required this.onOpenFullscreen,
  });

  @override
  State<_InlineVideoPage> createState() => _InlineVideoPageState();
}

class _InlineVideoPageState extends State<_InlineVideoPage> {
  Player? _player;
  VideoController? _controller;
  StreamSubscription<Duration>? _positionSub;
  bool _started = false;
  bool _playing = false;
  int _positionMs = 0;

  @override
  void dispose() {
    _positionSub?.cancel();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_started) return;
    if (widget.media.url.isEmpty) return;
    final player = Player();
    _player = player;
    _controller = VideoController(player);
    _positionSub = player.stream.position.listen((p) {
      if (!mounted) return;
      setState(() => _positionMs = p.inMilliseconds);
      final startMs = widget.media.trimStartMs;
      final endMs = widget.media.trimEndMs;
      if (endMs != null && startMs != null && endMs > startMs &&
          p.inMilliseconds >= endMs) {
        player.seek(Duration(milliseconds: startMs));
      }
    });
    player.stream.playing.listen((p) {
      if (mounted) setState(() => _playing = p);
    });
    await player.setVolume(0); // muted inline autoplay parity
    await player.open(Media(widget.media.url), play: true);
    if (mounted) setState(() => _started = true);
  }

  void _toggle() {
    final player = _player;
    if (player == null) return;
    if (player.state.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  int get _trimStartMs => widget.media.trimStartMs ?? 0;

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final endMs = widget.media.trimEndMs;
    final positionMs = _positionMs < _trimStartMs ? _trimStartMs : _positionMs;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_started && controller != null)
          GestureDetector(
            onTap: _toggle,
            child: Video(
              controller: controller,
              fit: BoxFit.cover,
              controls: NoVideoControls,
            ),
          )
        else
          GestureDetector(
            onTap: _start,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.media.posterUrl ?? widget.media.url,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: BuddyColors.surfaceRaised),
                  errorWidget: (_, _, _) => Container(
                    color: BuddyColors.surfaceRaised,
                    child: const Icon(
                      Icons.videocam_off,
                      color: BuddyColors.textSecondary,
                    ),
                  ),
                ),
                const Center(
                  child: Icon(Icons.play_arrow, color: Colors.white70, size: 56),
                ),
              ],
            ),
          ),
        if (_started && !_playing)
          const Center(
            child: Icon(Icons.pause_circle_outline, color: Colors.white70, size: 56),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.black38),
            icon: const Icon(Icons.fullscreen, color: Colors.white, size: 22),
            tooltip: 'Open in Bud Press',
            onPressed: widget.onOpenFullscreen,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: CaptionOverlay(
            captions: widget.media.captions,
            positionMs: positionMs,
          ),
        ),
        if (endMs != null && endMs > _trimStartMs)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LinearProgressIndicator(
              value: (positionMs / endMs).clamp(0.0, 1.0),
              minHeight: 2,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(BuddyColors.green),
            ),
          ),
      ],
    );
  }
}

class _LightboxPage extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  const _LightboxPage({required this.urls, required this.initialIndex});

  @override
  State<_LightboxPage> createState() => _LightboxPageState();
}

class _LightboxPageState extends State<_LightboxPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.urls.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.urls.length,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemBuilder: (_, i) {
            return InteractiveViewer(
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.urls[i],
                  fit: BoxFit.contain,
                  placeholder: (_, _) => const CircularProgressIndicator(),
                  errorWidget: (_, _, _) => const Icon(Icons.broken_image, color: Colors.white54, size: 64),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
