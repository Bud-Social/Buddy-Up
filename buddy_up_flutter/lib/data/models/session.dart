import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';
part 'session.g.dart';

@freezed
abstract class TrainerProfile with _$TrainerProfile {
  const factory TrainerProfile({
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') required String avatarUrl,
    @JsonKey(name: 'bio') @Default('') String bio,
    @JsonKey(name: 'specialties') @Default(<String>[]) List<String> specialties,
    @JsonKey(name: 'experience_years') @Default(0) int experienceYears,
    @JsonKey(name: 'certifications') @Default(<String>[]) List<String> certifications,
    @JsonKey(name: 'average_rating') @Default(0.0) double averageRating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'session_count') @Default(0) int sessionCount,
    @JsonKey(name: 'hourly_rate') @Default(0.0) double hourlyRate,
    @JsonKey(name: 'currency') @Default('USD') String currency,
    @JsonKey(name: 'location') @Default('') String location,
    @JsonKey(name: 'is_available') @Default(false) bool isAvailable,
  }) = _TrainerProfile;

  factory TrainerProfile.fromJson(Map<String, dynamic> json) =>
      _$TrainerProfileFromJson(json);
}

@freezed
abstract class AvailabilitySlot with _$AvailabilitySlot {
  const factory AvailabilitySlot({
    required String id,
    @JsonKey(name: 'day_of_week') required int dayOfWeek,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
    @Default(false) bool isBooked,
  }) = _AvailabilitySlot;

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) =>
      _$AvailabilitySlotFromJson(json);
}

@freezed
abstract class BookingSession with _$BookingSession {
  const factory BookingSession({
    required String id,
    @JsonKey(name: 'trainer_username') required String trainerUsername,
    @JsonKey(name: 'trainer_name') required String trainerName,
    @JsonKey(name: 'trainer_avatar') required String trainerAvatar,
    @JsonKey(name: 'student_username') required String studentUsername,
    @JsonKey(name: 'scheduled_date') required String scheduledDate,
    @JsonKey(name: 'scheduled_time') required String scheduledTime,
    @Default('pending') String status,
    @JsonKey(name: 'duration_minutes') @Default(60) int durationMinutes,
    @JsonKey(name: 'session_type') @Default('one_on_one') String sessionType,
    String? notes,
    @JsonKey(name: 'total_fee') double? totalFee,
    String? currency,
    @JsonKey(name: 'meeting_link') String? meetingLink,
    @JsonKey(name: 'cancellation_reason') String? cancellationReason,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _BookingSession;

  factory BookingSession.fromJson(Map<String, dynamic> json) =>
      _$BookingSessionFromJson(json);
}

@freezed
abstract class SessionReview with _$SessionReview {
  const factory SessionReview({
    required String id,
    @JsonKey(name: 'booking_id') required String bookingId,
    @JsonKey(name: 'trainer_username') required String trainerUsername,
    @JsonKey(name: 'reviewer_username') required String reviewerUsername,
    required int rating,
    String? comment,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _SessionReview;

  factory SessionReview.fromJson(Map<String, dynamic> json) =>
      _$SessionReviewFromJson(json);
}

@freezed
abstract class CreateBookingPayload with _$CreateBookingPayload {
  const factory CreateBookingPayload({
    @JsonKey(name: 'trainer_username') required String trainerUsername,
    @JsonKey(name: 'scheduled_date') required String scheduledDate,
    @JsonKey(name: 'scheduled_time') required String scheduledTime,
    @JsonKey(name: 'duration_minutes') @Default(60) int durationMinutes,
    @JsonKey(name: 'session_type') @Default('one_on_one') String sessionType,
    String? notes,
  }) = _CreateBookingPayload;

  factory CreateBookingPayload.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingPayloadFromJson(json);
}

@freezed
abstract class ProgrammeWeek with _$ProgrammeWeek {
  const factory ProgrammeWeek({
    required String id,
    @JsonKey(name: 'programme_id') required String programmeId,
    @JsonKey(name: 'week_number') required int weekNumber,
    required String title,
    required String description,
    @JsonKey(name: 'is_completed') @Default(false) bool isCompleted,
  }) = _ProgrammeWeek;

  factory ProgrammeWeek.fromJson(Map<String, dynamic> json) =>
      _$ProgrammeWeekFromJson(json);
}

@freezed
abstract class ProgrammeEnrollment with _$ProgrammeEnrollment {
  const factory ProgrammeEnrollment({
    required String id,
    @JsonKey(name: 'programme_id') required String programmeId,
    @JsonKey(name: 'programme_title') required String programmeTitle,
    @JsonKey(name: 'total_weeks') @Default(0) int totalWeeks,
    @JsonKey(name: 'completed_weeks') @Default(0) int completedWeeks,
    @JsonKey(name: 'started_at') required String startedAt,
    @JsonKey(name: 'completed_at') String? completedAt,
  }) = _ProgrammeEnrollment;

  factory ProgrammeEnrollment.fromJson(Map<String, dynamic> json) =>
      _$ProgrammeEnrollmentFromJson(json);
}
