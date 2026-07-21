import 'package:flutter/material.dart';
import 'dart:math';

class ReactionOverlay extends StatefulWidget {
  final Widget child;
  final void Function(String reaction)? onReact;

  const ReactionOverlay({super.key, required this.child, this.onReact});

  @override
  State<ReactionOverlay> createState() => _ReactionOverlayState();
}

class _ReactionOverlayState extends State<ReactionOverlay> with TickerProviderStateMixin {
  final List<_FloatingReaction> _activeReactions = [];

  void showReaction(String emoji) {
    final animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    final random = Random();
    final startX = random.nextDouble() * 200 + 50;
    final reaction = _FloatingReaction(
      emoji: emoji,
      animationController: animationController,
      startX: startX,
    );
    setState(() => _activeReactions.add(reaction));
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _activeReactions.remove(reaction));
        animationController.dispose();
      }
    });
    animationController.forward();
    widget.onReact?.call(emoji);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ..._activeReactions.map((r) => _buildFloatingReaction(r)),
      ],
    );
  }

  Widget _buildFloatingReaction(_FloatingReaction reaction) {
    return AnimatedBuilder(
      animation: reaction.animationController,
      builder: (_, _) {
        final progress = reaction.animationController.value;
        return Positioned(
          left: reaction.startX,
          bottom: 100 - (progress * 200),
          child: Opacity(
            opacity: 1 - progress,
            child: Transform.scale(
              scale: 1 + progress,
              child: Text(reaction.emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingReaction {
  final String emoji;
  final AnimationController animationController;
  final double startX;

  _FloatingReaction({
    required this.emoji,
    required this.animationController,
    required this.startX,
  });
}


