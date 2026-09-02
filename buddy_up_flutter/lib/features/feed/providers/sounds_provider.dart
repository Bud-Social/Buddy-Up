import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feed_provider.dart';

/// A library sound from GET /api/v1/sounds/.
class Sound {
  final String id;
  final String name;
  final String artist;
  final String audioUrl;
  final int durationMs;
  final String source;
  final int usageCount;

  const Sound({
    required this.id,
    required this.name,
    required this.artist,
    required this.audioUrl,
    this.durationMs = 0,
    this.source = '',
    this.usageCount = 0,
  });

  factory Sound.fromJson(Map<String, dynamic> json) {
    return Sound(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      artist: '${json['artist'] ?? ''}',
      audioUrl: '${json['audio_url'] ?? json['audioUrl'] ?? ''}',
      durationMs: (json['duration_ms'] as num?)?.toInt() ?? 0,
      source: '${json['source'] ?? ''}',
      usageCount: (json['usage_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class SoundsState {
  final List<Sound> items;
  final bool isLoading;
  final String query;
  final String ordering; // trending | recent
  final String? error;

  const SoundsState({
    this.items = const [],
    this.isLoading = false,
    this.query = '',
    this.ordering = 'trending',
    this.error,
  });

  SoundsState copyWith({
    List<Sound>? items,
    bool? isLoading,
    String? query,
    String? ordering,
    String? error,
  }) {
    return SoundsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      ordering: ordering ?? this.ordering,
      error: error,
    );
  }
}

class SoundsNotifier extends Notifier<SoundsState> {
  @override
  SoundsState build() => const SoundsState();

  Future<void> load({String? query, String? ordering}) async {
    final repo = ref.read(feedRepositoryProvider);
    final q = query ?? state.query;
    final ord = ordering ?? state.ordering;
    state = state.copyWith(isLoading: true, query: q, ordering: ord, error: null);
    try {
      final raw = await repo.getSounds(q: q.isEmpty ? null : q, ordering: ord);
      final results = raw['results'] ?? raw['data'] ?? raw;
      final items = results is List
          ? results
              .whereType<Map>()
              .map((e) => Sound.fromJson(e.cast<String, dynamic>()))
              .toList()
          : const <Sound>[];
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      debugPrint('sounds load failed: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Fire-and-forget usage counter so trending stays fresh.
  Future<void> markUsed(String soundId) async {
    try {
      await ref.read(feedRepositoryProvider).useSound(soundId);
    } catch (_) {}
  }
}

final soundsProvider = NotifierProvider<SoundsNotifier, SoundsState>(
  SoundsNotifier.new,
);
