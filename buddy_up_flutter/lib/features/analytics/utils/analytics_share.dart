import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// One share path for workout and activity rows.
///
/// Prefers the native share sheet and falls back to copying the link, so a
/// failed share degrades instead of breaking the row it was tapped from.
enum ShareOutcome { shared, copied, cancelled, failed }

/// Deep link into the analytics tab — `/app/analytics` redirects to it on web.
const String analyticsSharePath = '/app/analytics';

const String buddyUpWebOrigin = 'https://buddyup.app';

String analyticsShareUrl({String origin = buddyUpWebOrigin}) =>
    '$origin$analyticsSharePath';

/// Facts a shared row can state about itself.
class ShareFacts {
  final String label;
  final String? category;
  final int? durationMinutes;
  final double? distanceKm;
  final double? calories;
  final String? detail;

  const ShareFacts({
    required this.label,
    this.category,
    this.durationMinutes,
    this.distanceKm,
    this.calories,
    this.detail,
  });
}

String _round(double value) =>
    value >= 10 ? value.round().toString() : value.toStringAsFixed(1);

/// "Strength · Upper — 45 min · 5 km · 320 kcal. Logged on BuddyUp."
String buildShareText(ShareFacts facts) {
  final head = [
    facts.label,
    if (facts.category != null && facts.category!.isNotEmpty) facts.category!,
  ].join(' · ');
  final bits = <String>[
    if (facts.durationMinutes != null && facts.durationMinutes! > 0)
      '${facts.durationMinutes!.round()} min',
    if (facts.distanceKm != null && facts.distanceKm! > 0)
      '${_round(facts.distanceKm!)} km',
    if (facts.calories != null && facts.calories! > 0)
      '${facts.calories!.round()} kcal',
    if (facts.detail != null && facts.detail!.isNotEmpty) facts.detail!,
  ];
  final body = bits.isEmpty ? '' : ' — ${bits.join(' · ')}';
  return '$head$body. Logged on BuddyUp.';
}

/// Screen rect of the button that triggered the share — iOS needs an anchor to
/// present the sheet from, and it crashes without one on iPad.
Rect? shareOriginFor(BuildContext context) {
  final box = context.findRenderObject();
  if (box is RenderBox && box.hasSize) {
    return box.localToGlobal(Offset.zero) & box.size;
  }
  return null;
}

Future<ShareOutcome> shareAnalyticsItem({
  required BuildContext context,
  required String title,
  required String text,
  String url = buddyUpWebOrigin + analyticsSharePath,
  Rect? sharePositionOrigin,
}) async {
  try {
    await SharePlus.instance.share(
      ShareParams(
        subject: title,
        text: '$text\n$url',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
    return ShareOutcome.shared;
  } catch (_) {
    // No share sheet on this platform, or it refused the payload.
    try {
      await Clipboard.setData(ClipboardData(text: '$text\n$url'));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sharing unavailable — copied instead.')),
        );
      }
      return ShareOutcome.copied;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not share this.')),
        );
      }
      return ShareOutcome.failed;
    }
  }
}