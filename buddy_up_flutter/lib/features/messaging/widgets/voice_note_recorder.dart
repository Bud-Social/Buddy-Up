import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../../core/theme/app_theme.dart';

class VoiceNoteRecorder extends StatefulWidget {
  final void Function(int durationMs)? onSend;
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
  final List<double> _amplitudes = [];
  Timer? _amplitudeTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _pulseController.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() => _durationMs += 100);
    });
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      setState(() {
        _amplitudes.add(Random().nextDouble());
        if (_amplitudes.length > 30) _amplitudes.removeAt(0);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeTimer?.cancel();
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: BuddyColors.surface,
        border: Border(top: BorderSide(color: BuddyColors.border)),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: BuddyColors.red),
              onPressed: widget.onCancel,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            const SizedBox(width: 4),
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
            Text(
              formatted,
              style: const TextStyle(
                color: BuddyColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 32,
                child: CustomPaint(
                  painter: _WaveformPainter(amplitudes: _amplitudes),
                  size: const Size(double.infinity, 32),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: BuddyColors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stop, color: BuddyColors.black, size: 16),
              ),
              onPressed: () => widget.onSend?.call(_durationMs),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> amplitudes;

  _WaveformPainter({required this.amplitudes});

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;
    final paint = Paint()
      ..color = BuddyColors.green.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final midY = size.height / 2;
    final barWidth = size.width / amplitudes.length;
    for (var i = 0; i < amplitudes.length; i++) {
      final barH = amplitudes[i] * size.height * 0.7;
      final x = i * barWidth + barWidth / 2;
      canvas.drawLine(Offset(x, midY - barH / 2), Offset(x, midY + barH / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => true;
}
