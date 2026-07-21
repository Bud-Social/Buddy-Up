import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'button.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: BuddyColors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 14,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              BuddyButton(
                label: 'Retry',
                onPressed: onRetry,
                size: BuddyButtonSize.sm,
                variant: BuddyButtonVariant.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
