import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/analytics_repository.dart';
import '../../../data/models/analytics.dart';

/// One activity captured while the device had no usable connection.
class QueuedActivity {
  const QueuedActivity({
    required this.clientId,
    required this.ownerId,
    required this.queuedAtMs,
    required this.payload,
  });

  final String clientId;
  final String ownerId;
  final int queuedAtMs;
  final Map<String, dynamic> payload;

  factory QueuedActivity.fromJson(Map<String, dynamic> json) => QueuedActivity(
    clientId: json['client_id'] as String,
    ownerId: json['owner_id'] as String? ?? '',
    queuedAtMs: (json['queued_at'] as num?)?.toInt() ?? 0,
    payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const {}),
  );

  Map<String, dynamic> toJson() => {
    'client_id': clientId,
    'owner_id': ownerId,
    'queued_at': queuedAtMs,
    'payload': payload,
  };
}

class QueueFlushResult {
  const QueueFlushResult({
    required this.synced,
    required this.failed,
    required this.remaining,
  });

  final int synced;
  final int failed;
  final int remaining;

  static const empty = QueueFlushResult(synced: 0, failed: 0, remaining: 0);
}

/// Durable queue for activities recorded offline.
///
/// The API already de-duplicates on `source_event_id` (unique per user), so a
/// replay is safe: sending the same session twice writes one row. This service
/// keeps the whole payload — route points included — on the device until the
/// server accepts it, then drops it.
///
/// Records carry the account that created them, so a queued run is only ever
/// replayed for the same user even if someone else signs in on this phone.
class ActivityQueueService {
  ActivityQueueService(this._repository);

  static const _prefsKey = 'analytics.pending_activities.v1';
  static const _localActivityKey = 'analytics.local_activities.v1';
  static const _uuid = Uuid();

  final AnalyticsRepository _repository;

  /// Pending count for the account last passed to [refreshCount].
  final ValueNotifier<int> pendingCount = ValueNotifier<int>(0);

  Future<QueueFlushResult>? _flushing;

  /// A client-generated id that doubles as the server-side idempotency key.
  static String newClientId() => _uuid.v4();

  Future<List<QueuedActivity>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return <QueuedActivity>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <QueuedActivity>[];
      return [
        for (final entry in decoded)
          if (entry is Map)
            QueuedActivity.fromJson(Map<String, dynamic>.from(entry)),
      ];
    } catch (_) {
      // Corrupt storage must not brick the feature — start clean.
      return <QueuedActivity>[];
    }
  }

  Future<void> _writeAll(List<QueuedActivity> items) async {
    final prefs = await SharedPreferences.getInstance();
    if (items.isEmpty) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(
        _prefsKey,
        jsonEncode([for (final item in items) item.toJson()]),
      );
    }
  }

  /// Keep a compact local copy of activity facts so the analytics surface is
  /// useful immediately after recording and while the device is offline.
  Future<void> recordLocalActivity(
    Map<String, dynamic> payload, {
    required String ownerId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localActivityKey);
    List<Map<String, dynamic>> items = [];
    try {
      final decoded = raw == null ? null : jsonDecode(raw);
      if (decoded is List) {
        items = [
          for (final item in decoded)
            if (item is Map) Map<String, dynamic>.from(item),
        ];
      }
    } catch (_) {}
    final id = payload['source_event_id'] as String? ?? newClientId();
    items.removeWhere((item) =>
        item['owner_id'] == ownerId && item['source_event_id'] == id);
    items.add({
      ...payload,
      'owner_id': ownerId,
      'source_event_id': id,
      'recorded_at': DateTime.now().toIso8601String(),
    });
    // Keep the cache bounded; the server remains the source of truth online.
    if (items.length > 250) items = items.sublist(items.length - 250);
    await prefs.setString(_localActivityKey, jsonEncode(items));
  }

  Future<ActivitySummary?> localSummary(String? ownerId) async {
    if (ownerId == null || ownerId.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localActivityKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      final rows = decoded
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .where((row) => row['owner_id'] == ownerId)
          .toList();
      if (rows.isEmpty) return null;
      final byType = <String, Map<String, dynamic>>{};
      var distance = 0.0;
      var duration = 0;
      var calories = 0.0;
      var steps = 0;
      for (final row in rows) {
        final type = row['activity_type'] as String? ?? 'other';
        final bucket = byType.putIfAbsent(type, () => {
              'label': type[0].toUpperCase() + type.substring(1),
              'count': 0,
              'calories': 0.0,
              'distance_km': 0.0,
              'duration': 0.0,
            });
        final rowDistance = (row['distance_meters'] as num?)?.toDouble() ?? 0;
        final rowDuration = (row['duration_seconds'] as num?)?.toInt() ?? 0;
        final rowCalories =
            (row['calories_burned'] as num?)?.toDouble() ?? 0;
        final rowSteps = (row['steps'] as num?)?.toInt() ?? 0;
        bucket['count'] = (bucket['count'] as int) + 1;
        bucket['calories'] = (bucket['calories'] as double) + rowCalories;
        bucket['distance_km'] =
            (bucket['distance_km'] as double) + rowDistance / 1000;
        bucket['duration'] =
            (bucket['duration'] as double) + rowDuration / 60;
        distance += rowDistance / 1000;
        duration += rowDuration;
        calories += rowCalories;
        steps += rowSteps;
      }
      final recent = rows.reversed.take(20).map((row) => {
            'id': row['source_event_id'] ?? '',
            'activity_type': row['activity_type'] ?? 'other',
            'started_at': row['started_at'] ?? row['recorded_at'],
            'duration_seconds': row['duration_seconds'] ?? 0,
            'distance_meters': row['distance_meters'] ?? 0,
            'distance_km':
                ((row['distance_meters'] as num?)?.toDouble() ?? 0) / 1000,
            'avg_pace': row['avg_pace'],
            'calories_burned': row['calories_burned'],
            'route': row['route'] ?? const [],
          });
      return ActivitySummary.fromJson({
        'count': rows.length,
        'total_distance_km': distance,
        'total_duration_seconds': duration,
        'total_calories_burned': calories,
        'total_steps': steps,
        'by_type': byType.values.toList(),
        'recent': recent.toList(),
      });
    } catch (_) {
      return null;
    }
  }

  Future<List<QueuedActivity>> pending(String? ownerId) async {
    if (ownerId == null) return const [];
    final items = (await _readAll()).where((r) => r.ownerId == ownerId).toList()
      ..sort((a, b) => a.queuedAtMs.compareTo(b.queuedAtMs));
    return items;
  }

  /// Refresh [pendingCount] for the signed-in account.
  Future<int> refreshCount(String? ownerId) async {
    final count = (await pending(ownerId)).length;
    pendingCount.value = count;
    return count;
  }

  /// Persist an activity locally. Returns the record that will be replayed.
  Future<QueuedActivity> enqueue(
    Map<String, dynamic> payload, {
    required String ownerId,
  }) async {
    final clientId =
        (payload['source_event_id'] as String?) ?? newClientId();
    final record = QueuedActivity(
      clientId: clientId,
      ownerId: ownerId,
      queuedAtMs: DateTime.now().millisecondsSinceEpoch,
      payload: {...payload, 'source_event_id': clientId},
    );
    final items = await _readAll();
    items.removeWhere((r) => r.clientId == record.clientId);
    items.add(record);
    await _writeAll(items);
    await recordLocalActivity(record.payload, ownerId: ownerId);
    await refreshCount(ownerId);
    return record;
  }

  Future<void> remove(String clientId) async {
    final items = await _readAll();
    items.removeWhere((r) => r.clientId == clientId);
    await _writeAll(items);
  }

  /// Errors worth retrying: never reached a server, server unavailable,
  /// rate-limited, or auth temporarily unavailable. A payload rejection
  /// (4xx other than those) is dropped so the queue cannot wedge forever.
  static bool isRetryable(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == null) return true;
      if (status >= 500) return true;
      return status == 401 ||
          status == 403 ||
          status == 408 ||
          status == 429;
    }
    return true;
  }

  /// Replay every queued activity for this account, oldest first.
  Future<QueueFlushResult> flush(String? ownerId) {
    if (ownerId == null) return Future.value(QueueFlushResult.empty);
    final running = _flushing;
    if (running != null) return running;
    final future = _runFlush(ownerId);
    _flushing = future;
    return future.whenComplete(() => _flushing = null);
  }

  Future<QueueFlushResult> _runFlush(String ownerId) async {
    final pendingItems = await pending(ownerId);
    var synced = 0;
    var failed = 0;

    for (final record in pendingItems) {
      try {
        await _repository.createActivity(record.payload);
        await remove(record.clientId);
        synced += 1;
      } catch (error) {
        if (isRetryable(error)) break;
        await remove(record.clientId);
        failed += 1;
      }
    }

    final remaining = await refreshCount(ownerId);
    return QueueFlushResult(
      synced: synced,
      failed: failed,
      remaining: remaining,
    );
  }
}
