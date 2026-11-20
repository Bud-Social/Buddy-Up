import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Metadata for a newer release published on GitHub.
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.version,
    required this.tag,
    required this.url,
    required this.fileName,
    this.size,
    this.notes = '',
  });

  final String version;
  final String tag;
  final String url;
  final String fileName;
  final int? size;
  final String notes;
}

/// Checks the GitHub Releases feed for a newer Android build, downloads the
/// APK, and hands it to the system installer.
///
/// The APK is sideloaded from GitHub Releases (no Play Store), so updates are
/// discovered from the same place they are downloaded. Checks are throttled
/// to avoid burning the unauthenticated GitHub API rate limit.
class AppUpdateService {
  AppUpdateService({Dio? dio, SharedPreferences? prefs})
      : _dio = dio ?? Dio(),
        _prefs = prefs;

  static const String releasesUrl =
      'https://api.github.com/repos/Bud-Social/Buddy-Up/releases/latest';
  static const String _lastCheckKey = 'app_update_last_check_ms';
  static const Duration _checkInterval = Duration(hours: 6);

  final Dio _dio;
  final SharedPreferences? _prefs;

  /// Compares two dot-separated versions, ignoring `v`, pre-release and
  /// build-number suffixes. Returns 1 when [a] is newer, -1 when [b] is
  /// newer, 0 when equal.
  static int compareVersions(String a, String b) {
    List<int> parts(String v) {
      final clean = v.trim().replaceFirst(RegExp(r'^[vV]'), '').split('+').first.split('-').first;
      return clean
          .split('.')
          .map((p) => int.tryParse(p.trim()) ?? 0)
          .toList(growable: false);
    }

    final x = parts(a);
    final y = parts(b);
    final length = x.length > y.length ? x.length : y.length;
    for (var i = 0; i < length; i++) {
      final xv = i < x.length ? x[i] : 0;
      final yv = i < y.length ? y[i] : 0;
      if (xv != yv) return xv > yv ? 1 : -1;
    }
    return 0;
  }

  /// Returns an update when the latest published release is newer than the
  /// installed version, otherwise null. Network failures are thrown so the
  /// caller can fail silently (updates are best-effort).
  Future<AppUpdateInfo?> check({bool force = false}) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = prefs.getInt(_lastCheckKey) ?? 0;
    if (!force && now - last < _checkInterval.inMilliseconds) return null;
    await prefs.setInt(_lastCheckKey, now);

    final response = await _dio.get<Map<String, dynamic>>(
      releasesUrl,
      options: Options(
        headers: const {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'BuddyUp-Fit-App',
        },
      ),
    );
    final data = response.data;
    if (data == null) return null;

    final tag = (data['tag_name'] as String?)?.trim() ?? '';
    final remoteVersion = tag.replaceFirst(RegExp(r'^[vV]'), '');
    if (remoteVersion.isEmpty) return null;

    final package = await PackageInfo.fromPlatform();
    if (compareVersions(remoteVersion, package.version) <= 0) return null;

    final assets = (data['assets'] as List<dynamic>?) ?? const [];
    final apks = assets
        .whereType<Map<String, dynamic>>()
        .where((a) => (a['name'] as String? ?? '').toLowerCase().endsWith('.apk'))
        .toList();
    if (apks.isEmpty) return null;

    // arm64-v8a is the APK linked from the landing page and the one shipped to
    // modern Android devices; fall back to the first available APK.
    final asset = apks.firstWhere(
      (a) => (a['name'] as String?)?.toLowerCase().contains('arm64-v8a') == true,
      orElse: () => apks.first,
    );
    final url = asset['browser_download_url'] as String?;
    final name = asset['name'] as String?;
    if (url == null || url.isEmpty || name == null || name.isEmpty) return null;

    return AppUpdateInfo(
      version: remoteVersion,
      tag: tag,
      url: url,
      fileName: name,
      size: asset['size'] as int?,
      notes: (data['body'] as String?)?.trim() ?? '',
    );
  }

  /// Downloads the update into the app's private documents directory so no
  /// storage permission is needed, then returns the local path.
  Future<String> download(
    AppUpdateInfo update, {
    void Function(int received, int total)? onProgress,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final updates = Directory('${directory.path}/updates');
    if (!updates.existsSync()) await updates.create(recursive: true);
    final path = '${updates.path}/${update.fileName}';
    final file = File(path);

    // A previous complete download can be reused.
    if (await file.exists() && (update.size == null || await file.length() == update.size)) {
      return path;
    }

    await _dio.download(
      update.url,
      path,
      onReceiveProgress: onProgress,
      options: Options(
        headers: const {'User-Agent': 'BuddyUp-Fit-App'},
        responseType: ResponseType.bytes,
      ),
    );
    return path;
  }

  /// Opens the downloaded APK with the system package installer. `open_file`
  /// supplies a FileProvider URI so this works on modern Android.
  Future<OpenResult> install(String path) => OpenFile.open(path);
}
