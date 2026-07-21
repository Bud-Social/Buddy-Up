// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingPayload _$OnboardingPayloadFromJson(Map<String, dynamic> json) =>
    _OnboardingPayload(
      primaryGoal: (json['primaryGoal'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      activityLevel: json['activityLevel'] as String,
      preferredWorkouts: (json['preferredWorkouts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dietaryPreference: json['dietaryPreference'] as String,
      preferredTime: json['preferredTime'] as String,
      discoverySource: json['discoverySource'] as String?,
    );

Map<String, dynamic> _$OnboardingPayloadToJson(_OnboardingPayload instance) =>
    <String, dynamic>{
      'primaryGoal': instance.primaryGoal,
      'activityLevel': instance.activityLevel,
      'preferredWorkouts': instance.preferredWorkouts,
      'dietaryPreference': instance.dietaryPreference,
      'preferredTime': instance.preferredTime,
      'discoverySource': instance.discoverySource,
    };

_OnboardingData _$OnboardingDataFromJson(Map<String, dynamic> json) =>
    _OnboardingData(
      primaryGoal: (json['primaryGoal'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      activityLevel: json['activityLevel'] as String,
      preferredWorkouts: (json['preferredWorkouts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dietaryPreference: json['dietaryPreference'] as String,
      preferredTime: json['preferredTime'] as String,
      discoverySource: json['discoverySource'] as String?,
    );

Map<String, dynamic> _$OnboardingDataToJson(_OnboardingData instance) =>
    <String, dynamic>{
      'primaryGoal': instance.primaryGoal,
      'activityLevel': instance.activityLevel,
      'preferredWorkouts': instance.preferredWorkouts,
      'dietaryPreference': instance.dietaryPreference,
      'preferredTime': instance.preferredTime,
      'discoverySource': instance.discoverySource,
    };

_OnboardingPlan _$OnboardingPlanFromJson(Map<String, dynamic> json) =>
    _OnboardingPlan(
      primaryGoal: json['primaryGoal'] as String,
      recommendedTrainerSpecialties:
          (json['recommendedTrainerSpecialties'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      recommendedGymCategories:
          (json['recommendedGymCategories'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      suggestedWorkoutPlan: json['suggestedWorkoutPlan'] == null
          ? null
          : SuggestedWorkoutPlan.fromJson(
              json['suggestedWorkoutPlan'] as Map<String, dynamic>,
            ),
      activityLevelAdvice: json['activityLevelAdvice'] as String?,
      timePreferenceAdvice: json['timePreferenceAdvice'] as String?,
      buddyMatchingHint: json['buddyMatchingHint'] as String?,
      mealPlanRecommendation: json['mealPlanRecommendation'] as String?,
      recommendedDietaryTags: (json['recommendedDietaryTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$OnboardingPlanToJson(_OnboardingPlan instance) =>
    <String, dynamic>{
      'primaryGoal': instance.primaryGoal,
      'recommendedTrainerSpecialties': instance.recommendedTrainerSpecialties,
      'recommendedGymCategories': instance.recommendedGymCategories,
      'suggestedWorkoutPlan': instance.suggestedWorkoutPlan,
      'activityLevelAdvice': instance.activityLevelAdvice,
      'timePreferenceAdvice': instance.timePreferenceAdvice,
      'buddyMatchingHint': instance.buddyMatchingHint,
      'mealPlanRecommendation': instance.mealPlanRecommendation,
      'recommendedDietaryTags': instance.recommendedDietaryTags,
    };

_SuggestedWorkoutPlan _$SuggestedWorkoutPlanFromJson(
  Map<String, dynamic> json,
) => _SuggestedWorkoutPlan(
  frequency: json['frequency'] as String,
  focus: json['focus'] as String,
  sampleSplit: (json['sampleSplit'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$SuggestedWorkoutPlanToJson(
  _SuggestedWorkoutPlan instance,
) => <String, dynamic>{
  'frequency': instance.frequency,
  'focus': instance.focus,
  'sampleSplit': instance.sampleSplit,
};
