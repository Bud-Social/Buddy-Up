/// The complete set of vehicles a courier may ride or drive, mirroring
/// `DELIVERY_VEHICLE_TYPES` in `backend/apps/marketplace/models.py`.
///
/// Both `DeliveryPersonnel` and `DeliveryPersonnelApplication` point at the
/// backend list, so these six values are a wire contract, not a UI preference:
/// sending anything else fails validation with a 400. Labels mirror the
/// backend's own `get_vehicle_type_display` strings so the picker and the
/// server never disagree about what "tuktuk" is.
const List<({String value, String label})> kDeliveryVehicleTypes = [
  (value: 'bike', label: 'Bicycle'),
  (value: 'motorbike', label: 'Motorbike'),
  (value: 'tuktuk', label: 'Tuk-tuk'),
  (value: 'car', label: 'Car'),
  (value: 'pickup', label: 'Pickup Truck'),
  (value: 'lorry', label: 'Lorry / Truck'),
];

List<String> get deliveryVehicleTypeValues =>
    kDeliveryVehicleTypes.map((e) => e.value).toList();

String deliveryVehicleLabel(String value) {
  for (final entry in kDeliveryVehicleTypes) {
    if (entry.value == value) return entry.label;
  }
  return value;
}

/// Service zones are free-text area names, so new neighbourhoods need no
/// migration. Split on commas, newlines and semicolons, trim, drop blanks and
/// de-duplicate — the serializer rejects a list that is not all strings.
List<String> parseServiceZones(String raw) {
  final seen = <String>{};
  return raw
      .split(RegExp(r'[,\n;]'))
      .map((z) => z.trim())
      .where((z) => z.isNotEmpty && seen.add(z.toLowerCase()))
      .toList();
}

String serviceZonesLabel(List<String> zones) =>
    zones.isEmpty ? 'No zones listed' : zones.join(' · ');