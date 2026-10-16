// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnalyticsWindow _$AnalyticsWindowFromJson(Map<String, dynamic> json) =>
    _AnalyticsWindow(
      fromDate: json['from'] as String? ?? '',
      toDate: json['to'] as String? ?? '',
      days: (json['days'] as num?)?.toInt() ?? 0,
      basis: json['basis'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );

Map<String, dynamic> _$AnalyticsWindowToJson(_AnalyticsWindow instance) =>
    <String, dynamic>{
      'from': instance.fromDate,
      'to': instance.toDate,
      'days': instance.days,
      'basis': instance.basis,
      'timezone': instance.timezone,
      'label': instance.label,
    };

_AnalyticsTable _$AnalyticsTableFromJson(Map<String, dynamic> json) =>
    _AnalyticsTable(
      columns:
          (json['columns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      rows: json['rows'] == null
          ? const <List<Object?>>[]
          : _tableRows(json['rows']),
    );

Map<String, dynamic> _$AnalyticsTableToJson(_AnalyticsTable instance) =>
    <String, dynamic>{'columns': instance.columns, 'rows': instance.rows};

_AnalyticsKpi _$AnalyticsKpiFromJson(Map<String, dynamic> json) =>
    _AnalyticsKpi(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      group: json['group'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      value: json['value'] == null ? 0 : _optNumOrZero(json['value']),
      kind: json['kind'] as String? ?? 'gauge',
      window: json['window'] == null
          ? const AnalyticsWindow()
          : AnalyticsWindow.fromJson(json['window'] as Map<String, dynamic>),
      source: json['source'] as String? ?? '',
      indexed: json['indexed'] as bool? ?? true,
      note: json['note'] as String? ?? '',
      sourceCount: (json['source_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AnalyticsKpiToJson(_AnalyticsKpi instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'group': instance.group,
      'unit': instance.unit,
      'value': instance.value,
      'kind': instance.kind,
      'window': instance.window,
      'source': instance.source,
      'indexed': instance.indexed,
      'note': instance.note,
      'source_count': instance.sourceCount,
    };

_AnalyticsPerformanceNote _$AnalyticsPerformanceNoteFromJson(
  Map<String, dynamic> json,
) => _AnalyticsPerformanceNote(
  source: json['source'] as String? ?? '',
  issue: json['issue'] as String? ?? '',
  suggestedMigration: json['suggested_migration'] as String? ?? '',
  owner: json['owner'] as String? ?? '',
);

Map<String, dynamic> _$AnalyticsPerformanceNoteToJson(
  _AnalyticsPerformanceNote instance,
) => <String, dynamic>{
  'source': instance.source,
  'issue': instance.issue,
  'suggested_migration': instance.suggestedMigration,
  'owner': instance.owner,
};

_AnalyticsBreakdown _$AnalyticsBreakdownFromJson(Map<String, dynamic> json) =>
    _AnalyticsBreakdown(
      title: json['title'] as String? ?? '',
      window: json['window'] == null
          ? const AnalyticsWindow()
          : AnalyticsWindow.fromJson(json['window'] as Map<String, dynamic>),
      basis: json['basis'] as String? ?? '',
      note: json['note'] as String? ?? '',
      rows: json['rows'] == null
          ? const <Map<String, dynamic>>[]
          : _mapList(json['rows']),
    );

Map<String, dynamic> _$AnalyticsBreakdownToJson(_AnalyticsBreakdown instance) =>
    <String, dynamic>{
      'title': instance.title,
      'window': instance.window,
      'basis': instance.basis,
      'note': instance.note,
      'rows': instance.rows,
    };

_AnalyticsOverview _$AnalyticsOverviewFromJson(Map<String, dynamic> json) =>
    _AnalyticsOverview(
      window: json['window'] == null
          ? const AnalyticsWindow()
          : AnalyticsWindow.fromJson(json['window'] as Map<String, dynamic>),
      generatedAt: json['generated_at'] as String? ?? '',
      kpis: json['kpis'] == null
          ? const <Map<String, dynamic>>[]
          : _mapList(json['kpis']),
      breakdowns: json['breakdowns'] == null
          ? const <Map<String, dynamic>>[]
          : _mapList(json['breakdowns']),
      groups:
          (json['groups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      performanceNotes: json['performance_notes'] == null
          ? const <Map<String, dynamic>>[]
          : _mapList(json['performance_notes']),
      table: json['table'] == null
          ? const AnalyticsTable()
          : AnalyticsTable.fromJson(json['table'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnalyticsOverviewToJson(_AnalyticsOverview instance) =>
    <String, dynamic>{
      'window': instance.window,
      'generated_at': instance.generatedAt,
      'kpis': instance.kpis,
      'breakdowns': instance.breakdowns,
      'groups': instance.groups,
      'performance_notes': instance.performanceNotes,
      'table': instance.table,
    };

_AnalyticsMetric _$AnalyticsMetricFromJson(Map<String, dynamic> json) =>
    _AnalyticsMetric(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      group: json['group'] as String? ?? '',
      source: json['source'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$AnalyticsMetricToJson(_AnalyticsMetric instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'unit': instance.unit,
      'group': instance.group,
      'source': instance.source,
      'description': instance.description,
    };

_AnalyticsBucket _$AnalyticsBucketFromJson(Map<String, dynamic> json) =>
    _AnalyticsBucket(
      bucket: json['bucket'] as String? ?? '',
      value: json['value'] == null ? 0 : _optNumOrZero(json['value']),
    );

Map<String, dynamic> _$AnalyticsBucketToJson(_AnalyticsBucket instance) =>
    <String, dynamic>{'bucket': instance.bucket, 'value': instance.value};

_AnalyticsTotals _$AnalyticsTotalsFromJson(Map<String, dynamic> json) =>
    _AnalyticsTotals(
      sum: json['sum'] == null ? 0 : _optNumOrZero(json['sum']),
      nonZeroBuckets: json['non_zero_buckets'] == null
          ? 0
          : _optNumOrZero(json['non_zero_buckets']),
    );

Map<String, dynamic> _$AnalyticsTotalsToJson(_AnalyticsTotals instance) =>
    <String, dynamic>{
      'sum': instance.sum,
      'non_zero_buckets': instance.nonZeroBuckets,
    };

_AnalyticsDataSource _$AnalyticsDataSourceFromJson(Map<String, dynamic> json) =>
    _AnalyticsDataSource(
      path: json['path'] as String? ?? '',
      rollupComplete: json['rollup_complete'] as bool? ?? false,
      missingDays: json['missing_days'] == null
          ? const <String>[]
          : _stringList(json['missing_days']),
      note: json['note'] as String? ?? '',
    );

Map<String, dynamic> _$AnalyticsDataSourceToJson(
  _AnalyticsDataSource instance,
) => <String, dynamic>{
  'path': instance.path,
  'rollup_complete': instance.rollupComplete,
  'missing_days': instance.missingDays,
  'note': instance.note,
};

_AnalyticsMetricCatalogueEntry _$AnalyticsMetricCatalogueEntryFromJson(
  Map<String, dynamic> json,
) => _AnalyticsMetricCatalogueEntry(
  key: json['key'] as String? ?? '',
  label: json['label'] as String? ?? '',
  group: json['group'] as String? ?? '',
  unit: json['unit'] as String? ?? '',
  additive: json['additive'] as bool? ?? true,
  windowed: json['windowed'] as bool? ?? true,
  source: json['source'] as String? ?? '',
  description: json['description'] as String? ?? '',
);

Map<String, dynamic> _$AnalyticsMetricCatalogueEntryToJson(
  _AnalyticsMetricCatalogueEntry instance,
) => <String, dynamic>{
  'key': instance.key,
  'label': instance.label,
  'group': instance.group,
  'unit': instance.unit,
  'additive': instance.additive,
  'windowed': instance.windowed,
  'source': instance.source,
  'description': instance.description,
};

_AnalyticsTimeseries _$AnalyticsTimeseriesFromJson(Map<String, dynamic> json) =>
    _AnalyticsTimeseries(
      window: json['window'] == null
          ? const AnalyticsWindow()
          : AnalyticsWindow.fromJson(json['window'] as Map<String, dynamic>),
      metric: json['metric'] == null
          ? const AnalyticsMetric()
          : AnalyticsMetric.fromJson(json['metric'] as Map<String, dynamic>),
      granularity: json['granularity'] as String? ?? 'day',
      series: json['series'] == null
          ? const <Map<String, dynamic>>[]
          : _mapList(json['series']),
      totals: json['totals'] == null
          ? const AnalyticsTotals()
          : AnalyticsTotals.fromJson(json['totals'] as Map<String, dynamic>),
      dataSource: json['data_source'] == null
          ? null
          : AnalyticsDataSource.fromJson(
              json['data_source'] as Map<String, dynamic>,
            ),
      availableMetrics: json['available_metrics'] == null
          ? const <String>[]
          : _stringList(json['available_metrics']),
      metricCatalogue: json['metric_catalogue'] == null
          ? const <Map<String, dynamic>>[]
          : _mapList(json['metric_catalogue']),
      table: json['table'] == null
          ? const AnalyticsTable()
          : AnalyticsTable.fromJson(json['table'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnalyticsTimeseriesToJson(
  _AnalyticsTimeseries instance,
) => <String, dynamic>{
  'window': instance.window,
  'metric': instance.metric,
  'granularity': instance.granularity,
  'series': instance.series,
  'totals': instance.totals,
  'data_source': instance.dataSource,
  'available_metrics': instance.availableMetrics,
  'metric_catalogue': instance.metricCatalogue,
  'table': instance.table,
};

_TrendingItem _$TrendingItemFromJson(Map<String, dynamic> json) =>
    _TrendingItem(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      postId: json['post_id'] as String? ?? '',
      authorUsername: json['author_username'] as String? ?? '',
      postType: json['post_type'] as String? ?? '',
      bodyExcerpt: json['body_excerpt'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      reactions: (json['reactions'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      shareCount: (json['share_count'] as num?)?.toInt() ?? 0,
      engagement: (json['engagement'] as num?)?.toInt() ?? 0,
      kind: json['kind'] as String? ?? '',
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      creator: json['creator'] as String? ?? '',
      purchasesInWindow: (json['purchases_in_window'] as num?)?.toInt() ?? 0,
      purchaseCountTotal: (json['purchase_count_total'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      reviewCount: (json['review_count'] as num?)?.toInt(),
      isPublished: json['is_published'] as bool?,
      category: json['category'] as String? ?? '',
      eventType: json['event_type'] as String? ?? '',
      startsAt: json['starts_at'] as String?,
      shop: json['shop'] as String? ?? '',
      gym: json['gym'] as String? ?? '',
      ticketsInWindow: (json['tickets_in_window'] as num?)?.toInt() ?? 0,
      soldTicketsInWindow:
          (json['sold_tickets_in_window'] as num?)?.toInt() ?? 0,
      attendeeCount: (json['attendee_count'] as num?)?.toInt() ?? 0,
      isCancelled: json['is_cancelled'] as bool?,
      tag: json['tag'] as String? ?? '',
      tagId: json['tag_id'] as String? ?? '',
      postsInWindow: (json['posts_in_window'] as num?)?.toInt() ?? 0,
      postsInPreviousWindow:
          (json['posts_in_previous_window'] as num?)?.toInt() ?? 0,
      delta: (json['delta'] as num?)?.toInt() ?? 0,
      pctChange: (json['pct_change'] as num?)?.toDouble(),
      totalPostsEver: (json['total_posts_ever'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TrendingItemToJson(_TrendingItem instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'post_id': instance.postId,
      'author_username': instance.authorUsername,
      'post_type': instance.postType,
      'body_excerpt': instance.bodyExcerpt,
      'createdAt': instance.createdAt,
      'reactions': instance.reactions,
      'comments': instance.comments,
      'view_count': instance.viewCount,
      'share_count': instance.shareCount,
      'engagement': instance.engagement,
      'kind': instance.kind,
      'id': instance.id,
      'title': instance.title,
      'creator': instance.creator,
      'purchases_in_window': instance.purchasesInWindow,
      'purchase_count_total': instance.purchaseCountTotal,
      'average_rating': instance.averageRating,
      'review_count': instance.reviewCount,
      'is_published': instance.isPublished,
      'category': instance.category,
      'event_type': instance.eventType,
      'starts_at': instance.startsAt,
      'shop': instance.shop,
      'gym': instance.gym,
      'tickets_in_window': instance.ticketsInWindow,
      'sold_tickets_in_window': instance.soldTicketsInWindow,
      'attendee_count': instance.attendeeCount,
      'is_cancelled': instance.isCancelled,
      'tag': instance.tag,
      'tag_id': instance.tagId,
      'posts_in_window': instance.postsInWindow,
      'posts_in_previous_window': instance.postsInPreviousWindow,
      'delta': instance.delta,
      'pct_change': instance.pctChange,
      'total_posts_ever': instance.totalPostsEver,
    };

_AnalyticsTrending _$AnalyticsTrendingFromJson(Map<String, dynamic> json) =>
    _AnalyticsTrending(
      kind: json['kind'] as String? ?? '',
      available: json['available'] as bool? ?? false,
      reason: json['reason'] as String? ?? '',
      window: json['window'] == null
          ? const AnalyticsWindow()
          : AnalyticsWindow.fromJson(json['window'] as Map<String, dynamic>),
      rankBasis: json['rank_basis'] as String? ?? '',
      items: json['items'] == null
          ? const <Map<String, dynamic>>[]
          : _mapList(json['items']),
      table: json['table'] == null
          ? const AnalyticsTable()
          : AnalyticsTable.fromJson(json['table'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnalyticsTrendingToJson(_AnalyticsTrending instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'available': instance.available,
      'reason': instance.reason,
      'window': instance.window,
      'rank_basis': instance.rankBasis,
      'items': instance.items,
      'table': instance.table,
    };

_AiQualityTotals _$AiQualityTotalsFromJson(Map<String, dynamic> json) =>
    _AiQualityTotals(
      calls: (json['calls'] as num?)?.toInt() ?? 0,
      fallbacks: (json['fallbacks'] as num?)?.toInt() ?? 0,
      fallbackRate: (json['fallback_rate'] as num?)?.toDouble(),
      corrections: (json['corrections'] as num?)?.toInt() ?? 0,
      accuracyProxy: (json['accuracy_proxy'] as num?)?.toDouble(),
      costUsd: json['cost_usd'] == null ? 0 : _optNumOrZero(json['cost_usd']),
      costPerCallUsd: json['cost_per_call_usd'] == null
          ? 0
          : _optNumOrZero(json['cost_per_call_usd']),
      cumulativeCostUsd: json['cumulative_cost_usd'] == null
          ? 0
          : _optNumOrZero(json['cumulative_cost_usd']),
      cumulativeCalls: (json['cumulative_calls'] as num?)?.toInt() ?? 0,
      cumulativeCostPerCallUsd: json['cumulative_cost_per_call_usd'] == null
          ? 0
          : _optNumOrZero(json['cumulative_cost_per_call_usd']),
    );

Map<String, dynamic> _$AiQualityTotalsToJson(_AiQualityTotals instance) =>
    <String, dynamic>{
      'calls': instance.calls,
      'fallbacks': instance.fallbacks,
      'fallback_rate': instance.fallbackRate,
      'corrections': instance.corrections,
      'accuracy_proxy': instance.accuracyProxy,
      'cost_usd': instance.costUsd,
      'cost_per_call_usd': instance.costPerCallUsd,
      'cumulative_cost_usd': instance.cumulativeCostUsd,
      'cumulative_calls': instance.cumulativeCalls,
      'cumulative_cost_per_call_usd': instance.cumulativeCostPerCallUsd,
    };

_AiQualityLatency _$AiQualityLatencyFromJson(Map<String, dynamic> json) =>
    _AiQualityLatency(
      samples: (json['samples'] as num?)?.toInt() ?? 0,
      sampled: json['sampled'] as bool? ?? false,
      sampleLimit: (json['sample_limit'] as num?)?.toInt() ?? 0,
      p50: (json['p50'] as num?)?.toInt(),
      p95: (json['p95'] as num?)?.toInt(),
      min: (json['min'] as num?)?.toInt(),
      max: (json['max'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AiQualityLatencyToJson(_AiQualityLatency instance) =>
    <String, dynamic>{
      'samples': instance.samples,
      'sampled': instance.sampled,
      'sample_limit': instance.sampleLimit,
      'p50': instance.p50,
      'p95': instance.p95,
      'min': instance.min,
      'max': instance.max,
    };

_AiConfidenceBucket _$AiConfidenceBucketFromJson(Map<String, dynamic> json) =>
    _AiConfidenceBucket(
      bucket: json['bucket'] as String? ?? '',
      low: json['low'] == null ? 0 : _optNumOrZero(json['low']),
      high: json['high'] == null ? 0 : _optNumOrZero(json['high']),
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AiConfidenceBucketToJson(_AiConfidenceBucket instance) =>
    <String, dynamic>{
      'bucket': instance.bucket,
      'low': instance.low,
      'high': instance.high,
      'count': instance.count,
    };

_AiConfidenceDistribution _$AiConfidenceDistributionFromJson(
  Map<String, dynamic> json,
) => _AiConfidenceDistribution(
  window: json['window'] == null
      ? const AnalyticsWindow()
      : AnalyticsWindow.fromJson(json['window'] as Map<String, dynamic>),
  withConfidence: (json['with_confidence'] as num?)?.toInt() ?? 0,
  buckets:
      (json['buckets'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <Map<String, dynamic>>[],
);

Map<String, dynamic> _$AiConfidenceDistributionToJson(
  _AiConfidenceDistribution instance,
) => <String, dynamic>{
  'window': instance.window,
  'with_confidence': instance.withConfidence,
  'buckets': instance.buckets,
};

_AiFallbackReason _$AiFallbackReasonFromJson(Map<String, dynamic> json) =>
    _AiFallbackReason(
      reason: json['reason'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AiFallbackReasonToJson(_AiFallbackReason instance) =>
    <String, dynamic>{'reason': instance.reason, 'count': instance.count};

_AiModelUsage _$AiModelUsageFromJson(Map<String, dynamic> json) =>
    _AiModelUsage(
      model: json['model'] as String? ?? '',
      task: json['task'] as String? ?? '',
      modelVersion: json['model_version'] as String? ?? '',
      calls: (json['calls'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      failed: (json['failed'] as num?)?.toInt() ?? 0,
      successRate: (json['success_rate'] as num?)?.toDouble(),
      fallbacks: (json['fallbacks'] as num?)?.toInt() ?? 0,
      fallbackRate: (json['fallback_rate'] as num?)?.toDouble(),
      corrections: (json['corrections'] as num?)?.toInt() ?? 0,
      accuracyProxy: (json['accuracy_proxy'] as num?)?.toDouble(),
      meanConfidence: (json['mean_confidence'] as num?)?.toDouble(),
      costUsd: json['cost_usd'] == null ? 0 : _optNumOrZero(json['cost_usd']),
      costPerCallUsd: json['cost_per_call_usd'] == null
          ? 0
          : _optNumOrZero(json['cost_per_call_usd']),
    );

Map<String, dynamic> _$AiModelUsageToJson(_AiModelUsage instance) =>
    <String, dynamic>{
      'model': instance.model,
      'task': instance.task,
      'model_version': instance.modelVersion,
      'calls': instance.calls,
      'completed': instance.completed,
      'failed': instance.failed,
      'success_rate': instance.successRate,
      'fallbacks': instance.fallbacks,
      'fallback_rate': instance.fallbackRate,
      'corrections': instance.corrections,
      'accuracy_proxy': instance.accuracyProxy,
      'mean_confidence': instance.meanConfidence,
      'cost_usd': instance.costUsd,
      'cost_per_call_usd': instance.costPerCallUsd,
    };

_AiQualityReport _$AiQualityReportFromJson(
  Map<String, dynamic> json,
) => _AiQualityReport(
  window: json['window'] == null
      ? const AnalyticsWindow()
      : AnalyticsWindow.fromJson(json['window'] as Map<String, dynamic>),
  totals: json['totals'] == null
      ? const AiQualityTotals()
      : AiQualityTotals.fromJson(json['totals'] as Map<String, dynamic>),
  latency: json['latency_ms'] == null
      ? const AiQualityLatency()
      : AiQualityLatency.fromJson(json['latency_ms'] as Map<String, dynamic>),
  confidenceDistribution: json['confidence_distribution'] == null
      ? const AiConfidenceDistribution()
      : AiConfidenceDistribution.fromJson(
          json['confidence_distribution'] as Map<String, dynamic>,
        ),
  fallbackReasons: json['fallback_reasons'] == null
      ? const <Map<String, dynamic>>[]
      : _mapList(json['fallback_reasons']),
  models: json['models'] == null
      ? const <Map<String, dynamic>>[]
      : _mapList(json['models']),
  caveats:
      (json['caveats'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  table: json['table'] == null
      ? const AnalyticsTable()
      : AnalyticsTable.fromJson(json['table'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AiQualityReportToJson(_AiQualityReport instance) =>
    <String, dynamic>{
      'window': instance.window,
      'totals': instance.totals,
      'latency_ms': instance.latency,
      'confidence_distribution': instance.confidenceDistribution,
      'fallback_reasons': instance.fallbackReasons,
      'models': instance.models,
      'caveats': instance.caveats,
      'table': instance.table,
    };

_PredictiveSignal _$PredictiveSignalFromJson(Map<String, dynamic> json) =>
    _PredictiveSignal(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      observed: json['observed'] as bool? ?? false,
      derivation: json['derivation'] as String? ?? '',
      basis: json['basis'] as String? ?? '',
      value: _optNum(json['value']),
      note: json['note'] as String? ?? '',
    );

Map<String, dynamic> _$PredictiveSignalToJson(_PredictiveSignal instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'observed': instance.observed,
      'derivation': instance.derivation,
      'basis': instance.basis,
      'value': instance.value,
      'note': instance.note,
    };

_PredictiveFeedbackObserved _$PredictiveFeedbackObservedFromJson(
  Map<String, dynamic> json,
) => _PredictiveFeedbackObserved(
  window: json['window'] == null
      ? const AnalyticsWindow()
      : AnalyticsWindow.fromJson(json['window'] as Map<String, dynamic>),
  total: (json['total'] as num?)?.toInt() ?? 0,
  rows:
      (json['rows'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <Map<String, dynamic>>[],
  negative: (json['negative'] as num?)?.toInt() ?? 0,
  positive: (json['positive'] as num?)?.toInt() ?? 0,
  source: json['source'] as String? ?? '',
);

Map<String, dynamic> _$PredictiveFeedbackObservedToJson(
  _PredictiveFeedbackObserved instance,
) => <String, dynamic>{
  'window': instance.window,
  'total': instance.total,
  'rows': instance.rows,
  'negative': instance.negative,
  'positive': instance.positive,
  'source': instance.source,
};

_PredictiveImpressionsObserved _$PredictiveImpressionsObservedFromJson(
  Map<String, dynamic> json,
) => _PredictiveImpressionsObserved(
  window: json['window'] == null
      ? const AnalyticsWindow()
      : AnalyticsWindow.fromJson(json['window'] as Map<String, dynamic>),
  total: (json['total'] as num?)?.toInt() ?? 0,
  ai: (json['ai'] as num?)?.toInt(),
  fallback: (json['fallback'] as num?)?.toInt(),
  unlabelled: (json['unlabelled'] as num?)?.toInt() ?? 0,
  source: json['source'] as String? ?? '',
);

Map<String, dynamic> _$PredictiveImpressionsObservedToJson(
  _PredictiveImpressionsObserved instance,
) => <String, dynamic>{
  'window': instance.window,
  'total': instance.total,
  'ai': instance.ai,
  'fallback': instance.fallback,
  'unlabelled': instance.unlabelled,
  'source': instance.source,
};

_PredictiveAiJobsObserved _$PredictiveAiJobsObservedFromJson(
  Map<String, dynamic> json,
) => _PredictiveAiJobsObserved(
  window: json['window'] == null
      ? const AnalyticsWindow()
      : AnalyticsWindow.fromJson(json['window'] as Map<String, dynamic>),
  total: (json['total'] as num?)?.toInt(),
  corrected: (json['corrected'] as num?)?.toInt(),
  completed: (json['completed'] as num?)?.toInt(),
  source: json['source'] as String? ?? '',
);

Map<String, dynamic> _$PredictiveAiJobsObservedToJson(
  _PredictiveAiJobsObserved instance,
) => <String, dynamic>{
  'window': instance.window,
  'total': instance.total,
  'corrected': instance.corrected,
  'completed': instance.completed,
  'source': instance.source,
};

_PredictiveObserved _$PredictiveObservedFromJson(Map<String, dynamic> json) =>
    _PredictiveObserved(
      recommendationFeedback: json['recommendation_feedback'] == null
          ? const PredictiveFeedbackObserved()
          : PredictiveFeedbackObserved.fromJson(
              json['recommendation_feedback'] as Map<String, dynamic>,
            ),
      recommendationImpressions: json['recommendation_impressions'] == null
          ? const PredictiveImpressionsObserved()
          : PredictiveImpressionsObserved.fromJson(
              json['recommendation_impressions'] as Map<String, dynamic>,
            ),
      aiJobs: json['ai_jobs'] == null
          ? const PredictiveAiJobsObserved()
          : PredictiveAiJobsObserved.fromJson(
              json['ai_jobs'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PredictiveObservedToJson(_PredictiveObserved instance) =>
    <String, dynamic>{
      'recommendation_feedback': instance.recommendationFeedback,
      'recommendation_impressions': instance.recommendationImpressions,
      'ai_jobs': instance.aiJobs,
    };

_PredictiveReport _$PredictiveReportFromJson(Map<String, dynamic> json) =>
    _PredictiveReport(
      window: json['window'] == null
          ? const AnalyticsWindow()
          : AnalyticsWindow.fromJson(json['window'] as Map<String, dynamic>),
      disclaimer: json['disclaimer'] as String? ?? '',
      signals: json['signals'] == null
          ? const <Map<String, dynamic>>[]
          : _mapList(json['signals']),
      observed: json['observed'] == null
          ? const PredictiveObserved()
          : PredictiveObserved.fromJson(
              json['observed'] as Map<String, dynamic>,
            ),
      table: json['table'] == null
          ? const AnalyticsTable()
          : AnalyticsTable.fromJson(json['table'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PredictiveReportToJson(_PredictiveReport instance) =>
    <String, dynamic>{
      'window': instance.window,
      'disclaimer': instance.disclaimer,
      'signals': instance.signals,
      'observed': instance.observed,
      'table': instance.table,
    };
