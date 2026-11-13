import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';

import '../providers/live_provider.dart';
import '../services/live_socket.dart';
import '../widgets/live_chat_overlay.dart';
import '../widgets/reaction_overlay.dart';
import '../widgets/pip_live_overlay.dart';
import '../widgets/gift_picker.dart';
import '../widgets/cohost_panel.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../data/models/live.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/moderation_repository.dart';
import '../../../core/api/api_client.dart';
import '../../../router.dart';
import '../widgets/gift_burst_overlay.dart';
import '../../../features/analytics/providers/analytics_provider.dart';
import '../../../features/feed/providers/feed_provider.dart';

class LiveRoomScreen extends ConsumerStatefulWidget {
  final String liveId;

  const LiveRoomScreen({super.key, required this.liveId});

  @override
  ConsumerState<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends ConsumerState<LiveRoomScreen> with WidgetsBindingObserver {
  final GlobalKey<ReactionOverlayState> _reactionKey = GlobalKey<ReactionOverlayState>();
  final GlobalKey<GiftBurstOverlayState> _giftBurstKey = GlobalKey<GiftBurstOverlayState>();

  // LiveKit
  Room? _liveKitRoom;
  bool _isUsingLiveKit = false;

  // Room data cache for PiP
  LiveRoomData? _roomData;

  // Whether the local user asked to co-host and is waiting on the host.
  bool _hasRequestedToSpeak = false;
  // Pending speaker requests (host only) — refreshed on WS cohost events.
  int _speakerRequestCount = 0;

  // Replay state — a finished live with a saved recording plays inline.
  bool _replayMarked = false;
  Player? _replayPlayer;
  VideoController? _replayController;

  bool get _isHost =>
      _roomData != null &&
      (_roomData!.hostUserId.isNotEmpty) &&
      ref.read(authProvider).user?.id == _roomData!.hostUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _replayPlayer?.dispose();
    _cleanup();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _roomData != null) {
      _activatePip();
    } else if (state == AppLifecycleState.resumed) {
      if (PipLiveOverlayManager.isShowing) {
        PipLiveOverlayManager.hide();
      }
    }
  }

  void _activatePip() {
    if (_roomData == null) return;
    final overlayContext = rootNavigatorKey.currentContext;
    if (overlayContext == null) return;

    PipLiveOverlayManager.show(
      overlayContext,
      PipSessionData(
        liveId: widget.liveId,
        title: _roomData!.title,
        hostName: _roomData!.hostName,
        hostAvatarUrl: _roomData!.hostAvatar,
        viewerCount: _roomData!.viewerCount,
        isAudioOnly: _roomData!.liveType == 'audio',
        onClose: () {
          _cleanup();
        },
      ),
    );
  }

  Future<void> _cleanup() async {
    if (_liveKitRoom != null) {
      await _liveKitRoom!.disconnect();
      _liveKitRoom!.dispose();
    }
  }

  Future<void> _joinWithCredentials(LiveRoomData roomData) async {
    final creds = roomData.credentials;

    if (creds.livekit.url.isNotEmpty && creds.livekit.room.isNotEmpty) {
      await _joinLiveKit(creds.livekit);
    }
  }

  Future<void> _joinLiveKit(LiveKitCredentials creds) async {
    final room = Room();
    _liveKitRoom = room;

    await room.connect(creds.url, creds.token);

    if (creds.canPublish) {
      await room.localParticipant?.setCameraEnabled(true);
      await room.localParticipant?.setMicrophoneEnabled(true);
    }

    setState(() => _isUsingLiveKit = true);
  }

  void _markReplayViewed() {
    if (_replayMarked) return;
    _replayMarked = true;
    // Best effort — the counter is a unique-viewer stat, not a gate.
    ref.read(liveRepositoryProvider).recordReplayView(widget.liveId).ignore();
  }

  void _prepareReplay(BuddyLive live) {
    if (_replayPlayer != null) return;
    final url = live.replayUrl;
    if (url.isEmpty) return;
    _replayPlayer = Player();
    _replayController = VideoController(_replayPlayer!);
    _replayPlayer!
      ..setVolume(100)
      ..open(Media(url), play: true);
    _markReplayViewed();
  }

  void _react(String emoji) {
    // Send only — the WS broadcast comes back through the listener above
    // and floats for everyone, including us. Same as the web.
    ref.read(liveSocketProvider(widget.liveId).notifier).sendReaction(emoji);
  }

  Future<void> _refreshSpeakerRequestCount() async {
    if (!_isHost) return;
    try {
      final raw = await ref.read(liveRepositoryProvider).getCohostRequests(widget.liveId);
      final data = raw['data'] as List? ?? const [];
      if (mounted) setState(() => _speakerRequestCount = data.length);
    } catch (_) { /* transient — the next WS ping refreshes */ }
  }

  void _onCohostEvent(LiveCohostEvent? event) {
    if (event == null) return;
    final name = (event.data['display_name'] ?? event.data['username'] ?? 'Someone').toString();
    switch (event.type) {
      case 'live_cohost_request':
        if (_isHost) {
          _toast('$name requested to speak');
          _refreshSpeakerRequestCount();
        }
      case 'live_cohost_invite':
        final myUsername = ref.read(authProvider).profile?.username ?? '';
        final target = (event.data['username'] ?? '').toString();
        if (target == myUsername) {
          _showInviteDialog();
        } else if (_isHost) {
          _toast('Invited @$target');
        }
      case 'live_cohost_response':
        final action = (event.data['action'] ?? '').toString();
        if (action == 'approve') {
          _toast('$name can now speak');
        } else if (action == 'deny') {
          _toast('Speaker request denied');
        }
        // A new co-host changes the room roster — pull it fresh.
        ref.invalidate(liveRoomProvider(widget.liveId));
      case 'live_cohost_removed':
        _toast('$name removed from co-hosts');
        ref.invalidate(liveRoomProvider(widget.liveId));
    }
  }

  void _showInviteDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BuddyColors.surface,
        title: const Text('Co-host invite', style: TextStyle(color: BuddyColors.textPrimary)),
        content: const Text('The host invited you to co-host this live.',
            style: TextStyle(color: BuddyColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(liveRepositoryProvider).respondCohostInvite(
                      widget.liveId,
                      {'action': 'decline'},
                    );
                if (mounted) _toast('Invite declined');
              } catch (_) {}
            },
            child: const Text('Decline'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(liveRepositoryProvider).respondCohostInvite(
                      widget.liveId,
                      {'action': 'accept'},
                    );
                ref.invalidate(liveRoomProvider(widget.liveId));
                if (mounted) _toast('You are a co-host now!');
              } catch (_) {
                if (mounted) _toast('Could not accept the invite');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: BuddyColors.green,
              foregroundColor: BuddyColors.black,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showCoHostPanel() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BuddyColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CoHostRequestsSheet(liveId: widget.liveId),
    );
  }

  Future<void> _askToCoHost() async {
    if (_hasRequestedToSpeak) return;
    try {
      await ref.read(liveRepositoryProvider).requestToSpeak(widget.liveId);
      final profile = ref.read(authProvider).profile;
      ref.read(liveSocketProvider(widget.liveId).notifier).sendCohostEvent(
            'cohost_request',
            {'display_name': profile?.displayName ?? ''},
          );
      if (mounted) {
        setState(() => _hasRequestedToSpeak = true);
        _toast('Request sent to host');
      }
    } catch (_) {
      if (mounted) _toast('Could not send the request');
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveId = widget.liveId;
    // Invisible listener: float a reaction whenever one lands (mine included —
    // sending one re-triggers through the WS broadcast, exactly like the web).
    ref.listen(liveSocketProvider(liveId), (prev, next) {
      if (prev == null || next.reactionSeq != prev.reactionSeq) {
        final emoji = next.lastReaction?.emoji;
        if (emoji != null && emoji.isNotEmpty) {
          _reactionKey.currentState?.showReaction(emoji);
        }
      }
      // Co-host ladder: requests badge refresh + invite accept/decline
      // + approvals/removals.
      if (prev == null || next.cohostSeq != prev.cohostSeq) {
        _onCohostEvent(next.cohostEvent);
      }
      // Gift burst for everyone, including the sender — the server echoes
      // the settled gift to the whole room.
      if (prev == null || next.giftSeq != prev.giftSeq) {
        final gift = next.lastGift;
        if (gift != null) {
          _giftBurstKey.currentState?.burst(
                gift.artifactType,
                gift.quantity,
                gift.senderName,
                gift.total,
              );
        }
      }
    });

    final roomDataAsync = ref.watch(liveDetailProvider(liveId));

    return Scaffold(
      body: roomDataAsync.when(
        loading: () => const PageLoader(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(liveDetailProvider(liveId)),
        ),
        data: (live) {
          ref.listen(liveRoomProvider(liveId), (_, next) {
            next.whenData((roomData) {
              if (_roomData == null) {
                _roomData = roomData;
                _joinWithCredentials(roomData);
                _refreshSpeakerRequestCount();
              }
            });
          });

          // Ended live with a replay → replay player instead of the room.
          if (live.status != 'live' && live.replaySaved && live.replayUrl.isNotEmpty) {
            _prepareReplay(live);
            return _buildReplayShell(live);
          }

          return PopScope(
            key: const ValueKey('live-room-guard'),
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) {
                if (_roomData != null) {
                  _activatePip();
                }
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: GiftBurstOverlay(
                      key: _giftBurstKey,
                      child: ReactionOverlay(
                        key: _reactionKey,
                        child: Stack(
                          children: [
                          _buildVideoView(live),
                          _buildOverlay(live),
                          _buildGiftTotals(),
                          _buildCoHostStrip(),
                          _buildRoomActions(),
                          if (ref.watch(liveSocketProvider(widget.liveId).select((s) => s.feedbackPinned)) &&
                              !_isHost)
                            _buildFeedbackPinBanner(),
                        ],
                      ),
                      ),
                    ),
                  ),
                  _buildPollCard(live),
                  SizedBox(
                    height: 250,
                    child: LiveChatOverlay(liveId: liveId, onReaction: _react),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Video / replay surfaces ─────────────────────────────────────────────

  Widget _buildVideoView(BuddyLive live) {
    if (_isUsingLiveKit && _liveKitRoom != null) {
      return Stack(
        children: [
          Container(color: BuddyColors.black, child: const Center(child: Text('LiveKit Stream', style: TextStyle(color: Colors.white54)))),
        ],
      );
    }

    return Container(
      color: BuddyColors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Avatar(src: live.host.avatarUrl, alt: live.host.displayName, size: AvatarSize.xl),
            const SizedBox(height: 16),
            Text(live.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('@${live.host.displayName}', style: const TextStyle(color: BuddyColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final repo = ref.read(liveRepositoryProvider);
                try {
                  final raw = await repo.joinLive(widget.liveId);
                  final roomData = LiveRoomData.fromJson(raw['data'] as Map<String, dynamic>);
                  await _joinWithCredentials(roomData);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Join failed: $e')));
                  }
                }
              },
              icon: const Icon(Icons.videocam),
              label: const Text('Join Live'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplayShell(BuddyLive live) {
    final mux = live.muxPlaybackId;
    return PopScope(
      key: const ValueKey('live-replay-guard'),
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('REPLAY',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(live.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  if (_isHost)
                    IconButton(
                      icon: const Icon(Icons.lock_outline, color: Colors.white),
                      tooltip: 'Replay visibility',
                      onPressed: () => _showVisibilitySheet(live),
                    ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    tooltip: 'Share as a post',
                    onPressed: () => _shareReplay(live),
                  ),
                ],
              ),
              Expanded(
                child: _replayController != null
                    ? Video(controller: _replayController!)
                    : const Center(child: CircularProgressIndicator(color: BuddyColors.green)),
              ),
              if (mux != null && mux.isNotEmpty) const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  /// Host path mirrors the web: prepare a long_video draft server-side, then
  /// land on /feed with the inline composer open and the replay inside it.
  /// Audience path stays a plain share link.
  Future<void> _shareReplay(BuddyLive live) async {
    if (!_isHost) {
      await SharePlus.instance.share(
        ShareParams(text: 'Watch this live replay on Buddy Up: ${live.replayUrl}'),
      );
      return;
    }
    try {
      await ref.read(analyticsRepositoryProvider).sharePrepare({
        'kind': 'live',
        'obj_id': live.id,
      });
      ref.read(composerExpandRequestProvider.notifier).bump();
      if (mounted) context.go('/feed');
    } catch (_) {
      if (mounted) _toast('Could not prepare the replay post');
    }
  }

  void _showVisibilitySheet(BuddyLive live) {
    const options = [
      ('public', 'Public', 'Everyone can watch'),
      ('buddies', 'Buddies', 'Only your buddies'),
      ('gym_members', 'Gym members', 'Only members of an attached gym'),
      ('private', 'Only me', 'Not listed, no playback for others'),
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Replay visibility',
                  style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              for (final (value, label, hint) in options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    live.access == value ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: live.access == value ? BuddyColors.green : BuddyColors.textSecondary,
                  ),
                  title: Text(label, style: const TextStyle(color: BuddyColors.textPrimary)),
                  subtitle: Text(hint, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      await ref.read(liveRepositoryProvider).updateVisibility(
                            live.id,
                            {'access': value},
                          );
                      if (mounted) {
                        ref.invalidate(liveDetailProvider(live.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Replay visibility set to $label')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not change visibility: $e')),
                        );
                      }
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top overlay: host row + viewer count + menu ─────────────────────────

  Widget _buildOverlay(BuddyLive live) {
    final viewerCount = ref.watch(liveSocketProvider(widget.liveId).select((s) => s.viewerCount));
    final watching = viewerCount > 0 ? viewerCount : live.viewerCount;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  _cleanup();
                  Navigator.of(context).pop();
                },
              ),
              Avatar(src: live.host.avatarUrl, alt: live.host.displayName, size: AvatarSize.sm),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(live.host.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('$watching watching', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              if (live.status == 'live')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: const BoxDecoration(color: BuddyColors.red, borderRadius: BorderRadius.all(Radius.circular(6))),
                  child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                tooltip: 'More',
                onPressed: () => _showViewerMenu(live),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showViewerMenu(BuddyLive live) {
    final hostUserId = _roomData?.hostUserId.isNotEmpty == true
        ? _roomData!.hostUserId
        : live.host.userId;
    final hostUsername = live.host.username;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isHost) ...[
                ListTile(
                  leading: const Icon(Icons.person_add_outlined, color: BuddyColors.textPrimary),
                  title: const Text('Follow host', style: TextStyle(color: BuddyColors.textPrimary)),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      await ProfileRepository(ApiClient().dio)
                          .followUser(hostUsername);
                      _toast('Following @$hostUsername');
                    } catch (_) {
                      _toast('Could not follow — try again');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: BuddyColors.textPrimary),
                  title: const Text('Report host', style: TextStyle(color: BuddyColors.textPrimary)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showReportSheet(live, hostUserId);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.visibility_off_outlined, color: BuddyColors.textPrimary),
                  title: const Text('Not interested', style: TextStyle(color: BuddyColors.textPrimary)),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      await ref.read(liveRepositoryProvider).toggleNotInterested(live.id);
                      _toast('We will show fewer lives like this');
                    } catch (_) {
                      _toast('Could not update');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block, color: BuddyColors.textPrimary),
                  title: const Text('Never recommend this host',
                      style: TextStyle(color: BuddyColors.textPrimary)),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      await ref.read(liveRepositoryProvider).toggleMuteHost(live.id);
                      _toast('You will not see this host again');
                    } catch (_) {
                      _toast('Could not update');
                    }
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.bar_chart, color: BuddyColors.textPrimary),
                  title: const Text('Feedback summary',
                      style: TextStyle(color: BuddyColors.textPrimary)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showFeedbackSheet(hostMode: true);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.campaign_outlined, color: BuddyColors.textPrimary),
                  title: const Text('Ask audience to rate', style: TextStyle(color: BuddyColors.textPrimary)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    ref.read(liveSocketProvider(widget.liveId).notifier).sendFeedbackPin(true);
                    _toast('Feedback request pinned for the audience');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline, color: BuddyColors.textPrimary),
                  title: const Text('Create a poll', style: TextStyle(color: BuddyColors.textPrimary)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showPollComposer();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.stop_circle_outlined, color: BuddyColors.red),
                  title: const Text('End live', style: TextStyle(color: BuddyColors.red)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _confirmEndLive(live);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// The host decides at the end what happens to the replay. Publishing is
  /// gated server-side on the recording consent set at go-live; the
  /// staff-only path also forces the visibility private so nothing public
  /// leaks, matching the moderation-first architecture.
  Future<void> _endLive(BuddyLive live, {required bool publish}) async {
    try {
      await ref.read(liveRepositoryProvider).endLive(live.id, {'save_replay': true});
      if (!publish) {
        try {
          await ref.read(liveRepositoryProvider).updateVisibility(live.id, {'access': 'private'});
        } catch (_) {
          // Non-fatal: the replay stays unlisted by default visibility rules
          // when consent is off; log-and-forget is honest here.
        }
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(publish ? 'Live ended — replay will be published' : 'Live ended — replay stays private')),
        );
      }
    } catch (e) {
      _toast('Could not end the live: $e');
    }
  }

  void _confirmEndLive(BuddyLive live) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BuddyColors.surface,
        title: const Text('End this live?', style: TextStyle(color: BuddyColors.textPrimary)),
        content: const Text(
          'The recording is always kept by moderation. Choose what goes public.',
          style: TextStyle(color: BuddyColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Keep streaming')),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _endLive(live, publish: false);
            },
            icon: const Icon(Icons.lock_outline, size: 16),
            label: const Text('Staff only'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _endLive(live, publish: true);
            },
            icon: const Icon(Icons.public, size: 16),
            label: const Text('Publish replay'),
            style: FilledButton.styleFrom(backgroundColor: BuddyColors.green, foregroundColor: BuddyColors.black),
          ),
        ],
      ),
    );
  }

  void _showReportSheet(BuddyLive live, String hostUserId) {
    const reasons = ['spam', 'harassment', 'nsfw', 'misinformation'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Report host', style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              for (final reason in reasons)
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: BuddyColors.textPrimary),
                  title: Text(reason[0].toUpperCase() + reason.substring(1)),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      await ModerationRepository(ApiClient().dio).createReport({
                        'target_user': hostUserId,
                        'reason': reason,
                        'description': 'Reported from the live room: ${live.title}',
                        'content_url': '/live/${live.id}',
                      });
                      _toast('Report sent to moderation');
                    } catch (_) {
                      _toast('Could not send the report');
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Feedback sheet ──────────────────────────────────────────────────────

  void _showFeedbackSheet({required bool hostMode}) {
    int rating = 0;
    final comment = TextEditingController();
    Map<String, dynamic>? aggregate;

    if (hostMode) {
      // Load the aggregate for the host header.
      ref.read(liveRepositoryProvider).getFeedback(widget.liveId).then((raw) {
        final data = raw['data'];
        if (data is Map) aggregate = Map<String, dynamic>.from(data);
      }).ignore();
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BuddyColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(hostMode ? 'Audience feedback' : 'Rate this live',
                    style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                if (hostMode && aggregate != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: BuddyColors.gold, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        '${(aggregate!['average'] as num? ?? 0).toStringAsFixed(1)} · ${aggregate!['count'] ?? 0} ratings',
                        style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ] else if (!hostMode) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var star = 1; star <= 5; star++)
                        IconButton(
                          iconSize: 34,
                          icon: Icon(
                            rating >= star ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: BuddyColors.gold,
                          ),
                          onPressed: () => setSheetState(() => rating = star),
                        ),
                    ],
                  ),
                  TextField(
                    controller: comment,
                    maxLines: 2,
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'What did you think? (optional)',
                      hintStyle: TextStyle(color: BuddyColors.textSecondary),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                if (!hostMode)
                  FilledButton.icon(
                    onPressed: rating == 0
                        ? null
                        : () async {
                            Navigator.of(ctx).pop();
                            try {
                              await ref.read(liveRepositoryProvider).submitFeedback(
                                    widget.liveId,
                                    {'rating': rating, 'comment': comment.text.trim()},
                                  );
                              _toast('Thanks for the feedback!');
                            } catch (_) {
                              _toast('Could not send feedback');
                            }
                          },
                    icon: const Icon(Icons.send),
                    label: const Text('Submit'),
                    style: FilledButton.styleFrom(backgroundColor: BuddyColors.green, foregroundColor: BuddyColors.black),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Poll card + composer ───────────────────────────────────────────────

  Widget _buildPollCard(BuddyLive live) {
    final poll = ref.watch(liveSocketProvider(widget.liveId).select((s) => s.currentPoll));
    if (poll == null) return const SizedBox.shrink();
    final ended = poll.endsAt != null &&
        (DateTime.tryParse(poll.endsAt!)?.isBefore(DateTime.now()) ?? false);
    // An expired timed poll clears itself locally; the next dispatch replaces it.
    if (ended) return const SizedBox.shrink();

    final total = poll.tally?.fold<int>(0, (a, b) => a + b) ?? poll.totalVotes;
    final bool reveal = poll.yourVote != null || total > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BuddyColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BuddyColors.green.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.how_to_vote_outlined, size: 16, color: BuddyColors.green),
              const SizedBox(width: 6),
              Expanded(
                child: Text(poll.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              _PollCountdown(endsAt: poll.endsAt, fallback: poll.durationSeconds),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < poll.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _PollOption(
                label: poll.options[i],
                selected: poll.yourVote == i,
                fraction: reveal && total > 0 ? ((poll.tally?[i] ?? 0) / total) : null,
                onTap: () async {
                  if (poll.yourVote != null) return;
                  ref.read(liveSocketProvider(widget.liveId).notifier).setPollVote(i);
                  try {
                    await ref.read(liveRepositoryProvider).votePoll(
                          widget.liveId,
                          poll.pollId,
                          {'option': i},
                        );
                  } catch (_) {
                    _toast('Could not record your vote');
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showPollComposer() {
    final question = TextEditingController();
    final optionControllers = [TextEditingController(), TextEditingController()];
    int duration = 60;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BuddyColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Ask the audience',
                  style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              TextField(
                controller: question,
                style: const TextStyle(color: BuddyColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Question'),
              ),
              for (var i = 0; i < optionControllers.length; i++)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: optionControllers[i],
                          style: const TextStyle(color: BuddyColors.textPrimary),
                          decoration: InputDecoration(hintText: 'Option ${i + 1}'),
                        ),
                      ),
                      if (optionControllers.length > 2)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: BuddyColors.textSecondary),
                          onPressed: () => setSheetState(() => optionControllers.removeAt(i)),
                        ),
                    ],
                  ),
                ),
              if (optionControllers.length < 4)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        setSheetState(() => optionControllers.add(TextEditingController())),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add option'),
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text('Lasts', style: TextStyle(color: BuddyColors.textPrimary)),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: duration,
                    dropdownColor: BuddyColors.surfaceRaised,
                    items: const [30, 60, 120, 300]
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text('${d}s',
                                  style: const TextStyle(color: BuddyColors.textPrimary)),
                            ))
                        .toList(),
                    onChanged: (v) => setSheetState(() => duration = v ?? 60),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () async {
                  final q = question.text.trim();
                  final options = optionControllers
                      .map((c) => c.text.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();
                  if (q.isEmpty || options.length < 2) {
                    _toast('Add a question and at least two options');
                    return;
                  }
                  Navigator.of(ctx).pop();
                  try {
                    await ref.read(liveRepositoryProvider).createPoll(
                          widget.liveId,
                          {
                            'question': q,
                            'options': options,
                            'show_after_seconds': 0,
                            'duration_seconds': duration,
                          },
                        );
                    _toast('Poll sent to the audience');
                  } catch (e) {
                    _toast('Could not create the poll: $e');
                  }
                },
                icon: const Icon(Icons.how_to_vote_outlined),
                label: const Text('Send to audience'),
                style: FilledButton.styleFrom(
                  backgroundColor: BuddyColors.green,
                  foregroundColor: BuddyColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Gift totals + actions FAB stack ─────────────────────────────────────

  Widget _buildCoHostStrip() {
    final roomData = ref.watch(liveRoomProvider(widget.liveId)).value;
    final coHosts = roomData?.coHosts ?? const [];
    if (coHosts.isEmpty) return const SizedBox.shrink();
    return Positioned(
      top: 64,
      left: 0,
      right: 0,
      child: Container(
        height: 36,
        color: Colors.black.withValues(alpha: 0.35),
        child: CoHostStrip(coHosts: coHosts),
      ),
    );
  }

  Widget _buildGiftTotals() {
    final totals = ref.watch(liveSocketProvider(widget.liveId).select((s) => s.giftTotals));
    if (totals.isEmpty) return const SizedBox.shrink();
    final coHosts = ref.watch(liveRoomProvider(widget.liveId)).value?.coHosts.length ?? 0;
    final entries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final shown = entries.take(3);

    return Positioned(
      top: coHosts > 0 ? 104 : 64,
      left: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in shown)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${entry.key} ×${entry.value}',
                style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  /// Host pinned "rate this live" — audience sees a gold nudge they can act
  /// on or dismiss; it never blocks the feed of the room.
  bool _feedbackPinDismissed = false;

  Widget _buildFeedbackPinBanner() {
    if (_feedbackPinDismissed) return const SizedBox.shrink();
    return Positioned(
      left: 12,
      right: 76, // clear of the gift/rate FAB rail
      bottom: 12,
      child: Material(
        color: Colors.black.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        elevation: 6,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showFeedbackSheet(hostMode: false),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: BuddyColors.gold, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'The host would love your feedback — rate this live',
                    style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.white70),
                  onPressed: () => setState(() => _feedbackPinDismissed = true),
                  tooltip: 'Dismiss',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomActions() {
    final roomData = ref.watch(liveRoomProvider(widget.liveId)).value;
    final myId = ref.watch(authProvider).user?.id;
    final isCohost = roomData?.coHosts.any((c) => c.userId == myId) ?? false;
    final canAsk = !_isHost && !isCohost;

    return Positioned(
      right: 10,
      bottom: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isHost) ...[
            _CrownFab(count: _speakerRequestCount, onTap: _showCoHostPanel),
            const SizedBox(height: 10),
          ] else if (canAsk) ...[
            FloatingActionButton.small(
              heroTag: 'ask-cohost',
              backgroundColor:
                  _hasRequestedToSpeak ? BuddyColors.green : BuddyColors.surfaceRaised,
              foregroundColor: _hasRequestedToSpeak ? BuddyColors.black : Colors.white,
              onPressed: _askToCoHost,
              tooltip: _hasRequestedToSpeak ? 'Request sent — waiting for host' : 'Ask to co-host',
              child: Icon(_hasRequestedToSpeak ? Icons.check : Icons.mic_outlined),
            ),
            const SizedBox(height: 10),
          ],
          FloatingActionButton.small(
            heroTag: 'rate',
            backgroundColor: BuddyColors.gold,
            foregroundColor: BuddyColors.black,
            onPressed: () => _showFeedbackSheet(hostMode: _isHost),
            tooltip: _isHost ? 'Feedback summary' : 'Rate this live',
            child: const Icon(Icons.star_rounded),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.small(
            heroTag: 'gift',
            backgroundColor: BuddyColors.green,
            foregroundColor: BuddyColors.black,
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (_) => GiftPicker(
                  onSendGift: (artifact, quantity, total) {
                    Navigator.of(context).pop();
                    ref.read(liveSocketProvider(widget.liveId).notifier).sendGift(
                          artifact.toLowerCase(),
                          quantity,
                        );
                    _toast('Gift sent! 🎁');
                  },
                ),
              );
            },
            tooltip: 'Send a gift',
            child: const Icon(Icons.card_giftcard),
          ),
        ],
      ),
    );
  }
}

/// Hot countdown for a poll — re-renders every second.
class _PollCountdown extends StatefulWidget {
  final String? endsAt;
  final int fallback;

  const _PollCountdown({required this.endsAt, required this.fallback});

  @override
  State<_PollCountdown> createState() => _PollCountdownState();
}

class _PollCountdownState extends State<_PollCountdown> {
  Timer? _timer;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _left = _computeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = _computeLeft();
      if (next != _left) setState(() => _left = next);
      if (next == Duration.zero) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _computeLeft() {
    final ends = widget.endsAt != null ? DateTime.tryParse(widget.endsAt!) : null;
    if (ends != null) {
      final left = ends.difference(DateTime.now());
      return left.isNegative ? Duration.zero : left;
    }
    return Duration(seconds: widget.fallback);
  }

  @override
  Widget build(BuildContext context) {
    final s = _left.inSeconds;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: BuddyColors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}',
        style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PollOption extends StatelessWidget {
  final String label;
  final bool selected;
  final double? fraction;
  final VoidCallback onTap;

  const _PollOption({required this.label, required this.selected, required this.fraction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? BuddyColors.green.withValues(alpha: 0.22) : BuddyColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? BuddyColors.green : Colors.transparent,
          ),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            if (fraction != null)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: fraction!.clamp(0.0, 1.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: BuddyColors.green.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(label, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 13)),
                ),
                if (fraction != null)
                  Text('${(fraction! * 100).round()}%',
                      style: const TextStyle(color: BuddyColors.green, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Host's co-host ladder button — crown with a badge for pending speaker
/// requests. Opens the invite/approve sheet.
class _CrownFab extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _CrownFab({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BuddyColors.gold,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.workspace_premium, color: BuddyColors.black, size: 20),
              if (count > 0)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(color: BuddyColors.red, shape: BoxShape.circle),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, height: 1.4),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
