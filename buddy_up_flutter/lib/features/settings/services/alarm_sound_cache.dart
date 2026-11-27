import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/alarm.dart';

/// Keeps accepted/custom alarm sounds on-device so they continue to work
/// without a network connection.
class AlarmSoundCache {
  static const _prefix = 'alarm_sound_file_';

  static Future<String?> cache(AlarmSound sound) async {
    if (sound.audioUrl.isEmpty) return null;
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/alarm_${sound.id}.audio');
    try {
      if (!await file.exists()) {
        final response = await Dio().get<List<int>>(
          sound.audioUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        final bytes = response.data;
        if (bytes == null || bytes.isEmpty) return null;
        await file.writeAsBytes(bytes, flush: true);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix${sound.id}', file.path);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> pathFor(String soundId) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('$_prefix$soundId');
    if (path == null || !await File(path).exists()) return null;
    return path;
  }
}
