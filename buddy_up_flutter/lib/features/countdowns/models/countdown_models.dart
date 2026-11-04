import 'package:freezed_annotation/freezed_annotation.dart';

part 'countdown_models.freezed.dart';
part 'countdown_models.g.dart';

/// A platform template for a countdown reason (sobriety, gym attendance, etc.).
@freezed
abstract class CountdownTemplate with _$CountdownTemplate {
  const factory CountdownTemplate({
    @Default('') String id,
    @Default('') String code,
    @Default('') String title,
    @Default('') String description,
    @Default('days') String unit,
    @Default(0) int defaultTarget,
    @Default('📅') String icon,
    @Default('#6366f1') String color,
    @Default(true) bool isActive,
    @Default(0) int sortOrder,
  }) = _CountdownTemplate;

  factory CountdownTemplate.fromJson(Map<String, dynamic> json) =>
      _$CountdownTemplateFromJson(json);
}

/// A user's active countdown instance.
@freezed
abstract class UserCountdown with _$UserCountdown {
  const factory UserCountdown({
    @Default('') String id,
    @Default(null) String? templateId,
    @Default(null) CountdownTemplate? templateDetail,
    @Default('') String customReason,
    @Default('manual') String countdownType,
    @Default('days') String unit,
    @Default(0) int currentCount,
    @Default(0) int targetCount,
    @Default('') String startDate,
    @Default(null) String? lastCheckinAt,
    @Default(null) String? lastAutoAdvanceAt,
    @Default(null) String? autoAdvanceSignal,
    @Default(true) bool isActive,
    @Default(null) String? completedAt,
    @Default(0) int daysSinceStart,
    @Default('') String displayReason,
    @Default('📅') String displayIcon,
    @Default('') String createdAt,
    @Default('') String updatedAt,
  }) = _UserCountdown;

  factory UserCountdown.fromJson(Map<String, dynamic> json) =>
      _$UserCountdownFromJson(json);
}

/// Computed properties on UserCountdown.
extension UserCountdownExtensions on UserCountdown {
  /// Human-readable progress percentage (0-100).
  double get progressPercent {
    if (targetCount > 0) {
      return (currentCount / targetCount).clamp(0.0, 1.0) * 100;
    }
    final days = daysSinceStart > 0 ? daysSinceStart : 1;
    return (currentCount / days).clamp(0.0, 1.0) * 100;
  }

  /// Whether the countdown has reached its target (or is complete).
  bool get isCompleted => completedAt != null;
}

/// Request to create a new user countdown.
@freezed
abstract class CreateUserCountdown with _$CreateUserCountdown {
  const factory CreateUserCountdown({
    @Default(null) String? templateId,
    @Default(null) String? customReason,
    @Default('manual') String countdownType,
    @Default('days') String unit,
    @Default(0) int targetCount,
    @Default(null) String? startDate,
  }) = _CreateUserCountdown;

  factory CreateUserCountdown.fromJson(Map<String, dynamic> json) =>
      _$CreateUserCountdownFromJson(json);
}

/// Extension with request serialization for CreateUserCountdown.
extension CreateUserCountdownRequest on CreateUserCountdown {
  Map<String, dynamic> toRequestJson() {
    final map = <String, dynamic>{
      'countdown_type': countdownType,
      'unit': unit,
    };
    if (templateId != null) map['template'] = templateId;
    if (customReason != null && customReason!.isNotEmpty) {
      map['custom_reason'] = customReason;
    }
    if (targetCount > 0) {
      map['target_count'] = targetCount;
    }
    if (startDate != null && startDate!.isNotEmpty) {
      map['start_date'] = startDate;
    }
    return map;
  }
}

/// Request to update a user countdown.
@freezed
abstract class UpdateUserCountdown with _$UpdateUserCountdown {
  const factory UpdateUserCountdown({
    @Default(null) String? customReason,
    @Default(null) String? countdownType,
    @Default(null) String? unit,
    @Default(null) int? targetCount,
    @Default(null) String? startDate,
    @Default(null) bool? isActive,
  }) = _UpdateUserCountdown;

  factory UpdateUserCountdown.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserCountdownFromJson(json);
}

/// Extension with request serialization for UpdateUserCountdown.
extension UpdateUserCountdownRequest on UpdateUserCountdown {
  Map<String, dynamic> toRequestJson() {
    final map = <String, dynamic>{};
    if (customReason != null && customReason!.isNotEmpty) {
      map['custom_reason'] = customReason;
    }
    if (countdownType != null) {
      map['countdown_type'] = countdownType;
    }
    if (unit != null) {
      map['unit'] = unit;
    }
    if (targetCount != null) {
      map['target_count'] = targetCount;
    }
    if (startDate != null && startDate!.isNotEmpty) {
      map['start_date'] = startDate;
    }
    if (isActive != null) {
      map['is_active'] = isActive;
    }
    return map;
  }
}
