import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';

class VoiceNoteRecorder extends StatefulWidget {
  final void Function()? onSend;
  final void Function()? onCancel;

  const VoiceNoteRecorder({super.key, this.onSend, this.onCancel});

  @override
  State<VoiceNoteRecorder> createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends State<VoiceNoteRecorder>
    with TickerProviderStateMixin {
  int _durationMs = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _pulseController.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() => _durationMs += 100);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = (_durationMs / 1000).floor();
    final mins = (seconds ~/ 60);
    final secs = seconds % 60;
    final formatted = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: BuddyColors.surface,
        border: Border(top: BorderSide(color: BuddyColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: BuddyColors.textSecondary),
            onPressed: widget.onCancel,
          ),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, _) {
              return Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BuddyColors.red.withValues(alpha: 0.5 + _pulseController.value * 0.5),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(formatted, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          Expanded(child: Container()),
          Container(
            width: 120, height: 30,
            decoration: BoxDecoration(
              color: BuddyColors.surfaceRaised,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: BuddyColors.green),
            onPressed: widget.onSend,
          ),
        ],
      ),
    );
  }
}
