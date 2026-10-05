/// Shared distance formatting for every "near me" surface (buddies, gyms,
/// marketplace events).
///
/// The list APIs only ever hand back a banded `distance_km` computed from
/// coordinates the *viewer* supplied, so sub-kilometre readings are noise
/// dressed up as precision — a "640 m" badge invites someone to walk to the
/// wrong corner. Under 1 km therefore collapses to a single `<1 km` band;
/// everything at or above 1 km keeps the existing bands (one decimal up to
/// 10 km, whole kilometres beyond) so the familiar numbers do not move.
///
/// Null (the API could not band the distance), NaN and negatives return null
/// so callers can simply skip the badge.
String? formatDistanceBadge(double? km) {
  if (km == null || !km.isFinite || km < 0) return null;
  if (km < 1) return '<1 km';
  if (km < 10) return '${km.toStringAsFixed(1)} km';
  return '${km.round()} km';
}