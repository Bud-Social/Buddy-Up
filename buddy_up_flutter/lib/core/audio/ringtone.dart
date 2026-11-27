import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';

/// Looping ring/ringback tones for the call flow. Uses media_kit (already a
/// dependency) so no new audio stack is needed. Each named loop is a singleton
/// — starting one stops the previous with the same key.
class Ringtone {
  Ringtone._();

  static final Map<String, Player> _players = {};
  static const _channel = MethodChannel('com.buddyup.fit/audio');

  static Future<void> playLoop(String key, String assetPath) async {
    await stop(key);
    try {
      await _channel.invokeMethod('playLoop', {
        'key': key,
        'asset': assetPath,
        'alarm': key == 'alarm',
      });
      return;
    } catch (_) {
      // iOS/desktop and older builds fall back to the bundled player.
    }
    final player = Player();
    try {
      await player.setVolume(100);
      await player.setPlaylistMode(PlaylistMode.loop);
      await player.open(Media('asset:///$assetPath'), play: true);
      _players[key] = player;
    } catch (_) {
      try {
        await player.dispose();
      } catch (_) {}
    }
  }

  static Future<void> stop(String key) async {
    try {
      await _channel.invokeMethod('stop', {'key': key});
    } catch (_) {}
    final player = _players.remove(key);
    if (player == null) return;
    try {
      await player.stop();
    } catch (_) {}
    try {
      await player.dispose();
    } catch (_) {}
  }

  /// Plays a cached custom alarm on the platform alarm stream. The file is
  /// downloaded once and remains available when the device is offline.
  static Future<void> playAlarmFile(String path) async {
    try {
      await _channel.invokeMethod('playFile', {'key': 'alarm', 'path': path});
      return;
    } catch (_) {}
    await playLoop('alarm', 'assets/ringtones/incoming_ring.wav');
  }

  static Future<void> stopAll() async {
    for (final key in [..._players.keys]) {
      await stop(key);
    }
  }
}
