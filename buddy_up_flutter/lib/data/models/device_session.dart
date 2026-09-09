/// A logged-in device session as returned by GET /auth/sessions/.
/// Manual fromJson — no codegen needed for this minimal model.
class DeviceSession {
  final int id;
  final String deviceName;
  final String ipAddress;
  final String location;
  final String lastActive;
  final String createdAt;
  final bool isCurrent;

  const DeviceSession({
    required this.id,
    required this.deviceName,
    required this.ipAddress,
    required this.location,
    required this.lastActive,
    required this.createdAt,
    required this.isCurrent,
  });

  factory DeviceSession.fromJson(Map<String, dynamic> json) {
    return DeviceSession(
      id: (json['id'] as num?)?.toInt() ?? 0,
      deviceName: json['device_name']?.toString() ?? 'Unknown device',
      ipAddress: json['ip_address']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      lastActive: json['last_active']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      isCurrent: json['is_current'] == true,
    );
  }
}
