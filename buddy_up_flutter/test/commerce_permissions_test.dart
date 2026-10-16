import 'package:buddy_up_flutter/features/marketplace/utils/commerce_permissions.dart';
import 'package:flutter_test/flutter_test.dart';

/// The client-side mirror of the backend's publishing gates.
///
/// The matrix in `_can_create_meal_plan` and `_resolve_commerce_publisher`
/// (`backend/apps/marketplace/views.py`) is re-derived here line for line,
/// because a client that offers a button the server refuses is a worse bug than
/// one that hides a button the server would have accepted. These tests exist so
/// the two stay in step: if the backend widens or narrows a rule, the row that
/// changes should fail here first.
void main() {
  CommercePermissions profile({
    String role = 'user',
    String verificationStatus = 'none',
    Set<String> gyms = const {},
    List<MyShopRole> shops = const [],
  }) {
    return CommercePermissions(
      role: role,
      verificationStatus: verificationStatus,
      ownedGymHandles: gyms,
      myShops: shops,
    );
  }

  group('_can_create_meal_plan', () {
    test('a verified trainer may', () {
      expect(profile(role: 'trainer', verificationStatus: 'trainer').canCreateMealPlan,
          isTrue);
    });

    test('a verified practitioner may', () {
      expect(profile(role: 'practitioner', verificationStatus: 'practitioner').canCreateMealPlan,
          isTrue);
    });

    test('a gym owner may, and needs no shop to do it', () {
      final owner = profile(gyms: {'iron-foundry'});
      expect(owner.canCreateMealPlan, isTrue);
      expect(owner.publishesUnderAShop, isFalse,
          reason: 'running a gym is not the same as owning a shop');
    });

    test('a gym co-owner may', () {
      expect(profile(gyms: {'iron-foundry'}).canCreateMealPlan, isTrue);
    });

    test('a plain gym member may not', () {
      // Membership alone is not ownership. The set this gate reads is already
      // filtered by `ownedGymsProvider` on `membership_role in owner/co_owner`, so
      // "a plain gym member" arrives here holding nothing — which is the whole
      // reason the gate cannot be widened by a stray `hasGymMembership` flag.
      expect(kGymOwnerMembershipRoles, isNot(contains('member')));
      final member = profile();
      expect(member.runsAGym, isFalse);
      expect(member.canCreateMealPlan, isFalse);
    });

    test('an unverified trainer may not', () {
      // `role` was client-declared at registration, so a role with no matching
      // verification status is an unproven claim — the server's
      // `is_verified_role()` returns False for exactly this row.
      for (final status in ['none', 'email', 'id', 'shop', 'gym', 'distributor']) {
        expect(profile(role: 'trainer', verificationStatus: status).canCreateMealPlan,
            isFalse,
            reason: 'verification_status=$status does not certify trainer');
      }
    });

    test('a trainer status on a practitioner role does not certify', () {
      expect(profile(role: 'practitioner', verificationStatus: 'trainer').canCreateMealPlan,
          isFalse);
    });

    test('a plain user may not', () {
      expect(profile().canCreateMealPlan, isFalse);
      expect(CommercePermissions.none.canCreateMealPlan, isFalse);
    });

    test('a verified distributor alone does not grant meal-plan authority', () {
      // The backend keeps the two gates separate on purpose: nutrition authority
      // comes from a professional credential or a gym, not from selling things.
      expect(profile(role: 'distributor', verificationStatus: 'distributor').canCreateMealPlan,
          isFalse);
    });
  });

  group('_resolve_commerce_publisher', () {
    test('a verified distributor with no shop may publish', () {
      final distributor = profile(role: 'distributor', verificationStatus: 'distributor');
      expect(distributor.publishesUnderAShop, isFalse);
      expect(distributor.canPublishCommerce, isTrue);
    });

    test('a shop owner may', () {
      final owner = profile(shops: const [MyShopRole(handle: 'iron-goods', role: 'owner')]);
      expect(owner.canPublishCommerce, isTrue);
    });

    test('a shop manager may', () {
      final manager = profile(shops: const [MyShopRole(handle: 'iron-goods', role: 'manager')]);
      expect(manager.canPublishCommerce, isTrue);
    });

    test('shop staff may not', () {
      // Staff operate a shop; the backend filters on owner/manager, so this must
      // not read as permission or the user eats a 403 on the create screen.
      final staff = profile(shops: const [MyShopRole(handle: 'iron-goods', role: 'staff')]);
      expect(staff.publishesUnderAShop, isFalse);
      expect(staff.canPublishCommerce, isFalse);
    });

    test('a plain user may not', () {
      expect(profile().canPublishCommerce, isFalse);
    });

    test('an unverified distributor may not', () {
      expect(profile(role: 'distributor', verificationStatus: 'none').canPublishCommerce,
          isFalse);
    });

    test('owning a shop as staff plus being a distributor does not need the shop',
        () {
      final both = profile(
        role: 'distributor',
        verificationStatus: 'distributor',
        shops: const [MyShopRole(handle: 'iron-goods', role: 'staff')],
      );
      expect(both.canPublishCommerce, isTrue,
          reason: 'the distributor grant stands on its own');
    });
  });

  group('programmes are not gated', () {
    test('a plain user is not blocked from creating a programme', () {
      // The backend does not gate programme creation, so inventing a rule here
      // would hide a button the server accepts. Nothing in this file should ever
      // be read as "programmes are gated" — they simply are not modelled.
      final nobody = profile();
      expect(nobody.canCreateMealPlan, isFalse);
      expect(nobody.canPublishCommerce, isFalse);
    });
  });

  group('unknown signals close the gate, never open it', () {
    test('a role this build has never heard of is not verified', () {
      expect(isVerifiedRole('nutritionist', 'nutritionist'), isFalse);
      expect(profile(role: 'nutritionist', verificationStatus: 'nutritionist')
          .canCreateMealPlan, isFalse);
    });

    test('a blank role is not a verified role', () {
      expect(isVerifiedRole('', ''), isFalse);
      expect(isVerifiedRole(null, null), isFalse);
      expect(isVerifiedRole('trainer', ''), isFalse);
    });

    test('whitespace is trimmed rather than compared literally', () {
      expect(isVerifiedRole(' trainer ', ' trainer '), isTrue);
    });

    test('an empty gym-handle set is not a gym', () {
      expect(profile(gyms: {'', '  '}).runsAGym, isFalse);
    });

    test('an unrecognised shop membership is not a publisher', () {
      final odd = profile(shops: const [MyShopRole(handle: 'iron-goods', role: 'viewer')]);
      expect(odd.canPublishCommerce, isFalse);
    });
  });

  group('parsing shops/my/', () {
    Map<String, dynamic> shop(String handle, String role) =>
        {'id': 's-$handle', 'handle': handle, 'my_role': role};

    test('every membership comes back, staff included', () {
      // Parsing reports; the gate decides. Keeping the filter out of here is what
      // stops "which roles publish" from drifting between two places.
      final roles = parseMyShopRoles({
        'data': [shop('iron-goods', 'owner'), shop('rival', 'staff')],
      });
      expect(roles.map((r) => r.role), ['owner', 'staff']);
    });

    test('a row with no my_role is dropped, never defaulted to owner', () {
      // `shops/my/` is the only endpoint that sends it; every other shape of shop
      // omits the key entirely and must not inherit publishing rights from it.
      final roles = parseMyShopRoles({'data': [
        {'id': 's1', 'handle': 'iron-goods'},
        shop('rival', 'manager'),
      ]});
      expect(roles.map((r) => r.handle), ['rival']);
    });

    test('a bare array body is accepted as well as the envelope', () {
      expect(parseMyShopRoles([shop('iron-goods', 'owner')]), hasLength(1));
    });

    test('a missing, null or non-list body yields nothing', () {
      for (final body in [null, {}, {'data': null}, {'data': 'nope'}, 7]) {
        expect(parseMyShopRoles(body), isEmpty, reason: 'body=$body');
      }
    });

    test('a role of whitespace is treated as absent', () {
      expect(parseMyShopRoles({'data': [shop('iron-goods', '   ')]}), isEmpty);
    });
  });
}