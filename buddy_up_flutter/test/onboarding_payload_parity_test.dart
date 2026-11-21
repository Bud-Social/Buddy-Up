import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/onboarding.dart';

void main() {
  test('onboarding submit uses the snake_case keys the backend validates', () {
    const payload = OnboardingPayload(
      primaryGoal: ['muscle_gain'],
      activityLevel: 'moderately_active',
      preferredWorkouts: ['weights'],
      dietaryPreference: 'none',
      preferredTime: 'morning',
      displayName: 'Jane K.',
      username: 'jane_k',
      locationCity: 'Nairobi',
      bio: '5k beginner',
      customInterests: 'hiking',
      newPassword: 'strongpass1',
      termsVersion: '2026-08-v1',
    );

    final json = payload.toJson();
    expect(json['primary_goal'], ['muscle_gain']);
    expect(json['activity_level'], 'moderately_active');
    expect(json['preferred_workouts'], ['weights']);
    expect(json['dietary_preference'], 'none');
    expect(json['preferred_time'], 'morning');
    expect(json['display_name'], 'Jane K.');
    expect(json['username'], 'jane_k');
    expect(json['location_city'], 'Nairobi');
    expect(json['bio'], '5k beginner');
    expect(json['custom_interests'], 'hiking');
    expect(json['new_password'], 'strongpass1');
    expect(json['terms_version'], '2026-08-v1');
    expect(json.containsKey('primaryGoal'), isFalse);
  });

  test('the plan response parses the backend snake_case payload', () {
    final plan = OnboardingPlan.fromJson({
      'primary_goal': 'muscle_gain',
      'recommended_trainer_specialties': ['strength'],
      'recommended_gym_categories': ['holiday_gym'],
      'suggested_workout_plan': {
        'frequency': '3x per week',
        'focus': 'full body',
        'sample_split': ['Push', 'Pull', 'Legs'],
      },
      'buddy_matching_hint': 'Find a strength buddy',
    });

    expect(plan.recommendedTrainerSpecialties, ['strength']);
    expect(plan.suggestedWorkoutPlan?.frequency, '3x per week');
    expect(plan.suggestedWorkoutPlan?.sampleSplit, ['Push', 'Pull', 'Legs']);
    expect(plan.buddyMatchingHint, 'Find a strength buddy');
  });
}
