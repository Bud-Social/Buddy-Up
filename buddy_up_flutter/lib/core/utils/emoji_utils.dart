/// Reaction values are stored as emoji glyphs on the backend/web and legacy
/// short names still come back from older rows. Normalize everything to the
/// glyph before displaying, counting or sending a reaction.
const Map<String, String> reactionEmojiMap = {
  'pump': '💪',
  'fire': '🔥',
  'respect': '🤝',
  'grind': '😤',
  'lets_go': '🏋️',
  'haha': '😂',
  'too_hard': '💀',
  'heart': '❤️',
  'love': '❤️',
  'clap': '👏',
  'applause': '👏',
  'muscle': '💪',
  'strength': '💪',
};

/// Canonical reactions in the same order as the web picker.
const List<String> reactionEmojis = ['💪', '🔥', '🤝', '😤', '🏋️', '😂', '💀'];

String toReactionEmoji(String value) =>
    value.isEmpty ? value : (reactionEmojiMap[value] ?? value);

/// Collapses legacy short-name keys onto their emoji glyphs so counts and the
/// user's active reaction can be looked up with a single key.
Map<String, int> normalizeReactionCounts(Map<String, int> counts) {
  final normalized = <String, int>{};
  counts.forEach((key, value) {
    final emoji = toReactionEmoji(key);
    normalized[emoji] = (normalized[emoji] ?? 0) + value;
  });
  return normalized;
}
