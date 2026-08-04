import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AiAnalysisCard extends StatelessWidget {
  final Map<String, dynamic>? analysis;

  const AiAnalysisCard({super.key, required this.analysis});

  bool get _isEmpty =>
      analysis == null || analysis!.isEmpty || (analysis!['text'] == null && (analysis!['images'] as List?)?.isEmpty != false);

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) return const SizedBox.shrink();

    final checks = _buildChecks();
    if (checks.isEmpty) return const SizedBox.shrink();

    final allPassed = checks.every((c) => c.passed);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: allPassed
              ? BuddyColors.green.withValues(alpha: 0.35)
              : BuddyColors.gold.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 18,
                color: allPassed ? BuddyColors.green : BuddyColors.gold,
              ),
              const SizedBox(width: 6),
              const Text(
                'AI Analysis',
                style: TextStyle(
                  color: BuddyColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _StatusBadge(passed: allPassed),
            ],
          ),
          const SizedBox(height: 8),
          for (final check in checks) _CheckTile(check: check),
        ],
      ),
    );
  }

  List<_CheckData> _buildChecks() {
    final result = <_CheckData>[];
    final textCheck = analysis!['text'];
    final imageChecks = analysis!['images'];

    if (textCheck is Map && textCheck.isNotEmpty) {
      final isToxic = textCheck['is_toxic'] == true;
      result.add(_CheckData(
        title: 'Content check',
        passed: !isToxic,
        detail: _percent(textCheck['toxicity_score']) +
            (textCheck['method'] != null ? ' · ${textCheck['method']}' : ''),
      ));
    }

    if (imageChecks is List && imageChecks.isNotEmpty) {
      final maps = imageChecks.whereType<Map>();
      final anyNsfw = maps.any((m) => m['is_nsfw'] == true);
      final method = maps.isNotEmpty ? maps.first['method'] : null;
      result.add(_CheckData(
        title: imageChecks.length == 1 ? 'Media check' : 'Media check (${imageChecks.length})',
        passed: !anyNsfw,
        detail: _labels(maps) + (method != null ? ' · $method' : ''),
      ));
    }

    return result;
  }

  String _percent(Object? value) {
    final v = value is num ? value.toDouble() : 0.0;
    return 'toxicity ${(v * 100).toStringAsFixed(1)}%';
  }

  String _labels(Iterable<Map> maps) {
    final labels = maps
        .expand((m) => (m['labels'] as List?) ?? const [])
        .whereType<String>()
        .toSet();
    if (labels.isEmpty) return 'clean';
    return labels.join(', ');
  }
}

class _CheckData {
  final String title;
  final bool passed;
  final String detail;

  const _CheckData({required this.title, required this.passed, required this.detail});
}

class _CheckTile extends StatelessWidget {
  final _CheckData check;

  const _CheckTile({required this.check});

  @override
  Widget build(BuildContext context) {
    final color = check.passed ? BuddyColors.green : BuddyColors.gold;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            check.passed ? Icons.check_circle_outline : Icons.error_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  check.title,
                  style: const TextStyle(
                    color: BuddyColors.textPrimary,
                    fontSize: 12.5,
                  ),
                ),
                if (check.detail.isNotEmpty)
                  Text(
                    check.detail,
                    style: const TextStyle(
                      color: BuddyColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            check.passed ? 'Passed' : 'Review',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool passed;

  const _StatusBadge({required this.passed});

  @override
  Widget build(BuildContext context) {
    final color = passed ? BuddyColors.green : BuddyColors.gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        passed ? 'Passed' : 'Flagged',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
