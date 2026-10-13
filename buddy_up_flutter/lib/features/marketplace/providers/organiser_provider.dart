import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/marketplace.dart';
import 'marketplace_provider.dart';

/// The events the caller organises, for the selector at the top of the screen.
///
/// A 403 propagates rather than resolving to an empty list: "you are not an
/// organiser" and "you have organised nothing" are different answers, and
/// collapsing them would tell every non-organiser they have an empty page.
final organisedEventsProvider =
    FutureProvider<List<OrganiserEvent>>((ref) async {
  final raw = await ref.read(marketplaceRepositoryProvider).getOrganisedEvents();
  final data = raw['data'];
  if (data is! List) return const [];
  return data
      .whereType<Map<String, dynamic>>()
      .map(OrganiserEvent.fromJson)
      .toList();
});

final eventStatsProvider =
    FutureProvider.family<EventStats?, String>((ref, eventId) async {
  if (eventId.isEmpty) return null;
  try {
    final raw =
        await ref.read(marketplaceRepositoryProvider).getEventStats(eventId);
    return EventStats.fromJson(raw['data'] as Map<String, dynamic>);
  } catch (_) {
    // Stats are a read-only panel: a missing endpoint or a transient failure
    // should leave the rest of the dashboard working.
    return null;
  }
});

/// The attendee filters, held as one value so they travel to the repository
/// together and the `family` key stays a single comparable object.
class AttendeeFilters {
  /// null = any. A false here is "not checked in", which is a real filter and
  /// must not be dropped the way a blank status is.
  final bool? checkedIn;
  final String status;
  final String tier;

  const AttendeeFilters({
    this.checkedIn,
    this.status = '',
    this.tier = '',
  });

  bool get isFiltered => checkedIn != null || status.isNotEmpty || tier.isNotEmpty;

  AttendeeFilters copyWith({
    bool? checkedIn,
    bool clearCheckedIn = false,
    String? status,
    String? tier,
  }) {
    // Trimmed here rather than only in the notifier: a stray space is a
    // silently-unmatched filter (`tier__iexact`), which reads as "this event
    // has no attendees in that tier" rather than as a bug.
    return AttendeeFilters(
      checkedIn: clearCheckedIn ? null : (checkedIn ?? this.checkedIn),
      status: (status ?? this.status).trim(),
      tier: (tier ?? this.tier).trim(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AttendeeFilters &&
      other.checkedIn == checkedIn &&
      other.status == status &&
      other.tier == tier;

  @override
  int get hashCode => Object.hash(checkedIn, status, tier);
}

final attendeeFiltersProvider =
    NotifierProvider<AttendeeFiltersNotifier, AttendeeFilters>(
        AttendeeFiltersNotifier.new);

class AttendeeFiltersNotifier extends Notifier<AttendeeFilters> {
  @override
  AttendeeFilters build() => const AttendeeFilters();

  void setCheckedIn(bool? value) {
    state = value == null
        ? state.copyWith(clearCheckedIn: true)
        : state.copyWith(checkedIn: value);
  }

  void setStatus(String value) => state = state.copyWith(status: value);

  void setTier(String value) => state = state.copyWith(tier: value);
}

final eventAttendeesProvider =
    FutureProvider.family<List<EventAttendee>, AttendeeQuery>(
        (ref, query) async {
  final raw = await ref.read(marketplaceRepositoryProvider).getEventAttendees(
        query.eventId,
        checkedIn: query.filters.checkedIn,
        // Blank filters are dropped rather than sent: the server *validates*
        // `status`, so an empty string is a 400 rather than "no filter".
        status: query.filters.status.isEmpty ? null : query.filters.status,
        tier: query.filters.tier.isEmpty ? null : query.filters.tier,
      );
  final data = raw['data'];
  if (data is! List) return const [];
  return data
      .whereType<Map<String, dynamic>>()
      .map(EventAttendee.fromJson)
      .toList();
});

/// Family key: one event plus its filters.
class AttendeeQuery {
  final String eventId;
  final AttendeeFilters filters;

  const AttendeeQuery(this.eventId, this.filters);

  @override
  bool operator ==(Object other) =>
      other is AttendeeQuery && other.eventId == eventId && other.filters == filters;

  @override
  int get hashCode => Object.hash(eventId, filters);
}

final selectedEventIdProvider = NotifierProvider<SelectedEventIdNotifier, String>(
    SelectedEventIdNotifier.new);

class SelectedEventIdNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String id) => state = id;
}

/// The door actions: check a ticket in, and reverse a mistaken scan.
///
/// The status codes carry the information an organiser actually needs and are
/// deliberately *not* flattened into one generic failure: 404 unknown code,
/// 409 already checked in (the message names when), 400 cancelled or refunded.
/// The caller shows the server's own sentence verbatim.
class EventCheckInActions {
  final Ref _ref;

  EventCheckInActions(this._ref);

  /// Returns the confirmation to show: the envelope's `message` when present,
  /// else the one inside `data`, else a composed default.
  Future<String> checkIn(String eventId, String ticketCode) async {
    final raw = await _ref
        .read(marketplaceRepositoryProvider)
        .checkInAttendee(eventId, {'ticket_code': ticketCode});
    return _confirmation(raw, 'Checked in $ticketCode.');
  }

  Future<String> checkOut(String eventId, String ticketCode) async {
    final raw = await _ref
        .read(marketplaceRepositoryProvider)
        .checkOutAttendee(eventId, {'ticket_code': ticketCode});
    return _confirmation(raw, 'Reversed check-in for $ticketCode.');
  }

  static String _confirmation(dynamic raw, String fallback) {
    final envelope = '${raw['message'] ?? ''}'.trim();
    if (envelope.isNotEmpty) return envelope;
    final data = raw['data'];
    if (data is Map) {
      final nested = '${data['message'] ?? ''}'.trim();
      if (nested.isNotEmpty) return nested;
    }
    return fallback;
  }
}

final eventCheckInActionsProvider =
    Provider<EventCheckInActions>(EventCheckInActions.new);