// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainerProfile _$TrainerProfileFromJson(Map<String, dynamic> json) =>
    _TrainerProfile(
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String,
      bio: json['bio'] as String? ?? '',
      specialties:
          (json['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
      certifications:
          (json['certifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      sessionCount: (json['session_count'] as num?)?.toInt() ?? 0,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      location: json['location'] as String? ?? '',
      isAvailable: json['is_available'] as bool? ?? false,
    );

Map<String, dynamic> _$TrainerProfileToJson(_TrainerProfile instance) =>
    <String, dynamic>{
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'bio': instance.bio,
      'specialties': instance.specialties,
      'experience_years': instance.experienceYears,
      'certifications': instance.certifications,
      'average_rating': instance.averageRating,
      'review_count': instance.reviewCount,
      'session_count': instance.sessionCount,
      'hourly_rate': instance.hourlyRate,
      'currency': instance.currency,
      'location': instance.location,
      'is_available': instance.isAvailable,
    };

_AvailabilitySlot _$AvailabilitySlotFromJson(Map<String, dynamic> json) =>
    _AvailabilitySlot(
      id: json['id'] as String,
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isBooked: json['isBooked'] as bool? ?? false,
    );

Map<String, dynamic> _$AvailabilitySlotToJson(_AvailabilitySlot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day_of_week': instance.dayOfWeek,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'isBooked': instance.isBooked,
    };

_BookingSession _$BookingSessionFromJson(Map<String, dynamic> json) =>
    _BookingSession(
      id: json['id'] as String,
      trainerUsername: json['trainer_username'] as String,
      trainerName: json['trainer_name'] as String,
      trainerAvatar: json['trainer_avatar'] as String,
      studentUsername: json['student_username'] as String,
      scheduledDate: json['scheduled_date'] as String,
      scheduledTime: json['scheduled_time'] as String,
      status: json['status'] as String? ?? 'pending',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 60,
      sessionType: json['session_type'] as String? ?? 'one_on_one',
      notes: json['notes'] as String?,
      totalFee: (json['total_fee'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      meetingLink: json['meeting_link'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$BookingSessionToJson(_BookingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trainer_username': instance.trainerUsername,
      'trainer_name': instance.trainerName,
      'trainer_avatar': instance.trainerAvatar,
      'student_username': instance.studentUsername,
      'scheduled_date': instance.scheduledDate,
      'scheduled_time': instance.scheduledTime,
      'status': instance.status,
      'duration_minutes': instance.durationMinutes,
      'session_type': instance.sessionType,
      'notes': instance.notes,
      'total_fee': instance.totalFee,
      'currency': instance.currency,
      'meeting_link': instance.meetingLink,
      'cancellation_reason': instance.cancellationReason,
      'created_at': instance.createdAt,
    };

_SessionReview _$SessionReviewFromJson(Map<String, dynamic> json) =>
    _SessionReview(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      trainerUsername: json['trainer_username'] as String,
      reviewerUsername: json['reviewer_username'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$SessionReviewToJson(_SessionReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'booking_id': instance.bookingId,
      'trainer_username': instance.trainerUsername,
      'reviewer_username': instance.reviewerUsername,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt,
    };

_CreateBookingPayload _$CreateBookingPayloadFromJson(
  Map<String, dynamic> json,
) => _CreateBookingPayload(
  trainerUsername: json['trainer_username'] as String,
  scheduledDate: json['scheduled_date'] as String,
  scheduledTime: json['scheduled_time'] as String,
  durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 60,
  sessionType: json['session_type'] as String? ?? 'one_on_one',
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$CreateBookingPayloadToJson(
  _CreateBookingPayload instance,
) => <String, dynamic>{
  'trainer_username': instance.trainerUsername,
  'scheduled_date': instance.scheduledDate,
  'scheduled_time': instance.scheduledTime,
  'duration_minutes': instance.durationMinutes,
  'session_type': instance.sessionType,
  'notes': instance.notes,
};

_ProgrammeWeek _$ProgrammeWeekFromJson(Map<String, dynamic> json) =>
    _ProgrammeWeek(
      id: json['id'] as String,
      programmeId: json['programme_id'] as String,
      weekNumber: (json['week_number'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
    );

Map<String, dynamic> _$ProgrammeWeekToJson(_ProgrammeWeek instance) =>
    <String, dynamic>{
      'id': instance.id,
      'programme_id': instance.programmeId,
      'week_number': instance.weekNumber,
      'title': instance.title,
      'description': instance.description,
      'is_completed': instance.isCompleted,
    };

_ProgrammeEnrollment _$ProgrammeEnrollmentFromJson(Map<String, dynamic> json) =>
    _ProgrammeEnrollment(
      id: json['id'] as String,
      programmeId: json['programme_id'] as String,
      programmeTitle: json['programme_title'] as String,
      totalWeeks: (json['total_weeks'] as num?)?.toInt() ?? 0,
      completedWeeks: (json['completed_weeks'] as num?)?.toInt() ?? 0,
      startedAt: json['started_at'] as String,
      completedAt: json['completed_at'] as String?,
    );

Map<String, dynamic> _$ProgrammeEnrollmentToJson(
  _ProgrammeEnrollment instance,
) => <String, dynamic>{
  'id': instance.id,
  'programme_id': instance.programmeId,
  'programme_title': instance.programmeTitle,
  'total_weeks': instance.totalWeeks,
  'completed_weeks': instance.completedWeeks,
  'started_at': instance.startedAt,
  'completed_at': instance.completedAt,
};
