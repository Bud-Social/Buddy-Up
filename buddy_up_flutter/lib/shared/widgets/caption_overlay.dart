import 'package:flutter/material.dart';

import '../../data/models/post.dart';

/// Bottom pill rendering the caption segment active at [positionMs].
/// Renders nothing when no segment covers the current playback position.
class CaptionOverlay extends StatelessWidget {
  final List<CaptionSegment> captions;
  final int positionMs;

  const CaptionOverlay({
    super.key,
    required this.captions,
    required this.positionMs,
  });

  String? get _activeText {
    for (final segment in captions) {
      if (positionMs >= segment.startMs && positionMs < segment.endMs) {
        if (segment.text.trim().isNotEmpty) return segment.text;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final text = _activeText;
    if (text == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.35,
        ),
      ),
    );
  }
}
