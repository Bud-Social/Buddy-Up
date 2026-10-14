import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/env/env.dart';
import '../../../data/models/platform_analytics.dart';
import 'admin_provider.dart';
import 'governance_provider.dart' show auditExportFilename;

/// `/api/v1/portal/analytics/**` — the six staff reports plus the export.
///
/// Three things are load-bearing here and they are all about not overstating
/// what the server said:
///
/// 1. **Every figure declares its own window.** Nothing here computes a date
///    range, a delta or a total. A KPI is rendered with the window that KPI
///    carries, which is why [analyticsOverviewProvider] hands back the parsed
///    KPIs and not a flattened row list.
/// 2. **A refusal is not an empty result.** `trending?kind=pages` answers
///    `{available: false, reason}` and `timeseries?metric=` answers a 400 naming
///    the metric. Both are surfaced as themselves; neither is turned into a
///    "no data" list.
/// 3. **The export is the screen.** `build_report` runs the same builder with
///    the same params and takes the same `table`, so the only job here is to
///    carry the filters across without altering them.

/// The window and selection shared by the six reports.
///
/// A map, for the same reason as `PortalQuery.params`: the endpoints validate
/// their own values and answer a bad one with a 400 naming the allowed set,
/// which is a more useful message than a client-side guess. Identity is a
/// stable string so this works as a Riverpod family key.
class AnalyticsQuery {
  final String from;
  final String to;
  final String metric;
  final String granularity;
  final String kind;
  final int? limit;

  const AnalyticsQuery({
    this.from = '',
    this.to = '',
    this.metric = '',
    this.granularity = 'day',
    this.kind = 'posts',
    this.limit,
  });

  /// Drop blanks so the query string stays clean.
  ///
  /// `granularity` and `kind` always survive: they have server-side defaults
  /// and the screens pin them explicitly, so removing one would silently change
  /// which report is being read.
  factory AnalyticsQuery.of(
    int page, [
    Map<String, dynamic> filters = const {},
  ]) {
    final clean = <String, dynamic>{};
    filters.forEach((key, value) {
      if (value == null || value == '' || value == 'all') return;
      clean[key] = value;
    });
    return AnalyticsQuery(
      from: '${clean['from'] ?? ''}',
      to: '${clean['to'] ?? ''}',
      metric: '${clean['metric'] ?? ''}',
      granularity: '${clean['granularity'] ?? 'day'}',
      kind: '${clean['kind'] ?? 'posts'}',
      limit: clean['limit'] is int ? clean['limit'] as int : null,
    );
  }

  AnalyticsQuery copyWith({
    String? from,
    String? to,
    String? metric,
    String? granularity,
    String? kind,
    int? limit,
    bool clearLimit = false,
  }) =>
      AnalyticsQuery(
        from: from ?? this.from,
        to: to ?? this.to,
        metric: metric ?? this.metric,
        granularity: granularity ?? this.granularity,
        kind: kind ?? this.kind,
        limit: clearLimit ? null : (limit ?? this.limit),
      );

  /// Every key a report might accept, as query params, blanks omitted.
  ///
  /// Used by all six calls rather than passing the whole object, so a report
  /// never receives a parameter it does not understand — the export writer
  /// passes `metric`/`granularity` to `timeseries` only, and the row count it
  /// stamps has to describe the same request the screen made.
  Map<String, String> toParams() {
    final params = <String, String>{
      if (from.isNotEmpty) 'from': from,
      if (to.isNotEmpty) 'to': to,
      if (metric.isNotEmpty) 'metric': metric,
      'granularity': granularity,
      'kind': kind,
      if (limit != null) 'limit': '$limit',
    };
    return params;
  }

  String get identity => jsonEncode(toParams());

  @override
  bool operator ==(Object other) => other is AnalyticsQuery && other.identity == identity;

  @override
  int get hashCode => identity.hashCode;

  /// A one-line description of what is on screen, printed in the page header so
  /// an operator can tell two windows apart without opening a filter panel.
  String get windowLabel {
    if (from.isEmpty && to.isEmpty) return 'Default window (last 30 days, UTC)';
    final start = from.isEmpty ? '…' : from;
    final end = to.isEmpty ? 'today' : to;
    return '$start → $end (UTC)';
  }
}

/// The metric the Trends screen opens on.
///
/// `orders.new` rather than a hardcoded guess at "the most interesting" one:
/// it is in `TIMESERIES_METRICS` (additive and windowed, so it cannot be
/// refused with a 400) and it is one the overview shows, so the two pages
/// start describing the same thing.
const String kDefaultTimeseriesMetric = 'orders.new';

/// Granularities `_choice_param` accepts. Anything else is a 400.
const List<({String value, String label})> kGranularityChoices = [
  (value: 'day', label: 'Daily'),
  (value: 'week', label: 'Weekly'),
];

/// Trending kinds, including `pages`.
///
/// `pages` is listed because the server declares it and explains at length why
/// it has nothing. Offering it and then explaining is honest; hiding it would
/// leave an operator wondering whether the console simply forgot.
const List<({String value, String label})> kTrendingKindChoices = [
  (value: 'posts', label: 'Posts'),
  (value: 'services', label: 'Services'),
  (value: 'events', label: 'Events'),
  (value: 'hashtags', label: 'Hashtags'),
  (value: 'pages', label: 'Pages'),
];

// ---------------------------------------------------------------------------
// Report providers
// ---------------------------------------------------------------------------

final analyticsOverviewProvider =
    FutureProvider.family<AnalyticsOverview, AnalyticsQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getAnalyticsOverview(
        from: q.from.isEmpty ? null : q.from,
        to: q.to.isEmpty ? null : q.to,
      );
  return AnalyticsOverview.fromJson(_reportPayload(raw));
});

final analyticsTimeseriesProvider =
    FutureProvider.family<AnalyticsTimeseries, AnalyticsQuery>((ref, q) async {
  final raw =
      await ref.watch(adminPortalRepositoryProvider).getAnalyticsTimeseries(
            metric: q.metric.isEmpty ? kDefaultTimeseriesMetric : q.metric,
            granularity: q.granularity,
            from: q.from.isEmpty ? null : q.from,
            to: q.to.isEmpty ? null : q.to,
          );
  return AnalyticsTimeseries.fromJson(_reportPayload(raw));
});

final analyticsTrendingProvider =
    FutureProvider.family<AnalyticsTrending, AnalyticsQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getAnalyticsTrending(
        kind: q.kind,
        limit: q.limit,
        from: q.from.isEmpty ? null : q.from,
        to: q.to,
      );
  return AnalyticsTrending.fromJson(_reportPayload(raw));
});

final analyticsAiQualityProvider =
    FutureProvider.family<AiQualityReport, AnalyticsQuery>((ref, q) async {
  final raw =
      await ref.watch(adminPortalRepositoryProvider).getAnalyticsAiQuality(
            from: q.from.isEmpty ? null : q.from,
            to: q.to.isEmpty ? null : q.to,
          );
  return AiQualityReport.fromJson(_reportPayload(raw));
});

final analyticsPredictiveProvider =
    FutureProvider.family<PredictiveReport, AnalyticsQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getAnalyticsPredictive(
        from: q.from.isEmpty ? null : q.from,
        to: q.to.isEmpty ? null : q.to,
      );
  return PredictiveReport.fromJson(_reportPayload(raw));
});

/// The body of a `/portal/analytics/**` envelope, or an empty map.
///
/// These six wrap their payload in `PortalView.ok`, so `data` is the report.
/// A null or non-map body becomes `{}` and every model here fills in its own
/// defaults — which is the point of defaulting every field: a shape change on
/// one report degrades one tile, it does not take the screen down.
Map<String, dynamic> _reportPayload(dynamic envelope) {
  if (envelope is! Map) return const {};
  final data = envelope['data'];
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return data.map((key, value) => MapEntry('$key', value));
  return const {};
}

// ---------------------------------------------------------------------------
// Export
// ---------------------------------------------------------------------------

/// Report keys `REPORTS` declares, with the label each one carries.
const List<({String value, String label})> kExportReportChoices = [
  (value: 'overview', label: 'Platform overview'),
  (value: 'timeseries', label: 'Metric time series'),
  (value: 'trending', label: 'Trending'),
  (value: 'ai_quality', label: 'AI quality and cost'),
  (value: 'predictive', label: 'Recommendation signals'),
];

/// The two formats `FORMATS` accepts.
const List<({String value, String label})> kExportFormatChoices = [
  (value: 'csv', label: 'CSV'),
  (value: 'xlsx', label: 'Excel (xlsx)'),
];

/// What happened when the operator asked for a file.
///
/// Four outcomes, not two, because the two refusals are not the same problem:
/// the row cap means *narrow your range* and the missing `openpyxl` means *this
/// deployment cannot do that format at all*. Collapsing both into "export
/// failed" would send the first operator to rebuild an image for what is really
/// a date-range typo.
sealed class AnalyticsExportOutcome {
  const AnalyticsExportOutcome();
}

/// The file exists and its provenance is known.
class AnalyticsExportReady extends AnalyticsExportOutcome {
  final Uint8List bytes;

  /// From `Content-Disposition`. Encodes the report key and the window, so it
  /// is the difference between a file an operator can file and "download (1)".
  final String filename;
  final String mimeType;

  /// `X-Analytics-Rows`, parsed. Null when the header is absent — which is
  /// different from zero, and must not be shown as an empty report.
  final int? rowCount;
  final String? from;
  final String? to;
  final String? dataSource;

  const AnalyticsExportReady({
    required this.bytes,
    required this.filename,
    required this.mimeType,
    this.rowCount,
    this.from,
    this.to,
    this.dataSource,
  });

  /// The sentence shown after a successful export.
  ///
  /// It names the row count and the window because the whole reason the server
  /// refuses to truncate is that a short file is a lie about the data — so the
  /// confirmation states what the file actually covers, and the caller compares
  /// it to what they were looking at.
  String get summary {
    final rows = rowCount == null ? 'an unstated number of' : '$rowCount';
    final window = (from != null && to != null) ? ' for $from → $to' : '';
    final source = (dataSource != null && dataSource!.isNotEmpty)
        ? ' Served from the $dataSource path.'
        : '';
    return 'Exported $filename — $rows row(s)$window.$source';
  }
}

/// The 50k row cap. The server's sentence is the whole message.
///
/// `enforce_row_cap` raises rather than truncating precisely so that this
/// arrives instead of a quietly short file. Printing it verbatim keeps the
/// actionable parts — the row count, the cap, the setting name, and the reason
/// the file was not truncated.
class AnalyticsExportCapped extends AnalyticsExportOutcome {
  final String message;
  final int? rowCount;
  final int? cap;

  const AnalyticsExportCapped(this.message, {this.rowCount, this.cap});
}

/// The 503. `openpyxl` is not installed on the deployment.
///
/// Said plainly and pointed at CSV, because CSV is unaffected — the server
/// builds the report *before* it probes for the dependency, so a 503 means the
/// report was fine and only the rendering was unavailable.
class AnalyticsExportXlsxUnavailable extends AnalyticsExportOutcome {
  final String message;

  const AnalyticsExportXlsxUnavailable(this.message);
}

/// A 200 with no bytes. Treated as a failure, never as an empty report.
class AnalyticsExportEmpty extends AnalyticsExportOutcome {
  const AnalyticsExportEmpty();
}

/// Fetch one report as a file, with the current filters.
///
/// `report` is one of [kExportReportChoices]; the scoped params (`metric`,
/// `granularity` for `timeseries`; `kind`, `limit` for `trending`) travel with
/// it so the export runs the same builder the screen did.
Future<AnalyticsExportOutcome> fetchAnalyticsExport(
  WidgetRef ref,
  AnalyticsQuery query, {
  required String report,
  String format = 'csv',
}) async {
  try {
    final response =
        await ref.read(adminPortalRepositoryProvider).exportAnalyticsReport(
              report: report,
              format: format,
              from: query.from.isEmpty ? null : query.from,
              to: query.to.isEmpty ? null : query.to,
              metric: query.metric.isEmpty ? null : query.metric,
              granularity: report == 'timeseries' ? query.granularity : null,
              kind: report == 'trending' ? query.kind : null,
              limit: report == 'trending' ? query.limit : null,
            );
    final data = response.data;
    final bytes = switch (data) {
      final Uint8List value => value,
      final List<int> value => Uint8List.fromList(value),
      _ => Uint8List(0),
    };
    if (bytes.isEmpty) return const AnalyticsExportEmpty();
    return AnalyticsExportReady(
      bytes: bytes,
      filename: auditExportFilename(
        response.response.headers.value('content-disposition'),
        fallback: 'analytics-$report.${format == 'xlsx' ? 'xlsx' : 'csv'}',
      ),
      mimeType: format == 'xlsx'
          ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
          : 'text/csv',
      rowCount: _intHeader(response.response.headers.value('x-analytics-rows')),
      from: response.response.headers.value('x-analytics-from'),
      to: response.response.headers.value('x-analytics-to'),
      dataSource: response.response.headers.value('x-analytics-data-source'),
    );
  } catch (error) {
    final status = apiStatusCode(error);
    if (status == 503) {
      return AnalyticsExportXlsxUnavailable(apiErrorMessage(
        error,
        fallback: 'Spreadsheet export is unavailable on this deployment: the '
            '"openpyxl" package is not installed. It is declared in '
            'requirements/base.txt — rebuild the image or reinstall '
            'requirements. CSV export of the same report is unaffected.',
      ));
    }
    if (status == 400) {
      final message = apiErrorMessage(error, fallback: 'The export was refused.');
      final cap = _capFrom(message);
      return AnalyticsExportCapped(
        message,
        rowCount: cap.rowCount,
        cap: cap.cap,
      );
    }
    rethrow;
  }
}

/// Pull the row count and the cap out of the 400's sentence.
///
/// The server writes both as prose — "would contain 63,221 rows, above the
/// 50,000 row cap" — and this only *lifts* them for display. The message
/// itself is still shown verbatim; these are read so the banner can say "41,221
/// too many" without paraphrasing the server's wording.
({int? rowCount, int? cap}) _capFrom(String message) {
  int? rowCount;
  int? cap;
  final rowsMatch = RegExp(r'([\d,]+) rows').firstMatch(message);
  if (rowsMatch != null) {
    rowCount = int.tryParse(rowsMatch.group(1)!.replaceAll(',', ''));
  }
  final capMatch = RegExp(r'([\d,]+) row cap').firstMatch(message);
  if (capMatch != null) {
    cap = int.tryParse(capMatch.group(1)!.replaceAll(',', ''));
  }
  return (rowCount: rowCount, cap: cap);
}

int? _intHeader(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return int.tryParse(raw.trim());
}

/// The absolute export URL for these filters.
///
/// Two uses: `url_launcher` hands the operator the address so a file can be
/// fetched by whatever has a session, and the screen prints it so the filters
/// behind a downloaded file are checkable rather than remembered.
///
/// Deliberately assembled from [AnalyticsQuery.toParams] — the same map the
/// authenticated call sends — so the address and the request can never describe
/// different reports.
Uri analyticsExportUrl(AnalyticsQuery query, {required String report, String format = 'csv'}) {
  final base = Env.apiBaseUrl.endsWith('/')
      ? Env.apiBaseUrl.substring(0, Env.apiBaseUrl.length - 1)
      : Env.apiBaseUrl;
  final params = <String, String>{'report': report, 'format': format}
    ..addAll(query.toParams());
  return Uri.parse('$base/portal/analytics/export/')
      .replace(queryParameters: params);
}

/// A percent or a ratio as the console prints them.
///
/// `None` and `0.0` are different answers — "no jobs ran" versus "every job hit
/// the fallback" — so a null ratio prints as an em dash and never as `0%`.
String analyticsPercent(double? ratio) {
  if (ratio == null) return '—';
  return '${(ratio * 100).toStringAsFixed(1)}%';
}

/// Money with the precision the unit implies.
String analyticsMoney(num? value) {
  if (value == null) return '—';
  return '\$${value.toStringAsFixed(2)}';
}

/// A latency percentile in whole milliseconds, or an em dash when the server
/// reported none.
String analyticsMs(int? value) => value == null ? '—' : '$value ms';