import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/marketplace.dart';
import 'package:buddy_up_flutter/features/marketplace/utils/delivery_vehicles.dart';
import 'package:buddy_up_flutter/features/marketplace/utils/stations.dart';

/// Fixtures shaped from `PickupStationSerializer` and `PickupStationListView`
/// in `backend/apps/marketplace/`.
void main() {
  Map<String, dynamic> stationJson({
    String id = 's1',
    String name = 'Karura Fitness',
    String? address = 'Mombasa Road',
    String? city = 'Nairobi',
    String? country = 'Kenya',
    String? instructions = 'Buzz 4B',
    Map<String, dynamic> openingHours = const {
      'monday': {'open': '06:00', 'close': '22:00'},
      'tuesday': {'open': '06:00', 'close': '22:00'},
      'wednesday': {'open': '06:00', 'close': '22:00'},
      'thursday': {'open': '06:00', 'close': '22:00'},
      'friday': {'open': '06:00', 'close': '22:00'},
      'saturday': {'open': '08:00', 'close': '18:00'},
      'sunday': {'closed': true},
    },
    double? distanceKm,
  }) {
    return {
      'id': id,
      'name': name,
      'description': '',
      'address': address,
      'city': city,
      'country': country,
      // DecimalField columns serialise as strings.
      'latitude': '-1.286389',
      'longitude': '36.823608',
      'opening_hours': openingHours,
      'phone': '+254 712 345 678',
      'instructions': instructions,
      'is_active': true,
      'is_primary': true,
      'owner_type': 'shop',
      'owner_name': 'Iron Foundry',
      'shop': '11111111-1111-1111-1111-111111111111',
      if (distanceKm != null) 'distance_km': distanceKm,
      'created_at': '2026-03-01T00:00:00Z',
    };
  }

  group('parsing', () {
    test('a bare array is the documented shape', () {
      final stations = stationList([stationJson()]);
      expect(stations, hasLength(1));
      expect(stations.first.name, 'Karura Fitness');
    });

    test('a paginated body does not crash the picker', () {
      final stations = stationList({
        'results': [stationJson()],
      });
      expect(stations, hasLength(1));
    });

    test('an `items` body is tolerated too', () {
      expect(stationList({'items': [stationJson()]}), hasLength(1));
    });

    test('a null or unrecognised body is an empty list, not an error', () {
      expect(stationList(null), isEmpty);
      expect(stationList('nonsense'), isEmpty);
    });

    test('decimal columns arrive as strings and still parse', () {
      final station = stationList([stationJson()]).first;
      expect(station.latitude, closeTo(-1.286389, 0.000001));
      expect(station.longitude, closeTo(36.823608, 0.000001));
    });
  });

  group('distance handling', () {
    test('distance is absent unless the caller supplied lat and lng', () {
      // The server never infers a buyer location, so a list fetched without
      // coordinates carries no distances at all. That is a degraded case, not an
      // error.
      final station = stationList([stationJson()]).first;
      expect(station.distanceKm, isNull);
      expect(hasStationDistance(station), isFalse);
    });

    test('a measured station is recognised', () {
      final station = stationList([stationJson(distanceKm: 2.4)]).first;
      expect(hasStationDistance(station), isTrue);
    });

    test('server order is kept when nothing is measured', () {
      final stations = stationList([
        stationJson(id: 'a', name: 'Alpha'),
        stationJson(id: 'b', name: 'Beta'),
      ]);
      expect(
        sortStationsByDistance(stations).map((s) => s.name),
        ['Alpha', 'Beta'],
      );
    });

    test('measured rows sort nearest first, unmeasured sink to the bottom', () {
      final stations = stationList([
        stationJson(id: 'far', name: 'Far', distanceKm: 12.0),
        stationJson(id: 'none', name: 'Unknown'),
        stationJson(id: 'near', name: 'Near', distanceKm: 1.2),
      ]);
      expect(
        sortStationsByDistance(stations).map((s) => s.name),
        ['Near', 'Far', 'Unknown'],
      );
    });
  });

  group('labels', () {
    test('the area collapses address, city and country', () {
      expect(
        stationAreaLabel(stationList([stationJson()]).first),
        'Mombasa Road, Nairobi, Kenya',
      );
    });

    test('a station with no address degrades to a placeholder', () {
      final station = stationList([
        stationJson(address: null, city: null, country: null),
      ]).first;
      expect(stationAreaLabel(station), addressUnknownLabel);
    });

    test('identical windows on all seven days read as Daily', () {
      final station = stationList([stationJson(openingHours: {
        for (final day in stationDayKeys) day: {'open': '08:00', 'close': '20:00'},
      })]).first;
      expect(stationOpeningHoursLabel(station.openingHours), 'Daily 08:00–20:00');
    });

    test('a weekday-only gym is not Daily, and closed days are dropped', () {
      final station = stationList([stationJson(openingHours: {
        'monday': {'open': '06:00', 'close': '22:00'},
        'tuesday': {'open': '06:00', 'close': '22:00'},
        'saturday': {'open': '08:00', 'close': '18:00'},
        'sunday': {'closed': true},
      })]).first;
      expect(
        stationOpeningHoursLabel(station.openingHours),
        'Mon 06:00–22:00 · Tue 06:00–22:00 · Sat 08:00–18:00',
      );
    });

    test('a plain string per day is tolerated', () {
      final station = stationList([
        stationJson(openingHours: {'monday': '08:00-20:00'}),
      ]).first;
      expect(stationOpeningHoursLabel(station.openingHours), 'Mon 08:00-20:00');
    });

    test('absent or unrecognisable hours never collapse to an empty string', () {
      expect(stationOpeningHoursLabel({}), hoursUnknownLabel);
      expect(
        stationOpeningHoursLabel({'public_holidays': {'closed': true}}),
        hoursUnknownLabel,
      );
    });
  });

  group('degradation when the endpoint is absent', () {
    DioException missing() => DioException(
          requestOptions: RequestOptions(path: '/marketplace/stations/'),
          response: Response(
            requestOptions: RequestOptions(path: '/marketplace/stations/'),
            statusCode: 404,
          ),
        );

    DioException failing() => DioException(
          requestOptions: RequestOptions(path: '/marketplace/stations/'),
          response: Response(
            requestOptions: RequestOptions(path: '/marketplace/stations/'),
            statusCode: 500,
          ),
        );

    test('404, 405 and 501 mean "not built yet", not "broken"', () {
      for (final status in [404, 405, 501]) {
        final error = DioException(
          requestOptions: RequestOptions(path: '/marketplace/stations/'),
          response: Response(
            requestOptions: RequestOptions(path: '/marketplace/stations/'),
            statusCode: status,
          ),
        );
        expect(isStationsUnavailable(error), isTrue, reason: '$status');
      }
    });

    test('a real failure is not treated as absence', () {
      expect(isStationsUnavailable(failing()), isFalse);
    });

    test('an absent endpoint still produces a usable message', () {
      expect(stationsErrorMessage(missing(), fallback: 'Could not load.'),
          'Could not load.');
    });

    test("the server's own message is preferred over the fallback", () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/marketplace/stations/'),
        response: Response(
          requestOptions: RequestOptions(path: '/marketplace/stations/'),
          statusCode: 400,
          data: {
            'success': false,
            'message': 'owner_type must be one of: [shop, gym].',
            'errors': null,
          },
        ),
      );
      expect(
        stationsErrorMessage(error, fallback: 'Could not load.'),
        'owner_type must be one of: [shop, gym].',
      );
      expect(isStationsUnavailable(error), isFalse);
    });
  });

  group('client-side search', () {
    test('matches name, area, city, owner and instructions', () {
      final stations = stationList([
        stationJson(id: 'a', name: 'Karura Fitness', address: 'Mombasa Road'),
        stationJson(
          id: 'b',
          name: 'Iron Foundry',
          address: 'Ngong Road',
          instructions: 'Use the loading bay',
        ),
      ]);
      expect(filterStations(stations, 'karura').map((s) => s.id), ['a']);
      expect(filterStations(stations, 'ngong').map((s) => s.id), ['b']);
      expect(filterStations(stations, 'buzz').map((s) => s.id), ['a']);
    });

    test('an empty query returns everything', () {
      final stations = stationList([stationJson()]);
      expect(filterStations(stations, '   '), hasLength(1));
    });

    test('a query that matches nothing returns nothing', () {
      final stations = stationList([stationJson()]);
      expect(filterStations(stations, 'atlantis'), isEmpty);
    });
  });

  group('vehicle types are a wire contract', () {
    test('exactly the six backend choices, in order', () {
      expect(
        deliveryVehicleTypeValues,
        ['bike', 'motorbike', 'tuktuk', 'car', 'pickup', 'lorry'],
      );
    });

    test('labels mirror get_vehicle_type_display', () {
      expect(deliveryVehicleLabel('tuktuk'), 'Tuk-tuk');
      expect(deliveryVehicleLabel('lorry'), 'Lorry / Truck');
      expect(deliveryVehicleLabel('pickup'), 'Pickup Truck');
    });

    test('an unknown value still renders as itself', () {
      expect(deliveryVehicleLabel('hovercraft'), 'hovercraft');
    });
  });

  group('service zones', () {
    test('split on commas, newlines and semicolons, then de-duplicate', () {
      expect(
        parseServiceZones('Westlands, Kilimani\nParklands; westlands'),
        ['Westlands', 'Kilimani', 'Parklands'],
      );
    });

    test('blank input is an empty list, not a list of one blank', () {
      expect(parseServiceZones('  , ; '), isEmpty);
      expect(serviceZonesLabel(const []), 'No zones listed');
    });
  });
}