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

_MealRecent _$MealRecentFromJson(Map<String, dynamic> json) => _MealRecent(
  id: json['id'] as String? ?? '',
  mealType: json['meal_type'] as String? ?? '',
  foodName: json['food_name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  calories: (json['calories'] as num?)?.toDouble(),
  proteinG: (json['protein_g'] as num?)?.toDouble(),
  carbsG: (json['carbs_g'] as num?)?.toDouble(),
  fatG: (json['fat_g'] as num?)?.toDouble(),
  photoUrl: json['photo_url'] as String? ?? '',
  loggedAt: json['logged_at'] as String?,
);

Map<String, dynamic> _$MealRecentToJson(_MealRecent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'meal_type': instance.mealType,
      'food_name': instance.foodName,
      'description': instance.description,
      'calories': instance.calories,
      'protein_g': instance.proteinG,
      'carbs_g': instance.carbsG,
      'fat_g': instance.fatG,
      'photo_url': instance.photoUrl,
      'logged_at': instance.loggedAt,
    };

_NutritionSummary _$NutritionSummaryFromJson(Map<String, dynamic> json) =>
    _NutritionSummary(
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0,
      totalProteinG: (json['total_protein_g'] as num?)?.toDouble() ?? 0,
      totalCarbsG: (json['total_carbs_g'] as num?)?.toDouble() ?? 0,
      totalFatG: (json['total_fat_g'] as num?)?.toDouble() ?? 0,
      byType:
          (json['by_type'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ActivityTypeBreakdown.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ActivityTypeBreakdown>[],
      avgDailyCalories: (json['avg_daily_calories'] as num?)?.toDouble(),
      recent:
          (json['recent'] as List<dynamic>?)
              ?.map((e) => MealRecent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MealRecent>[],
    );

Map<String, dynamic> _$NutritionSummaryToJson(_NutritionSummary instance) =>
    <String, dynamic>{
      'count': instance.count,
      'total_calories': instance.totalCalories,
      'total_protein_g': instance.totalProteinG,
      'total_carbs_g': instance.totalCarbsG,
      'total_fat_g': instance.totalFatG,
      'by_type': instance.byType,
      'avg_daily_calories': instance.avgDailyCalories,
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
  nutrition: json['nutrition'] == null
      ? const NutritionSummary()
      : NutritionSummary.fromJson(json['nutrition'] as Map<String, dynamic>),
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
);

Map<String, dynamic> _$AnalyticsSummaryDataToJson(
  _AnalyticsSummaryData instance,
) => <String, dynamic>{
  'period': instance.period,
  'user': instance.user,
  'workouts': instance.workouts,
  'activity': instance.activity,
  'nutrition': instance.nutrition,
  'body': instance.body,
  'lives': instance.lives,
  'spending': instance.spending,
  'programmes': instance.programmes,
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
