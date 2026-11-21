import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';

/// Keyless OSM route renderer, mirroring the web `OsmRouteMap` fallback in
/// `components/analytics/RouteMap.tsx`. The backend stores routes as
/// `[[lat, lng], ...]`.
class ActivityRouteMap extends StatelessWidget {
  final List<dynamic> route;
  final double height;

  const ActivityRouteMap({super.key, required this.route, this.height = 140});

  @override
  Widget build(BuildContext context) {
    final points = <LatLng>[];
    for (final raw in route) {
      if (raw is! List || raw.length < 2) continue;
      final lat = (raw[0] as num?)?.toDouble();
      final lng = (raw[1] as num?)?.toDouble();
      if (lat != null && lng != null) points.add(LatLng(lat, lng));
    }
    if (points.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: points.first,
            initialZoom: 14,
            // Small history preview: keep it non-interactive like the web SVG.
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.buddyup.buddy_up_flutter',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: points,
                  color: BuddyColors.green,
                  strokeWidth: 3,
                ),
              ],
            ),
            if (points.length == 1)
              MarkerLayer(
                markers: [
                  Marker(
                    point: points.first,
                    width: 20,
                    height: 20,
                    child: const Icon(Icons.place, color: BuddyColors.green),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
