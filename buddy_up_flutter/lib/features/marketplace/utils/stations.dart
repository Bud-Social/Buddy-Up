import '../../../core/api/api_error.dart';
import '../../../data/models/marketplace.dart';

/// Helpers for the pickup-station list, mirroring
/// `frontend/src/api/stations.ts`.
///
/// Two rules shape everything here:
///
///  1. `GET /marketplace/stations/` only computes `distance_km` when **both**
///     `lat` and `lng` are supplied, and the server never infers a buyer's
///     location. A caller with no coordinates therefore gets a list with no
///     distances at all — a first-class state, not an error.
///  2. A 404 / 405 / 501 means the endpoint is absent, not broken. The checkout
///     uses that to fall back to a free-text collection point rather than
///     dead-ending the buyer.

const List<String> stationDayKeys = [
  'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday',
];

const Map<String, String> stationDayLabels = {
  'monday': 'Mon',
  'tuesday': 'Tue',
  'wednesday': 'Wed',
  'thursday': 'Thu',
  'friday': 'Fri',
  'saturday': 'Sat',
  'sunday': 'Sun',
};

const String hoursUnknownLabel = 'Hours not listed';
const String addressUnknownLabel = 'Address not listed';

/// True only for a usable, finite distance — the marker for "we know where the
/// buyer is".
bool hasStationDistance(PickupStation station) {
  final km = station.distanceKm;
  return km != null && km.isFinite;
}

/// Nearest first.
///
/// The API already sorts this way, but re-sorting locally means the list still
/// reads correctly if that ordering regresses. When no station carries a
/// distance the server's order is returned untouched (Dart's sort is stable, so
/// partially-measured lists keep their relative server order behind the
/// measured ones).
List<PickupStation> sortStationsByDistance(List<PickupStation> stations) {
  if (!stations.any(hasStationDistance)) return List.of(stations);
  final sorted = List.of(stations)
    ..sort((a, b) => _rank(a).compareTo(_rank(b)));
  return sorted;
}

double _rank(PickupStation station) =>
    hasStationDistance(station) ? station.distanceKm! : double.infinity;

/// Normalise a list payload that may arrive bare, paginated, or empty.
List<PickupStation> stationList(dynamic data) {
  if (data is List) {
    return data
        .whereType<Map<String, dynamic>>()
        .map(PickupStation.fromJson)
        .toList();
  }
  if (data is Map) {
    final results = data['results'];
    if (results is List) {
      return results
          .whereType<Map<String, dynamic>>()
          .map(PickupStation.fromJson)
          .toList();
    }
    final items = data['items'];
    if (items is List) {
      return items
          .whereType<Map<String, dynamic>>()
          .map(PickupStation.fromJson)
          .toList();
    }
  }
  return [];
}

/// `address, city, country` collapsed into one line, or a placeholder.
String stationAreaLabel(PickupStation station) {
  final parts = [station.address, station.city, station.country]
      .map((p) => (p ?? '').trim())
      .where((p) => p.isNotEmpty)
      .toList();
  return parts.isEmpty ? addressUnknownLabel : parts.join(', ');
}

String? _dayWindowLabel(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  if (value is Map) {
    if (value['closed'] == true) return null;
    final open = (value['open'] as String? ?? '').trim();
    final close = (value['close'] as String? ?? '').trim();
    if (open.isNotEmpty && close.isNotEmpty) return '$open–$close';
    if (open.isNotEmpty) return open;
    if (close.isNotEmpty) return close;
  }
  return null;
}

/// One-line opening-hours summary.
///
/// `Daily HH:MM–HH:MM` only appears when all seven days are defined and share
/// one window — a station that only opens on weekdays is not "Daily".
/// Otherwise each open day is labelled and closed days are dropped.
/// Unrecognised or absent hours degrade to a placeholder rather than an empty
/// string, so a picker row never collapses to two words.
String stationOpeningHoursLabel(Map<String, dynamic>? hours) {
  if (hours == null || hours.isEmpty) return hoursUnknownLabel;
  final windows = [
    for (final key in stationDayKeys) _dayWindowLabel(hours[key]),
  ];
  final first = windows.isEmpty ? null : windows.first;
  if (first != null &&
      windows.every((w) => w != null && w == first)) {
    return 'Daily $first';
  }
  final labelled = <String>[];
  for (var i = 0; i < stationDayKeys.length; i++) {
    final window = windows[i];
    if (window != null) {
      labelled.add('${stationDayLabels[stationDayKeys[i]]} $window');
    }
  }
  // Tolerate non-canonical day keys ("mon", "public_holidays") rather than
  // dropping them.
  for (final entry in hours.entries) {
    if (stationDayKeys.contains(entry.key)) continue;
    final window = _dayWindowLabel(entry.value);
    if (window != null) labelled.add(window);
  }
  return labelled.isEmpty ? hoursUnknownLabel : labelled.join(' · ');
}

/// True when the endpoint itself is absent (not built yet / wrong route) rather
/// than merely failing.
bool isStationsUnavailable(Object error) {
  final status = apiStatusCode(error);
  return status == 404 || status == 405 || status == 501;
}

/// Best-effort human message for a failed station call.
String stationsErrorMessage(Object error,
    {String fallback = 'Something went wrong.'}) =>
    apiErrorMessage(error, fallback: fallback);

/// Client-side filter for the "no location shared" case: name, area, city and
/// the collection instructions.
List<PickupStation> filterStations(List<PickupStation> stations, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return stations;
  return stations.where((station) {
    final haystack = [
      station.name,
      stationAreaLabel(station),
      station.city ?? '',
      station.instructions ?? '',
      station.ownerName ?? '',
    ].join(' ').toLowerCase();
    return haystack.contains(needle);
  }).toList();
}