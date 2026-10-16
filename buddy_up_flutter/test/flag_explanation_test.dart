import 'package:buddy_up_flutter/data/models/admin_portal.dart';
import 'package:flutter_test/flutter_test.dart';

ContentFlag _flag({String explanation = '', String method = '', bool bias = false}) {
  return ContentFlag.fromJson({
    'id': 'f1',
    'flag_reason': 'toxic',
    'severity': 'high',
    'confidence': 0.82,
    'source': 'ai_service',
    'content_type': 'feed.post',
    'content_id': 'abc',
    'content_preview': 'text',
    'is_actioned': false,
    'action_taken': '',
    'created_at': '2026-03-01T00:00:00Z',
    if (explanation.isNotEmpty) 'ai_explanation': explanation,
    if (method.isNotEmpty) 'ai_method': method,
    'bias_assessed': bias,
  });
}

void main() {
  group('ContentFlag model explanations', () {
    test('carries the explanation, method and bias flag across the wire', () {
      final flag = _flag(
        explanation: 'The safety classifier flagged this as unsafe (LABEL_1, 78%).',
        method: 'onnx_2.0.0',
      );

      expect(flag.aiExplanation, contains('LABEL_1'));
      expect(flag.aiMethod, 'onnx_2.0.0');
      expect(flag.biasAssessed, isFalse);
    });

    test('a flag with no stored explanation parses to empty, not a crash', () {
      // Hand-raised flags, and rows written before the field existed, have
      // none. The screen has to be able to say so rather than throwing.
      final flag = _flag();
      expect(flag.aiExplanation, isEmpty);
      expect(flag.aiMethod, isEmpty);
      expect(flag.biasAssessed, isFalse);
    });

    test('an older payload without the fields at all still parses', () {
      // The decisive case: a client talking to a server that has not shipped
      // these fields, or a cached response from before they existed.
      final flag = ContentFlag.fromJson({
        'flag_reason': 'nsfw',
        'severity': 'low',
        'confidence': 0.1,
      });

      expect(flag.aiExplanation, isEmpty);
      expect(flag.biasAssessed, isFalse);
    });

    test('bias_assessed: true survives the round-trip', () {
      // False means "not assessed". True means a model actually ran, and the UI
      // drops the caveat. Collapsing the two would let a reviewer read silence
      // as a clean bill of health on bias.
      final flag = _flag(explanation: 'Flagged.', bias: true);
      expect(flag.biasAssessed, isTrue);
    });
  });
}
