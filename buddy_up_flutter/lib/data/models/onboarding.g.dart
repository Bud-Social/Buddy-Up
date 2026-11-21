// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingPayload _$OnboardingPayloadFromJson(Map<String, dynamic> json) =>
    _OnboardingPayload(
      primaryGoal: (json['primary_goal'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      activityLevel: json['activity_level'] as String,
      preferredWorkouts: (json['preferred_workouts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dietaryPreference: json['dietary_preference'] as String,
      preferredTime: json['preferred_time'] as String,
      discoverySource: json['discovery_source'] as String?,
      displayName: json['display_name'] as String?,
      username: json['username'] as String?,
      locationCity: json['location_city'] as String?,
      bio: json['bio'] as String?,
      customInterests: json['custom_interests'] as String?,
      newPassword: json['new_password'] as String?,
      termsVersion: json['terms_version'] as String,
      marketingConsent: json['marketing_consent'] as bool? ?? false,
    );

Map<String, dynamic> _$OnboardingPayloadToJson(_OnboardingPayload instance) =>
    <String, dynamic>{
      'primary_goal': instance.primaryGoal,
      'activity_level': instance.activityLevel,
      'preferred_workouts': instance.preferredWorkouts,
      'dietary_preference': instance.dietaryPreference,
      'preferred_time': instance.preferredTime,
      'discovery_source': instance.discoverySource,
      'display_name': instance.displayName,
      'username': instance.username,
      'location_city': instance.locationCity,
      'bio': instance.bio,
      'custom_interests': instance.customInterests,
      'new_password': instance.newPassword,
      'terms_version': instance.termsVersion,
      'marketing_consent': instance.marketingConsent,
    };

_OnboardingData _$OnboardingDataFromJson(Map<String, dynamic> json) =>
    _OnboardingData(
      primaryGoal: (json['primary_goal'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      activityLevel: json['activity_level'] as String,
      preferredWorkouts: (json['preferred_workouts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dietaryPreference: json['dietary_preference'] as String,
      preferredTime: json['preferred_time'] as String,
      discoverySource: json['discovery_source'] as String?,
    );

Map<String, dynamic> _$OnboardingDataToJson(_OnboardingData instance) =>
    <String, dynamic>{
      'primary_goal': instance.primaryGoal,
      'activity_level': instance.activityLevel,
      'preferred_workouts': instance.preferredWorkouts,
      'dietary_preference': instance.dietaryPreference,
      'preferred_time': instance.preferredTime,
      'discovery_source': instance.discoverySource,
    };

_OnboardingPlan _$OnboardingPlanFromJson(Map<String, dynamic> json) =>
    _OnboardingPlan(
      primaryGoal: json['primary_goal'] as String,
      recommendedTrainerSpecialties:
          (json['recommended_trainer_specialties'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      recommendedGymCategories:
          (json['recommended_gym_categories'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      suggestedWorkoutPlan: json['suggested_workout_plan'] == null
          ? null
          : SuggestedWorkoutPlan.fromJson(
              json['suggested_workout_plan'] as Map<String, dynamic>,
            ),
      activityLevelAdvice: json['activity_level_advice'] as String?,
      timePreferenceAdvice: json['time_preference_advice'] as String?,
      buddyMatchingHint: json['buddy_matching_hint'] as String?,
      mealPlanRecommendation: json['meal_plan_recommendation'] as String?,
      recommendedDietaryTags:
          (json['recommended_dietary_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$OnboardingPlanToJson(_OnboardingPlan instance) =>
    <String, dynamic>{
      'primary_goal': instance.primaryGoal,
      'recommended_trainer_specialties': instance.recommendedTrainerSpecialties,
      'recommended_gym_categories': instance.recommendedGymCategories,
      'suggested_workout_plan': instance.suggestedWorkoutPlan,
      'activity_level_advice': instance.activityLevelAdvice,
      'time_preference_advice': instance.timePreferenceAdvice,
      'buddy_matching_hint': instance.buddyMatchingHint,
      'meal_plan_recommendation': instance.mealPlanRecommendation,
      'recommended_dietary_tags': instance.recommendedDietaryTags,
    };

_SuggestedWorkoutPlan _$SuggestedWorkoutPlanFromJson(
  Map<String, dynamic> json,
) => _SuggestedWorkoutPlan(
  frequency: json['frequency'] as String,
  focus: json['focus'] as String,
  sampleSplit: (json['sample_split'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$SuggestedWorkoutPlanToJson(
  _SuggestedWorkoutPlan instance,
) => <String, dynamic>{
  'frequency': instance.frequency,
  'focus': instance.focus,
  'sample_split': instance.sampleSplit,
};
