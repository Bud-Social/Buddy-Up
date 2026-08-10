import 'package:intl/intl.dart';

String formatDuration(int seconds) {
  if (seconds <= 0) return '0m';
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h > 0) return '${h}h ${m}m';
  return '${m}m';
}

String formatPace(double? secondsPerKm) {
  if (secondsPerKm == null || secondsPerKm <= 0) return '—';
  final m = secondsPerKm ~/ 60;
  final s = (secondsPerKm % 60).round();
  return '$m:${s.toString().padLeft(2, '0')} /km';
}

String formatNumber(double? value, {int decimals = 0}) {
  if (value == null) return '0';
  return value.toStringAsFixed(decimals);
}

String formatDate(String? iso, {bool includeTime = false}) {
  if (iso == null || iso.isEmpty) return '—';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  if (includeTime) {
    return DateFormat('MMM d, y • HH:mm').format(dt.toLocal());
  }
  return DateFormat('MMM d, y').format(dt.toLocal());
}

String titleCase(String value) {
  if (value.isEmpty) return value;
  return value
      .split('_')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
