import 'package:buddy_up_flutter/core/updates/app_update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUpdateService.compareVersions', () {
    test('ignores the v prefix and build number suffix', () {
      expect(AppUpdateService.compareVersions('v1.0.0', '1.0.0+1'), 0);
      expect(AppUpdateService.compareVersions('v1.0.1', '1.0.0'), 1);
      expect(AppUpdateService.compareVersions('1.0.0', '1.0.1'), -1);
    });

    test('compares numeric components, not strings', () {
      expect(AppUpdateService.compareVersions('1.10.0', '1.9.9'), 1);
      expect(AppUpdateService.compareVersions('2.0', '1.99.99'), 1);
      expect(AppUpdateService.compareVersions('1.2', '1.2.1'), -1);
    });

    test('treats a missing component as zero', () {
      expect(AppUpdateService.compareVersions('v1.1', '1.1.0'), 0);
    });
  });
}
