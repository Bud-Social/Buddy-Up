import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_analytics.freezed.dart';
part 'platform_analytics.g.dart';

// Typed client for `/api/v1/portal/analytics/**`, mirroring
// `backend/apps/analytics/platform_metrics.py`.
//
// The rule this file encodes is the one that module states at the top: every
// figure declares its own window. There is no ambient "current period" a KPI
// inherits, which is why [AnalyticsWindow] is a field on every KPI rather than
// a field on the response — `users.total` is a lifetime gauge and `users.new` is
// a period delta, and a UI that shows them side by side has to show two
// different windows or it is lying.
//
// Every member is defaulted for the same reason as `admin_portal.dart`: this
// console is coded against a contract landing in parallel, so a renamed or
// absent field must degrade in the UI rather than crash it. Values are typed by
// shape (`num`, `String`) rather than by assumption — the server's `_num`
// helper returns an int for a whole count and a float for money, so a `value`
// field is genuinely `num`.

// ---------------------------------------------------------------------------
// Coercions
//
// Re-declared rather than imported: `admin_portal.dart` keeps these private to
// its own file, and sharing a helper across two model files would couple the
// portal surface to the analytics one for no gain.
// ---------------------------------------------------------------------------

/// A number that may arrive as an int, a float, or a string.
///
/// The server normalises with `_num`, which returns `int` for a whole value and
/// `round(x, 6)` otherwise — so a KPI's `value` is genuinely polymorphic and a
/// model that declared `int` would throw on `orders.gross_usd`.
num? _optNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is String) return num.tryParse(v);
  return null;
}

num _optNumOrZero(dynamic v) => _optNum(v) ?? 0;

/// Normalise a table's `rows` to `List<List<Object?>>`.
///
/// The `table` block is `{columns, rows}` where each row is a heterogeneous
/// JSON list. json_serializable's generated cast throws on a null row or a row
/// that is not a list, and this is exactly the shape a future builder could
/// get wrong — so it degrades to an empty table rather than taking the screen
/// down with it.
List<List<Object?>> _tableRows(dynamic json) {
  if (json is! List) return const [];
  return json.whereType<List>().map(List<Object?>.from).toList();
}

/// Normalise a list field whose element shape is decided per-kind.
///
/// `items` on trending is a list of four different row shapes depending on
/// `kind`, and `signal.values` / `kpis` are lists of maps. A missing, null or
/// wrong-shaped list must be empty, not an exception.
List<Map<String, dynamic>> _mapList(dynamic json) {
  if (json is! List) return const [];
  return json.whereType<Map>().map(_stringKeyed).toList();
}

Map<String, dynamic> _stringKeyed(Map<dynamic, dynamic> json) =>
    json.map((key, value) => MapEntry('$key', value));

/// Normalise a list of plain strings (`groups`, `available_metrics`,
/// `missing_days`). A non-string element is skipped rather than crashing.
List<String> _stringList(dynamic json) {
  if (json is! List) return const [];
  return json.where((e) => e != null).map((e) => '$e').toList();
}

// ---------------------------------------------------------------------------
// The window
// ---------------------------------------------------------------------------

/// `{from, to, days, basis, timezone, label}`.
///
/// `label` is the reason this type exists on a *KPI*: `_kpi()` labels a gauge
/// "All time" and a flow "Window", even though both are computed over the same
/// `Window` object. `from` is a Dart keyword, so the member is [fromDate] and
/// carries the server's name in its `JsonKey`.
@freezed
abstract class AnalyticsWindow with _$AnalyticsWindow {
  const factory AnalyticsWindow({
    @JsonKey(name: 'from') @Default('') String fromDate,
    @JsonKey(name: 'to') @Default('') String toDate,
    @Default(0) int days,
    @Default('') String basis,
    @Default('') String timezone,
    /// "All time" for a gauge, "Window" for a flow, and the date range for
    /// everything else.
    @Default('') String label,
  }) = _AnalyticsWindow;

  factory AnalyticsWindow.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsWindowFromJson(json);
}

extension AnalyticsWindowX on AnalyticsWindow {
  /// The date range without the server's `label` prose.
  String get range =>
      fromDate.isEmpty && toDate.isEmpty ? '—' : '$fromDate → $toDate';

  /// What to print above a tile. Prefers the server's own label and falls back
  /// to the range, so a renamed `label` degrades to something true rather than
  /// to blank.
  String get displayLabel => label.isEmpty ? range : label;

  bool get isGaugeLabel => label == 'All time';
}

/// The `{columns, rows}` block every report returns for display and export.
///
/// Not a chart and not a convenience: it is the *same* rows the CSV writer
/// renders, which is why an export can never differ from the screen.
@freezed
abstract class AnalyticsTable with _$AnalyticsTable {
  const factory AnalyticsTable({
    @Default(<String>[]) List<String> columns,
    @JsonKey(name: 'rows', fromJson: _tableRows) @Default(<List<Object?>>[])
    List<List<Object?>> rows,
  }) = _AnalyticsTable;

  factory AnalyticsTable.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsTableFromJson(json);
}

extension AnalyticsTableX on AnalyticsTable {
  bool get isEmpty => columns.isEmpty || rows.isEmpty;

  int get rowCount => rows.length;
}

/// One `table` cell as a string, or an em dash for nothing.
///
/// Top-level rather than a static on the extension: `AnalyticsTable.cell(…)`
/// resolves as an *instance* getter at the call site, which is a confusing way
/// to lose a type error.
///
/// The null case matters. An empty trending-post excerpt and a missing
/// `pct_change` print the same way here, and that is honest — both mean "the
/// server had nothing there", which is not the same as zero.
String analyticsTableCell(Object? value) {
  if (value == null) return '—';
  if (value is bool) return value ? 'true' : 'false';
  if (value is num) return '$value';
  final text = '$value';
  return text.isEmpty ? '—' : text;
}

// ---------------------------------------------------------------------------
// GET /overview/
// ---------------------------------------------------------------------------

/// One KPI. `kind` is `gauge` (cumulative) or `flow` (a delta inside the
/// window) and decides which window label it carries — see
/// `MetricSpec.windowed_label`.
@freezed
abstract class AnalyticsKpi with _$AnalyticsKpi {
  const factory AnalyticsKpi({
    @Default('') String key,
    @Default('') String label,
    @Default('') String group,
    /// `count` or `usd`.
    @Default('') String unit,
    @JsonKey(name: 'value', fromJson: _optNumOrZero) @Default(0) num value,
    @Default('gauge') String kind,
    @Default(AnalyticsWindow()) AnalyticsWindow window,
    @Default('') String source,
    /// False when the figure reads a column no index covers. Disclosed, not
    /// hidden — see `performance_notes` on the overview.
    @Default(true) bool indexed,
    @Default('') String note,
    @JsonKey(name: 'source_count') int? sourceCount,
  }) = _AnalyticsKpi;

  factory AnalyticsKpi.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsKpiFromJson(json);
}

extension AnalyticsKpiX on AnalyticsKpi {
  /// Defaulting `kind` to `gauge` above means an absent field reads as a
  /// lifetime number; this is the honest second guess. A KPI the server sent
  /// with no `kind` is far more likely to be a period delta than a lifetime
  /// count, because only `windowed: false` specs omit nothing here.
  bool get isGauge => kind == 'gauge';

  bool get isFlow => !isGauge;

  /// The tile's window caption: the KPI's own label, never the page's.
  String get windowLabel =>
      window.label.isEmpty ? (isGauge ? 'All time' : 'Window') : window.label;

  String get windowRange => window.range;

  /// Money gets two decimals; a count does not get any, because a
  /// "1,204.00 users" tile reads as a different measurement.
  String get formattedValue => unit == 'usd'
      ? '\$${_grouped(value)}'
      : _grouped(value);

  static String _grouped(num v) {
    final digits = v is int || v == v.roundToDouble() ? 0 : 2;
    final text = v.toStringAsFixed(digits);
    final parts = text.split('.');
    final whole = parts.first;
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
      buffer.write(whole[i]);
    }
    if (parts.length > 1) buffer.write('.${parts[1]}');
    return buffer.toString();
  }
}

/// One `performance_notes` row: a column the aggregate reads that no index
/// covers, the migration that fixes it, and which app owns it.
@freezed
abstract class AnalyticsPerformanceNote with _$AnalyticsPerformanceNote {
  const factory AnalyticsPerformanceNote({
    @Default('') String source,
    @Default('') String issue,
    @JsonKey(name: 'suggested_migration') @Default('') String suggestedMigration,
    @Default('') String owner,
  }) = _AnalyticsPerformanceNote;

  factory AnalyticsPerformanceNote.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsPerformanceNoteFromJson(json);
}

/// A `breakdowns[]` block. The row shape is decided by the builder, so the
/// rows stay as a map list and the screen prints `title` + whatever keys the
/// builder chose — which is what keeps the client from hard-coding a shape that
/// differs per breakdown.
@freezed
abstract class AnalyticsBreakdown with _$AnalyticsBreakdown {
  const factory AnalyticsBreakdown({
    @Default('') String title,
    @Default(AnalyticsWindow()) AnalyticsWindow window,
    @Default('') String basis,
    @Default('') String note,
    @JsonKey(name: 'rows', fromJson: _mapList)
    @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> rows,
  }) = _AnalyticsBreakdown;

  factory AnalyticsBreakdown.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsBreakdownFromJson(json);
}

extension AnalyticsBreakdownX on AnalyticsBreakdown {
  /// Column order for the row table: union of the keys in first-seen order, so
  /// two blocks with different shapes do not force the screen to know either.
  List<String> get columns {
    final seen = <String>{};
    for (final row in rows) {
      row.forEach((key, _) => seen.add(key));
    }
    return seen.toList();
  }
}

/// `GET /portal/analytics/overview/`.
@freezed
abstract class AnalyticsOverview with _$AnalyticsOverview {
  const factory AnalyticsOverview({
    @Default(AnalyticsWindow()) AnalyticsWindow window,
    @JsonKey(name: 'generated_at') @Default('') String generatedAt,
    @JsonKey(name: 'kpis', fromJson: _mapList) @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> kpis,
    @JsonKey(name: 'breakdowns', fromJson: _mapList)
    @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> breakdowns,
    @Default(<String>[]) List<String> groups,
    @JsonKey(name: 'performance_notes', fromJson: _mapList)
    @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> performanceNotes,
    @Default(AnalyticsTable()) AnalyticsTable table,
  }) = _AnalyticsOverview;

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsOverviewFromJson(json);
}

extension AnalyticsOverviewX on AnalyticsOverview {
  List<AnalyticsKpi> get parsedKpis =>
      kpis.map(AnalyticsKpi.fromJson).toList();

  List<AnalyticsBreakdown> get parsedBreakdowns =>
      breakdowns.map(AnalyticsBreakdown.fromJson).toList();

  List<AnalyticsPerformanceNote> get parsedPerformanceNotes =>
      performanceNotes.map(AnalyticsPerformanceNote.fromJson).toList();

  /// KPIs grouped by their `group`, preserving the server's render order within
  /// each group. The overview returns `groups` as a sorted list and `kpis` in
  /// render order, so the grouping is by first appearance — not by the sorted
  /// `groups` member — which is the order the operator will read it in.
  Map<String, List<AnalyticsKpi>> get kpisByGroup {
    final out = <String, List<AnalyticsKpi>>{};
    for (final kpi in parsedKpis) {
      out.putIfAbsent(kpi.group.isEmpty ? 'other' : kpi.group, () => []).add(kpi);
    }
    return out;
  }
}

// ---------------------------------------------------------------------------
// GET /timeseries/
// ---------------------------------------------------------------------------

/// `metric{key, label, unit, group, source, description}`.
@freezed
abstract class AnalyticsMetric with _$AnalyticsMetric {
  const factory AnalyticsMetric({
    @Default('') String key,
    @Default('') String label,
    @Default('') String unit,
    @Default('') String group,
    @Default('') String source,
    @Default('') String description,
  }) = _AnalyticsMetric;

  factory AnalyticsMetric.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsMetricFromJson(json);
}

/// One zero-filled bucket. The zero-fill is the server's doing
/// (`read_rollup` returns the full label set), which is what lets the screen
/// distinguish "no rows" from "a real zero".
@freezed
abstract class AnalyticsBucket with _$AnalyticsBucket {
  const factory AnalyticsBucket({
    @Default('') String bucket,
    @JsonKey(name: 'value', fromJson: _optNumOrZero) @Default(0) num value,
  }) = _AnalyticsBucket;

  factory AnalyticsBucket.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsBucketFromJson(json);
}

extension AnalyticsBucketX on AnalyticsBucket {
  bool get isZero => value == 0;
}

/// `totals{sum, non_zero_buckets}`.
@freezed
abstract class AnalyticsTotals with _$AnalyticsTotals {
  const factory AnalyticsTotals({
    @JsonKey(name: 'sum', fromJson: _optNumOrZero) @Default(0) num sum,
    @JsonKey(name: 'non_zero_buckets', fromJson: _optNumOrZero)
    @Default(0)
    num nonZeroBuckets,
  }) = _AnalyticsTotals;

  factory AnalyticsTotals.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsTotalsFromJson(json);
}

/// `data_source{path, rollup_complete, missing_days, note}`.
///
/// `path` is `rollup` when the batch table answered and `live` when the server
/// fell back to aggregating the source table because the rollup had gaps. The
/// two cost very different amounts and the screen says which one ran.
@freezed
abstract class AnalyticsDataSource with _$AnalyticsDataSource {
  const factory AnalyticsDataSource({
    @Default('') String path,
    @JsonKey(name: 'rollup_complete') @Default(false) bool rollupComplete,
    @JsonKey(name: 'missing_days', fromJson: _stringList)
    @Default(<String>[])
    List<String> missingDays,
    @Default('') String note,
  }) = _AnalyticsDataSource;

  factory AnalyticsDataSource.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDataSourceFromJson(json);
}

extension AnalyticsDataSourceX on AnalyticsDataSource {
  /// True when the cheap path answered. Defaults false rather than true: an
  /// absent `path` must not read as "served from the rollup", because that
  /// claims the data was cheap when we do not know it was.
  bool get isRollup => path == 'rollup';

  bool get isLive => !isRollup;
}

/// One entry of `metric_catalogue` — the documented allow-list a picker is
/// built from, so the picker can never drift from the registry the server
/// validates against.
@freezed
abstract class AnalyticsMetricCatalogueEntry with _$AnalyticsMetricCatalogueEntry {
  const factory AnalyticsMetricCatalogueEntry({
    @Default('') String key,
    @Default('') String label,
    @Default('') String group,
    @Default('') String unit,
    /// False for distinct-counts and gauges, which the server refuses a series
    /// over with a 400 naming the reason.
    @Default(true) bool additive,
    @Default(true) bool windowed,
    @Default('') String source,
    @Default('') String description,
  }) = _AnalyticsMetricCatalogueEntry;

  factory AnalyticsMetricCatalogueEntry.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsMetricCatalogueEntryFromJson(json);
}

extension AnalyticsMetricCatalogueEntryX on AnalyticsMetricCatalogueEntry {
  /// Only additive, windowed metrics can be plotted — which is exactly the
  /// server's `TIMESERIES_METRICS`. Offered-but-disabled in a picker rather
  /// than hidden, because "why can't I see active users?" is answered by
  /// showing the entry and the reason.
  bool get isPlottable => additive && windowed;
}

/// `GET /portal/analytics/timeseries/`.
@freezed
abstract class AnalyticsTimeseries with _$AnalyticsTimeseries {
  const factory AnalyticsTimeseries({
    @Default(AnalyticsWindow()) AnalyticsWindow window,
    @Default(AnalyticsMetric()) AnalyticsMetric metric,
    /// `day` or `week`.
    @Default('day') String granularity,
    @JsonKey(name: 'series', fromJson: _mapList)
    @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> series,
    @Default(AnalyticsTotals()) AnalyticsTotals totals,
    @JsonKey(name: 'data_source') AnalyticsDataSource? dataSource,
    @JsonKey(name: 'available_metrics', fromJson: _stringList)
    @Default(<String>[])
    List<String> availableMetrics,
    @JsonKey(name: 'metric_catalogue', fromJson: _mapList)
    @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> metricCatalogue,
    @Default(AnalyticsTable()) AnalyticsTable table,
  }) = _AnalyticsTimeseries;

  factory AnalyticsTimeseries.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsTimeseriesFromJson(json);
}

extension AnalyticsTimeseriesX on AnalyticsTimeseries {
  List<AnalyticsBucket> get buckets =>
      series.map(AnalyticsBucket.fromJson).toList();

  List<AnalyticsMetricCatalogueEntry> get catalogue => metricCatalogue
      .map(AnalyticsMetricCatalogueEntry.fromJson)
      .toList();

  /// The source block, defaulted. `data_source` is optional above because a
  /// null is a legal JSON value here and freezed cannot default a nested
  /// object; this is where the screen reads it.
  AnalyticsDataSource get source => dataSource ?? const AnalyticsDataSource();

  bool get isZeroFilled => buckets.any((b) => b.isZero) || buckets.isNotEmpty;

  /// True when every bucket is a zero — the "this metric has no rows in this
  /// window" case that a table of zeros renders as a wall of nothing.
  bool get isAllZero => buckets.isNotEmpty && buckets.every((b) => b.isZero);

  /// The largest bucket, for scaling a bar in the bucket table. Null when the
  /// series is empty or entirely zero, so the bar widget can say "no scale"
  /// rather than dividing by zero.
  num? get peak {
    num? max;
    for (final bucket in buckets) {
      if (max == null || bucket.value > max) max = bucket.value;
    }
    return (max == null || max == 0) ? null : max;
  }
}

// ---------------------------------------------------------------------------
// GET /trending/
// ---------------------------------------------------------------------------

/// The five `TRENDING_KINDS`. `pages` is declared here because the client must
/// offer it and then render its refusal, not skip it: a kind the console cannot
/// ask about looks like a kind that was forgotten.
enum TrendingKind {
  posts('posts', 'Posts'),
  services('services', 'Services'),
  events('events', 'Events'),
  hashtags('hashtags', 'Hashtags'),
  pages('pages', 'Pages');

  const TrendingKind(this.wire, this.label);

  final String wire;
  final String label;

  static TrendingKind fromWire(String? value) => TrendingKind.values.firstWhere(
        (kind) => kind.wire == value,
        // An unknown kind is not a crash and not a silent `posts`: the server
        // 400s naming the allowed set, and the screen will show that.
        orElse: () => TrendingKind.posts,
      );
}

/// One trending row.
///
/// **The item fields differ per kind.** `hashtags` has `tag` / `posts_in_window`
/// / `delta`; `posts` has `author_username` / `reactions`; `events` has
/// `starts_at` / `sold_tickets_in_window`; `services` has `purchases_in_window`
/// / `average_rating`. Rather than four models and four widgets — or one model
/// that pretends every field is always there — this is one row whose absent
/// fields are empty, and [TrendingColumns] decides what to print for the kind
/// in hand. Every field is defaulted for the same reason.
@freezed
abstract class TrendingItem with _$TrendingItem {
  const factory TrendingItem({
    @Default(0) int rank,
    // posts
    @JsonKey(name: 'post_id') @Default('') String postId,
    @JsonKey(name: 'author_username') @Default('') String authorUsername,
    @JsonKey(name: 'post_type') @Default('') String postType,
    @JsonKey(name: 'body_excerpt') @Default('') String bodyExcerpt,
    @Default('') String createdAt,
    @Default(0) int reactions,
    @Default(0) int comments,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
    @JsonKey(name: 'share_count') @Default(0) int shareCount,
    @Default(0) int engagement,
    // services + events share `kind` / `id` / `title`
    @Default('') String kind,
    @Default('') String id,
    @Default('') String title,
    @Default('') String creator,
    @JsonKey(name: 'purchases_in_window') @Default(0) int purchasesInWindow,
    @JsonKey(name: 'purchase_count_total') @Default(0) int purchaseCountTotal,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'is_published') bool? isPublished,
    // events
    @Default('') String category,
    @JsonKey(name: 'event_type') @Default('') String eventType,
    @JsonKey(name: 'starts_at') String? startsAt,
    @Default('') String shop,
    @Default('') String gym,
    @JsonKey(name: 'tickets_in_window') @Default(0) int ticketsInWindow,
    @JsonKey(name: 'sold_tickets_in_window') @Default(0) int soldTicketsInWindow,
    @JsonKey(name: 'attendee_count') @Default(0) int attendeeCount,
    @JsonKey(name: 'is_cancelled') bool? isCancelled,
    // hashtags
    @Default('') String tag,
    @JsonKey(name: 'tag_id') @Default('') String tagId,
    @JsonKey(name: 'posts_in_window') @Default(0) int postsInWindow,
    @JsonKey(name: 'posts_in_previous_window') @Default(0)
    int postsInPreviousWindow,
    @Default(0) int delta,
    @JsonKey(name: 'pct_change') double? pctChange,
    @JsonKey(name: 'total_posts_ever') @Default(0) int totalPostsEver,
  }) = _TrendingItem;

  factory TrendingItem.fromJson(Map<String, dynamic> json) =>
      _$TrendingItemFromJson(json);
}

/// What a trending row is called, per kind.
///
/// The identity column differs enough across the four builders that guessing it
/// from `title`/`tag`/`post_id` would be fragile; the server already tells us
/// the kind, so the client reads it from there.
extension TrendingItemX on TrendingItem {
  static String titleFor(TrendingKind kind, TrendingItem item) => switch (kind) {
        TrendingKind.posts =>
          item.bodyExcerpt.isEmpty ? item.postId : item.bodyExcerpt,
        TrendingKind.hashtags => '#${item.tag}',
        TrendingKind.services ||
        TrendingKind.events =>
          item.title,
        TrendingKind.pages => '',
      };

  static String subtitleFor(TrendingKind kind, TrendingItem item) =>
      switch (kind) {
        TrendingKind.posts => item.authorUsername,
        TrendingKind.hashtags => item.tagId,
        TrendingKind.services =>
          '${item.kind.replaceAll('_', ' ')}'
              '${item.creator.isEmpty ? '' : ' · ${item.creator}'}',
        TrendingKind.events => item.shop.isEmpty ? item.gym : item.shop,
        TrendingKind.pages => '',
      };
}

/// `GET /portal/analytics/trending/`.
///
/// `available: false` carries a `reason` and **no items**. That pair is the
/// whole contract of the `pages` kind: an empty list would read as "no page
/// views happened", which is a different claim from "nothing emits page views",
/// and the second one is true. So [isUnavailable] is checked before [items] is
/// ever rendered.
@freezed
abstract class AnalyticsTrending with _$AnalyticsTrending {
  const factory AnalyticsTrending({
    @Default('') String kind,
    /// Defaults false: an absent `available` must not let a list through.
    @Default(false) bool available,
    @Default('') String reason,
    @Default(AnalyticsWindow()) AnalyticsWindow window,
    @JsonKey(name: 'rank_basis') @Default('') String rankBasis,
    @JsonKey(name: 'items', fromJson: _mapList)
    @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> items,
    @Default(AnalyticsTable()) AnalyticsTable table,
  }) = _AnalyticsTrending;

  factory AnalyticsTrending.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsTrendingFromJson(json);
}

extension AnalyticsTrendingX on AnalyticsTrending {
  List<TrendingItem> get parsedItems =>
      items.map(TrendingItem.fromJson).toList();

  TrendingKind get trendingKind => TrendingKind.fromWire(kind);

  /// True when the server declined to produce a list and said why.
  bool get isUnavailable => !available;

  /// Never empty when [isUnavailable] — falls back to the kind so the panel
  /// still says something true if `reason` is renamed.
  String get unavailableReason => reason.isNotEmpty
      ? reason
      : 'This trending kind has no data source, so the server returned no '
          'items. That is a missing measurement, not an empty period.';
}

// ---------------------------------------------------------------------------
// GET /ai-quality/
// ---------------------------------------------------------------------------

/// `totals{…}`.
///
/// `accuracyProxy` is named that way on purpose, here and in the UI. The
/// server's own caveat says it is corrected/calls with no ground-truth column,
/// so calling it "accuracy" would be a claim the data cannot support.
@freezed
abstract class AiQualityTotals with _$AiQualityTotals {
  const factory AiQualityTotals({
    @Default(0) int calls,
    @Default(0) int fallbacks,
    @JsonKey(name: 'fallback_rate') double? fallbackRate,
    @Default(0) int corrections,
    @JsonKey(name: 'accuracy_proxy') double? accuracyProxy,
    @JsonKey(name: 'cost_usd', fromJson: _optNumOrZero) @Default(0) num costUsd,
    @JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero)
    @Default(0)
    num costPerCallUsd,
    @JsonKey(name: 'cumulative_cost_usd', fromJson: _optNumOrZero)
    @Default(0)
    num cumulativeCostUsd,
    @JsonKey(name: 'cumulative_calls') @Default(0) int cumulativeCalls,
    @JsonKey(name: 'cumulative_cost_per_call_usd', fromJson: _optNumOrZero)
    @Default(0)
    num cumulativeCostPerCallUsd,
  }) = _AiQualityTotals;

  factory AiQualityTotals.fromJson(Map<String, dynamic> json) =>
      _$AiQualityTotalsFromJson(json);
}

/// `latency_ms{samples, sampled, sample_limit, p50, p95, min, max}`.
///
/// The percentiles are nullable and must stay so: the server routes them
/// through `_ms`, which deliberately maps "no jobs ran" to `None` rather than
/// through `_num`'s `None → 0`, because "every job took 0ms" is a lie.
@freezed
abstract class AiQualityLatency with _$AiQualityLatency {
  const factory AiQualityLatency({
    @Default(0) int samples,
    @Default(false) bool sampled,
    @JsonKey(name: 'sample_limit') @Default(0) int sampleLimit,
    @JsonKey(name: 'p50') int? p50,
    @JsonKey(name: 'p95') int? p95,
    int? min,
    int? max,
  }) = _AiQualityLatency;

  factory AiQualityLatency.fromJson(Map<String, dynamic> json) =>
      _$AiQualityLatencyFromJson(json);
}

/// One confidence histogram bucket.
@freezed
abstract class AiConfidenceBucket with _$AiConfidenceBucket {
  const factory AiConfidenceBucket({
    @Default('') String bucket,
    @JsonKey(name: 'low', fromJson: _optNumOrZero) @Default(0) num low,
    @JsonKey(name: 'high', fromJson: _optNumOrZero) @Default(0) num high,
    @Default(0) int count,
  }) = _AiConfidenceBucket;

  factory AiConfidenceBucket.fromJson(Map<String, dynamic> json) =>
      _$AiConfidenceBucketFromJson(json);
}

/// `confidence_distribution{window, with_confidence, buckets}`.
@freezed
abstract class AiConfidenceDistribution with _$AiConfidenceDistribution {
  const factory AiConfidenceDistribution({
    @Default(AnalyticsWindow()) AnalyticsWindow window,
    @JsonKey(name: 'with_confidence') @Default(0) int withConfidence,
    @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> buckets,
  }) = _AiConfidenceDistribution;

  factory AiConfidenceDistribution.fromJson(Map<String, dynamic> json) =>
      _$AiConfidenceDistributionFromJson(json);
}

extension AiConfidenceDistributionX on AiConfidenceDistribution {
  List<AiConfidenceBucket> get parsedBuckets =>
      buckets.map(AiConfidenceBucket.fromJson).toList();
}

/// One `fallback_reasons` row.
@freezed
abstract class AiFallbackReason with _$AiFallbackReason {
  const factory AiFallbackReason({
    @Default('') String reason,
    @Default(0) int count,
  }) = _AiFallbackReason;

  factory AiFallbackReason.fromJson(Map<String, dynamic> json) =>
      _$AiFallbackReasonFromJson(json);
}

/// One row of `models[]`.
@freezed
abstract class AiModelUsage with _$AiModelUsage {
  const factory AiModelUsage({
    @Default('') String model,
    @Default('') String task,
    @JsonKey(name: 'model_version') @Default('') String modelVersion,
    @Default(0) int calls,
    @Default(0) int completed,
    @Default(0) int failed,
    @JsonKey(name: 'success_rate') double? successRate,
    @Default(0) int fallbacks,
    @JsonKey(name: 'fallback_rate') double? fallbackRate,
    @Default(0) int corrections,
    @JsonKey(name: 'accuracy_proxy') double? accuracyProxy,
    @JsonKey(name: 'mean_confidence') double? meanConfidence,
    @JsonKey(name: 'cost_usd', fromJson: _optNumOrZero) @Default(0) num costUsd,
    @JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero)
    @Default(0)
    num costPerCallUsd,
  }) = _AiModelUsage;

  factory AiModelUsage.fromJson(Map<String, dynamic> json) =>
      _$AiModelUsageFromJson(json);
}

/// `GET /portal/analytics/ai-quality/`.
@freezed
abstract class AiQualityReport with _$AiQualityReport {
  const factory AiQualityReport({
    @Default(AnalyticsWindow()) AnalyticsWindow window,
    @Default(AiQualityTotals()) AiQualityTotals totals,
    @JsonKey(name: 'latency_ms') @Default(AiQualityLatency()) AiQualityLatency latency,
    @JsonKey(name: 'confidence_distribution')
    @Default(AiConfidenceDistribution())
    AiConfidenceDistribution confidenceDistribution,
    @JsonKey(name: 'fallback_reasons', fromJson: _mapList)
    @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> fallbackReasons,
    @JsonKey(name: 'models', fromJson: _mapList)
    @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> models,
    @Default(<String>[]) List<String> caveats,
    @Default(AnalyticsTable()) AnalyticsTable table,
  }) = _AiQualityReport;

  factory AiQualityReport.fromJson(Map<String, dynamic> json) =>
      _$AiQualityReportFromJson(json);
}

extension AiQualityReportX on AiQualityReport {
  List<AiModelUsage> get modelRows =>
      models.map(AiModelUsage.fromJson).toList();

  List<AiFallbackReason> get reasons =>
      fallbackReasons.map(AiFallbackReason.fromJson).toList();

  /// `sampled: true` means the percentiles came from a truncated read and the
  /// screen must say so. `sampled` is confusingly named server-side — it is
  /// `not (len(latencies) < LIMIT)`, i.e. "was the sample cut".
  bool get latencyIsSampled => latency.sampled;
}

// ---------------------------------------------------------------------------
// GET /predictive/
// ---------------------------------------------------------------------------

/// One signal row.
///
/// `observed: false` means the value is a ratio of two counted sets, not a
/// count. That is the single most important distinction on this screen, so it
/// is a first-class boolean rather than something inferred from the label.
@freezed
abstract class PredictiveSignal with _$PredictiveSignal {
  const factory PredictiveSignal({
    @Default('') String key,
    @Default('') String label,
    @Default(false) bool observed,
    @Default('') String derivation,
    @Default('') String basis,
    /// Null is meaningful: the server leaves `recommendation.impressions.ai`
    /// null on a database that cannot do JSON key lookups, and that is
    /// different from zero.
    @JsonKey(name: 'value', fromJson: _optNum) num? value,
    @Default('') String note,
  }) = _PredictiveSignal;

  factory PredictiveSignal.fromJson(Map<String, dynamic> json) =>
      _$PredictiveSignalFromJson(json);
}

extension PredictiveSignalX on PredictiveSignal {
  bool get isDerived => !observed;
}

/// `observed.recommendation_feedback` — the counted block.
@freezed
abstract class PredictiveFeedbackObserved with _$PredictiveFeedbackObserved {
  const factory PredictiveFeedbackObserved({
    @Default(AnalyticsWindow()) AnalyticsWindow window,
    @Default(0) int total,
    @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> rows,
    @Default(0) int negative,
    @Default(0) int positive,
    @Default('') String source,
  }) = _PredictiveFeedbackObserved;

  factory PredictiveFeedbackObserved.fromJson(Map<String, dynamic> json) =>
      _$PredictiveFeedbackObservedFromJson(json);
}

/// `observed.recommendation_impressions` — including the AI/fallback split,
/// which is nullable on a non-Postgres backend.
@freezed
abstract class PredictiveImpressionsObserved with _$PredictiveImpressionsObserved {
  const factory PredictiveImpressionsObserved({
    @Default(AnalyticsWindow()) AnalyticsWindow window,
    @Default(0) int total,
    int? ai,
    int? fallback,
    @Default(0) int unlabelled,
    @Default('') String source,
  }) = _PredictiveImpressionsObserved;

  factory PredictiveImpressionsObserved.fromJson(Map<String, dynamic> json) =>
      _$PredictiveImpressionsObservedFromJson(json);
}

/// `observed.ai_jobs` — null in every member when the AI app is unavailable,
/// which the server catches rather than 500-ing the report.
@freezed
abstract class PredictiveAiJobsObserved with _$PredictiveAiJobsObserved {
  const factory PredictiveAiJobsObserved({
    @Default(AnalyticsWindow()) AnalyticsWindow window,
    int? total,
    int? corrected,
    int? completed,
    @Default('') String source,
  }) = _PredictiveAiJobsObserved;

  factory PredictiveAiJobsObserved.fromJson(Map<String, dynamic> json) =>
      _$PredictiveAiJobsObservedFromJson(json);
}

/// The `observed` block, keyed by section.
///
/// A named type per section rather than one map, because the three shapes are
/// unrelated and the screen reads all three differently.
@freezed
abstract class PredictiveObserved with _$PredictiveObserved {
  const factory PredictiveObserved({
    @JsonKey(name: 'recommendation_feedback')
    @Default(PredictiveFeedbackObserved())
    PredictiveFeedbackObserved recommendationFeedback,
    @JsonKey(name: 'recommendation_impressions')
    @Default(PredictiveImpressionsObserved())
    PredictiveImpressionsObserved recommendationImpressions,
    @JsonKey(name: 'ai_jobs')
    @Default(PredictiveAiJobsObserved())
    PredictiveAiJobsObserved aiJobs,
  }) = _PredictiveObserved;

  factory PredictiveObserved.fromJson(Map<String, dynamic> json) =>
      _$PredictiveObservedFromJson(json);
}

/// `GET /portal/analytics/predictive/`.
///
/// The `disclaimer` is rendered above the signals, every time, not folded into
/// a tooltip: it says the endpoint does not forecast, and the fastest way to
/// make that false is for someone to read the numbers as a forecast.
@freezed
abstract class PredictiveReport with _$PredictiveReport {
  const factory PredictiveReport({
    @Default(AnalyticsWindow()) AnalyticsWindow window,
    @Default('') String disclaimer,
    @JsonKey(name: 'signals', fromJson: _mapList)
    @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> signals,
    @Default(PredictiveObserved()) PredictiveObserved observed,
    @Default(AnalyticsTable()) AnalyticsTable table,
  }) = _PredictiveReport;

  factory PredictiveReport.fromJson(Map<String, dynamic> json) =>
      _$PredictiveReportFromJson(json);
}

extension PredictiveReportX on PredictiveReport {
  List<PredictiveSignal> get parsedSignals =>
      signals.map(PredictiveSignal.fromJson).toList();

  /// Never empty, for the same reason as `AnalyticsTrending.unavailableReason`:
  /// a missing disclaimer would leave the page making an uncaveated claim.
  String get disclaimerText => disclaimer.isNotEmpty
      ? disclaimer
      : 'This endpoint reports observed signals only. It does not forecast.';
}