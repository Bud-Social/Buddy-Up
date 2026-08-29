import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';

/// Minimal fire-and-forget analytics tracker.
///
/// Batches events and POSTs them to `/analytics/events/` (the ApiClient
/// baseUrl already carries `/api/v1`) as:
///
/// ```json
/// {"events": [{
///   "event_name": "...", "occurred_at": "...", "platform": "android|ios",
///   "surface": "...", "object_type": "...", "object_id": "...",
///   "properties": {...}, "consent": {"analytics": true}
/// }]}
/// ```
///
/// Contract:
///  - Batching: flushes every 5 seconds or when 10 events are queued.
///  - session_id: random UUID per app session (generated locally, no dep).
///  - Failure policy: fire-and-forget — errors are swallowed after logging
///    in debug builds so analytics can never break a user flow. A missing
///    backend endpoint (404) is expected and silent.
class AnalyticsService {
  AnalyticsService._internal() {
    // The timer stays active for the app session without a field reference.
    Timer.periodic(_flushInterval, (_) => flush());
  }

  static final AnalyticsService instance = AnalyticsService._internal();

  static const Duration _flushInterval = Duration(seconds: 5);
  static const int _flushThreshold = 10;

  final Dio _dio = ApiClient().dio;
  final String _sessionId = _randomUuid();
  final List<Map<String, dynamic>> _buffer = <Map<String, dynamic>>[];
  bool _flushing = false;

  /// Record an event. Never throws, never awaits network.
  void track(
    String eventName, {
    required String surface,
    String? objectType,
    String? objectId,
    Map<String, dynamic>? properties,
  }) {
    _buffer.add({
      'event_name': eventName,
      'occurred_at': DateTime.now().toUtc().toIso8601String(),
      'platform': _platform,
      'session_id': _sessionId,
      'surface': surface,
      'object_type': objectType,
      'object_id': objectId,
      'properties': properties ?? const <String, dynamic>{},
      'consent': {'analytics': true},
    });
    if (_buffer.length >= _flushThreshold) {
      flush();
    }
  }

  /// Send the queued batch. Safe to call repeatedly/concurrently.
  Future<void> flush() async {
    if (_flushing || _buffer.isEmpty) return;
    _flushing = true;
    final batch = List<Map<String, dynamic>>.of(_buffer);
    _buffer.clear();
    try {
      await _dio.post('/analytics/events/', data: {'events': batch});
    } on DioException catch (e) {
      // Expected when the endpoint is absent (404) or offline — silent in
      // release, visible in debug for wiring mistakes.
      debugPrint('analytics flush skipped (${e.response?.statusCode})');
    } catch (e) {
      debugPrint('analytics flush failed: $e');
    } finally {
      _flushing = false;
    }
  }

  String get _platform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      default:
        // Contract only allows android|ios; the mobile app is the target.
        return 'android';
    }
  }

  /// RFC-4122 v4 UUID without an external dependency.
  static String _randomUuid() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
