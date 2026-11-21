import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding.freezed.dart';
part 'onboarding.g.dart';

@freezed
abstract class OnboardingPayload with _$OnboardingPayload {
  const factory OnboardingPayload({
    @JsonKey(name: 'primary_goal') required List<String> primaryGoal,
    @JsonKey(name: 'activity_level') required String activityLevel,
    @JsonKey(name: 'preferred_workouts')
    required List<String> preferredWorkouts,
    @JsonKey(name: 'dietary_preference') required String dietaryPreference,
    @JsonKey(name: 'preferred_time') required String preferredTime,
    @JsonKey(name: 'discovery_source') String? discoverySource,
    // Profile fields the web collects in onboarding (social sign-ins have
    // none yet). Sent with the same payload so one submit activates everything.
    @JsonKey(name: 'display_name') String? displayName,
    String? username,
    @JsonKey(name: 'location_city') String? locationCity,
    String? bio,
    @JsonKey(name: 'custom_interests') String? customInterests,
    @JsonKey(name: 'new_password') String? newPassword,
    // Consent — required by the backend; recorded on the profile with a
    // version + timestamp (mirrors the web onboarding payload).
    @JsonKey(name: 'terms_version') required String termsVersion,
    @JsonKey(name: 'marketing_consent') @Default(false) bool marketingConsent,
  }) = _OnboardingPayload;

  factory OnboardingPayload.fromJson(Map<String, dynamic> json) =>
      _$OnboardingPayloadFromJson(json);
}

@freezed
abstract class OnboardingData with _$OnboardingData {
  const factory OnboardingData({
    @JsonKey(name: 'primary_goal') required List<String> primaryGoal,
    @JsonKey(name: 'activity_level') required String activityLevel,
    @JsonKey(name: 'preferred_workouts')
    required List<String> preferredWorkouts,
    @JsonKey(name: 'dietary_preference') required String dietaryPreference,
    @JsonKey(name: 'preferred_time') required String preferredTime,
    @JsonKey(name: 'discovery_source') String? discoverySource,
  }) = _OnboardingData;

  factory OnboardingData.fromJson(Map<String, dynamic> json) =>
      _$OnboardingDataFromJson(json);
}

@freezed
abstract class OnboardingPlan with _$OnboardingPlan {
  const factory OnboardingPlan({
    @JsonKey(name: 'primary_goal') required String primaryGoal,
    @JsonKey(name: 'recommended_trainer_specialties')
    required List<String> recommendedTrainerSpecialties,
    @JsonKey(name: 'recommended_gym_categories')
    required List<String> recommendedGymCategories,
    @JsonKey(name: 'suggested_workout_plan')
    SuggestedWorkoutPlan? suggestedWorkoutPlan,
    @JsonKey(name: 'activity_level_advice') String? activityLevelAdvice,
    @JsonKey(name: 'time_preference_advice') String? timePreferenceAdvice,
    @JsonKey(name: 'buddy_matching_hint') String? buddyMatchingHint,
    @JsonKey(name: 'meal_plan_recommendation') String? mealPlanRecommendation,
    @JsonKey(name: 'recommended_dietary_tags')
    List<String>? recommendedDietaryTags,
  }) = _OnboardingPlan;

  factory OnboardingPlan.fromJson(Map<String, dynamic> json) =>
      _$OnboardingPlanFromJson(json);
}

@freezed
abstract class SuggestedWorkoutPlan with _$SuggestedWorkoutPlan {
  const factory SuggestedWorkoutPlan({
    required String frequency,
    required String focus,
    @JsonKey(name: 'sample_split') required List<String> sampleSplit,
  }) = _SuggestedWorkoutPlan;

  factory SuggestedWorkoutPlan.fromJson(Map<String, dynamic> json) =>
      _$SuggestedWorkoutPlanFromJson(json);
}
