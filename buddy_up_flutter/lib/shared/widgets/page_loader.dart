import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PageLoader extends StatelessWidget {
  final bool fullScreen;
  final String? message;

  const PageLoader({
    super.key,
    this.fullScreen = true,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: BuddyColors.green,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: const TextStyle(
              color: BuddyColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );

    if (fullScreen) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: BuddyColors.green)),
      );
    }
    return Center(child: content);
  }
}
