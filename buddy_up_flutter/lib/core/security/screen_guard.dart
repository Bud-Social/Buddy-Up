import 'dart:io';

import 'package:flutter/services.dart';

/// Blocks screenshots and screen recording while a view-once payload is on
/// screen. Android uses FLAG_SECURE; iOS does not expose a public equivalent,
/// so this is a no-op there.
class ScreenGuard {
  ScreenGuard._();

  static const MethodChannel _channel = MethodChannel('com.buddyup.fit/screen_guard');

  static Future<void> secure() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('secure');
    } catch (_) {
      // Older hosts without the channel simply cannot block screenshots.
    }
  }

  static Future<void> release() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('unsecure');
    } catch (_) {}
  }
}
