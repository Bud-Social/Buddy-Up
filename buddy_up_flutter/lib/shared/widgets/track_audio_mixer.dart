import 'package:media_kit/media_kit.dart';

/// One added audio track on the clip timeline (mirrors the web mixer's
/// AddedTrackParams). All times are milliseconds unless noted.
class TrackCue {
  final String id;
  final String url;
  final double volume; // 0..200 (%)
  final int startMs; // timeline position where the track starts
  final int? durationMs; // max play length on the timeline
  final int offsetMs; // start position inside the audio file
  final int fadeInMs;
  final int fadeOutMs;
  final bool ducking;

  const TrackCue({
    required this.id,
    required this.url,
    this.volume = 100,
    this.startMs = 0,
    this.durationMs,
    this.offsetMs = 0,
    this.fadeInMs = 0,
    this.fadeOutMs = 0,
    this.ducking = false,
  });
}

/// Plays a post's parametric audio mix in sync with its video player.
///
/// Each cue gets its own media_kit Player; [sync] is driven by the video
/// position stream. Fades apply as live volume automation; ducking-enabled
/// tracks dip every other track to 35% while audible. Call [dispose] with
/// the owning widget.
class TrackAudioMixer {
  final Map<String, Player> _players = {};
  final Map<String, TrackCue> _cues = {};
  bool _disposed = false;

  /// Reconcile players with the desired cue list (keyed by cue id + url).
  void setTracks(List<TrackCue> cues) {
    if (_disposed) return;
    final nextIds = cues.map((c) => c.id).toSet();
    for (final id in _players.keys.toList()) {
      final existing = _cues[id];
      TrackCue? wanted;
      for (final c in cues) {
        if (c.id == id) wanted = c;
      }
      if (!nextIds.contains(id) || wanted == null || wanted.url != existing?.url) {
        _players.remove(id)?.dispose();
        _cues.remove(id);
      }
    }
    for (final cue in cues) {
      _cues[cue.id] = cue;
      _players.putIfAbsent(cue.id, () => Player());
    }
  }

  double _fade(TrackCue cue, int localMs, int windowMs) {
    var f = 1.0;
    if (cue.fadeInMs > 0 && localMs < cue.fadeInMs) {
      f = (localMs / cue.fadeInMs).clamp(0.0, 1.0);
    }
    if (cue.fadeOutMs > 0) {
      final remaining = windowMs - localMs;
      if (remaining < cue.fadeOutMs) {
        f = (remaining / cue.fadeOutMs).clamp(0.0, 1.0);
      }
    }
    return f.clamp(0.0, 1.0);
  }

  bool _inWindow(TrackCue cue, int positionMs, int trackLenMs) {
    final windowEnd = cue.startMs +
        (cue.durationMs ?? (trackLenMs > 0 ? trackLenMs : 0));
    return positionMs >= cue.startMs && positionMs < windowEnd;
  }

  /// Advance every cue to [positionMs] (clip timeline). [playing] is false
  /// while the video is paused, muted, or the page is inactive.
  Future<void> sync(int positionMs, bool playing) async {
    if (_disposed) return;
    // Ducking pass: any audible ducking cue dips the rest.
    var duckActive = false;
    if (playing) {
      for (final entry in _cues.entries) {
        final player = _players[entry.key];
        if (player == null || !entry.value.ducking) continue;
        final lenMs = player.state.duration.inMilliseconds;
        if (_inWindow(entry.value, positionMs, lenMs) && player.state.playing) {
          duckActive = true;
          break;
        }
      }
    }
    for (final entry in _cues.entries) {
      final cue = entry.value;
      final player = _players[entry.key];
      if (player == null) continue;
      final lenMs = player.state.duration.inMilliseconds;
      final windowMs = cue.durationMs ?? (lenMs > 0 ? lenMs : 0);
      final windowEnd = cue.startMs + windowMs;
      final inWindow =
          playing && windowMs > 0 && positionMs >= cue.startMs && positionMs < windowEnd;
      if (!inWindow) {
        if (player.state.playing) await player.pause();
        continue;
      }
      final localMs = positionMs - cue.startMs;
      var level = (cue.volume / 100).clamp(0.0, 1.0) *
          _fade(cue, localMs, windowMs);
      if (duckActive && !cue.ducking) level *= 0.35;
      await player.setVolume((level * 100).clamp(0, 100));
      final wantPos = cue.offsetMs + localMs;
      final drift = (player.state.position.inMilliseconds - wantPos).abs();
      if (!player.state.playing || drift > 750) {
        if (player.state.playlist.medias.isEmpty ||
            player.state.playlist.medias.first.uri != cue.url) {
          await player.open(Media(cue.url), play: false);
        }
        await player.seek(Duration(milliseconds: wantPos.clamp(0, 1 << 30)));
        await player.play();
      }
    }
  }

  /// Pause everything (page inactive / video muted).
  Future<void> silence() async {
    for (final player in _players.values) {
      try {
        if (player.state.playing) await player.pause();
      } catch (_) {}
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    for (final player in _players.values) {
      try {
        await player.dispose();
      } catch (_) {}
    }
    _players.clear();
    _cues.clear();
  }
}
