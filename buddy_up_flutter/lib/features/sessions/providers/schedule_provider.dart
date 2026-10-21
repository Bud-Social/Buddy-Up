import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/gym.dart';
import '../../../data/models/marketplace.dart';
import '../../../data/models/session.dart';
import '../../gym/providers/gym_provider.dart';
import '../../marketplace/providers/marketplace_provider.dart';
import 'session_provider.dart';

/// One dated thing on the member's schedule.
///
/// `startsAt` is nullable because bookings carry a date and a time as separate
/// strings and either may be missing. A row without a parseable time still
/// belongs on the schedule — it is shown at the end rather than dropped.
class ScheduleEntry {
  const ScheduleEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.route,
    this.startsAt,
    this.meta,
  });

  final String id;
  final String title;
  final String subtitle;
  final String kind;
  final String route;
  final DateTime? startsAt;
  final String? meta;
}

class ScheduleData {
  const ScheduleData({
    this.entries = const [],
    this.programmes = const [],
    this.mealPlans = const [],
  });

  final List<ScheduleEntry> entries;
  final List<TrainingProgramme> programmes;
  final List<MealPlan> mealPlans;

  int get ownedPlanCount => programmes.length + mealPlans.length;
}

DateTime? _parseBookingStart(BookingSession booking) {
  final raw = '${booking.scheduledDate}T${booking.scheduledTime}';
  return DateTime.tryParse(raw) ??
      DateTime.tryParse(booking.scheduledDate);
}

/// Bookings + gym enrolments + owned plans in one aggregate.
///
/// Each source is fetched independently and a failing gym must not blank the
/// whole page: a member's bookings are still their schedule even if one gym's
/// enrolment endpoint is down.
final scheduleProvider = FutureProvider<ScheduleData>((ref) async {
  final bookingsFuture = ref.watch(mySessionsProvider.future);
  final programmesFuture = ref.watch(myProgrammesProvider.future);
  final mealPlansFuture = ref.watch(myMealPlansProvider.future);
  final gymRepository = ref.watch(gymRepositoryProvider);

  final results = await Future.wait([
    bookingsFuture.catchError((_) => <BookingSession>[]),
    programmesFuture.catchError((_) => <TrainingProgramme>[]),
    mealPlansFuture.catchError((_) => <MealPlan>[]),
  ]);

  final bookings = results[0] as List<BookingSession>;
  final programmes = results[1] as List<TrainingProgramme>;
  final mealPlans = results[2] as List<MealPlan>;

  final entries = <ScheduleEntry>[
    for (final booking in bookings)
      if (booking.status == 'confirmed' || booking.status == 'pending')
        ScheduleEntry(
          id: 'booking-${booking.id}',
          title: 'Session with ${booking.trainerName}',
          subtitle: booking.sessionType.replaceAll('_', ' '),
          kind: 'booking',
          route: '/sessions/${booking.id}',
          startsAt: _parseBookingStart(booking),
          meta: '${booking.durationMinutes} min',
        ),
  ];

  try {
    final rawGyms = await gymRepository.getGyms(my: true);
    final gyms = (rawGyms['data'] as List)
        .map((e) => Gym.fromJson(e as Map<String, dynamic>))
        .toList();
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day);
    final enrollmentResults = await Future.wait(
      gyms.map((gym) async {
        try {
          final raw = await gymRepository.getMyEnrollments(gym.handle);
          return MapEntry(gym, raw['data'] as List);
        } catch (_) {
          return MapEntry(gym, const []);
        }
      }),
    );
    for (final result in enrollmentResults) {
      final gym = result.key;
      for (final item in result.value) {
        if (item is! Map) continue;
        final post = item['schedule_post_data'];
        if (post is! Map) continue;
        final start = DateTime.tryParse('${post['start_time'] ?? ''}');
        if (start != null && start.isBefore(cutoff)) continue;
        entries.add(
          ScheduleEntry(
            id: 'gym-${item['id']}',
            title: '${post['title'] ?? 'Gym session'}',
            subtitle: gym.name,
            kind: 'gym',
            route: '/gyms/${gym.handle}/schedule',
            startsAt: start,
            meta: '${post['activity_type'] ?? ''}'.replaceAll('_', ' '),
          ),
        );
      }
    }
  } catch (_) {
    // One unreachable gym should not hide bookings; the entry list already
    // contains them.
  }

  entries.sort((a, b) {
    if (a.startsAt == null && b.startsAt == null) return 0;
    if (a.startsAt == null) return 1;
    if (b.startsAt == null) return -1;
    return a.startsAt!.compareTo(b.startsAt!);
  });

  return ScheduleData(
    entries: entries,
    programmes: programmes,
    mealPlans: mealPlans,
  );
});
