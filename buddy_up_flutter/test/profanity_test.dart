import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/core/utils/profanity.dart';

void main() {
  test('masks whole words and keeps the first letter', () {
    expect(maskProfanity('what the hell'), 'what the h***');
    expect(maskProfanity('This is shit.'), 'This is s***.');
  });

  test('leaves non-matching text and partial words alone', () {
    expect(maskProfanity('Shell out for a classic'), 'Shell out for a classic');
    expect(maskProfanity('assessment'), 'assessment');
    expect(maskProfanity(''), '');
  });
}
