import 'dart:typed_data';

import 'package:uuid/uuid.dart';

/// A locally-picked attachment ready to be uploaded with a post.
///
/// A layer in the Bud Press creation studio: photo, video, audio or styled
/// text. Every field maps 1:1 onto the backend ``media[]`` contract so the
/// studio can publish any mix in a single post.
class ComposerMedia {
  final String path;
  final String name;
  final String type; // image | video | audio | text | file | document
  final Uint8List? bytes;

  // Video studio results (trim + sound + captions), persisted into the media JSON.
  final int trimStartMs;
  final int trimEndMs;
  final int? durationMs;
  final String? soundId;
  final double? soundVolume;
  // Client-generated id for this clip instance — captions + cover offset are
  // saved per item id so they survive studio re-opens and draft restores.
  final String? studioItemId;
  // Cover frame offset in seconds (0 = start of clip).
  final double? coverOffsetSec;
  // Creative-studio edit metadata (captions style, text overlays, stickers…)
  // shipped to the backend as media[].edit_meta.
  final Map<String, dynamic>? editMeta;
  // For text media items: the styled body + its style.
  final String? textContent;
  final Map<String, dynamic>? textStyle;
  final List<Map<String, dynamic>> captions;

  const ComposerMedia({
    this.path = '',
    required this.name,
    required this.type,
    this.bytes,
    this.trimStartMs = 0,
    this.trimEndMs = 0,
    this.durationMs,
    this.soundId,
    this.soundVolume,
    this.studioItemId,
    this.coverOffsetSec,
    this.editMeta,
    this.textContent,
    this.textStyle,
    this.captions = const [],
  });

  ComposerMedia copyWith({
    String? path,
    String? name,
    String? type,
    Uint8List? bytes,
    int? trimStartMs,
    int? trimEndMs,
    int? durationMs,
    String? soundId,
    double? soundVolume,
    String? studioItemId,
    double? coverOffsetSec,
    Map<String, dynamic>? editMeta,
    String? textContent,
    Map<String, dynamic>? textStyle,
    List<Map<String, dynamic>>? captions,
  }) {
    return ComposerMedia(
      path: path ?? this.path,
      name: name ?? this.name,
      type: type ?? this.type,
      bytes: bytes ?? this.bytes,
      trimStartMs: trimStartMs ?? this.trimStartMs,
      trimEndMs: trimEndMs ?? this.trimEndMs,
      durationMs: durationMs ?? this.durationMs,
      soundId: soundId ?? this.soundId,
      soundVolume: soundVolume ?? this.soundVolume,
      studioItemId: studioItemId ?? this.studioItemId,
      coverOffsetSec: coverOffsetSec ?? this.coverOffsetSec,
      editMeta: editMeta ?? this.editMeta,
      textContent: textContent ?? this.textContent,
      textStyle: textStyle ?? this.textStyle,
      captions: captions ?? this.captions,
    );
  }
}
