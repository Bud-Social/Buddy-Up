import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum ToastType { success, error, info }

OverlayEntry? _currentToast;

void showToast(BuildContext context, String message, {ToastType type = ToastType.info}) {
  _currentToast?.remove();

  final overlay = Overlay.of(context);
  final color = switch (type) {
    ToastType.success => BuddyColors.green,
    ToastType.error => BuddyColors.red,
    ToastType.info => BuddyColors.surfaceRaised,
  };

  _currentToast = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: type == ToastType.info ? BuddyColors.textPrimary : BuddyColors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(_currentToast!);

  Future.delayed(const Duration(seconds: 3), () {
    _currentToast?.remove();
    _currentToast = null;
  });
}
