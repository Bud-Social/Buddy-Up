import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/core/utils/distance.dart';

/// Distance bands shown on every "near me" surface.
///
/// The sub-kilometre band used to advertise metre-level precision the API
/// cannot deliver (`850 m`, `640 m`), which sent people to the wrong corner.
/// It is now a single `<1 km` band; 1 km and above is untouched so the
/// familiar numbers do not move.
void main() {
  group('formatDistanceBadge — under 1 km', () {
    test('collapses every sub-kilometre reading to one band', () {
      expect(formatDistanceBadge(0.04), '<1 km');
      expect(formatDistanceBadge(0.64), '<1 km');
      expect(formatDistanceBadge(0.85), '<1 km');
      expect(formatDistanceBadge(0.999), '<1 km');
    });

    test('never renders a bare metre reading', () {
      expect(formatDistanceBadge(0.85), isNot(matches(RegExp(r'^\d+ m$'))));
    });

    test('treats exactly 1 km as a real distance', () {
      expect(formatDistanceBadge(1.0), '1.0 km');
    });
  });

  group('formatDistanceBadge — 1 km and above', () {
    test('one decimal below 10 km', () {
      expect(formatDistanceBadge(1.3), '1.3 km');
      expect(formatDistanceBadge(9.94), '9.9 km');
    });

    test('whole kilometres at and above 10 km', () {
      expect(formatDistanceBadge(12), '12 km');
      expect(formatDistanceBadge(12.4), '12 km');
      expect(formatDistanceBadge(240.6), '241 km');
    });
  });

  group('formatDistanceBadge — unbandable distances', () {
    test('null for a distance the API could not compute', () {
      expect(formatDistanceBadge(null), isNull);
    });

    test('null for NaN and infinity', () {
      expect(formatDistanceBadge(double.nan), isNull);
      expect(formatDistanceBadge(double.infinity), isNull);
      expect(formatDistanceBadge(double.negativeInfinity), isNull);
    });

    test('null for a negative reading rather than a nonsense badge', () {
      expect(formatDistanceBadge(-1), isNull);
    });
  });
}