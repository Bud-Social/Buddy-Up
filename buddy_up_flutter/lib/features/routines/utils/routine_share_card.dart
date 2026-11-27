import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/routine.dart';

/// Offline-first routine card renderer. It deliberately uses Flutter's
/// canvas rather than a server image so sharing still works without a network.
class RoutineShareCardRenderer {
  static const double width = 1080;
  static const double height = 1350;

  Future<File> render(Routine routine) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, width, height),
      Paint()..color = const Color(0xFF0B0F0D),
    );
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, width, 18),
      Paint()..color = BuddyColors.green,
    );
    _text(canvas, 'BuddyUp Fit', const Offset(64, 70), 42, Colors.white, bold: true);
    _text(canvas, 'ROUTINE', const Offset(64, 150), 22, BuddyColors.green, bold: true);
    _text(
      canvas,
      routine.displayName.isNotEmpty ? routine.displayName : routine.name,
      const Offset(64, 220),
      66,
      Colors.white,
      bold: true,
      maxWidth: 940,
      maxLines: 2,
    );
    _text(
      canvas,
      '${routine.target} ${routine.unit} · ${routine.typeLabel}',
      const Offset(64, 390),
      30,
      const Color(0xFFB5C2BA),
      maxWidth: 940,
    );

    final stats = <({String label, String value, Color color})>[
      (label: 'STREAK', value: '${routine.streak} days', color: BuddyColors.green),
      (label: 'CHECK-INS', value: '${routine.checkinCount}', color: BuddyColors.gold),
      (label: 'STATUS', value: routine.completedToday ? 'Complete' : 'Ready', color: BuddyColors.electric),
    ];
    for (var i = 0; i < stats.length; i++) {
      final left = 64 + i * 320.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(left, 520, 288, 190), const Radius.circular(24)),
        Paint()..color = const Color(0xFF151C18),
      );
      _text(canvas, stats[i].label, Offset(left + 24, 548), 20, const Color(0xFF8D9B92), bold: true);
      _text(canvas, stats[i].value, Offset(left + 24, 594), 38, stats[i].color, bold: true, maxWidth: 240);
    }

    canvas.drawLine(
      const Offset(64, 1110),
      const Offset(width - 64, 1110),
      Paint()..color = const Color(0xFF26332C)..strokeWidth = 2,
    );
    _text(canvas, 'Build consistency. Move with your buddies.', const Offset(64, 1150), 30, Colors.white, maxWidth: 950);
    _text(canvas, 'buddyupfit.com', const Offset(64, 1250), 28, BuddyColors.green, bold: true);
    _text(canvas, 'BuddyUp Fit', const Offset(width - 260, 1250), 28, Colors.white, bold: true, maxWidth: 196, alignRight: true);

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/buddyup_routine_${routine.id}.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  void _text(Canvas canvas, String value, Offset offset, double size, Color color,
      {bool bold = false, double maxWidth = 900, int maxLines = 1, bool alignRight = false}) {
    final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
      maxLines: maxLines,
      ellipsis: '…',
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
    ))
      ..pushStyle(ui.TextStyle(
        color: color,
        fontSize: size,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
        fontFamily: 'Inter',
      ))
      ..addText(value);
    final paragraph = builder.build()..layout(ui.ParagraphConstraints(width: maxWidth));
    canvas.drawParagraph(paragraph, offset);
  }
}
