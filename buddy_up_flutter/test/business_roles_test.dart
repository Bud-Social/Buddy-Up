import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/marketplace.dart';
import 'package:buddy_up_flutter/features/marketplace/utils/stations.dart';
import 'package:buddy_up_flutter/shared/navigation/business_roles.dart';

/// The "Your business" navigation group.
///
/// The rule these tests exist to lock: **a probe that fails can only ever hide
/// an entry.** A backend that is mid-rollout must never produce a nav tile for
/// something the caller does not hold, and must never break navigation.
void main() {
  const all = BusinessRoleFlags(
    hasShop: true,
    hasEvents: true,
    gymSlug: 'iron-foundry',
    gymName: 'Iron Foundry',
    hasStation: true,
    isCourier: true,
  );

  group('the default is "holds nothing"', () {
    test('an unresolved flags object produces no entries', () {
      expect(businessEntries(const BusinessRoleFlags()), isEmpty);
      expect(const BusinessRoleFlags().isEmpty, isTrue);
    });

    test('a loading flags object produces no entries either', () {
      expect(businessEntries(BusinessRoleFlags.empty), isEmpty);
    });
  });

  group('entries appear only when the signal is true', () {
    test('a shop owner sees the Creator Studio', () {
      final entries = businessEntries(
          const BusinessRoleFlags(hasShop: true));
      expect(entries.map((e) => e.key), [BusinessRoleKey.shop]);
      expect(entries.single.route, '/marketplace/creator-studio');
    });

    test('an organiser sees My Events', () {
      final entries =
          businessEntries(const BusinessRoleFlags(hasEvents: true));
      expect(entries.single.route, '/marketplace/events');
    });

    test('a gym owner is routed to that gym’s manage screen', () {
      final entries = businessEntries(
        const BusinessRoleFlags(gymSlug: 'iron-foundry', gymName: 'Iron Foundry'),
      );
      expect(entries.single.route, '/gyms/iron-foundry/manage');
      expect(entries.single.subtitle, 'Iron Foundry');
    });

    test('a gym with a handle but no name still gets a usable subtitle', () {
      final entries =
          businessEntries(const BusinessRoleFlags(gymSlug: 'iron-foundry'));
      expect(entries.single.subtitle, isNotEmpty);
    });

    test('a station owner sees My Stations', () {
      final entries =
          businessEntries(const BusinessRoleFlags(hasStation: true));
      expect(entries.single.route, '/marketplace/stations');
    });

    test('a courier sees the delivery dashboard', () {
      final entries = businessEntries(const BusinessRoleFlags(isCourier: true));
      expect(entries.single.route, '/marketplace/delivery');
    });
  });

  group('the order is working-priority, and stable', () {
    test('an operator holding everything gets all five, in order', () {
      expect(
        businessEntries(all).map((e) => e.key),
        [
          BusinessRoleKey.shop,
          BusinessRoleKey.events,
          BusinessRoleKey.gym,
          BusinessRoleKey.stations,
          BusinessRoleKey.courier,
        ],
      );
    });

    test('a courier alone still gets exactly one entry', () {
      final flags =
          all.copyWith(hasShop: false, hasEvents: false, gymSlug: null, hasStation: false);
      expect(businessEntries(flags).map((e) => e.key), [BusinessRoleKey.courier]);
    });
  });

  group('the switcher and the tiles are the same list', () {
    test('every entry has a route, a label and a compact label', () {
      for (final entry in businessEntries(all)) {
        expect(entry.route, startsWith('/'));
        expect(entry.label, isNotEmpty);
        expect(entry.shortLabel, isNotEmpty);
      }
    });

    test('no two entries share a route', () {
      final routes = businessEntries(all).map((e) => e.route).toList();
      expect(routes.toSet(), hasLength(routes.length));
    });
  });

  group('station ownership is derived, not asserted', () {
    PickupStation station({
      String id = 's1',
      String ownerType = 'shop',
      String? shop,
      String? gym,
    }) {
      return PickupStation.fromJson({
        'id': id,
        'name': 'Karura Fitness',
        'owner_type': ownerType,
        if (shop != null) 'shop': shop,
        if (gym != null) 'gym': gym,
      });
    }

    test('a shop station the caller owns is included', () {
      final owned = deriveOwnedStations(
        [station(shop: 'shop-1')],
        shopIds: {'shop-1'},
      );
      expect(owned, hasLength(1));
    });

    test('a shop station owned by somebody else is excluded', () {
      final owned = deriveOwnedStations(
        [station(shop: 'shop-9')],
        shopIds: {'shop-1'},
      );
      expect(owned, isEmpty);
    });

    test('a gym station is decided on the gym id, not the shop id', () {
      // The two id spaces are unrelated; reading the wrong field would match a
      // station owned by a different business.
      final owned = deriveOwnedStations(
        [station(ownerType: 'gym', gym: 'gym-1')],
        shopIds: {'gym-1'},
        gymIds: {'gym-1'},
      );
      expect(owned, hasLength(1));
    });

    test('a gym station the caller merely trains at is excluded', () {
      final owned = deriveOwnedStations(
        [station(ownerType: 'gym', gym: 'gym-2')],
        gymIds: const {},
      );
      expect(owned, isEmpty);
    });

    test('an owner_type of shop does not match a gym id in the caller’s set', () {
      final owned = deriveOwnedStations(
        [station(ownerType: 'shop', shop: 'gym-1')],
        gymIds: {'gym-1'},
      );
      expect(owned, isEmpty);
    });

    test('an unrecognised owner_type falls back to whichever id is present', () {
      // A station saved before `owner_type` existed must not be invisible.
      final owned = deriveOwnedStations(
        [station(ownerType: '', gym: 'gym-1')],
        gymIds: {'gym-1'},
      );
      expect(owned, hasLength(1));
    });

    test('a row with no owner id at all is never claimed', () {
      final owned = deriveOwnedStations(
        [station(ownerType: '', shop: null, gym: null)],
        shopIds: {'shop-1'},
        gymIds: {'gym-1'},
      );
      expect(owned, isEmpty);
    });

    test('an unknown owner must never widen the set', () {
      final owned = deriveOwnedStations(
        [station(shop: '')],
        shopIds: {'shop-1'},
      );
      expect(owned, isEmpty);
    });

    test('with no owned shops or gyms, nothing is owned', () {
      final owned = deriveOwnedStations([
        station(id: 'a', shop: 'shop-1'),
        station(id: 'b', ownerType: 'gym', gym: 'gym-1'),
      ]);
      expect(owned, isEmpty);
    });

    test('only the caller’s own rows survive a mixed list', () {
      final owned = deriveOwnedStations(
        [
          station(id: 'mine', shop: 'shop-1'),
          station(id: 'theirs', shop: 'shop-9'),
          station(id: 'gym-mine', ownerType: 'gym', gym: 'gym-1'),
          station(id: 'gym-theirs', ownerType: 'gym', gym: 'gym-9'),
        ],
        shopIds: {'shop-1'},
        gymIds: {'gym-1'},
      );
      expect(owned.map((s) => s.id), ['mine', 'gym-mine']);
    });
  });
}