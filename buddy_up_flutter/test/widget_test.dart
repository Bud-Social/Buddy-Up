import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:buddy_up_flutter/core/env/env.dart';

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env.example', isOptional: true);
  });

  test('production env defaults are configured', () {
    expect(Env.apiBaseUrl, isNotEmpty);
    expect(Env.wsBaseUrl, isNotEmpty);
    expect(Env.livekitUrl, isNotEmpty);
  });

  test('isLocal is false unless explicitly overridden', () {
    expect(Env.isLocal, isFalse);
  });
}