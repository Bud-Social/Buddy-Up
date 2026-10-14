import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/platform_analytics.dart';
import '../providers/analytics_provider.dart';
import 'admin_widgets.dart';

/// Analytics-specific building blocks: the series table that stands in for a
/// chart, and the export action.
///
/// **On the missing chart library.** There is no plotting package in
/// `pubspec.yaml` and none was added. What replaces a line chart is a table
/// with a bar drawn in each row, because that is what this data is actually
/// for: the operator is checking a *window*, a *metric* and a *provenance* —
/// "did anything happen on the 3rd, and is that number real" — and a sparkline
/// answers none of those questions. The bar is a proportion of the series peak,
/// so it is comparable bucket-to-bucket and cannot mislead across two
/// different metrics (each table is scaled to its own peak and says so).
///
/// Zero-filled buckets are kept and marked rather than dropped. `read_rollup`
/// returns the complete label set precisely so a caller can tell "no rows" from
/// "a real zero", and hiding the zeros throws that away: a gap in the middle of
/// a series is the most interesting thing on the screen.

/// One bucket/value row with an inline bar.
///
/// The bar is `value / peak` of this series' maximum. It is a row-local
/// proportion, not an axis — [peakLabel] states the scale so the number is
/// always read alongside a value rather than inferred from a line.
class AnalyticsBucketRow extends StatelessWidget {
  final AnalyticsBucket bucket;
  final num? peak;
  final bool isPeak;
  final String unit;

  const AnalyticsBucketRow({
    super.key,
    required this.bucket,
    required this.peak,
    required this.isPeak,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ratio = (peak == null || peak == 0) ? 0.0 : bucket.value / peak!;
    final width = (ratio.clamp(0.0, 1.0) * 100).toDouble();
    final zero = bucket.isZero;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 96,
                child: Text(
                  bucket.bucket.isEmpty ? '—' : bucket.bucket,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isPeak ? FontWeight.w700 : FontWeight.w400,
                    color: isPeak ? BuddyColors.green : cs.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: cs.outline.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      // A zero bucket gets a 2px stub rather than nothing, so a
                      // zero-filled gap is visible as a row rather than as the
                      // absence of one.
                      widthFactor: zero ? 0.0 : width / 100,
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: isPeak
                              ? BuddyColors.green.withValues(alpha: 0.65)
                              : cs.primary.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 74,
                child: Text(
                  unit == 'usd'
                      ? '\$${bucket.value.toStringAsFixed(2)}'
                      : '${bucket.value}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: zero ? FontWeight.w400 : FontWeight.w600,
                    color: zero ? cs.onSurfaceVariant : cs.onSurface,
                  ),
                ),
              ),
              SizedBox(
                width: 22,
                child: isPeak && !zero
                    ? const Icon(Icons.trending_up,
                        size: 13, color: BuddyColors.green)
                    : null,
              ),
            ],
          ),
          if (zero)
            Padding(
              padding: const EdgeInsets.only(left: 96, top: 1),
              child: Text(
                'zero-filled bucket — no rows for this date',
                style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

/// The zero-filled series, rendered as a readable bucket/value table.
class AnalyticsSeriesTable extends StatelessWidget {
  final AnalyticsTimeseries series;

  const AnalyticsSeriesTable({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final buckets = series.buckets;
    final peak = series.peak;
    final peakBucket = buckets.isEmpty || peak == null
        ? null
        : buckets.reduce(
            (best, b) => b.value > best.value ? b : best,
          );

    if (buckets.isEmpty) {
      return const AdminEmptyState(
        icon: Icons.timeline_outlined,
        title: 'No buckets in this window.',
        hint: 'The server returned a zero-length series. Narrow or widen the '
            'window and try again.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${series.metric.label.isEmpty ? series.metric.key : series.metric.label}'
                ' · ${series.granularity} buckets',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
            AdminStatusBadge(
              status: '${buckets.length} buckets',
              upper: false,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          peak == null
              ? 'Every bucket is zero. Bars are omitted because there is no '
                  'non-zero value to scale against.'
              : 'Bars are scaled to this series\' peak of '
                  '${series.metric.unit == 'usd' ? '\$${peak.toStringAsFixed(2)}' : peak} '
                  'in ${peakBucket?.bucket ?? '—'}. Each row also prints the value.',
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, height: 1.35),
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            SizedBox(
              width: 96,
              child: Text('Bucket', style: TextStyle(fontSize: 10)),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text('Relative to peak', style: TextStyle(fontSize: 10)),
            ),
            SizedBox(width: 10),
            SizedBox(
              width: 74,
              child: Text('Value', textAlign: TextAlign.right, style: TextStyle(fontSize: 10)),
            ),
            SizedBox(width: 22),
          ],
        ),
        const SizedBox(height: 4),
        for (final bucket in buckets)
          AnalyticsBucketRow(
            bucket: bucket,
            peak: peak,
            isPeak: bucket.bucket == peakBucket?.bucket && !bucket.isZero,
            unit: series.metric.unit,
          ),
      ],
    );
  }
}

/// The report's `table` block, printed as a plain grid.
///
/// The server ships a `table` on every report because the export writer renders
/// exactly it. Showing it on the page means the operator can see the file's
/// contents before downloading it, and it means the two cannot disagree.
class AnalyticsTableBlock extends StatelessWidget {
  final AnalyticsTable table;
  final String emptyHint;

  const AnalyticsTableBlock({
    super.key,
    required this.table,
    this.emptyHint = 'This report returned no table for this window.',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (table.isEmpty) {
      return AdminHintNote(text: emptyHint);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rows in this report — the export contains exactly these '
          '(${table.rowCount} row(s)).',
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, height: 1.35),
        ),
        const SizedBox(height: 8),
        for (final row in table.rows.take(50))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(
              row.map(analyticsTableCell).join('  ·  '),
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        if (table.rowCount > 50)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Showing the first 50 of ${table.rowCount} rows. The export '
              'carries all ${table.rowCount}.',
              style: const TextStyle(fontSize: 11, color: BuddyColors.gold),
            ),
          ),
      ],
    );
  }
}

/// What an export attempt did, as an inline block.
///
/// The three refusals are each spelled out rather than collapsed into
/// "Export failed", because the operator's next move differs for every one:
///
/// * **Row cap (400)** — narrow the date range. The server's sentence is
///   printed verbatim, including the row count and the cap, because it also
///   explains why the file was not silently truncated.
/// * **xlsx missing (503)** — this deployment has no `openpyxl`. Nothing is
///   wrong with the report and nothing is wrong with the filters; the CSV of
///   the same report is unaffected, so the CSV button is offered here.
/// * **Empty body** — a 200 with no bytes is never presented as a successful
///   export of zero rows.
class AnalyticsExportResultPanel extends StatelessWidget {
  final AnalyticsExportOutcome outcome;
  final VoidCallback? onRetryAsCsv;

  const AnalyticsExportResultPanel({
    super.key,
    required this.outcome,
    this.onRetryAsCsv,
  });

  @override
  Widget build(BuildContext context) {
    return switch (outcome) {
      AnalyticsExportReady ready => AdminNoticeBanner(message: ready.summary),
      AnalyticsExportCapped capped => _cappedPanel(context, capped),
      AnalyticsExportXlsxUnavailable unavailable =>
        _xlsxUnavailablePanel(context, unavailable, onRetryAsCsv),
      AnalyticsExportEmpty() => _emptyPanel(context),
    };
  }

  Widget _cappedPanel(BuildContext context, AnalyticsExportCapped outcome) {
    final cs = Theme.of(context).colorScheme;
    final rows = outcome.rowCount;
    final cap = outcome.cap;
    final headline = rows != null && cap != null
        ? 'Export refused — ${_grouped(rows)} rows is '
            '${_grouped(rows - cap)} over the ${_grouped(cap)} row cap.'
        : 'Export refused — over the row cap.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BuddyColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.block_outlined, size: 16, color: BuddyColors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headline,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: BuddyColors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Verbatim. The server's sentence names the setting and explains why
          // the file was not silently truncated, and paraphrasing it drops both.
          Text(
            outcome.message,
            style: TextStyle(fontSize: 11, color: cs.onSurface, height: 1.45),
          ),
          const SizedBox(height: 6),
          const Text(
            'No file was produced. Nothing was truncated: a shorter file would '
            'differ from the report you were looking at.',
            style: TextStyle(fontSize: 11, color: BuddyColors.gold, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _xlsxUnavailablePanel(
    BuildContext context,
    AnalyticsExportXlsxUnavailable outcome,
    VoidCallback? onRetryAsCsv,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BuddyColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.table_chart_outlined, size: 16, color: BuddyColors.gold),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Spreadsheet export is unavailable on this deployment.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: BuddyColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            outcome.message,
            style: TextStyle(fontSize: 11, color: cs.onSurface, height: 1.45),
          ),
          const SizedBox(height: 6),
          const Text(
            'The report itself built fine — only the xlsx renderer is missing. '
            'CSV of the same report and the same filters is unaffected.',
            style: TextStyle(fontSize: 11, height: 1.4),
          ),
          if (onRetryAsCsv != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onRetryAsCsv,
                style: TextButton.styleFrom(
                  foregroundColor: BuddyColors.green,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.download_outlined, size: 14),
                label: const Text(
                  'Switch to CSV and export again',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyPanel(BuildContext context) {
    // Runtime-red rather than `BuddyColors.red` directly: the panel is the
    // one "something went wrong but the server said OK" surface, and it must
    // not read as the calm, neutral empty state.
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BuddyColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.red.withValues(alpha: 0.25)),
      ),
      child: Text(
        'The server answered 200 with no file bytes. That is not a report with '
        'zero rows, so nothing has been handed over. Retry, and tell an '
        'administrator if it repeats.',
        style: TextStyle(fontSize: 11, color: cs.onSurface, height: 1.45),
      ),
    );
  }

  /// Thousands separators, matching how the server writes the number in its
  /// own refusal sentence so the two read as the same figure.
  static String _grouped(int value) {
    final text = value.abs().toString();
    final buffer = StringBuffer(value < 0 ? '-' : '');
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
      buffer.write(text[i]);
    }
    return buffer.toString();
  }
}

/// The export control: format picker, report picker, download and open-URL.
///
/// Two ways out, and the difference matters.
///
/// **Download** goes through the authenticated Dio client and then the platform
/// share sheet — the same handover `admin_audit_screen` uses, and for the same
/// reason: the route is scope-gated and the app authenticates with a Bearer
/// token, so handing the bare address to an external browser would answer 401
/// rather than a file.
///
/// **Open the export URL** hands [analyticsExportUrl] to `url_launcher`. The
/// address is built from the same parameter map the authenticated call sends,
/// so it provably describes the same report; it is offered for the operator who
/// wants the file through a client that already holds a session, and the URL is
/// printed underneath so the filters behind a downloaded file are checkable
/// rather than remembered.
class AnalyticsExportBar extends ConsumerStatefulWidget {
  final AnalyticsQuery query;
  final List<String> availableReports;
  final String defaultReport;
  final String title;

  const AnalyticsExportBar({
    super.key,
    required this.query,
    required this.availableReports,
    required this.defaultReport,
    this.title = 'Export',
  });

  @override
  ConsumerState<AnalyticsExportBar> createState() => _AnalyticsExportBarState();
}

class _AnalyticsExportBarState extends ConsumerState<AnalyticsExportBar> {
  late String _report = widget.defaultReport;
  String _format = 'csv';
  bool _busy = false;
  AnalyticsExportOutcome? _outcome;
  String? _failure;

  @override
  void didUpdateWidget(covariant AnalyticsExportBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Following the screen: a change of report resets the attempt so a stale
    // refusal for a different report is not left on the page.
    if (oldWidget.defaultReport != widget.defaultReport) {
      _report = widget.defaultReport;
      _outcome = null;
      _failure = null;
    }
  }

  Uri get _url => analyticsExportUrl(widget.query, report: _report, format: _format);

  Future<void> _run() async {
    setState(() {
      _busy = true;
      _outcome = null;
      _failure = null;
    });
    try {
      final outcome = await fetchAnalyticsExport(
        ref,
        widget.query,
        report: _report,
        format: _format,
      );
      if (!mounted) return;
      setState(() => _outcome = outcome);
      if (outcome is AnalyticsExportReady) {
        await _share(outcome);
      }
    } catch (e) {
      // Deliberately *not* collapsed into `AnalyticsExportEmpty`. That panel
      // says "the server answered 200 with no bytes", and a dropped connection
      // or a 500 did not do that — showing it would turn a transport failure
      // into a claim about the report.
      if (!mounted) return;
      setState(() {
        _failure = apiErrorMessage(
          e,
          fallback: 'The export could not be fetched. Nothing was downloaded '
              'and no file was produced.',
        );
        _busy = false;
      });
      return;
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _share(AnalyticsExportReady export) async {
    await SharePlus.instance.share(
      ShareParams(
        subject: 'BuddyUp $_report export',
        text: export.summary,
        files: [
          XFile.fromData(
            export.bytes,
            mimeType: export.mimeType,
            name: export.filename,
          ),
        ],
        sharePositionOrigin: _shareOrigin(),
      ),
    );
  }

  Rect? _shareOrigin() {
    final box = context.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The file is produced by the same builder that drew this screen, '
            'with the filters above — so it holds exactly what you are looking '
            'at, or it is refused.',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final option in kExportReportChoices)
                if (widget.availableReports.contains(option.value))
                  ChoiceChip(
                    label: Text(option.label, style: const TextStyle(fontSize: 11)),
                    selected: _report == option.value,
                    onSelected: (_) => setState(() {
                      _report = option.value;
                      _outcome = null;
                      _failure = null;
                    }),
                    selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                    backgroundColor: cs.surface,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                      color: _report == option.value
                          ? BuddyColors.green
                          : cs.outline.withValues(alpha: 0.3),
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  children: [
                    for (final option in kExportFormatChoices)
                      ChoiceChip(
                        label: Text(option.label, style: const TextStyle(fontSize: 11)),
                        selected: _format == option.value,
                        onSelected: (_) => setState(() {
                          _format = option.value;
                          _outcome = null;
                          _failure = null;
                        }),
                        selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                        backgroundColor: cs.surface,
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(
                          color: _format == option.value
                              ? BuddyColors.green
                              : cs.outline.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _busy ? null : _run,
                style: FilledButton.styleFrom(
                  backgroundColor: BuddyColors.green,
                  foregroundColor: Colors.black,
                  visualDensity: VisualDensity.compact,
                ),
                icon: _busy
                    ? const SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_outlined, size: 15),
                label: Text(_busy ? 'Exporting…' : 'Export',
                    style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _url.toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                ),
              ),
              TextButton.icon(
                onPressed: () => launchUrl(_url, mode: LaunchMode.externalApplication),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: BuddyColors.green,
                ),
                icon: const Icon(Icons.open_in_new, size: 13),
                label: const Text('Open URL', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          if (_outcome != null) ...[
            const SizedBox(height: 8),
            AnalyticsExportResultPanel(
              outcome: _outcome!,
              onRetryAsCsv: _outcome is AnalyticsExportXlsxUnavailable
                  ? () => setState(() {
                        _format = 'csv';
                        _outcome = null;
                        _failure = null;
                      })
                  : null,
            ),
          ],
          if (_failure != null) ...[
            const SizedBox(height: 8),
            AdminErrorBanner(message: _failure!),
          ],
        ],
      ),
    );
  }
}