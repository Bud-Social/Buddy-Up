import 'package:media_kit/media_kit.dart';

/// Looping ring/ringback tones for the call flow. Uses media_kit (already a
/// dependency) so no new audio stack is needed. Each named loop is a singleton
/// — starting one stops the previous with the same key.
class Ringtone {
  Ringtone._();

  static final Map<String, Player> _players = {};

  static Future<void> playLoop(String key, String assetPath) async {
    await stop(key);
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
    final player = _players.remove(key);
    if (player == null) return;
    try {
      await player.stop();
    } catch (_) {}
    try {
      await player.dispose();
    } catch (_) {}
  }

  static Future<void> stopAll() async {
    for (final key in [..._players.keys]) {
      await stop(key);
    }
  }
}
