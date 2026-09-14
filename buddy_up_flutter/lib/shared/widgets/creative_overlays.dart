import 'dart:math' as math;

import 'package:flutter/material.dart';

/// TikTok-style text color presets shared with the web studio.
Color? _hexColor(String? hex) {
  if (hex == null) return null;
  var h = hex.replaceAll('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return null;
  return Color(int.tryParse(h, radix: 16) ?? 0xFFFFFFFF);
}

Color _resolveColor(String? name) {
  const values = {
    'white': Color(0xFFFFFFFF),
    'yellow': Color(0xFFFFD400),
    'cyan': Color(0xFF38E1FF),
    'black': Color(0xFF111111),
    'pink': Color(0xFFFF3CA7),
    'green': Color(0xFF00FF9D),
  };
  final key = (name ?? '').toLowerCase();
  if (values.containsKey(key)) return values[key]!;
  return _hexColor(name) ?? Colors.white;
}

/// Display-face mapping for the web studio font catalog. System fonts only;
/// display faces approximate through weight, style and spacing.
TextStyle _fontFor(String? id) {
  switch (id) {
    case 'typewriter':
    case 'retro':
    case 'gamer':
      return const TextStyle(fontFamily: 'monospace');
    case 'handwrite':
    case 'script':
    case 'satisfy':
    case 'kaushan':
      return const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w600);
    case 'serif':
      return const TextStyle(fontFamily: 'serif');
    case 'lucky':
    case 'bangers':
    case 'anton':
    case 'bebas':
    case 'bungee':
    case 'racing':
    case 'neon':
    case 'spooky':
    case 'grotesk':
      return const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5);
    case 'marker':
      return const TextStyle(fontWeight: FontWeight.w700);
    case 'soft':
      return const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3);
    case 'classic':
    default:
      return const TextStyle(fontWeight: FontWeight.w600);
  }
}

double _overlayPx(num size) {
  final s = size.toDouble().clamp(0.0, 2.0);
  return 12 * math.pow(1.85, s).toDouble();
}

/// Renders timed text overlays + stickers from studio `edit_meta`,
/// mirroring the web CreativeLayer. Purely presentational.
class CreativeOverlays extends StatelessWidget {
  final Map<String, dynamic>? meta;
  final int positionMs;

  const CreativeOverlays({super.key, required this.meta, required this.positionMs});

  bool _visible(int start, int end) =>
      positionMs >= start - 60 && positionMs <= end + 60;

  @override
  Widget build(BuildContext context) {
    final meta = this.meta;
    if (meta == null) return const SizedBox.shrink();
    final children = <Widget>[];

    final stickers = meta['stickers'];
    if (stickers is List) {
      for (final raw in stickers) {
        if (raw is! Map) continue;
        final start = (raw['start_ms'] as num?)?.toInt() ?? 0;
        final end = (raw['end_ms'] as num?)?.toInt() ?? 0;
        if (!_visible(start, end)) continue;
        final kind = raw['kind'] as String? ?? 'emoji';
        final content = raw['content'] as String? ?? '';
        final x = ((raw['x'] as num?)?.toDouble() ?? 50).clamp(0.0, 100.0);
        final y = ((raw['y'] as num?)?.toDouble() ?? 50).clamp(0.0, 100.0);
        final scale = ((raw['scale'] as num?)?.toDouble() ?? 1).clamp(0.5, 2.0);
        final String text;
        if (kind == 'countdown') {
          final remaining = ((end - positionMs) / 1000).ceil().clamp(0, 999);
          text = '$remaining';
        } else if (kind == 'mention') {
          text = '@$content';
        } else {
          text = content;
        }
        children.add(Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Align(
            alignment: Alignment((x - 50) / 50, (y - 50) / 50),
            child: Text(text, style: TextStyle(fontSize: 26 * scale, height: 1.0)),
          ),
        ));
      }
    }

    final overlays = meta['text_overlays'];
    if (overlays is List) {
      for (final raw in overlays) {
        if (raw is! Map) continue;
        final start = (raw['start_ms'] as num?)?.toInt() ?? 0;
        final end = (raw['end_ms'] as num?)?.toInt() ?? 0;
        if (!_visible(start, end)) continue;
        final text = raw['text'] as String? ?? '';
        if (text.isEmpty) continue;
        final color = _resolveColor(raw['color'] as String?);
        final x = ((raw['x'] as num?)?.toDouble() ?? 50).clamp(0.0, 100.0);
        final y = ((raw['y'] as num?)?.toDouble() ?? 0).clamp(0.0, 100.0);
        final size = _overlayPx((raw['size'] as num?) ?? 1);
        final effect = raw['effect'] as String? ?? 'none';
        final bg = raw['bg'] as String? ?? 'none';
        final bgColor = _hexColor(raw['bg_color'] as String?) ??
            const Color(0x8C000000);
        children.add(Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Align(
            alignment: Alignment((x - 50) / 50, (y - 50) / 50),
            child: _StyledText(
              text: text,
              color: color,
              size: size,
              font: _fontFor(raw['font'] as String?),
              effect: effect,
              bg: bg,
              bgColor: bgColor,
            ),
          ),
        ));
      }
    }

    if (children.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(child: Stack(children: children));
  }
}

class _StyledText extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final TextStyle font;
  final String effect;
  final String bg;
  final Color bgColor;

  const _StyledText({
    required this.text,
    required this.color,
    required this.size,
    required this.font,
    required this.effect,
    required this.bg,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = color.computeLuminance() < 0.4;
    TextStyle base = font.copyWith(color: color, fontSize: size, height: 1.25);
    Widget child = Text(text, textAlign: TextAlign.center, style: base);

    switch (effect) {
      case 'outline':
        child = Stack(
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: base.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = Colors.black.withValues(alpha: 0.92),
              ),
            ),
            Text(text, textAlign: TextAlign.center, style: base),
          ],
        );
        break;
      case 'glow':
        child = Text(
          text,
          textAlign: TextAlign.center,
          style: base.copyWith(shadows: [
            Shadow(color: color, blurRadius: 6),
            Shadow(color: color, blurRadius: 14),
            Shadow(color: color, blurRadius: 28),
          ]),
        );
        break;
      case 'neon':
        child = Text(
          text,
          textAlign: TextAlign.center,
          style: base.copyWith(
            color: const Color(0xFF3FF3FF),
            shadows: const [
              Shadow(color: Color(0xFF2EE6FF), blurRadius: 4),
              Shadow(color: Color(0xFF1680D8), blurRadius: 10),
              Shadow(color: Color(0xFF7A05F0), blurRadius: 22),
              Shadow(color: Color(0xFFC017D9), blurRadius: 48),
            ],
          ),
        );
        break;
      case 'bubble':
        child = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withValues(alpha: 0.9), width: 3),
          ),
          child: Text(text, textAlign: TextAlign.center, style: base),
        );
        break;
      case 'highlight':
        child = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFFFFD400) : color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: base.copyWith(color: const Color(0xFF111111)),
          ),
        );
        break;
      case 'shadow':
        child = Text(
          text,
          textAlign: TextAlign.center,
          style: base.copyWith(shadows: const [
            Shadow(color: Color(0x8C000000), offset: Offset(0, 4), blurRadius: 0),
            Shadow(color: Color(0x73000000), offset: Offset(0, 8), blurRadius: 18),
          ]),
        );
        break;
      default:
        child = Text(
          text,
          textAlign: TextAlign.center,
          style: base.copyWith(shadows: const [
            Shadow(color: Color(0x8C000000), offset: Offset(0, 1), blurRadius: 4),
          ]),
        );
    }

    if (bg == 'pill' || bg == 'block') {
      child = Container(
        padding: bg == 'pill'
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 3)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(bg == 'pill' ? 999 : 8),
        ),
        child: child,
      );
    }
    return child;
  }
}
