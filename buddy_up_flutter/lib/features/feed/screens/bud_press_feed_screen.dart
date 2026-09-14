import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/post.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/caption_overlay.dart';
import '../../../shared/widgets/creative_overlays.dart';
import '../../../shared/widgets/track_audio_mixer.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/toast.dart';
import '../providers/feed_provider.dart';
import '../widgets/share_sheet.dart';

/// Full-screen vertical video feed (Bud Press) over the `videos` tab posts.
///
/// The active page auto-plays muted + looped; tap toggles play/pause, an
/// unmute button lives top-right, right-rail carries like/save/comment and
/// the bottom shows author + caption. Photo posts (multi-item or image
/// media) render as a horizontal swipeable carousel instead.
class BudPressFeedScreen extends ConsumerStatefulWidget {
  /// Optional post to land on (deep link from inline video players).
  final String? initialPostId;

  const BudPressFeedScreen({super.key, this.initialPostId});

  @override
  ConsumerState<BudPressFeedScreen> createState() =>
      _BudPressFeedScreenState();
}

class _BudPressFeedScreenState extends ConsumerState<BudPressFeedScreen> {
  final PageController _pageController = PageController();
  int _index = 0;
  bool _muted = true;
  bool _jumpedToInitialPost = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(feedProvider);
      if (state.activeTab != 'videos' || state.posts.isEmpty) {
        ref.read(feedProvider.notifier).loadFeed(tab: 'videos');
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _maybeJumpToInitialPost(List<Post> posts) {
    if (_jumpedToInitialPost || widget.initialPostId == null) return;
    final target = posts.indexWhere((p) => p.id == widget.initialPostId);
    if (target < 0) return;
    _jumpedToInitialPost = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.jumpToPage(target);
      setState(() => _index = target);
    });
  }

  void _onPageChanged(int i, int itemCount, bool hasMore) {
    setState(() => _index = i);
    if (i >= itemCount - 1 && hasMore) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);
    final notifier = ref.read(feedProvider.notifier);

    if (state.isLoading && state.posts.isEmpty) {
      return const Scaffold(backgroundColor: Colors.black, body: PageLoader());
    }
    if (state.error != null && state.posts.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: ErrorView(
          message: state.error!,
          onRetry: () => notifier.loadFeed(tab: 'videos'),
        ),
      );
    }
    if (state.posts.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Bud Press'),
        ),
        body: const Center(
          child: Text(
            'No videos yet',
            style: TextStyle(color: BuddyColors.textSecondary),
          ),
        ),
      );
    }

    final posts = state.posts;
    _maybeJumpToInitialPost(posts);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Bud Press',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: posts.length,
        onPageChanged: (i) => _onPageChanged(i, posts.length, state.hasMore),
        itemBuilder: (context, i) {
          final post = posts[i];
          return _isVideoPost(post)
              ? _BudPressVideoPage(
                  post: post,
                  active: i == _index,
                  muted: _muted,
                  onToggleMute: () => setState(() => _muted = !_muted),
                )
              : _BudPressPhotoPage(post: post);
        },
      ),
    );
  }

  /// Single-video posts play inline; everything else (multi-item or image
  /// media, or legacy url-only posts) uses the photo carousel.
  bool _isVideoPost(Post post) {
    if (post.media.isNotEmpty) {
      return post.media.length == 1 && post.media.first.isVideo;
    }
    return post.mediaUrls.length == 1 && _looksLikeVideo(post.mediaUrls.first);
  }

  static bool _looksLikeVideo(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.contains('/video/upload');
  }
}

/// Bottom overlay shared by video and photo pages.
class _PostMeta extends ConsumerStatefulWidget {
  final Post post;
  final VoidCallback onProfileTap;

  const _PostMeta({required this.post, required this.onProfileTap});

  @override
  ConsumerState<_PostMeta> createState() => _PostMetaState();
}

class _PostMetaState extends ConsumerState<_PostMeta> {
  bool _following = false;
  bool _pending = false;

  Post get _post => widget.post;

  static String _count(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '${(n / 1000000).toStringAsFixed(1)}m';
  }

  Future<void> _toggleFollow() async {
    if (_pending) return;
    setState(() {
      _pending = true;
      _following = !_following;
    });
    try {
      final repo = ProfileRepository(ApiClient().dio);
      if (_following) {
        await repo.followUser(_post.authorData.username);
      } else {
        await repo.unfollowUser(_post.authorData.username);
      }
    } catch (_) {
      if (mounted) setState(() => _following = !_following);
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: widget.onProfileTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Avatar(
                        src: post.authorData.avatarUrl,
                        alt: post.authorData.displayName,
                        size: AvatarSize.sm,
                        verificationStatus: post.authorData.verificationStatus,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            post.authorData.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '@${post.authorData.username}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility_outlined,
                        color: Colors.white70, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      _count(post.viewCount),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _pending ? null : _toggleFollow,
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        _following ? Colors.white70 : BuddyColors.green,
                    side: BorderSide(
                      color: _following ? Colors.white38 : BuddyColors.green,
                    ),
                    minimumSize: const Size(0, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(_following ? 'Following' : 'Follow'),
                ),
              ],
            ),
            if (post.body.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                post.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Right-rail action buttons (like / repost / save / comment / share / views).
class _ActionRail extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onRepost;
  final VoidCallback onSave;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const _ActionRail({
    required this.post,
    required this.onLike,
    required this.onRepost,
    required this.onSave,
    required this.onComment,
    required this.onShare,
  });

  static String _count(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '${(n / 1000000).toStringAsFixed(1)}m';
  }

  @override
  Widget build(BuildContext context) {
    final likes = post.reactionCounts.values.fold(0, (a, b) => a + b);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RailButton(
          icon: post.userReaction != null ? Icons.favorite : Icons.favorite_border,
          color: post.userReaction != null ? BuddyColors.red : Colors.white,
          label: _count(likes),
          onTap: onLike,
        ),
        const SizedBox(height: 18),
        _RailButton(
          icon: Icons.chat_bubble_outline,
          color: Colors.white,
          label: _count(post.commentCount),
          onTap: onComment,
        ),
        const SizedBox(height: 18),
        _RailButton(
          icon: Icons.repeat,
          color: post.isRepostedByMe ? BuddyColors.green : Colors.white,
          label: _count(post.repostCount),
          onTap: onRepost,
        ),
        const SizedBox(height: 18),
        _RailButton(
          icon: post.isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: post.isSaved ? BuddyColors.gold : Colors.white,
          label: _count(post.saveCount),
          onTap: onSave,
        ),
        const SizedBox(height: 18),
        _RailButton(
          icon: Icons.share_outlined,
          color: Colors.white,
          label: _count(post.shareCount),
          onTap: onShare,
        ),
        const SizedBox(height: 18),
        _RailButton(
          icon: Icons.visibility_outlined,
          color: Colors.white,
          label: _count(post.viewCount),
          onTap: () {},
        ),
      ],
    );
  }
}

class _RailButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? label;
  final VoidCallback onTap;

  const _RailButton({
    required this.icon,
    required this.color,
    this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          if (label != null) ...[
            const SizedBox(height: 2),
            Text(
              label!,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shared rail actions (used by both video and photo pages).
void _openComments(BuildContext context, Post post) {
  if (post.commentsDisabled) {
    showToast(context, 'Comments are turned off for this post');
    return;
  }
  AnalyticsService.instance.track(
    'feed.post_opened',
    surface: 'bud_press',
    objectType: 'post',
    objectId: post.id,
    properties: {'feed_tab': 'videos'},
  );
  context.push('/feed/${post.id}');
}

Future<void> _reactToPost(WidgetRef ref, Post post) async {
  if (post.userReaction != null) return;
  try {
    final raw = await ref.read(feedRepositoryProvider).react(
          post.id,
          const ReactionInput(reactionType: 'fire'),
        );
    ref
        .read(feedProvider.notifier)
        .updatePostInList(Post.fromJson(raw['data'] as Map<String, dynamic>));
  } catch (_) {}
}

Future<void> _savePost(WidgetRef ref, Post post) async {
  final repo = ref.read(feedRepositoryProvider);
  try {
    if (post.isSaved) {
      await repo.unsave(post.id);
    } else {
      await repo.save(post.id, const SavePayload());
    }
    ref
        .read(feedProvider.notifier)
        .updatePostInList(post.copyWith(isSaved: !post.isSaved));
  } catch (_) {}
}

/// One full-screen video page. The player is created per page and disposed
/// when the page scrolls out of the PageView cache; [active] gates playback.
class _BudPressVideoPage extends ConsumerStatefulWidget {
  final Post post;
  final bool active;
  final bool muted;
  final VoidCallback onToggleMute;

  const _BudPressVideoPage({
    required this.post,
    required this.active,
    required this.muted,
    required this.onToggleMute,
  });

  @override
  ConsumerState<_BudPressVideoPage> createState() => _BudPressVideoPageState();
}

class _BudPressVideoPageState extends ConsumerState<_BudPressVideoPage> {
  Player? _player;
  VideoController? _controller;
  StreamSubscription<Duration>? _positionSub;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  bool _opened = false;
  bool _viewRecorded = false;
  int _activePlayMs = 0;
  int _lastTickMs = 0;
  Offset? _dragStart;
  final TrackAudioMixer _mixer = TrackAudioMixer();

  Post get _post => widget.post;
  PostMedia get _media => _post.media.isNotEmpty
      ? _post.media.first
      : PostMedia(url: _post.mediaUrls.first, mediaType: 'video');

  int get _trimStartMs => _media.trimStartMs ?? 0;
  int? get _trimEndMs => _media.trimEndMs;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  void _setupPlayer() {
    final player = Player();
    _player = player;
    _controller = VideoController(player);
    _positionSub = player.stream.position.listen(_onPosition);
    player.stream.duration.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    player.stream.playing.listen((p) {
      if (mounted) setState(() => _playing = p);
    });
    player.setVolume(widget.muted ? 0 : _soundVolume);
    _syncMixerTracks();
    if (widget.active) _startPlayback();
  }

  /// Parametric studio mix for this clip: added tracks + attached sound.
  void _syncMixerTracks() {
    final meta = _media.editMeta;
    final tracks = <TrackCue>[];
    final rawTracks = meta?['audio_tracks'];
    if (rawTracks is List) {
      var i = 0;
      for (final raw in rawTracks) {
        if (raw is! Map) continue;
        final url = raw['url'] as String?;
        if (url == null || url.isEmpty) continue;
        tracks.add(TrackCue(
          id: 'track-$i',
          url: url,
          volume: ((raw['volume'] as num?)?.toDouble() ?? 100),
          startMs: (raw['start_ms'] as num?)?.toInt() ?? 0,
          durationMs: (raw['duration_ms'] as num?)?.toInt(),
          fadeInMs: (raw['fade_in_ms'] as num?)?.toInt() ?? 0,
          fadeOutMs: (raw['fade_out_ms'] as num?)?.toInt() ?? 0,
          ducking: raw['ducking'] == true,
        ));
        i++;
      }
    }
    final soundUrl = _media.soundAudioUrl;
    if (soundUrl != null && soundUrl.isNotEmpty) {
      final placement = meta?['sound_placement'];
      final asMap = placement is Map ? placement : <String, dynamic>{};
      tracks.add(TrackCue(
        id: 'attached-sound',
        url: soundUrl,
        volume: _soundVolume,
        offsetMs: (asMap['start_ms'] as num?)?.toInt() ?? 0,
        fadeInMs: (asMap['fade_in_ms'] as num?)?.toInt() ?? 0,
        fadeOutMs: (asMap['fade_out_ms'] as num?)?.toInt() ?? 0,
      ));
    }
    _mixer.setTracks(tracks);
  }

  double get _soundVolume {
    final v = _media.soundVolume;
    if (v == null) return 100;
    return (v <= 1.0 ? v * 100 : v).clamp(0, 100).toDouble();
  }

  Future<void> _startPlayback() async {
    final player = _player;
    if (player == null) return;
    if (_media.url.isEmpty) return;
    if (!_opened) {
      await player.open(Media(_media.url), play: true);
      _opened = true;
    } else if (!player.state.playing) {
      await player.play();
    }
    setState(() => _playing = true);
  }

  void _onPosition(Duration position) {
    if (!mounted) return;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (widget.active && _playing && _lastTickMs > 0) {
      _activePlayMs += nowMs - _lastTickMs;
      if (!_viewRecorded && _activePlayMs >= 2000) {
        _viewRecorded = true;
        ref.read(feedProvider.notifier).recordViewById(_post.id);
      }
    }
    _lastTickMs = nowMs;
    setState(() => _position = position);
    // Keep the parametric mix glued to the video clock.
    unawaited(_mixer.sync(
      position.inMilliseconds,
      widget.active && _playing && !widget.muted,
    ));
    // Trim loop: jump back to the in-point when the out-point is crossed.
    final endMs = _trimEndMs;
    if (endMs != null && endMs > _trimStartMs) {
      if (position.inMilliseconds >= endMs) {
        _player?.seek(Duration(milliseconds: _trimStartMs));
      }
    }
  }

  void _togglePlayPause() {
    final player = _player;
    if (player == null) return;
    if (_playing) {
      player.pause();
      setState(() => _playing = false);
    } else {
      player.play();
      setState(() => _playing = true);
    }
  }

  /// Engagement targets the ORIGINAL on repost rows so counts never zero out.
  String get _engagementId =>
      _post.isRepost && _post.originalPostData != null ? _post.originalPostData!.id : _post.id;

  Map<String, int> get _engagementCounts =>
      _post.isRepost && _post.originalPostData != null
          ? _post.originalPostData!.reactionCounts
          : _post.reactionCounts;

  String? get _engagementReaction =>
      _post.isRepost && _post.originalPostData != null
          ? _post.originalPostData!.userReaction
          : _post.userReaction;

  void _patchEngagement({String? userReaction, Map<String, int>? counts}) {
    final orig = _post.originalPostData;
    final updated = _post.copyWith(
      userReaction: userReaction,
      reactionCounts: counts ?? _post.reactionCounts,
      originalPostData: orig == null
          ? null
          : orig.copyWith(
              userReaction: userReaction,
              reactionCounts: counts ?? orig.reactionCounts,
            ),
    );
    ref.read(feedProvider.notifier).updatePostInList(updated);
  }

  Future<void> _handleReact() async {
    const emoji = '💪';
    final counts = Map<String, int>.from(_engagementCounts);
    final prevReaction = _engagementReaction;
    final prevCounts = Map<String, int>.from(counts);
    if (prevReaction == emoji) {
      counts[emoji] = (counts[emoji] ?? 1) - 1;
      if (counts[emoji]! <= 0) counts.remove(emoji);
      _patchEngagement(userReaction: null, counts: counts);
      try {
        await ref.read(feedRepositoryProvider).unreact(_engagementId);
      } catch (_) {
        _patchEngagement(userReaction: prevReaction, counts: prevCounts);
      }
      return;
    }
    if (prevReaction != null) {
      counts[prevReaction] = (counts[prevReaction] ?? 1) - 1;
      if (counts[prevReaction]! <= 0) counts.remove(prevReaction);
    }
    counts[emoji] = (counts[emoji] ?? 0) + 1;
    _patchEngagement(userReaction: emoji, counts: counts);
    try {
      await ref
          .read(feedRepositoryProvider)
          .react(_engagementId, const ReactionInput(reactionType: emoji));
    } catch (_) {
      _patchEngagement(userReaction: prevReaction, counts: prevCounts);
    }
  }

  void _handleSave() => _savePost(ref, _post);

  void _handleRepost() {
    ref.read(feedProvider.notifier).toggleRepost(_post.id);
  }

  void _handleShare() => ShareSheet.show(context, _post);

  void _handleComment() => _openComments(context, _post);

  @override
  void didUpdateWidget(covariant _BudPressVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        _startPlayback();
      } else {
        _player?.pause();
        setState(() => _playing = false);
      }
    }
    if (widget.muted != oldWidget.muted) {
      _player?.setVolume(widget.muted ? 0 : _soundVolume);
      if (widget.muted) unawaited(_mixer.silence());
    }
    if (widget.post.id != oldWidget.post.id) _syncMixerTracks();
  }

  @override
  void deactivate() {
    _player?.pause();
    unawaited(_mixer.silence());
    super.deactivate();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _player?.dispose();
    unawaited(_mixer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final duration = _duration.inMilliseconds > 0
        ? _duration.inMilliseconds
        : (_media.durationMs ?? 0);
    final progress =
        duration > 0 ? (_position.inMilliseconds / duration).clamp(0.0, 1.0) : 0.0;
    // Engagement reflects the ORIGINAL on repost rows.
    final orig = _post.originalPostData;
    final engagement = _post.isRepost && orig != null
        ? _post.copyWith(
            reactionCounts: orig.reactionCounts,
            userReaction: orig.userReaction,
            commentCount: orig.commentCount,
            repostCount: orig.repostCount,
            saveCount: orig.saveCount,
            shareCount: orig.shareCount,
          )
        : _post;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null)
          GestureDetector(
            onTap: _togglePlayPause,
            onHorizontalDragStart: (d) => _dragStart = d.globalPosition,
            onHorizontalDragEnd: (d) {
              final start = _dragStart;
              _dragStart = null;
              if (start == null) return;
              final dx = d.globalPosition.dx - start.dx;
              final dy = (d.globalPosition.dy - start.dy).abs();
              // Deliberate left swipe opens the creator's profile.
              if (dx < -80 && dx.abs() > dy * 1.5) {
                context.push('/${_post.authorData.username}');
              }
            },
            child: Video(
              controller: controller,
              fit: BoxFit.cover,
              controls: NoVideoControls,
              wakelock: true,
            ),
          )
        else
          const ColoredBox(color: Colors.black),
        // Poster while the stream buffers.
        if (!_playing)
          IgnorePointer(
            child: Container(
              color: Colors.black,
              child: _buildPoster(),
            ),
          ),
        if (!_playing)
          const Center(
            child: Icon(Icons.play_arrow, color: Colors.white70, size: 72),
          ),
        // Right rail.
        Positioned(
          right: 12,
          bottom: 120,
          child: _ActionRail(
            post: engagement,
            onLike: _handleReact,
            onRepost: _handleRepost,
            onSave: _handleSave,
            onComment: _handleComment,
            onShare: _handleShare,
          ),
        ),
        // Unmute button.
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          right: 12,
          child: IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.black38),
            icon: Icon(
              widget.muted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
            tooltip: widget.muted ? 'Unmute' : 'Mute',
            onPressed: widget.onToggleMute,
          ),
        ),
        // Captions + meta.
        Builder(builder: (context) {
          final rawStyle = _media.editMeta?['captions_style'];
          final style = rawStyle is Map<String, dynamic>
              ? rawStyle
              : rawStyle is Map
                  ? Map<String, dynamic>.from(rawStyle)
                  : null;
          final placement = captionPlacement(style);
          return Positioned(
            left: 0,
            right: 0,
            bottom: placement == 'top' ? null : 96,
            top: placement == 'top' ? 96 : null,
            child: CaptionOverlay(
              captions: _media.captions,
              positionMs: _position.inMilliseconds,
              style: style,
            ),
          );
        }),
        CreativeOverlays(
          meta: _media.editMeta,
          positionMs: _position.inMilliseconds,
        ),
        Positioned(
          left: 0,
          right: 64,
          bottom: 0,
          child: _PostMeta(
            post: _post,
            onProfileTap: () => context.push('/${_post.authorData.username}'),
          ),
        ),
        // Progress bar.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: LinearProgressIndicator(
            value: progress > 0 ? progress : null,
            minHeight: 2,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(BuddyColors.green),
          ),
        ),
      ],
    );
  }

  Widget _buildPoster() {
    final poster = _media.posterUrl;
    if (poster != null && poster.isNotEmpty) {
      return Image.network(
        poster,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
      );
    }
    return const ColoredBox(color: Colors.black);
  }
}

/// Photo-mode page: horizontal swipe through media items with an 'n/N'
/// counter. No inline video here — video posts take the player path.
class _BudPressPhotoPage extends ConsumerStatefulWidget {
  final Post post;

  const _BudPressPhotoPage({required this.post});

  @override
  ConsumerState<_BudPressPhotoPage> createState() => _BudPressPhotoPageState();
}

class _BudPressPhotoPageState extends ConsumerState<_BudPressPhotoPage> {
  final PageController _pageController = PageController();
  int _page = 0;

  Post get _post => widget.post;

  List<PostMedia> get _items {
    if (_post.media.isNotEmpty) return _post.media;
    return _post.mediaUrls
        .map((url) => PostMedia(url: url, mediaType: 'image'))
        .toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final post = _post;
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: items.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (_, i) {
            final item = items[i];
            final src = item.posterUrl?.isNotEmpty == true && item.isVideo
                ? item.posterUrl!
                : item.url;
            return Image.network(
              src,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: BuddyColors.surface,
                child: Center(
                  child: Icon(Icons.broken_image, color: Colors.white38, size: 48),
                ),
              ),
            );
          },
        ),
        if (items.length > 1)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 56,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_page + 1}/${items.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        Positioned(
          right: 12,
          bottom: 120,
          child: _ActionRail(
            post: post,
            onLike: () => _reactToPost(ref, post),
            onRepost: () => ref.read(feedProvider.notifier).toggleRepost(post.id),
            onSave: () => _savePost(ref, post),
            onComment: () => _openComments(context, post),
            onShare: () => ShareSheet.show(context, post),
          ),
        ),
        Positioned(
          left: 0,
          right: 64,
          bottom: 0,
          child: _PostMeta(
            post: post,
            onProfileTap: () => context.push('/${post.authorData.username}'),
          ),
        ),
      ],
    );
  }
}
