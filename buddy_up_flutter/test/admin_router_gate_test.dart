import 'package:buddy_up_flutter/core/auth/auth_provider.dart';
import 'package:buddy_up_flutter/data/models/profile.dart';
import 'package:buddy_up_flutter/data/models/user.dart';
import 'package:buddy_up_flutter/router.dart';
import 'package:flutter_test/flutter_test.dart';

AuthState _auth({
  required bool isStaff,
  bool isAuthenticated = true,
  bool onboardingDone = true,
  bool isLoading = false,
}) {
  return AuthState(
    isAuthenticated: isAuthenticated,
    accessToken: isAuthenticated ? 'token' : null,
    isLoading: isLoading,
    user: isAuthenticated
        ? User(
            id: 'u1',
            email: isStaff ? 'staff@test.com' : 'person@test.com',
            isStaff: isStaff,
          )
        : null,
    profile: isAuthenticated
        ? Profile(
            userId: 'u1',
            username: isStaff ? 'staffer' : 'person',
            displayName: isStaff ? 'Staffer' : 'Person',
            onboardingCompleted: onboardingDone,
          )
        : null,
  );
}

void main() {
  group('admin console gate', () {
    test('a signed-in non-staff user is sent away from /admin', () {
      expect(redirectFor('/admin', _auth(isStaff: false)), '/feed');
    });

    test('a non-staff user cannot deep-link past the index', () {
      // The reason this gate exists: AdminConsoleScreen refuses to render for a
      // non-staff user, but several screens behind it never re-checked isStaff
      // in build, so the index was the only thing standing in the way.
      for (final route in const [
        '/admin/wallet',
        '/admin/users',
        '/admin/analytics',
        '/admin/staff-roles',
        '/admin/verification',
      ]) {
        expect(redirectFor(route, _auth(isStaff: false)), '/feed',
            reason: '$route must not be reachable by a non-staff user');
      }
    });

    test('a staff user keeps every admin route', () {
      for (final route in const [
        '/admin',
        '/admin/wallet',
        '/admin/users',
        '/admin/analytics',
        '/admin/analytics/predictive',
        '/admin/staff-roles',
      ]) {
        expect(redirectFor(route, _auth(isStaff: true)), isNull,
            reason: '$route should stay reachable for staff');
      }
    });

    test('the gate stops at a segment boundary', () {
      // startsWith('/admin') alone would also catch a future /administration.
      expect(redirectFor('/administer', _auth(isStaff: false)), isNull);
      expect(redirectFor('/admin-tools', _auth(isStaff: false)), isNull);
    });

    test('a signed-out visitor is sent to login, not to feed', () {
      expect(redirectFor('/admin', _auth(isStaff: false, isAuthenticated: false)), '/login');
    });
  });

  group('existing navigation rules still hold', () {
    test('a signed-out visitor reaches the public pages', () {
      expect(redirectFor('/terms', _auth(isStaff: false, isAuthenticated: false)), isNull);
      expect(redirectFor('/login', _auth(isStaff: false, isAuthenticated: false)), isNull);
    });

    test('incomplete onboarding is finished first', () {
      expect(
        redirectFor('/feed', _auth(isStaff: true, onboardingDone: false)),
        '/onboarding',
      );
    });

    test('a signed-in user is kept off the public pages', () {
      expect(redirectFor('/login', _auth(isStaff: false)), '/feed');
    });

    test('a normal route is untouched', () {
      expect(redirectFor('/feed', _auth(isStaff: false)), isNull);
      expect(redirectFor('/gyms/karura/manage', _auth(isStaff: false)), isNull);
    });

    test('nothing is decided while the session is still loading', () {
      expect(redirectFor('/admin', _auth(isStaff: false, isLoading: true)), isNull);
    });
  });
}