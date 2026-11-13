import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' show VideoTrackRenderer, VideoViewFit;

import '../../../core/audio/ringtone.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/models/messaging.dart';
import '../providers/livekit_call_provider.dart';
import '../providers/messaging_provider.dart';
import '../utils/conversation_identity.dart';

/// Full-screen multi-party LiveKit call room. Participant grid for N people,
/// camera-off placeholders with avatars, mute/camera/screen-share controls,
/// buddy invites, and the voice→video switch handshake.
class CallRoomScreen extends ConsumerStatefulWidget {
  const CallRoomScreen({super.key});

  @override
  ConsumerState<CallRoomScreen> createState() => _CallRoomScreenState();
}

class _CallRoomScreenState extends ConsumerState<CallRoomScreen> {
  /// Display name of the remote person who asked for the video switch, if any.
  String? _switchRequestFrom;
  bool _switchPending = false;
  StreamSubscription<dynamic>? _socketSub;

  @override
  void initState() {
    super.initState();
    // Ringback while we wait for the other side to pick up.
    Ringtone.playLoop('ringback', 'assets/ringtones/ringback.wav');
    WidgetsBinding.instance.addPostFrameCallback((_) => _wireSocket());
  }

  @override
  void dispose() {
    Ringtone.stop('ringback');
    _socketSub?.cancel();
    super.dispose();
  }

  void _wireSocket() {
    final convoId = ref.read(liveKitCallProvider).conversationId;
    if (convoId.isEmpty) return;
    final socket = ref.read(chatSocketProvider(convoId));
    if (socket == null) return;
    _socketSub?.cancel();
    _socketSub = socket.events.listen((event) {
      event.when(
        message: (_) {},
        typingStart: (_, _, _, _) {},
        typingStop: (_, _) {},
        read: (_, _, _, _) {},
        react: (_, _, _) {},
        callSignal: (signalType, data, _) {
          switch (signalType) {
            case 'call_switch_request':
              if (!mounted) return;
              setState(() =>
                  _switchRequestFrom = (data['from_display_name'] ?? data['from_username'] ?? 'Someone') as String);
              Ringtone.playLoop('switch-request', 'assets/ringtones/ringback.wav');
              Future<void>.delayed(const Duration(seconds: 2),
                  () => Ringtone.stop('switch-request'));
            case 'call_switch_response':
              if (data['accepted'] == true) {
                ref.read(liveKitCallProvider.notifier).setCamera(true);
              }
              if (mounted) setState(() => _switchPending = false);
            case 'call_switched_to_video':
              ref.read(liveKitCallProvider.notifier).setCamera(true);
          }
        },
      );
    });
  }

  void _requestVideoSwitch() {
    if (_switchPending) return;
    final profile = ref.read(authProvider).profile;
    final convoId = ref.read(liveKitCallProvider).conversationId;
    final socket = ref.read(chatSocketProvider(convoId));
    setState(() => _switchPending = true);
    socket?.sendCallSignal('call_switch_request', {
      'from_user_id': ref.read(authProvider).user?.id,
      'from_username': profile?.username,
      'from_display_name': profile?.displayName,
      'from_avatar_url': profile?.avatarUrl,
    }, callType: 'audio');
  }

  void _acceptSwitch() {
    final convoId = ref.read(liveKitCallProvider).conversationId;
    ref.read(messagingRepositoryProvider).switchCallType(convoId, {'accept': true}).ignore();
    final socket = ref.read(chatSocketProvider(convoId));
    socket?.sendCallSignal('call_switch_response', {'accepted': true}, callType: 'audio');
    ref.read(liveKitCallProvider.notifier).setCamera(true);
    Ringtone.stop('switch-request');
    setState(() => _switchRequestFrom = null);
  }

  void _declineSwitch() {
    final convoId = ref.read(liveKitCallProvider).conversationId;
    ref.read(messagingRepositoryProvider).switchCallType(convoId, {'accept': false}).ignore();
    final socket = ref.read(chatSocketProvider(convoId));
    socket?.sendCallSignal('call_switch_response', {'accepted': false}, callType: 'audio');
    Ringtone.stop('switch-request');
    setState(() => _switchRequestFrom = null);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveKitCallProvider);
    if (state.phase == LkCallPhase.inCall || state.phase == LkCallPhase.ended) {
      Ringtone.stop('ringback');
    }
    final conversations = ref.watch(conversationsProvider).conversations;
    final convo = conversations.where((c) => c.id == state.conversationId).firstOrNull;
    final myUserId = ref.watch(authProvider).user?.id;
    final identity = ConversationIdentity.of(convo, myUserId);

    return Material(
      color: BuddyColors.black,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            if (state.phase != LkCallPhase.inCall)
              Expanded(child: _PreCall(state: state, identity: identity))
            else ...[
              _StatusBar(state: state),
              const SizedBox(height: 8),
              if (_switchRequestFrom != null)
                _SwitchRequestBanner(
                  fromName: _switchRequestFrom!,
                  onAccept: _acceptSwitch,
                  onDecline: _declineSwitch,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _ParticipantGrid(tiles: state.tiles),
                ),
              ),
              if (state.cameraError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 16, right: 16),
                  child: Text(
                    '${state.cameraError} — audio only',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                  ),
                ),
            ],
            _Controls(
              state: state,
              switchPending: _switchPending,
              onRequestVideoSwitch: _requestVideoSwitch,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRequestBanner extends StatelessWidget {
  final String fromName;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _SwitchRequestBanner({
    required this.fromName,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: BuddyColors.surfaceRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BuddyColors.green.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$fromName wants to switch to video',
              style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onDecline,
            child: const Text('Decline', style: TextStyle(color: BuddyColors.textSecondary)),
          ),
          FilledButton.icon(
            onPressed: onAccept,
            icon: const Icon(Icons.videocam, size: 16),
            label: const Text('Accept'),
            style: FilledButton.styleFrom(
              backgroundColor: BuddyColors.green,
              foregroundColor: BuddyColors.black,
              minimumSize: const Size(0, 36),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreCall extends StatelessWidget {
  final LiveKitCallState state;
  final ConversationIdentity identity;
  const _PreCall({required this.state, required this.identity});

  @override
  Widget build(BuildContext context) {
    final String label;
    switch (state.phase) {
      case LkCallPhase.calling:
        label = 'Calling…';
        break;
      case LkCallPhase.ended:
        label = 'Call ended';
        break;
      default:
        label = '';
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Avatar(src: identity.avatarUrl, alt: identity.name, size: AvatarSize.xl),
          const SizedBox(height: 20),
          Text(
            identity.name,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

class _StatusBar extends StatefulWidget {
  final LiveKitCallState state;
  const _StatusBar({required this.state});

  @override
  State<_StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<_StatusBar> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _elapsed {
    return '${widget.state.tiles.length} in call';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _elapsed,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// Buddy picker — tap a buddy to ring them into the live call.
class _BuddyPicker extends ConsumerStatefulWidget {
  final String conversationId;
  const _BuddyPicker({required this.conversationId});

  @override
  ConsumerState<_BuddyPicker> createState() => _BuddyPickerState();
}

class _BuddyPickerState extends ConsumerState<_BuddyPicker> {
  List<Map<String, dynamic>>? _buddies;
  bool _loading = true;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final username = ref.read(authProvider).profile?.username ?? '';
      final raw = await ProfileRepository(ApiClient().dio).getBuddies(username);
      final data = raw['data'] as List? ?? raw['results'] as List? ?? const [];
      if (!mounted) return;
      setState(() {
        _buddies = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add(String buddyUserId) async {
    if (_adding) return;
    setState(() => _adding = true);
    try {
      await ref
          .read(messagingRepositoryProvider)
          .addCallBuddy(widget.conversationId, {'buddy_user_id': buddyUserId});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ringing them…')),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _adding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not add them — are you still in the call?')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Add a buddy to the call',
                style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: BuddyColors.green)),
              )
            else if (_buddies == null || _buddies!.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No buddies yet — add some from Find a Buddy.',
                    style: TextStyle(color: BuddyColors.textSecondary)),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _buddies!.length,
                  itemBuilder: (_, i) {
                    final b = _buddies![i];
                    final name = (b['display_name'] ?? b['username'] ?? '') as String;
                    final avatar = (b['avatar_url'] ?? '') as String;
                    final userId = (b['user_id'] ?? b['id'] ?? '') as String;
                    return ListTile(
                      leading: Avatar(src: avatar, alt: name, size: AvatarSize.md),
                      title: Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: BuddyColors.textPrimary)),
                      trailing: const Icon(Icons.call_outlined, color: BuddyColors.green, size: 20),
                      onTap: () => _add(userId),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantGrid extends StatelessWidget {
  final List<CallTile> tiles;
  const _ParticipantGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    if (tiles.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: BuddyColors.green),
      );
    }
    final cols = tiles.length <= 1 ? 1 : (tiles.length <= 4 ? 2 : 3);
    return GridView.builder(
      itemCount: tiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (_, i) => _Tile(tile: tiles[i]),
    );
  }
}

class _Tile extends StatelessWidget {
  final CallTile tile;
  const _Tile({required this.tile});

  @override
  Widget build(BuildContext context) {
    final hasVideo = tile.videoTrack != null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey.shade800, Colors.grey.shade900],
              ),
            ),
            child: hasVideo
                ? FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 1.4,
                      child: VideoTrackRenderer(tile.videoTrack!, fit: VideoViewFit.cover),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: BuddyColors.surfaceRaised,
                          backgroundImage: null,
                          child: Text(
                            tile.name.isNotEmpty ? tile.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white70, fontSize: 20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          Icons.videocam_off,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                  ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            right: 8,
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tile.isLocal ? 'You' : tile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
                if (!tile.isAudioEnabled) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.mic_off, size: 13, color: Colors.redAccent),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends ConsumerWidget {
  final LiveKitCallState state;
  final bool switchPending;
  final VoidCallback onRequestVideoSwitch;

  const _Controls({
    required this.state,
    required this.switchPending,
    required this.onRequestVideoSwitch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(liveKitCallProvider.notifier);
    final localTile = state.tiles.where((t) => t.isLocal).firstOrNull;
    final isMuted = localTile != null && !localTile.isAudioEnabled;
    final isCameraOff = localTile == null || !localTile.isVideoEnabled;
    final isVideo = state.callType == 'video';
    final inCall = state.phase == LkCallPhase.inCall;

    void openBuddyPicker() {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: BuddyColors.surface,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _BuddyPicker(conversationId: state.conversationId),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 10,
        children: [
          _ControlButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            label: isMuted ? 'Unmute' : 'Mute',
            color: isMuted ? BuddyColors.green : Colors.white24,
            onTap: controller.toggleMute,
          ),
          _ControlButton(
            icon: Icons.call_end,
            label: 'End',
            color: BuddyColors.red,
            iconColor: Colors.white,
            onTap: controller.leave,
          ),
          if (isVideo && inCall)
            _ControlButton(
              icon: Icons.videocam_off,
              label: isCameraOff ? 'Camera on' : 'Camera off',
              color: isCameraOff ? BuddyColors.green : Colors.white24,
              onTap: controller.toggleCamera,
            ),
          if (!isVideo && inCall)
            _ControlButton(
              icon: Icons.videocam,
              label: switchPending ? 'Requested…' : 'Go video',
              color: switchPending ? Colors.white24 : Colors.white24,
              onTap: onRequestVideoSwitch,
            ),
          if (inCall)
            _ControlButton(
              icon: Icons.person_add_outlined,
              label: 'Add buddy',
              color: Colors.white24,
              onTap: openBuddyPicker,
            ),
          if (isVideo && inCall && !PlatformIsDesktop.current)
            _ControlButton(
              icon: Icons.screen_share,
              label: 'Share',
              color: Colors.white24,
              onTap: controller.toggleScreenShare,
            ),
        ],
      ),
    );
  }
}

/// Screen share requires platform support; gate on mobile for now.
class PlatformIsDesktop {
  static bool get current =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: null,
          backgroundColor: color ?? Colors.white24,
          foregroundColor: iconColor ?? Colors.white,
          onPressed: onTap,
          child: Icon(icon),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
