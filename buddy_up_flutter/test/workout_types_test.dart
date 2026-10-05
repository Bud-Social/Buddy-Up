import 'package:buddy_up_flutter/features/analytics/utils/analytics_share.dart';
import 'package:buddy_up_flutter/features/analytics/utils/workout_types.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keys the backend `WORKOUT_TYPE_KEYS` taxonomy publishes, in order. If this
/// list changes, the sibling web/backend task changed too.
const List<String> _typeKeys = [
  'strength',
  'hiit',
  'cardio',
  'running',
  'walking',
  'cycling',
  'swimming',
  'climbing',
  'rowing',
  'dance',
  'yoga',
  'pilates',
  'mobility',
  'sport',
  'boxing',
  'martial_arts',
  'other',
];

final WorkoutTypeSpecs types = localWorkoutTypeSpecs;

List<String> _fieldsOf(String key) => visibleFields(types.specFor(key));

List<String> _categoriesOf(String key) =>
    types.specFor(key).categories.map((c) => c.key).toList();

void main() {
  group('local fallback catalogue', () {
    test('covers exactly the backend type list, in order', () {
      expect(types.order, _typeKeys);
    });

    test('gives every type a duration field and a label', () {
      for (final key in _typeKeys) {
        expect(types.specFor(key).label, isNotEmpty);
        expect(_fieldsOf(key), contains('duration_minutes'));
      }
    });

    test('leaves cardio, the distance sports and the described types uncategorised', () {
      for (final key in [
        'cardio',
        'running',
        'walking',
        'cycling',
        'swimming',
        'climbing',
        'rowing',
        'dance',
        'boxing',
        'martial_arts',
        'other',
      ]) {
        expect(_categoriesOf(key), isEmpty, reason: key);
      }
    });

    test('mirrors the taxonomy category lists exactly', () {
      expect(_categoriesOf('strength'),
          ['upper', 'lower', 'push', 'pull', 'legs', 'arms', 'core', 'full']);
      expect(_categoriesOf('hiit'), ['full', 'upper', 'lower', 'core', 'cardio']);
      expect(_categoriesOf('yoga'),
          ['flexibility', 'mobility', 'balance', 'strength', 'mindfulness']);
      expect(_categoriesOf('pilates'),
          ['core', 'posture', 'flexibility', 'mobility', 'full']);
      expect(_categoriesOf('mobility'),
          ['hips', 'shoulders', 'spine', 'ankles', 'full']);
      expect(
        _categoriesOf('sport'),
        [
          'football',
          'basketball',
          'tennis',
          'cricket',
          'rugby',
          'netball',
          'volleyball',
          'other',
        ],
      );
    });

    test('labels every category the way the backend does', () {
      expect(
        types.specFor('yoga').categories.firstWhere((c) => c.key == 'mindfulness').label,
        'Mindfulness',
      );
      expect(
        types.specFor('sport').categories.firstWhere((c) => c.key == 'other').label,
        'Other',
      );
    });
  });

  group('per-type field visibility', () {
    test('shows sets, reps and weight for strength', () {
      expect(_fieldsOf('strength'),
          containsAll(['sets', 'reps', 'weight_kg', 'duration_minutes']));
      expect(types.specFor('strength').measured, isTrue);
    });

    test('shows rounds for hiit and distance for cardio', () {
      expect(_fieldsOf('hiit'), contains('rounds'));
      expect(_fieldsOf('cardio'),
          ['distance_km', 'calories_burned', 'duration_minutes']);
      expect(types.specFor('cardio').measured, isTrue);
    });

    test('shows distance and calories for every GPS distance sport', () {
      for (final key in ['running', 'walking', 'cycling', 'swimming']) {
        expect(_fieldsOf(key), contains('distance_km'), reason: key);
        expect(_fieldsOf(key), contains('calories_burned'), reason: key);
      }
      // Rowing and climbing carry no measured fields in the taxonomy.
      expect(_fieldsOf('rowing'), ['duration_minutes']);
      expect(_fieldsOf('climbing'), ['duration_minutes']);
    });

    test('gives yoga and pilates a style and never sets/reps/weight', () {
      for (final key in ['yoga', 'pilates']) {
        final spec = types.specFor(key);
        expect(visibleFields(spec), ['style', 'duration_minutes'], reason: key);
        expect(hasField(spec, 'sets'), isFalse, reason: key);
        expect(hasField(spec, 'reps'), isFalse, reason: key);
        expect(hasField(spec, 'weight_kg'), isFalse, reason: key);
      }
    });

    test('gives mobility a focus, sport a sport and the combat types a style', () {
      expect(_fieldsOf('mobility'), ['focus', 'duration_minutes']);
      expect(_fieldsOf('sport'), ['sport', 'duration_minutes']);
      for (final key in ['boxing', 'martial_arts']) {
        expect(_fieldsOf(key), ['style', 'duration_minutes'], reason: key);
      }
      expect(_fieldsOf('dance'), ['duration_minutes']);
      expect(_fieldsOf('other'), ['duration_minutes']);
    });

    test('always keeps duration, even when a spec omits it', () {
      expect(withDuration(const []), ['duration_minutes']);
    });
  });

  group('normalizeCategory', () {
    test('rejects a category that belongs to another type', () {
      // 'upper' is a strength category; sending it on a yoga log is a 400.
      expect(normalizeCategory(types.specFor('strength'), 'upper'), 'upper');
      expect(normalizeCategory(types.specFor('yoga'), 'upper'), '');
      expect(normalizeCategory(types.specFor('yoga'), 'balance'), 'balance');
      // Cardio has no categories at all — it sends ''.
      expect(normalizeCategory(types.specFor('cardio'), 'upper'), '');
      expect(normalizeCategory(types.specFor('cardio'), null), '');
    });
  });

  group('measuredNotice', () {
    test('is silent for measured types and explains the unmeasured ones', () {
      expect(measuredNotice(types.specFor('strength')), isNull);
      expect(measuredNotice(types.specFor('running')), isNull);
      expect(measuredNotice(types.specFor('yoga')), isNotNull);
      expect(measuredNotice(types.specFor('yoga')), contains('Yoga'));
    });
  });

  group('mergeWorkoutTypes', () {
    test('server categories win, including an empty list', () {
      final merged = mergeWorkoutTypes({
        'workout_types': {
          'yoga': {
            'label': 'Yoga',
            'categories': ['flow', 'restorative'],
            'fields': ['style'],
            'measured': false,
          },
          'running': {
            'label': 'Running',
            'categories': [],
            'fields': ['distance_meters', 'calories_burned'],
            'measured': true,
          },
        },
      });
      expect(
        merged.specFor('yoga').categories.map((c) => c.key).toList(),
        ['flow', 'restorative'],
      );
      expect(merged.specFor('running').categories, isEmpty);
      // Model column names map onto the field the form collects.
      expect(merged.specFor('running').has('distance_km'), isTrue);
      expect(merged.specFor('running').has('calories_burned'), isTrue);
      // Untouched types keep the offline fallback.
      expect(
        merged.specFor('mobility').categories.map((c) => c.key).toList(),
        _categoriesOf('mobility'),
      );
    });

    test('keeps duration when the server sends no fields', () {
      final merged = mergeWorkoutTypes({
        'types': {
          'climbing': {'label': 'Climbing', 'categories': [], 'fields': []},
        },
      });
      expect(merged.specFor('climbing').has('duration_minutes'), isTrue);
      expect(merged.specFor('climbing').has('sets'), isFalse);
    });

    test('adds server-only types after the canonical order', () {
      final merged = mergeWorkoutTypes({
        'types': {
          'sauna': {'label': 'Sauna', 'categories': [], 'fields': []},
        },
      });
      expect(merged.order.first, 'strength');
      expect(merged.order.last, 'sauna');
    });
  });

  group('buildShareText', () {
    test('includes type, category, duration and distance', () {
      final text = buildShareText(const ShareFacts(
        label: 'Strength',
        category: 'Upper',
        durationMinutes: 45,
        distanceKm: 5,
        calories: 320,
      ));
      expect(text, contains('Strength · Upper'));
      expect(text, contains('45 min'));
      expect(text, contains('5.0 km'));
      expect(text, contains('320 kcal'));
      expect(text, contains('BuddyUp'));
    });

    test('omits facts the row does not have', () {
      final text = buildShareText(const ShareFacts(label: 'Yoga', category: 'Balance'));
      expect(text, 'Yoga · Balance. Logged on BuddyUp.');
    });

    test('points at the analytics deep link', () {
      expect(analyticsShareUrl(), 'https://buddyup.app/app/analytics');
    });
  });
}