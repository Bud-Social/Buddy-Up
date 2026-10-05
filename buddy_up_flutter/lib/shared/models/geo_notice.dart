/// Adaptive nearby radius metadata returned by list endpoints
/// (`geo` block): 5 km in dense areas, 10 km where places are sparse.
class GeoNotice {
  final double radiusKm;
  final bool auto;
  final String? density;
  final String? message;

  const GeoNotice({
    required this.radiusKm,
    required this.auto,
    this.density,
    this.message,
  });

  factory GeoNotice.fromJson(Map<String, dynamic> json) => GeoNotice(
        radiusKm: (json['radius_km'] as num?)?.toDouble() ?? 10,
        auto: json['auto'] as bool? ?? false,
        density: json['density'] as String?,
        message: json['message'] as String?,
      );
}
