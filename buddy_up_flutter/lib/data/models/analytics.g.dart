// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnalyticsUserInfo _$AnalyticsUserInfoFromJson(Map<String, dynamic> json) =>
    _AnalyticsUserInfo(
      username: json['username'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AnalyticsUserInfoToJson(_AnalyticsUserInfo instance) =>
    <String, dynamic>{
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'streak_days': instance.streakDays,
    };

_ActivityTypeBreakdown _$ActivityTypeBreakdownFromJson(
  Map<String, dynamic> json,
) => _ActivityTypeBreakdown(
  label: json['label'] as String? ?? '',
  count: (json['count'] as num?)?.toInt() ?? 0,
  calories: (json['calories'] as num?)?.toDouble() ?? 0,
  distance: (json['distance'] as num?)?.toDouble() ?? 0,
  duration: (json['duration'] as num?)?.toDouble() ?? 0,
  distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$ActivityTypeBreakdownToJson(
  _ActivityTypeBreakdown instance,
) => <String, dynamic>{
  'label': instance.label,
  'count': instance.count,
  'calories': instance.calories,
  'distance': instance.distance,
  'duration': instance.duration,
  'distance_km': instance.distanceKm,
};

_WorkoutRecent _$WorkoutRecentFromJson(Map<String, dynamic> json) =>
    _WorkoutRecent(
      performedAt: json['performed_at'] as String?,
      workoutType: json['workout_type'] as String? ?? '',
      exercise: json['exercise'] as String? ?? '',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      caloriesBurned: (json['calories_burned'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$WorkoutRecentToJson(_WorkoutRecent instance) =>
    <String, dynamic>{
      'performed_at': instance.performedAt,
      'workout_type': instance.workoutType,
      'exercise': instance.exercise,
      'duration_minutes': instance.durationMinutes,
      'calories_burned': instance.caloriesBurned,
    };

_WorkoutSummary _$WorkoutSummaryFromJson(Map<String, dynamic> json) =>
    _WorkoutSummary(
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalCaloriesBurned:
          (json['total_calories_burned'] as num?)?.toDouble() ?? 0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0,
      byType:
          (json['by_type'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ActivityTypeBreakdown.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ActivityTypeBreakdown>[],
      mostTrained: json['most_trained'] as String?,
      recent:
          (json['recent'] as List<dynamic>?)
              ?.map((e) => WorkoutRecent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <WorkoutRecent>[],
    );

Map<String, dynamic> _$WorkoutSummaryToJson(_WorkoutSummary instance) =>
    <String, dynamic>{
      'count': instance.count,
      'total_calories_burned': instance.totalCaloriesBurned,
      'total_volume': instance.totalVolume,
      'by_type': instance.byType,
      'most_trained': instance.mostTrained,
      'recent': instance.recent,
    };

_ActivityRecent _$ActivityRecentFromJson(Map<String, dynamic> json) =>
    _ActivityRecent(
      id: json['id'] as String? ?? '',
      activityType: json['activity_type'] as String? ?? '',
      startedAt: json['started_at'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
      avgPace: (json['avg_pace'] as num?)?.toDouble(),
      caloriesBurned: (json['calories_burned'] as num?)?.toDouble(),
      steps: (json['steps'] as num?)?.toInt() ?? 0,
      route: json['route'] as List<dynamic>? ?? const <dynamic>[],
    );

Map<String, dynamic> _$ActivityRecentToJson(_ActivityRecent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activity_type': instance.activityType,
      'started_at': instance.startedAt,
      'duration_seconds': instance.durationSeconds,
      'distance_meters': instance.distanceMeters,
      'distance_km': instance.distanceKm,
      'avg_pace': instance.avgPace,
      'calories_burned': instance.caloriesBurned,
      'steps': instance.steps,
      'route': instance.route,
    };

_ActivitySummary _$ActivitySummaryFromJson(
  Map<String, dynamic> json,
) => _ActivitySummary(
  count: (json['count'] as num?)?.toInt() ?? 0,
  totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble() ?? 0,
  totalDurationSeconds: (json['total_duration_seconds'] as num?)?.toInt() ?? 0,
  totalCaloriesBurned: (json['total_calories_burned'] as num?)?.toDouble() ?? 0,
  totalSteps: (json['total_steps'] as num?)?.toInt() ?? 0,
  avgPace: (json['avg_pace'] as num?)?.toDouble(),
  byType:
      (json['by_type'] as List<dynamic>?)
          ?.map(
            (e) => ActivityTypeBreakdown.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ActivityTypeBreakdown>[],
  recent:
      (json['recent'] as List<dynamic>?)
          ?.map((e) => ActivityRecent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ActivityRecent>[],
);

Map<String, dynamic> _$ActivitySummaryToJson(_ActivitySummary instance) =>
    <String, dynamic>{
      'count': instance.count,
      'total_distance_km': instance.totalDistanceKm,
      'total_duration_seconds': instance.totalDurationSeconds,
      'total_calories_burned': instance.totalCaloriesBurned,
      'total_steps': instance.totalSteps,
      'avg_pace': instance.avgPace,
      'by_type': instance.byType,
      'recent': instance.recent,
    };

_BodySeriesPoint _$BodySeriesPointFromJson(Map<String, dynamic> json) =>
    _BodySeriesPoint(
      id: json['id'] as String? ?? '',
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0,
      bodyFatPct: (json['body_fat_pct'] as num?)?.toDouble(),
      measuredAt: json['measured_at'] as String?,
      photoUrl: json['photo_url'] as String? ?? '',
      scalePhotoUrl: json['scale_photo_url'] as String? ?? '',
    );

Map<String, dynamic> _$BodySeriesPointToJson(_BodySeriesPoint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'weight_kg': instance.weightKg,
      'body_fat_pct': instance.bodyFatPct,
      'measured_at': instance.measuredAt,
      'photo_url': instance.photoUrl,
      'scale_photo_url': instance.scalePhotoUrl,
    };

_BodySummary _$BodySummaryFromJson(Map<String, dynamic> json) => _BodySummary(
  count: (json['count'] as num?)?.toInt() ?? 0,
  startWeightKg: (json['start_weight_kg'] as num?)?.toDouble(),
  latestWeightKg: (json['latest_weight_kg'] as num?)?.toDouble(),
  weightChangeKg: (json['weight_change_kg'] as num?)?.toDouble(),
  latestBodyFatPct: (json['latest_body_fat_pct'] as num?)?.toDouble(),
  series:
      (json['series'] as List<dynamic>?)
          ?.map((e) => BodySeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <BodySeriesPoint>[],
);

Map<String, dynamic> _$BodySummaryToJson(_BodySummary instance) =>
    <String, dynamic>{
      'count': instance.count,
      'start_weight_kg': instance.startWeightKg,
      'latest_weight_kg': instance.latestWeightKg,
      'weight_change_kg': instance.weightChangeKg,
      'latest_body_fat_pct': instance.latestBodyFatPct,
      'series': instance.series,
    };

_LivesSummary _$LivesSummaryFromJson(Map<String, dynamic> json) =>
    _LivesSummary(
      joinedCount: (json['joined_count'] as num?)?.toInt() ?? 0,
      totalDurationSeconds:
          (json['total_duration_seconds'] as num?)?.toInt() ?? 0,
      byType:
          (json['by_type'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ActivityTypeBreakdown.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ActivityTypeBreakdown>[],
    );

Map<String, dynamic> _$LivesSummaryToJson(_LivesSummary instance) =>
    <String, dynamic>{
      'joined_count': instance.joinedCount,
      'total_duration_seconds': instance.totalDurationSeconds,
      'by_type': instance.byType,
    };

_SpendingCategory _$SpendingCategoryFromJson(Map<String, dynamic> json) =>
    _SpendingCategory(
      category: json['category'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
    );

Map<String, dynamic> _$SpendingCategoryToJson(_SpendingCategory instance) =>
    <String, dynamic>{
      'category': instance.category,
      'quantity': instance.quantity,
      'count': instance.count,
      'label': instance.label,
    };

_SpendingSummary _$SpendingSummaryFromJson(
  Map<String, dynamic> json,
) => _SpendingSummary(
  giftsSent: json['gifts_sent'] == null
      ? const SpendingCategory()
      : SpendingCategory.fromJson(json['gifts_sent'] as Map<String, dynamic>),
  giftsReceived: json['gifts_received'] == null
      ? const SpendingCategory()
      : SpendingCategory.fromJson(
          json['gifts_received'] as Map<String, dynamic>,
        ),
  tipsSent: json['tips_sent'] == null
      ? const SpendingCategory()
      : SpendingCategory.fromJson(json['tips_sent'] as Map<String, dynamic>),
  tipsReceived: json['tips_received'] == null
      ? const SpendingCategory()
      : SpendingCategory.fromJson(
          json['tips_received'] as Map<String, dynamic>,
        ),
  liveFees: json['live_fees'] == null
      ? const SpendingCategory()
      : SpendingCategory.fromJson(json['live_fees'] as Map<String, dynamic>),
  gymSubscriptions: json['gym_subscriptions'] == null
      ? const SpendingCategory()
      : SpendingCategory.fromJson(
          json['gym_subscriptions'] as Map<String, dynamic>,
        ),
  sessionFees: json['session_fees'] == null
      ? const SpendingCategory()
      : SpendingCategory.fromJson(json['session_fees'] as Map<String, dynamic>),
  marketplaceSpend: json['marketplace_spend'] == null
      ? const SpendingCategory()
      : SpendingCategory.fromJson(
          json['marketplace_spend'] as Map<String, dynamic>,
        ),
  totalTransactions: (json['total_transactions'] as num?)?.toInt() ?? 0,
  totalArtifactsSpent: (json['total_artifacts_spent'] as num?)?.toInt() ?? 0,
  breakdown:
      (json['breakdown'] as List<dynamic>?)
          ?.map((e) => SpendingCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SpendingCategory>[],
);

Map<String, dynamic> _$SpendingSummaryToJson(_SpendingSummary instance) =>
    <String, dynamic>{
      'gifts_sent': instance.giftsSent,
      'gifts_received': instance.giftsReceived,
      'tips_sent': instance.tipsSent,
      'tips_received': instance.tipsReceived,
      'live_fees': instance.liveFees,
      'gym_subscriptions': instance.gymSubscriptions,
      'session_fees': instance.sessionFees,
      'marketplace_spend': instance.marketplaceSpend,
      'total_transactions': instance.totalTransactions,
      'total_artifacts_spent': instance.totalArtifactsSpent,
      'breakdown': instance.breakdown,
    };

_CountdownEntry _$CountdownEntryFromJson(Map<String, dynamic> json) =>
    _CountdownEntry(
      id: json['id'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      unit: json['unit'] as String? ?? 'days',
      countdownType: json['countdown_type'] as String? ?? '',
      currentCount: (json['current_count'] as num?)?.toInt() ?? 0,
      targetCount: (json['target_count'] as num?)?.toInt() ?? 0,
      elapsedUnits: (json['elapsed_units'] as num?)?.toInt() ?? 0,
      longestRunUnits: (json['longest_run_units'] as num?)?.toDouble() ?? 0,
      checkins: (json['checkins'] as num?)?.toInt() ?? 0,
      resets: (json['resets'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      lastEventAt: json['last_event_at'] as String?,
    );

Map<String, dynamic> _$CountdownEntryToJson(_CountdownEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reason': instance.reason,
      'icon': instance.icon,
      'unit': instance.unit,
      'countdown_type': instance.countdownType,
      'current_count': instance.currentCount,
      'target_count': instance.targetCount,
      'elapsed_units': instance.elapsedUnits,
      'longest_run_units': instance.longestRunUnits,
      'checkins': instance.checkins,
      'resets': instance.resets,
      'completed': instance.completed,
      'is_active': instance.isActive,
      'last_event_at': instance.lastEventAt,
    };

_CountdownEventEntry _$CountdownEventEntryFromJson(Map<String, dynamic> json) =>
    _CountdownEventEntry(
      id: json['id'] as String? ?? '',
      countdownId: json['countdown_id'] as String? ?? '',
      eventType: json['event_type'] as String? ?? '',
      countAfter: (json['count_after'] as num?)?.toInt() ?? 0,
      elapsedSeconds: (json['elapsed_seconds'] as num?)?.toDouble() ?? 0,
      runElapsedSeconds: (json['run_elapsed_seconds'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? 'days',
      occurredAt: json['occurred_at'] as String? ?? '',
    );

Map<String, dynamic> _$CountdownEventEntryToJson(
  _CountdownEventEntry instance,
) => <String, dynamic>{
  'id': instance.id,
  'countdown_id': instance.countdownId,
  'event_type': instance.eventType,
  'count_after': instance.countAfter,
  'elapsed_seconds': instance.elapsedSeconds,
  'run_elapsed_seconds': instance.runElapsedSeconds,
  'unit': instance.unit,
  'occurred_at': instance.occurredAt,
};

_CadenceSummary _$CadenceSummaryFromJson(Map<String, dynamic> json) =>
    _CadenceSummary(
      medianGapSeconds: (json['median_gap_seconds'] as num?)?.toDouble(),
      onTimeCheckins: (json['on_time_checkins'] as num?)?.toInt() ?? 0,
      lateCheckins: (json['late_checkins'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CadenceSummaryToJson(_CadenceSummary instance) =>
    <String, dynamic>{
      'median_gap_seconds': instance.medianGapSeconds,
      'on_time_checkins': instance.onTimeCheckins,
      'late_checkins': instance.lateCheckins,
    };

_CountdownSummary _$CountdownSummaryFromJson(
  Map<String, dynamic> json,
) => _CountdownSummary(
  count: (json['count'] as num?)?.toInt() ?? 0,
  activeCount: (json['active_count'] as num?)?.toInt() ?? 0,
  totalCheckins: (json['total_checkins'] as num?)?.toInt() ?? 0,
  totalResets: (json['total_resets'] as num?)?.toInt() ?? 0,
  totalCompletions: (json['total_completions'] as num?)?.toInt() ?? 0,
  currentStreakUnits: (json['current_streak_units'] as num?)?.toDouble() ?? 0,
  longestStreakUnits: (json['longest_streak_units'] as num?)?.toDouble() ?? 0,
  totalStreakDays: (json['total_streak_days'] as num?)?.toDouble() ?? 0,
  byCountdown:
      (json['by_countdown'] as List<dynamic>?)
          ?.map((e) => CountdownEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CountdownEntry>[],
  recentEvents:
      (json['recent_events'] as List<dynamic>?)
          ?.map((e) => CountdownEventEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CountdownEventEntry>[],
  cadence: json['cadence'] == null
      ? const CadenceSummary()
      : CadenceSummary.fromJson(json['cadence'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CountdownSummaryToJson(_CountdownSummary instance) =>
    <String, dynamic>{
      'count': instance.count,
      'active_count': instance.activeCount,
      'total_checkins': instance.totalCheckins,
      'total_resets': instance.totalResets,
      'total_completions': instance.totalCompletions,
      'current_streak_units': instance.currentStreakUnits,
      'longest_streak_units': instance.longestStreakUnits,
      'total_streak_days': instance.totalStreakDays,
      'by_countdown': instance.byCountdown,
      'recent_events': instance.recentEvents,
      'cadence': instance.cadence,
    };

_RoutineCategoryCount _$RoutineCategoryCountFromJson(
  Map<String, dynamic> json,
) => _RoutineCategoryCount(
  category: json['category'] as String? ?? '',
  label: json['label'] as String? ?? '',
  count: (json['count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RoutineCategoryCountToJson(
  _RoutineCategoryCount instance,
) => <String, dynamic>{
  'category': instance.category,
  'label': instance.label,
  'count': instance.count,
};

_RoutineTrackingCount _$RoutineTrackingCountFromJson(
  Map<String, dynamic> json,
) => _RoutineTrackingCount(
  tracking: json['tracking'] as String? ?? '',
  count: (json['count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RoutineTrackingCountToJson(
  _RoutineTrackingCount instance,
) => <String, dynamic>{'tracking': instance.tracking, 'count': instance.count};

_RoutinesSummary _$RoutinesSummaryFromJson(
  Map<String, dynamic> json,
) => _RoutinesSummary(
  activeRoutines: (json['active_routines'] as num?)?.toInt() ?? 0,
  totalCheckins: (json['total_checkins'] as num?)?.toInt() ?? 0,
  byCategory:
      (json['by_category'] as List<dynamic>?)
          ?.map((e) => RoutineCategoryCount.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RoutineCategoryCount>[],
  byTracking:
      (json['by_tracking'] as List<dynamic>?)
          ?.map((e) => RoutineTrackingCount.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RoutineTrackingCount>[],
);

Map<String, dynamic> _$RoutinesSummaryToJson(_RoutinesSummary instance) =>
    <String, dynamic>{
      'active_routines': instance.activeRoutines,
      'total_checkins': instance.totalCheckins,
      'by_category': instance.byCategory,
      'by_tracking': instance.byTracking,
    };

_ProgrammesSummary _$ProgrammesSummaryFromJson(Map<String, dynamic> json) =>
    _ProgrammesSummary(
      programmesPurchased: (json['programmes_purchased'] as num?)?.toInt() ?? 0,
      mealPlansPurchased: (json['meal_plans_purchased'] as num?)?.toInt() ?? 0,
      activeEnrolments: (json['active_enrolments'] as num?)?.toInt() ?? 0,
      completedEnrolments: (json['completed_enrolments'] as num?)?.toInt() ?? 0,
      avgProgressPct: (json['avg_progress_pct'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ProgrammesSummaryToJson(_ProgrammesSummary instance) =>
    <String, dynamic>{
      'programmes_purchased': instance.programmesPurchased,
      'meal_plans_purchased': instance.mealPlansPurchased,
      'active_enrolments': instance.activeEnrolments,
      'completed_enrolments': instance.completedEnrolments,
      'avg_progress_pct': instance.avgProgressPct,
    };

_AnalyticsSummaryData _$AnalyticsSummaryDataFromJson(
  Map<String, dynamic> json,
) => _AnalyticsSummaryData(
  period: json['period'] as String? ?? 'all',
  user: json['user'] == null
      ? const AnalyticsUserInfo()
      : AnalyticsUserInfo.fromJson(json['user'] as Map<String, dynamic>),
  workouts: json['workouts'] == null
      ? const WorkoutSummary()
      : WorkoutSummary.fromJson(json['workouts'] as Map<String, dynamic>),
  activity: json['activity'] == null
      ? const ActivitySummary()
      : ActivitySummary.fromJson(json['activity'] as Map<String, dynamic>),
  body: json['body'] == null
      ? const BodySummary()
      : BodySummary.fromJson(json['body'] as Map<String, dynamic>),
  lives: json['lives'] == null
      ? const LivesSummary()
      : LivesSummary.fromJson(json['lives'] as Map<String, dynamic>),
  spending: json['spending'] == null
      ? const SpendingSummary()
      : SpendingSummary.fromJson(json['spending'] as Map<String, dynamic>),
  programmes: json['programmes'] == null
      ? const ProgrammesSummary()
      : ProgrammesSummary.fromJson(json['programmes'] as Map<String, dynamic>),
  countdowns: json['countdowns'] == null
      ? const CountdownSummary()
      : CountdownSummary.fromJson(json['countdowns'] as Map<String, dynamic>),
  routines: json['routines'] == null
      ? const RoutinesSummary()
      : RoutinesSummary.fromJson(json['routines'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AnalyticsSummaryDataToJson(
  _AnalyticsSummaryData instance,
) => <String, dynamic>{
  'period': instance.period,
  'user': instance.user,
  'workouts': instance.workouts,
  'activity': instance.activity,
  'body': instance.body,
  'lives': instance.lives,
  'spending': instance.spending,
  'programmes': instance.programmes,
  'countdowns': instance.countdowns,
  'routines': instance.routines,
};

_AnalyticsReportResult _$AnalyticsReportResultFromJson(
  Map<String, dynamic> json,
) => _AnalyticsReportResult(
  id: json['id'] as String? ?? '',
  period: json['period'] as String? ?? 'all',
  data: json['data'] == null
      ? const AnalyticsSummaryData()
      : AnalyticsSummaryData.fromJson(json['data'] as Map<String, dynamic>),
  imageUrl: json['image_url'] as String? ?? '',
);

Map<String, dynamic> _$AnalyticsReportResultToJson(
  _AnalyticsReportResult instance,
) => <String, dynamic>{
  'id': instance.id,
  'period': instance.period,
  'data': instance.data,
  'image_url': instance.imageUrl,
};

_ShareReportResult _$ShareReportResultFromJson(Map<String, dynamic> json) =>
    _ShareReportResult(
      reportId: json['report_id'] as String? ?? '',
      postId: json['post_id'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
    );

Map<String, dynamic> _$ShareReportResultToJson(_ShareReportResult instance) =>
    <String, dynamic>{
      'report_id': instance.reportId,
      'post_id': instance.postId,
      'image_url': instance.imageUrl,
    };
