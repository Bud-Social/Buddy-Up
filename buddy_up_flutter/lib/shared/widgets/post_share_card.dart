import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/post.dart';

/// Web `lib/shareCard.ts` parity: a 1080x1350 branded PNG with the post media,
/// author, body and a BuddyUp Fit watermark, shareable as a file.
class PostShareCardRenderer {
  static const double width = 1080;
  static const double height = 1350;

  Future<File> render(Post post, {String? permalink}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Backdrop
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, width, height),
      Paint()..color = const Color(0xFF0B0F0D),
    );

    // Header
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, width, 96),
      Paint()..color = BuddyColors.green,
    );
    _drawText(
      canvas,
      'BuddyUp Fit',
      const Offset(48, 22),
      fontSize: 44,
      color: Colors.black,
      bold: true,
      maxWidth: 900,
    );
    _drawText(
      canvas,
      'Find Your Fitness Family',
      const Offset(48, 66),
      fontSize: 17,
      color: Colors.black.withValues(alpha: 0.72),
      maxWidth: 900,
    );

    // Author row
    final author = post.authorData;
    canvas.drawCircle(
      const Offset(96, 176),
      40,
      Paint()..color = BuddyColors.surfaceRaised,
    );
    _drawText(
      canvas,
      author.displayName.isEmpty ? 'B' : author.displayName[0].toUpperCase(),
      const Offset(96, 176),
      fontSize: 40,
      color: BuddyColors.green,
      bold: true,
      maxWidth: 80,
      centered: true,
    );
    _drawText(
      canvas,
      author.displayName,
      const Offset(152, 134),
      fontSize: 36,
      color: Colors.white,
      bold: true,
      maxWidth: 860,
    );
    _drawText(
      canvas,
      '@${author.username}',
      const Offset(152, 184),
      fontSize: 27,
      color: const Color(0xFF9BA69F),
      maxWidth: 860,
    );

    // Media block
    const mediaRect = Rect.fromLTWH(56, 250, 968, 620);
    final image = await _loadLeadMedia(post);
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(mediaRect, const Radius.circular(36)),
    );
    if (image != null) {
      _drawCover(canvas, image, mediaRect);
    } else {
      canvas.drawRect(mediaRect, Paint()..color = BuddyColors.surface);
      _drawText(
        canvas,
        '💪',
        Offset(width / 2, mediaRect.center.dy),
        fontSize: 140,
        color: Colors.white,
        maxWidth: 400,
        centered: true,
      );
    }
    canvas.restore();

    // Workout metrics and route preview
    final workout = post.workoutLogData;
    if (workout != null) {
      _drawWorkoutMetrics(canvas, workout);
      _drawRoute(canvas, workout['route']);
    }

    // Body
    if (post.body.trim().isNotEmpty && post.workoutLogData == null) {
      _drawText(
        canvas,
        post.body.trim(),
        const Offset(56, 910),
        fontSize: 34,
        color: const Color(0xFFF4F7F5),
        maxWidth: 968,
        maxLines: 6,
        lineHeight: 1.35,
      );
    }

    // Footer watermark
    canvas.drawLine(
      const Offset(56, 1246),
      const Offset(width - 56, 1246),
      Paint()
        ..color = const Color(0xFF1E262E)
        ..strokeWidth = 2,
    );
    _drawText(
      canvas,
      'BuddyUp Fit Post  •  www.buddyupfit.com',
      const Offset(56, 1272),
      fontSize: 26,
      color: const Color(0xFF9BA69F),
      maxWidth: 968,
    );
    if (permalink != null && permalink.isNotEmpty) {
      _drawText(
        canvas,
        permalink,
        const Offset(56, 1310),
        fontSize: 19,
        color: const Color(0xFF6B756F),
        maxWidth: 968,
      );
    }

    final picture = recorder.endRecording();
    final uiImage = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/buddyup_card_${post.id}.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  void _drawWorkoutMetrics(Canvas canvas, Map<String, dynamic> data) {
    final entries = <String, String>{
      'Duration': _metric(data, ['duration_minutes', 'duration_seconds']),
      'Distance': _metric(data, ['distance_km', 'distance_meters']),
      'Calories': _metric(data, ['calories_burned']),
      'Avg pace': _metric(data, ['avg_pace']),
      'Steps': _metric(data, ['steps']),
      'Sets × reps': '${data['sets'] ?? '-'} × ${data['reps'] ?? '-'}',
    };
    final keys = entries.keys.toList();
    for (var i = 0; i < keys.length; i++) {
      final x = 56 + (i % 3) * 322.0;
      final y = 885 + (i ~/ 3) * 62.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 300, 48),
          const Radius.circular(12),
        ),
        Paint()..color = BuddyColors.surface,
      );
      _drawText(
        canvas,
        keys[i],
        Offset(x + 14, y + 7),
        fontSize: 16,
        color: const Color(0xFF9BA69F),
        maxWidth: 270,
      );
      _drawText(
        canvas,
        entries[keys[i]]!,
        Offset(x + 14, y + 25),
        fontSize: 18,
        color: Colors.white,
        bold: true,
        maxWidth: 270,
      );
    }
  }

  String _metric(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      if (key == 'duration_seconds') {
        return '${((value as num) / 60).round()} min';
      }
      if (key == 'distance_meters') {
        return '${((value as num) / 1000).toStringAsFixed(1)} km';
      }
      if (key == 'calories_burned') return '${(value as num).round()} kcal';
      return value.toString();
    }
    return '-';
  }

  void _drawRoute(Canvas canvas, dynamic rawRoute) {
    if (rawRoute is! List || rawRoute.length < 2) return;
    final points = <Offset>[];
    for (final item in rawRoute) {
      if (item is! List || item.length < 2) continue;
      final lat = double.tryParse('${item[0]}');
      final lng = double.tryParse('${item[1]}');
      if (lat != null && lng != null) points.add(Offset(lng, lat));
    }
    if (points.length < 2) return;
    final minX = points.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
    final maxX = points.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
    final minY = points.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
    const rect = Rect.fromLTWH(56, 1015, 968, 190);
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x =
          rect.left +
          (maxX == minX ? 0.5 : (points[i].dx - minX) / (maxX - minX)) *
              rect.width;
      final y =
          rect.bottom -
          (maxY == minY ? 0.5 : (points[i].dy - minY) / (maxY - minY)) *
              rect.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(22)),
      Paint()..color = BuddyColors.surface,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = BuddyColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  Future<ui.Image?> _loadLeadMedia(Post post) async {
    String? url;
    for (final m in post.media) {
      if (m.url.isNotEmpty) {
        url = m.url;
        break;
      }
    }
    url ??= post.mediaUrls.where((u) => u.isNotEmpty).firstOrNull;
    if (url == null) return null;
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 25),
        ),
      );
      if (response.data == null) return null;
      return await _decode(Uint8List.fromList(response.data!));
    } catch (_) {
      return null;
    }
  }

  Future<ui.Image> _decode(Uint8List bytes) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, (image) => completer.complete(image));
    return completer.future;
  }

  void _drawCover(Canvas canvas, ui.Image image, Rect target) {
    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final sourceAspect = source.width / source.height;
    final targetAspect = target.width / target.height;
    Rect crop = source;
    if (sourceAspect > targetAspect) {
      final w = source.height * targetAspect;
      crop = Rect.fromLTWH((source.width - w) / 2, 0, w, source.height);
    } else {
      final h = source.width / targetAspect;
      crop = Rect.fromLTWH(0, (source.height - h) / 2, source.width, h);
    }
    canvas.drawImageRect(image, crop, target, Paint());
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset origin, {
    required double fontSize,
    required Color color,
    bool bold = false,
    bool centered = false,
    double maxWidth = 900,
    int maxLines = 1,
    double lineHeight = 1.1,
  }) {
    final style = ui.TextStyle(
      color: color,
      fontSize: fontSize,
      height: lineHeight,
      fontFamily: 'Inter',
      fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
    );
    final paragraphStyle = ui.ParagraphStyle(
      textAlign: centered ? TextAlign.center : TextAlign.left,
      maxLines: maxLines,
      ellipsis: '…',
    );
    final builder = ui.ParagraphBuilder(paragraphStyle)..pushStyle(style);
    builder.addText(text);
    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: maxWidth));
    final dx = centered ? origin.dx - maxWidth / 2 : origin.dx;
    canvas.drawParagraph(paragraph, Offset(dx, origin.dy));
  }
}
