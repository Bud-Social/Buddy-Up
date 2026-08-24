import 'package:flutter/material.dart';

class EventCategory {
  final String key;
  final String label;
  final String section;
  final IconData icon;

  const EventCategory({
    required this.key,
    required this.label,
    required this.section,
    required this.icon,
  });
}

const List<EventCategory> kEventCategories = [
  // Fitness & Gym
  EventCategory(key: 'fitness', label: 'Fitness', section: 'Fitness & Gym', icon: Icons.fitness_center),
  EventCategory(key: 'weightlifting', label: 'Weightlifting', section: 'Fitness & Gym', icon: Icons.fitness_center),
  EventCategory(key: 'hiit', label: 'HIIT', section: 'Fitness & Gym', icon: Icons.bolt),
  EventCategory(key: 'crossfit', label: 'CrossFit', section: 'Fitness & Gym', icon: Icons.sports_kabaddi),
  EventCategory(key: 'calisthenics', label: 'Calisthenics', section: 'Fitness & Gym', icon: Icons.accessibility_new),
  EventCategory(key: 'bodybuilding', label: 'Bodybuilding', section: 'Fitness & Gym', icon: Icons.sports_gymnastics),

  // Outdoor & Cardio
  EventCategory(key: 'running', label: 'Running', section: 'Outdoor & Cardio', icon: Icons.directions_run),
  EventCategory(key: 'cycling', label: 'Cycling', section: 'Outdoor & Cardio', icon: Icons.directions_bike),
  EventCategory(key: 'hiking', label: 'Hiking', section: 'Outdoor & Cardio', icon: Icons.terrain),
  EventCategory(key: 'climbing', label: 'Climbing', section: 'Outdoor & Cardio', icon: Icons.landscape),
  EventCategory(key: 'water_sports', label: 'Water Sports', section: 'Outdoor & Cardio', icon: Icons.pool),
  EventCategory(key: 'swimming', label: 'Swimming', section: 'Outdoor & Cardio', icon: Icons.pool),
  EventCategory(key: 'outdoor', label: 'Outdoor Adventure', section: 'Outdoor & Cardio', icon: Icons.nature_people),

  // Mind & Body
  EventCategory(key: 'yoga', label: 'Yoga', section: 'Mind & Body', icon: Icons.self_improvement),
  EventCategory(key: 'pilates', label: 'Pilates', section: 'Mind & Body', icon: Icons.spa),
  EventCategory(key: 'meditation', label: 'Meditation', section: 'Mind & Body', icon: Icons.nights_stay),
  EventCategory(key: 'wellness', label: 'Wellness & Recovery', section: 'Mind & Body', icon: Icons.favorite),
  EventCategory(key: 'mental_health', label: 'Mental Health', section: 'Mind & Body', icon: Icons.psychology),

  // Competitions & Sports
  EventCategory(key: 'competition', label: 'Competition', section: 'Sports & Competition', icon: Icons.emoji_events),
  EventCategory(key: 'tournament', label: 'Tournament', section: 'Sports & Competition', icon: Icons.military_tech),
  EventCategory(key: 'race', label: 'Race & Marathon', section: 'Sports & Competition', icon: Icons.flag),
  EventCategory(key: 'boxing', label: 'Boxing & MMA', section: 'Sports & Competition', icon: Icons.sports_mma),
  EventCategory(key: 'football', label: 'Football / Soccer', section: 'Sports & Competition', icon: Icons.sports_soccer),
  EventCategory(key: 'basketball', label: 'Basketball', section: 'Sports & Competition', icon: Icons.sports_basketball),

  // Social & Learning
  EventCategory(key: 'social', label: 'Social Meetup', section: 'Social & Workshops', icon: Icons.people),
  EventCategory(key: 'networking', label: 'Networking', section: 'Social & Workshops', icon: Icons.connect_without_contact),
  EventCategory(key: 'nutrition', label: 'Nutrition & Cooking', section: 'Social & Workshops', icon: Icons.restaurant),
  EventCategory(key: 'workshop', label: 'Workshop & Clinic', section: 'Social & Workshops', icon: Icons.school),
  EventCategory(key: 'seminar', label: 'Seminar', section: 'Social & Workshops', icon: Icons.mic),
  EventCategory(key: 'party', label: 'Fitness Party / Rave', section: 'Social & Workshops', icon: Icons.celebration),
  EventCategory(key: 'other', label: 'Other', section: 'Other', icon: Icons.more_horiz),
];
