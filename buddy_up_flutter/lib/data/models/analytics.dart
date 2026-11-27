import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics.freezed.dart';
part 'analytics.g.dart';

@freezed
abstract class AnalyticsUserInfo with _$AnalyticsUserInfo {
  const factory AnalyticsUserInfo({
    @Default('') String username,
    @JsonKey(name: 'display_name') @Default('') String displayName,
    @JsonKey(name: 'avatar_url') @Default('') String avatarUrl,
    @JsonKey(name: 'streak_days') @Default(0) int streakDays,
  }) = _AnalyticsUserInfo;

  factory AnalyticsUserInfo.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsUserInfoFromJson(json);
}

@freezed
abstract class ActivityTypeBreakdown with _$ActivityTypeBreakdown {
  const factory ActivityTypeBreakdown({
    @Default('') String label,
    @Default(0) int count,
    @Default(0) double calories,
    @Default(0) double distance,
    @Default(0) double duration,
    @JsonKey(name: 'distance_km') @Default(0) double distanceKm,
  }) = _ActivityTypeBreakdown;

  factory ActivityTypeBreakdown.fromJson(Map<String, dynamic> json) =>
      _$ActivityTypeBreakdownFromJson(json);
}

@freezed
abstract class WorkoutRecent with _$WorkoutRecent {
  const factory WorkoutRecent({
    @JsonKey(name: 'performed_at') String? performedAt,
    @JsonKey(name: 'workout_type') @Default('') String workoutType,
    @Default('') String exercise,
    @JsonKey(name: 'duration_minutes') @Default(0) int durationMinutes,
    @JsonKey(name: 'calories_burned') double? caloriesBurned,
  }) = _WorkoutRecent;

  factory WorkoutRecent.fromJson(Map<String, dynamic> json) =>
      _$WorkoutRecentFromJson(json);
}

@freezed
abstract class WorkoutSummary with _$WorkoutSummary {
  const factory WorkoutSummary({
    @Default(0) int count,
    @JsonKey(name: 'total_calories_burned')
    @Default(0)
    double totalCaloriesBurned,
    @JsonKey(name: 'total_volume') @Default(0) double totalVolume,
    @JsonKey(name: 'by_type')
    @Default(<ActivityTypeBreakdown>[])
    List<ActivityTypeBreakdown> byType,
    @JsonKey(name: 'most_trained') String? mostTrained,
    @Default(<WorkoutRecent>[]) List<WorkoutRecent> recent,
  }) = _WorkoutSummary;

  factory WorkoutSummary.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSummaryFromJson(json);
}

@freezed
abstract class ActivityRecent with _$ActivityRecent {
  const factory ActivityRecent({
    @Default('') String id,
    @JsonKey(name: 'activity_type') @Default('') String activityType,
    @JsonKey(name: 'started_at') String? startedAt,
    @JsonKey(name: 'duration_seconds') @Default(0) int durationSeconds,
    @JsonKey(name: 'distance_meters') @Default(0) double distanceMeters,
    @JsonKey(name: 'distance_km') @Default(0) double distanceKm,
    @JsonKey(name: 'avg_pace') double? avgPace,
    @JsonKey(name: 'calories_burned') double? caloriesBurned,
    @Default(0) int steps,
    @Default(<dynamic>[]) List<dynamic> route,
  }) = _ActivityRecent;

  factory ActivityRecent.fromJson(Map<String, dynamic> json) =>
      _$ActivityRecentFromJson(json);
}

@freezed
abstract class ActivitySummary with _$ActivitySummary {
  const factory ActivitySummary({
    @Default(0) int count,
    @JsonKey(name: 'total_distance_km') @Default(0) double totalDistanceKm,
    @JsonKey(name: 'total_duration_seconds')
    @Default(0)
    int totalDurationSeconds,
    @JsonKey(name: 'total_calories_burned')
    @Default(0)
    double totalCaloriesBurned,
    @JsonKey(name: 'total_steps') @Default(0) int totalSteps,
    @JsonKey(name: 'avg_pace') double? avgPace,
    @JsonKey(name: 'by_type')
    @Default(<ActivityTypeBreakdown>[])
    List<ActivityTypeBreakdown> byType,
    @Default(<ActivityRecent>[]) List<ActivityRecent> recent,
  }) = _ActivitySummary;

  factory ActivitySummary.fromJson(Map<String, dynamic> json) =>
      _$ActivitySummaryFromJson(json);
}

@freezed
abstract class BodySeriesPoint with _$BodySeriesPoint {
  const factory BodySeriesPoint({
    @Default('') String id,
    @JsonKey(name: 'weight_kg') @Default(0) double weightKg,
    @JsonKey(name: 'body_fat_pct') double? bodyFatPct,
    @JsonKey(name: 'measured_at') String? measuredAt,
    @JsonKey(name: 'photo_url') @Default('') String photoUrl,
    @JsonKey(name: 'scale_photo_url') @Default('') String scalePhotoUrl,
  }) = _BodySeriesPoint;

  factory BodySeriesPoint.fromJson(Map<String, dynamic> json) =>
      _$BodySeriesPointFromJson(json);
}

@freezed
abstract class BodySummary with _$BodySummary {
  const factory BodySummary({
    @Default(0) int count,
    @JsonKey(name: 'start_weight_kg') double? startWeightKg,
    @JsonKey(name: 'latest_weight_kg') double? latestWeightKg,
    @JsonKey(name: 'weight_change_kg') double? weightChangeKg,
    @JsonKey(name: 'latest_body_fat_pct') double? latestBodyFatPct,
    @Default(<BodySeriesPoint>[]) List<BodySeriesPoint> series,
  }) = _BodySummary;

  factory BodySummary.fromJson(Map<String, dynamic> json) =>
      _$BodySummaryFromJson(json);
}

@freezed
abstract class LivesSummary with _$LivesSummary {
  const factory LivesSummary({
    @JsonKey(name: 'joined_count') @Default(0) int joinedCount,
    @JsonKey(name: 'total_duration_seconds')
    @Default(0)
    int totalDurationSeconds,
    @JsonKey(name: 'by_type')
    @Default(<ActivityTypeBreakdown>[])
    List<ActivityTypeBreakdown> byType,
  }) = _LivesSummary;

  factory LivesSummary.fromJson(Map<String, dynamic> json) =>
      _$LivesSummaryFromJson(json);
}

@freezed
abstract class SpendingCategory with _$SpendingCategory {
  const factory SpendingCategory({
    @Default('') String category,
    @Default(0) int quantity,
    @Default(0) int count,
    @Default('') String label,
  }) = _SpendingCategory;

  factory SpendingCategory.fromJson(Map<String, dynamic> json) =>
      _$SpendingCategoryFromJson(json);
}

@freezed
abstract class SpendingSummary with _$SpendingSummary {
  const factory SpendingSummary({
    @JsonKey(name: 'gifts_sent')
    @Default(SpendingCategory())
    SpendingCategory giftsSent,
    @JsonKey(name: 'gifts_received')
    @Default(SpendingCategory())
    SpendingCategory giftsReceived,
    @JsonKey(name: 'tips_sent')
    @Default(SpendingCategory())
    SpendingCategory tipsSent,
    @JsonKey(name: 'tips_received')
    @Default(SpendingCategory())
    SpendingCategory tipsReceived,
    @JsonKey(name: 'live_fees')
    @Default(SpendingCategory())
    SpendingCategory liveFees,
    @JsonKey(name: 'gym_subscriptions')
    @Default(SpendingCategory())
    SpendingCategory gymSubscriptions,
    @JsonKey(name: 'session_fees')
    @Default(SpendingCategory())
    SpendingCategory sessionFees,
    @JsonKey(name: 'marketplace_spend')
    @Default(SpendingCategory())
    SpendingCategory marketplaceSpend,
    @JsonKey(name: 'total_transactions') @Default(0) int totalTransactions,
    @JsonKey(name: 'total_artifacts_spent') @Default(0) int totalArtifactsSpent,
    @Default(<SpendingCategory>[]) List<SpendingCategory> breakdown,
  }) = _SpendingSummary;

  factory SpendingSummary.fromJson(Map<String, dynamic> json) =>
      _$SpendingSummaryFromJson(json);
}

@freezed
abstract class CountdownEntry with _$CountdownEntry {
  const factory CountdownEntry({
    @Default('') String id,
    @Default('') String reason,
    @Default('') String icon,
    @Default('days') String unit,
    @JsonKey(name: 'countdown_type') @Default('') String countdownType,
    @JsonKey(name: 'current_count') @Default(0) int currentCount,
    @JsonKey(name: 'target_count') @Default(0) int targetCount,
    @JsonKey(name: 'elapsed_units') @Default(0) int elapsedUnits,
    @JsonKey(name: 'longest_run_units') @Default(0) double longestRunUnits,
    @Default(0) int checkins,
    @Default(0) int resets,
    @Default(false) bool completed,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'last_event_at') String? lastEventAt,
  }) = _CountdownEntry;

  factory CountdownEntry.fromJson(Map<String, dynamic> json) =>
      _$CountdownEntryFromJson(json);
}

@freezed
abstract class CountdownEventEntry with _$CountdownEventEntry {
  const factory CountdownEventEntry({
    @Default('') String id,
    @JsonKey(name: 'countdown_id') @Default('') String countdownId,
    @JsonKey(name: 'event_type') @Default('') String eventType,
    @JsonKey(name: 'count_after') @Default(0) int countAfter,
    @JsonKey(name: 'elapsed_seconds') @Default(0) double elapsedSeconds,
    @JsonKey(name: 'run_elapsed_seconds') @Default(0) double runElapsedSeconds,
    @Default('days') String unit,
    @JsonKey(name: 'occurred_at') @Default('') String occurredAt,
  }) = _CountdownEventEntry;

  factory CountdownEventEntry.fromJson(Map<String, dynamic> json) =>
      _$CountdownEventEntryFromJson(json);
}

@freezed
abstract class CadenceSummary with _$CadenceSummary {
  const factory CadenceSummary({
    @JsonKey(name: 'median_gap_seconds') double? medianGapSeconds,
    @JsonKey(name: 'on_time_checkins') @Default(0) int onTimeCheckins,
    @JsonKey(name: 'late_checkins') @Default(0) int lateCheckins,
  }) = _CadenceSummary;

  factory CadenceSummary.fromJson(Map<String, dynamic> json) =>
      _$CadenceSummaryFromJson(json);
}

@freezed
abstract class CountdownSummary with _$CountdownSummary {
  const factory CountdownSummary({
    @Default(0) int count,
    @JsonKey(name: 'active_count') @Default(0) int activeCount,
    @JsonKey(name: 'total_checkins') @Default(0) int totalCheckins,
    @JsonKey(name: 'total_resets') @Default(0) int totalResets,
    @JsonKey(name: 'total_completions') @Default(0) int totalCompletions,
    @JsonKey(name: 'current_streak_units')
    @Default(0)
    double currentStreakUnits,
    @JsonKey(name: 'longest_streak_units')
    @Default(0)
    double longestStreakUnits,
    @JsonKey(name: 'total_streak_days') @Default(0) double totalStreakDays,
    @JsonKey(name: 'by_countdown')
    @Default(<CountdownEntry>[])
    List<CountdownEntry> byCountdown,
    @JsonKey(name: 'recent_events')
    @Default(<CountdownEventEntry>[])
    List<CountdownEventEntry> recentEvents,
    @JsonKey(name: 'cadence') @Default(CadenceSummary()) CadenceSummary cadence,
  }) = _CountdownSummary;

  factory CountdownSummary.fromJson(Map<String, dynamic> json) =>
      _$CountdownSummaryFromJson(json);
}

@freezed
abstract class RoutineCategoryCount with _$RoutineCategoryCount {
  const factory RoutineCategoryCount({
    @Default('') String category,
    @Default('') String label,
    @Default(0) int count,
  }) = _RoutineCategoryCount;

  factory RoutineCategoryCount.fromJson(Map<String, dynamic> json) =>
      _$RoutineCategoryCountFromJson(json);
}

@freezed
abstract class RoutineTrackingCount with _$RoutineTrackingCount {
  const factory RoutineTrackingCount({
    @Default('') String tracking,
    @Default(0) int count,
  }) = _RoutineTrackingCount;

  factory RoutineTrackingCount.fromJson(Map<String, dynamic> json) =>
      _$RoutineTrackingCountFromJson(json);
}

@freezed
abstract class RoutinesSummary with _$RoutinesSummary {
  const factory RoutinesSummary({
    @JsonKey(name: 'active_routines') @Default(0) int activeRoutines,
    @JsonKey(name: 'total_checkins') @Default(0) int totalCheckins,
    @JsonKey(name: 'by_category')
    @Default(<RoutineCategoryCount>[])
    List<RoutineCategoryCount> byCategory,
    @JsonKey(name: 'by_tracking')
    @Default(<RoutineTrackingCount>[])
    List<RoutineTrackingCount> byTracking,
  }) = _RoutinesSummary;

  factory RoutinesSummary.fromJson(Map<String, dynamic> json) =>
      _$RoutinesSummaryFromJson(json);
}

@freezed
abstract class ProgrammesSummary with _$ProgrammesSummary {
  const factory ProgrammesSummary({
    @JsonKey(name: 'programmes_purchased') @Default(0) int programmesPurchased,
    @JsonKey(name: 'meal_plans_purchased') @Default(0) int mealPlansPurchased,
    @JsonKey(name: 'active_enrolments') @Default(0) int activeEnrolments,
    @JsonKey(name: 'completed_enrolments') @Default(0) int completedEnrolments,
    @JsonKey(name: 'avg_progress_pct') double? avgProgressPct,
  }) = _ProgrammesSummary;

  factory ProgrammesSummary.fromJson(Map<String, dynamic> json) =>
      _$ProgrammesSummaryFromJson(json);
}

@freezed
abstract class AnalyticsSummaryData with _$AnalyticsSummaryData {
  const factory AnalyticsSummaryData({
    @Default('all') String period,
    @Default(AnalyticsUserInfo()) AnalyticsUserInfo user,
    @Default(WorkoutSummary()) WorkoutSummary workouts,
    @Default(ActivitySummary()) ActivitySummary activity,
    @Default(BodySummary()) BodySummary body,
    @Default(LivesSummary()) LivesSummary lives,
    @Default(SpendingSummary()) SpendingSummary spending,
    @Default(ProgrammesSummary()) ProgrammesSummary programmes,
    @Default(CountdownSummary()) CountdownSummary countdowns,
    @Default(RoutinesSummary()) RoutinesSummary routines,
  }) = _AnalyticsSummaryData;

  factory AnalyticsSummaryData.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsSummaryDataFromJson(json);
}

@freezed
abstract class AnalyticsReportResult with _$AnalyticsReportResult {
  const factory AnalyticsReportResult({
    @Default('') String id,
    @Default('all') String period,
    @Default(AnalyticsSummaryData()) AnalyticsSummaryData data,
    @JsonKey(name: 'image_url') @Default('') String imageUrl,
  }) = _AnalyticsReportResult;

  factory AnalyticsReportResult.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsReportResultFromJson(json);
}

@freezed
abstract class ShareReportResult with _$ShareReportResult {
  const factory ShareReportResult({
    @JsonKey(name: 'report_id') @Default('') String reportId,
    @JsonKey(name: 'post_id') @Default('') String postId,
    @JsonKey(name: 'image_url') @Default('') String imageUrl,
  }) = _ShareReportResult;

  factory ShareReportResult.fromJson(Map<String, dynamic> json) =>
      _$ShareReportResultFromJson(json);
}
