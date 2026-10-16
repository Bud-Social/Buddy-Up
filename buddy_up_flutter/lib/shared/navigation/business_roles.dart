/// Role signals for the "Your business" navigation group, mirroring
/// `frontend/src/hooks/useBusinessRoles.ts` and
/// `frontend/src/components/layout/sidebarBusiness.ts`.
///
/// Two deliberate design rules, both carried over from the web:
///
///  1. **Every signal is independently optional and defaults to `false`.** A
///     probe that fails, or an endpoint that does not exist on this deployment
///     yet, resolves false rather than throwing. A backend that is mid-rollout
///     can therefore only ever *hide* a nav entry — never show one the user does
///     not hold, and never break navigation.
///  2. **The entry list is derived from the flags in one place.** The settings
///     group and the role switcher are both built from [businessEntries], so a
///     destination can never be reachable from one and missing from the other.
///
/// Kept free of Flutter and Riverpod imports (the file the web calls
/// `sidebarBusiness.ts` is likewise React-free) so the derivation is testable on
/// its own and the provider that feeds it stays a thin IO layer.
library;

enum BusinessRoleKey { shop, events, gym, stations, courier }

/// The five signals derived from real ownership data.
class BusinessRoleFlags {
  /// Owns a shop, or has ever sold a marketplace listing.
  final bool hasShop;

  /// Has created or hosts at least one event.
  final bool hasEvents;

  /// Handle of the first gym where the user is owner or co-owner.
  final String? gymSlug;

  /// Name of that gym, for the switcher label.
  final String? gymName;

  /// Owns at least one pickup station.
  final bool hasStation;

  /// Has a `DeliveryPersonnel` row.
  final bool isCourier;

  /// True until every probe has settled. The nav renders nothing meanwhile.
  final bool loading;

  const BusinessRoleFlags({
    this.hasShop = false,
    this.hasEvents = false,
    this.gymSlug,
    this.gymName,
    this.hasStation = false,
    this.isCourier = false,
    this.loading = false,
  });

  static const BusinessRoleFlags empty = BusinessRoleFlags(loading: true);

  /// True while nothing has been decided yet — the nav shows no business group.
  bool get isEmpty =>
      !hasShop && !hasEvents && gymSlug == null && !hasStation && !isCourier;

  /// Sentinel for "argument not passed".
  ///
  /// `gymSlug` and `gymName` are nullable, so a plain `x ?? this.x` would make it
  /// impossible to *clear* them — `copyWith(gymSlug: null)` would silently keep
  /// the old gym. A caller that drops a gym from the switcher must be able to say
  /// so, so the nullable fields are widened to `Object?` and compared by
  /// identity.
  static const Object _unset = Object();

  BusinessRoleFlags copyWith({
    bool? hasShop,
    bool? hasEvents,
    Object? gymSlug = _unset,
    Object? gymName = _unset,
    bool? hasStation,
    bool? isCourier,
    bool? loading,
  }) {
    return BusinessRoleFlags(
      hasShop: hasShop ?? this.hasShop,
      hasEvents: hasEvents ?? this.hasEvents,
      gymSlug: identical(gymSlug, _unset) ? this.gymSlug : gymSlug as String?,
      gymName: identical(gymName, _unset) ? this.gymName : gymName as String?,
      hasStation: hasStation ?? this.hasStation,
      isCourier: isCourier ?? this.isCourier,
      loading: loading ?? this.loading,
    );
  }

  @override
  String toString() =>
      'BusinessRoleFlags(shop: $hasShop, events: $hasEvents, gym: $gymSlug, '
      'stations: $hasStation, courier: $isCourier, loading: $loading)';
}

/// One destination the operator holds, and how the nav labels it.
class BusinessEntry {
  final BusinessRoleKey key;
  final String route;
  final String label;

  /// Compact label for the role switcher.
  final String shortLabel;

  final String subtitle;

  const BusinessEntry({
    required this.key,
    required this.route,
    required this.label,
    required this.shortLabel,
    required this.subtitle,
  });
}

/// Destinations the operator qualifies for, in working-priority order.
List<BusinessEntry> businessEntries(BusinessRoleFlags flags) {
  final entries = <BusinessEntry>[];
  if (flags.hasShop) {
    entries.add(const BusinessEntry(
      key: BusinessRoleKey.shop,
      route: '/marketplace/creator-studio',
      label: 'Shop',
      shortLabel: 'Shop',
      subtitle: 'Listings, orders and payouts',
    ));
  }
  if (flags.hasEvents) {
    entries.add(const BusinessEntry(
      key: BusinessRoleKey.events,
      route: '/marketplace/events',
      label: 'My Events',
      shortLabel: 'Events',
      subtitle: 'Check in attendees and track attendance',
    ));
  }
  final slug = flags.gymSlug;
  if (slug != null && slug.isNotEmpty) {
    entries.add(BusinessEntry(
      key: BusinessRoleKey.gym,
      route: '/gyms/$slug/manage',
      label: 'My Gym',
      shortLabel: 'Gym',
      subtitle: flags.gymName?.isNotEmpty == true
          ? flags.gymName!
          : 'Members, requests, schedule and reviews',
    ));
  }
  if (flags.hasStation) {
    entries.add(const BusinessEntry(
      key: BusinessRoleKey.stations,
      route: '/marketplace/stations',
      label: 'My Stations',
      shortLabel: 'Stations',
      subtitle: 'Collection points you run',
    ));
  }
  if (flags.isCourier) {
    entries.add(const BusinessEntry(
      key: BusinessRoleKey.courier,
      route: '/marketplace/delivery',
      label: 'Courier',
      shortLabel: 'Courier',
      subtitle: 'Your deliveries',
    ));
  }
  return entries;
}
