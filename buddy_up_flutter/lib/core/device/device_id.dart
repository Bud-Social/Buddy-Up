import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Device-scoped identifier sent as `X-Device-Id` on every API call so the
/// backend can attribute sessions (login, device session list) to a device.
///
/// A UUIDv4 is generated once and persisted in SharedPreferences.
class DeviceId {
  static const _key = 'device_id';
  static String? _cached;

  static Future<String> get() async {
    if (_cached != null) return _cached!;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_key);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(_key, id);
    }
    _cached = id;
    return id;
  }
}
