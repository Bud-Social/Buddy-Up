import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/core/utils/emoji_utils.dart';

void main() {
  group('reaction emoji parity with web/backend', () {
    test('legacy short names normalize to the same glyphs the web sends', () {
      expect(toReactionEmoji('pump'), '💪');
      expect(toReactionEmoji('fire'), '🔥');
      expect(toReactionEmoji('respect'), '🤝');
      expect(toReactionEmoji('grind'), '😤');
      expect(toReactionEmoji('lets_go'), '🏋️');
      expect(toReactionEmoji('haha'), '😂');
      expect(toReactionEmoji('too_hard'), '💀');
    });

    test('actual emoji glyphs pass through unchanged', () {
      expect(toReactionEmoji('💪'), '💪');
      expect(toReactionEmoji('😂'), '😂');
      expect(toReactionEmoji('🎉'), '🎉');
      expect(toReactionEmoji(''), '');
    });

    test('legacy and glyph counts collapse onto one key', () {
      final counts = normalizeReactionCounts({
        'pump': 2,
        '💪': 1,
        'fire': 3,
        'unknown_emoji': 1,
      });
      expect(counts['💪'], 3);
      expect(counts['🔥'], 3);
      expect(counts['unknown_emoji'], 1);
    });
  });
}
