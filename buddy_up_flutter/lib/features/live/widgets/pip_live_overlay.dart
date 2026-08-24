import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../router.dart';

class PipSessionData {
  final String liveId;
  final String title;
  final String hostName;
  final String hostAvatarUrl;
  final int viewerCount;
  final String? lastChatMessage;
  final bool isAudioOnly;
  final VoidCallback? onClose;
  final VoidCallback? onToggleMute;

  const PipSessionData({
    required this.liveId,
    required this.title,
    required this.hostName,
    required this.hostAvatarUrl,
    this.viewerCount = 1,
    this.lastChatMessage,
    this.isAudioOnly = false,
    this.onClose,
    this.onToggleMute,
  });
}

class PipLiveOverlayManager {
  static OverlayEntry? _overlayEntry;
  static PipSessionData? _currentSession;

  static bool get isShowing => _overlayEntry != null;

  static void show(BuildContext context, PipSessionData session) {
    _currentSession = session;
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    final overlayState = Overlay.maybeOf(context) ?? rootNavigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => _PipOverlayView(
        session: _currentSession!,
        onClose: () {
          session.onClose?.call();
          hide();
        },
        onExpand: () {
          final liveId = _currentSession?.liveId;
          hide();
          if (liveId != null) {
            rootNavigatorKey.currentContext?.push('/lives/$liveId');
          }
        },
      ),
    );

    overlayState.insert(_overlayEntry!);
  }

  static void updateSession(PipSessionData session) {
    _currentSession = session;
    _overlayEntry?.markNeedsBuild();
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _currentSession = null;
  }
}

class _PipOverlayView extends StatefulWidget {
  final PipSessionData session;
  final VoidCallback onClose;
  final VoidCallback onExpand;

  const _PipOverlayView({
    required this.session,
    required this.onClose,
    required this.onExpand,
  });

  @override
  State<_PipOverlayView> createState() => _PipOverlayViewState();
}

class _PipOverlayViewState extends State<_PipOverlayView> {
  Offset _offset = const Offset(16, 100);
  bool _isMuted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    _offset = Offset(size.width - 200 - 16, size.height - 280);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final newDx = (_offset.dx + details.delta.dx).clamp(8.0, size.width - 210.0);
            final newDy = (_offset.dy + details.delta.dy).clamp(40.0, size.height - 260.0);
            _offset = Offset(newDx, newDy);
          });
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              color: BuddyColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BuddyColors.green.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Video/Preview Window
                  Stack(
                    children: [
                      Container(
                        height: 110,
                        width: double.infinity,
                        color: Colors.black87,
                        child: Center(
                          child: CircleAvatar(
                            radius: 28,
                            backgroundImage: widget.session.hostAvatarUrl.isNotEmpty
                                ? NetworkImage(widget.session.hostAvatarUrl)
                                : null,
                            child: widget.session.hostAvatarUrl.isEmpty
                                ? const Icon(Icons.person, size: 28, color: Colors.white)
                                : null,
                          ),
                        ),
                      ),
                      // Live Badge
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fiber_manual_record, size: 8, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                'LIVE',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Controls Row in Overlay
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _miniBtn(
                              icon: Icons.open_in_full,
                              onTap: widget.onExpand,
                              tooltip: 'Expand to Live Room',
                            ),
                            const SizedBox(width: 4),
                            _miniBtn(
                              icon: Icons.close,
                              onTap: widget.onClose,
                              tooltip: 'Close Live',
                            ),
                          ],
                        ),
                      ),
                      // Mute button
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: _miniBtn(
                          icon: _isMuted ? Icons.volume_off : Icons.volume_up,
                          onTap: () {
                            setState(() => _isMuted = !_isMuted);
                            widget.session.onToggleMute?.call();
                          },
                          tooltip: _isMuted ? 'Unmute' : 'Mute',
                        ),
                      ),
                    ],
                  ),

                  // Bottom Info & Mini Chat
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.session.title.isNotEmpty ? widget.session.title : 'Live Stream',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.session.hostName.isNotEmpty ? widget.session.hostName : 'Host',
                                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.people, size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.session.viewerCount}',
                              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                        if (widget.session.lastChatMessage != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.session.lastChatMessage!,
                              style: const TextStyle(fontSize: 9, color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniBtn({required IconData icon, required VoidCallback onTap, required String tooltip}) {
    return Material(
      color: Colors.black.withValues(alpha: 0.65),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}
