import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class LocationCard extends StatelessWidget {
  final double? lat;
  final double? lng;
  final String? label;

  const LocationCard({super.key, this.lat, this.lng, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: BuddyColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, color: BuddyColors.green, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label ?? 'Location',
              style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
