import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TypingIndicator extends StatelessWidget {
  final String? userName;

  const TypingIndicator({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _AnimatedDots(),
          const SizedBox(width: 8),
          Text(
            userName != null ? '$userName is typing...' : 'Typing...',
            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final value = ((_controller.value - delay) % 1.0);
            final scale = value < 0.5 ? value * 2 : (1 - value) * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: 0.3 + scale * 0.7,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: BuddyColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
