import 'package:flutter/material.dart';

import '../../data/models/post.dart';

Color _parseColor(String? value, [Color fallback = Colors.white]) {
  if (value == null) return fallback;
  var h = value.replaceAll('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return fallback;
  return Color(int.tryParse(h, radix: 16) ?? 0xFFFFFFFF);
}

/// Resolve the bubble placement from a studio `captions_style` map.
String captionPlacement(Map<String, dynamic>? style) {
  final p = style?['placement'] as String?;
  if (p == 'top' || p == 'center') return p!;
  return 'bottom';
}

class CaptionOverlay extends StatelessWidget {
  final List<CaptionSegment> captions;
  final int positionMs;
  final Map<String, dynamic>? style;

  const CaptionOverlay({
    super.key,
    required this.captions,
    required this.positionMs,
    this.style,
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
    final style = this.style ?? {};
    final preset = style['preset'] as String? ?? 'classic';
    final sizeFactor = ((style['size'] as num?)?.toDouble() ?? 1.0).clamp(0.8, 1.6);
    final color = _parseColor(style['color'] as String?);
    final bg = style['bg'] as String? ?? 'none';
    final placement = style['placement'] as String? ?? 'bottom';

    final bubble = Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg == 'block'
            ? Colors.black.withValues(alpha: 0.45)
            : bg == 'pill'
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.black54,
        borderRadius: BorderRadius.circular(bg == 'pill' ? 999 : 10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 14 * sizeFactor,
          height: 1.35,
          fontWeight: preset == 'karaoke' ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );

    // Placement is handled by the parent stack position; center shifts up.
    if (placement == 'center') {
      return Transform.translate(offset: const Offset(0, -120), child: bubble);
    }
    return bubble;
  }
}
