import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CacheEntry {
  final String jsonData;
  final DateTime cachedAt;

  CacheEntry({required this.jsonData, DateTime? cachedAt})
      : cachedAt = cachedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {'jsonData': jsonData, 'cachedAt': cachedAt.toIso8601String()};

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
        jsonData: json['jsonData'] as String,
        cachedAt: DateTime.parse(json['cachedAt'] as String),
      );
}

class CacheService {
  final String _baseDir;
  final Map<String, CacheEntry> _memory = {};

  CacheService(this._baseDir);

  static Future<CacheService> create() async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/buddy_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return CacheService(cacheDir.path);
  }

  String _filePath(String key) => '$_baseDir/${_sanitizeKey(key)}.json';

  String _sanitizeKey(String key) => key.replaceAll(RegExp(r'[^\w_]'), '_');

  Future<void> set(String key, dynamic data, {Duration? ttl}) async {
    final entry = CacheEntry(jsonData: jsonEncode(data));
    _memory[key] = entry;
    final file = File(_filePath(key));
    await file.writeAsString(jsonEncode(entry.toJson()));
  }

  Future<T?> get<T>(String key, {T Function(dynamic)? fromJson}) async {
    final mem = _memory[key];
    if (mem != null) {
      final decoded = jsonDecode(mem.jsonData);
      if (fromJson != null) return fromJson(decoded);
      return decoded as T;
    }
    try {
      final file = File(_filePath(key));
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final entry = CacheEntry.fromJson(jsonDecode(content) as Map<String, dynamic>);
      _memory[key] = entry;
      final decoded = jsonDecode(entry.jsonData);
      if (fromJson != null) return fromJson(decoded);
      return decoded as T;
    } catch (_) {
      return null;
    }
  }

  bool isExpired(String key, {Duration ttl = const Duration(minutes: 5)}) {
    final entry = _memory[key];
    if (entry == null) return true;
    return DateTime.now().difference(entry.cachedAt) > ttl;
  }

  Future<void> invalidate(String key) async {
    _memory.remove(key);
    final file = File(_filePath(key));
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> clear() async {
    _memory.clear();
    final dir = Directory(_baseDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create();
    }
  }
}
