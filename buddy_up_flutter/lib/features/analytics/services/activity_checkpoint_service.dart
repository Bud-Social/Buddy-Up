import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A live activity session checkpoint.
///
/// Flutter keeps recording with the screen locked, but Android can still
/// kill the process under memory pressure and iOS can reclaim the app. The
/// checkpoint is written every few seconds so the next launch can offer to
/// resume the route instead of losing it.
class ActivityCheckpoint {
  const ActivityCheckpoint({
    required this.ownerId,
    required this.activityType,
    required this.startedAt,
    required this.elapsedS,
    required this.distanceM,
    required this.route,
    required this.lastUpdatedMs,
  });

  final String ownerId;
  final String activityType;
  final String startedAt;
  final int elapsedS;
  final double distanceM;
  final List<List<dynamic>> route;
  final int lastUpdatedMs;

  factory ActivityCheckpoint.fromJson(Map<String, dynamic> json) {
    final rawRoute = json['route'];
    final route = <List<dynamic>>[];
    if (rawRoute is List) {
      for (final point in rawRoute) {
        if (point is List && point.length >= 2) {
          route.add(List<dynamic>.from(point));
        }
      }
    }
    return ActivityCheckpoint(
      ownerId: json['owner_id'] as String? ?? '',
      activityType: json['activity_type'] as String? ?? 'run',
      startedAt: json['started_at'] as String? ?? '',
      elapsedS: (json['elapsed_s'] as num?)?.toInt() ?? 0,
      distanceM: (json['distance_m'] as num?)?.toDouble() ?? 0,
      route: route,
      lastUpdatedMs: (json['last_updated_ms'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'owner_id': ownerId,
    'activity_type': activityType,
    'started_at': startedAt,
    'elapsed_s': elapsedS,
    'distance_m': distanceM,
    'route': route,
    'last_updated_ms': lastUpdatedMs,
  };

  String ageLabel([int? nowMs]) {
    final seconds =
        (((nowMs ?? DateTime.now().millisecondsSinceEpoch) - lastUpdatedMs) /
                1000)
            .round();
    if (seconds < 60) return 'just now';
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes min ago';
    return '${(minutes / 60).round()} hr ago';
  }
}

/// Durable storage for the one live session on this device.
///
/// Scoped by owner id so signing into another account never offers to resume
/// a route that belongs to someone else. Checkpoints expire after half a day.
class ActivityCheckpointService {
  static const _prefsKey = 'analytics.activity_checkpoint.v1';
  static const maxAgeMs = 12 * 60 * 60 * 1000;
  static const maxPoints = 20000;

  Future<ActivityCheckpoint?> load(String? ownerId) async {
    if (ownerId == null || ownerId.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return null;
    ActivityCheckpoint checkpoint;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        await clear();
        return null;
      }
      checkpoint = ActivityCheckpoint.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      await clear();
      return null;
    }
    if (checkpoint.ownerId != ownerId) return null;
    final age = DateTime.now().millisecondsSinceEpoch - checkpoint.lastUpdatedMs;
    if (age > maxAgeMs) {
      await clear(ownerId);
      return null;
    }
    return checkpoint;
  }

  Future<void> save(ActivityCheckpoint checkpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final route = checkpoint.route.length > maxPoints
        ? checkpoint.route.sublist(checkpoint.route.length - maxPoints)
        : checkpoint.route;
    final payload = ActivityCheckpoint(
      ownerId: checkpoint.ownerId,
      activityType: checkpoint.activityType,
      startedAt: checkpoint.startedAt,
      elapsedS: checkpoint.elapsedS,
      distanceM: checkpoint.distanceM,
      route: route,
      lastUpdatedMs: DateTime.now().millisecondsSinceEpoch,
    );
    await prefs.setString(_prefsKey, jsonEncode(payload.toJson()));
  }

  /// Clear the checkpoint. Passing an owner only clears their own session.
  Future<void> clear([String? ownerId]) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    if (ownerId != null && ownerId.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map && (decoded['owner_id'] as String?) != ownerId) {
          return;
        }
      } catch (_) {
        // Corrupt data is safe to delete.
      }
    }
    await prefs.remove(_prefsKey);
  }

  /// Fire-and-forget helper for lifecycle callbacks and `dispose`.
  void saveNow(ActivityCheckpoint checkpoint) {
    unawaited(save(checkpoint));
  }
}
