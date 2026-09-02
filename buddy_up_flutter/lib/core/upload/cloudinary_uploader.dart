import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:video_compress/video_compress.dart';

/// Result of POST /api/v1/uploads/sign/ — everything needed to push the file
/// straight to Cloudinary from the client.
class CloudinarySignResult {
  final String cloudName;
  final String apiKey;
  final String timestamp;
  final String signature;
  final String folder;
  final String resourceType;
  final String? eager;
  final String uploadUrl;

  const CloudinarySignResult({
    required this.cloudName,
    required this.apiKey,
    required this.timestamp,
    required this.signature,
    required this.folder,
    required this.resourceType,
    this.eager,
    required this.uploadUrl,
  });

  static CloudinarySignResult? fromData(dynamic data) {
    if (data is! Map) return null;
    final map = data.cast<String, dynamic>();
    final uploadUrl = map['upload_url'] as String?;
    if ((map['api_key'] ?? '').toString().isEmpty ||
        (map['signature'] ?? '').toString().isEmpty) {
      return null;
    }
    return CloudinarySignResult(
      cloudName: '${map['cloud_name'] ?? ''}',
      apiKey: '${map['api_key']}',
      timestamp: '${map['timestamp'] ?? ''}',
      signature: '${map['signature']}',
      folder: '${map['folder'] ?? ''}',
      resourceType: '${map['resource_type'] ?? 'image'}',
      eager: map['eager']?.toString(),
      uploadUrl: uploadUrl ?? '',
    );
  }
}

/// Direct-upload result matching the media JSON contract.
class CloudinaryUploadResult {
  final String url;
  final String? posterUrl;
  final int? width;
  final int? height;
  final int? durationMs;

  const CloudinaryUploadResult({
    required this.url,
    this.posterUrl,
    this.width,
    this.height,
    this.durationMs,
  });
}

/// Signs via the backend and uploads files directly to Cloudinary so large
/// videos never transit the API. Falls back silently (`sign` returns null /
/// throws) so callers can use the legacy multipart path.
class CloudinaryUploader {
  /// Authenticated API client (baseUrl carries /api/v1) used for signing.
  final Dio _api;

  /// Plain client for the Cloudinary upload endpoint (no auth header,
  /// long timeouts — video uploads can take a while).
  final Dio _uploadDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(minutes: 10),
      receiveTimeout: const Duration(minutes: 10),
    ),
  );

  CloudinaryUploader(this._api);

  /// Returns null when the backend cannot sign (503 / unavailable / offline).
  Future<CloudinarySignResult?> sign({
    required String resourceType,
    required String filename,
  }) async {
    try {
      final res = await _api.post<dynamic>(
        '/uploads/sign/',
        data: {'resource_type': resourceType, 'filename': filename},
      );
      final body = res.data;
      return CloudinarySignResult.fromData(
        body is Map ? body['data'] : null,
      );
    } on DioException catch (e) {
      debugPrint('cloudinary sign unavailable '
          '(${e.response?.statusCode}) — falling back to multipart');
      return null;
    } catch (e) {
      debugPrint('cloudinary sign failed: $e');
      return null;
    }
  }

  /// Multipart POST to the signed upload_url with progress reporting.
  Future<CloudinaryUploadResult> upload({
    required File file,
    required CloudinarySignResult sign,
    void Function(int sent, int total)? onProgress,
  }) async {
    final form = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
      'api_key': sign.apiKey,
      'timestamp': sign.timestamp,
      'signature': sign.signature,
      'folder': sign.folder,
      if (sign.eager != null && sign.eager!.isNotEmpty) 'eager': sign.eager,
    });

    final res = await _uploadDio.post<dynamic>(
      sign.uploadUrl,
      data: form,
      onSendProgress: onProgress,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = res.data;
    if (data is! Map) {
      throw const FormatException('Unexpected Cloudinary response');
    }
    final eager = data['eager'];
    String? posterUrl;
    if (eager is List && eager.isNotEmpty && eager.first is Map) {
      posterUrl = eager.first['secure_url'] as String?;
    }
    final duration = (data['duration'] as num?)?.toDouble();
    return CloudinaryUploadResult(
      url: data['secure_url'] as String,
      posterUrl: posterUrl,
      width: (data['width'] as num?)?.toInt(),
      height: (data['height'] as num?)?.toInt(),
      durationMs:
          duration == null ? null : (duration * 1000).round(),
    );
  }

  /// Pre-upload video compression: anything over 30 MB or longer than 1080p
  /// on its longest side is transcoded to a 1080p preset. Mobile only —
  /// other platforms upload the original. Returns the (possibly replaced)
  /// file plus reported dimensions when known.
  Future<({File file, int? width, int? height})> prepareVideo(
    File file, {
    int? width,
    int? height,
  }) async {
    if (kIsWeb || !Platform.isAndroid && !Platform.isIOS) {
      return (file: file, width: width, height: height);
    }
    try {
      final length = await file.length();
      final longestSide = (width ?? 0) > (height ?? 0) ? width ?? 0 : height ?? 0;
      final needsCompress =
          length > _maxBytes || (longestSide > 0 && longestSide > 1080);
      if (!needsCompress) {
        return (file: file, width: width, height: height);
      }
      final info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.Res1920x1080Quality,
        includeAudio: true,
        deleteOrigin: false,
      );
      final path = info?.path;
      if (path == null || path.isEmpty) {
        return (file: file, width: width, height: height);
      }
      return (
        file: File(path),
        width: info?.width,
        height: info?.height,
      );
    } catch (e) {
      debugPrint('video compress skipped: $e');
      return (file: file, width: width, height: height);
    }
  }

  static const int _maxBytes = 30 * 1024 * 1024;
}
