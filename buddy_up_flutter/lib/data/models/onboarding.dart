import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding.freezed.dart';
part 'onboarding.g.dart';

@freezed
abstract class OnboardingPayload with _$OnboardingPayload {
  const factory OnboardingPayload({
    required List<String> primaryGoal,
    required String activityLevel,
    required List<String> preferredWorkouts,
    required String dietaryPreference,
    required String preferredTime,
    String? discoverySource,
  }) = _OnboardingPayload;

  factory OnboardingPayload.fromJson(Map<String, dynamic> json) =>
      _$OnboardingPayloadFromJson(json);
}

@freezed
abstract class OnboardingData with _$OnboardingData {
  const factory OnboardingData({
    required List<String> primaryGoal,
    required String activityLevel,
    required List<String> preferredWorkouts,
    required String dietaryPreference,
    required String preferredTime,
    String? discoverySource,
  }) = _OnboardingData;

  factory OnboardingData.fromJson(Map<String, dynamic> json) =>
      _$OnboardingDataFromJson(json);
}

@freezed
abstract class OnboardingPlan with _$OnboardingPlan {
  const factory OnboardingPlan({
    required String primaryGoal,
    required List<String> recommendedTrainerSpecialties,
    required List<String> recommendedGymCategories,
    SuggestedWorkoutPlan? suggestedWorkoutPlan,
    String? activityLevelAdvice,
    String? timePreferenceAdvice,
    String? buddyMatchingHint,
    String? mealPlanRecommendation,
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
    required List<String> sampleSplit,
  }) = _SuggestedWorkoutPlan;

  factory SuggestedWorkoutPlan.fromJson(Map<String, dynamic> json) =>
      _$SuggestedWorkoutPlanFromJson(json);
}
