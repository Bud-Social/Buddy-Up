/// workoutTypes — the one place that decides which fields a workout type
/// records.
///
/// The backend owns the catalogue (`GET /analytics/workout-types/`, public so
/// it resolves before a session exists). We fetch it once and cache the result
/// at provider level, so every form on a screen shares one request. Until it
/// resolves — and forever if it fails — [localWorkoutTypes] below drives the
/// forms, which keeps category pickers and field visibility correct offline.
///
/// [localWorkoutTypes] must stay in sync with the backend
/// `WORKOUT_TYPE_SPECS` taxonomy: the same 17 keys in the same order, with the
/// same labels, per-type category lists and `measured` flags. Categories are
/// validated per workout type server-side, so a looser fallback would 400 every
/// log made while the catalogue is unavailable.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import 'analytics_format.dart';

/// Every field the log form knows how to render.
const List<String> workoutFieldOrder = [
  'exercise',
  'sets',
  'reps',
  'weight_kg',
  'rounds',
  'distance_km',
  'calories_burned',
  'style',
  'focus',
  'sport',
  'duration_minutes',
];

/// Taxonomy field names the form renders under a different name. The catalogue
/// speaks model column names; the form collects the friendly unit.
const Map<String, String> _fieldAliases = {
  'distance_meters': 'distance_km',
  'calories': 'calories_burned',
  'weight': 'weight_kg',
  'duration': 'duration_minutes',
};

/// Category chip labels — same wording as the backend `category_label()` and
/// the web client, so a muscle group reads identically on every surface.
const Map<String, String> workoutCategoryLabels = {
  // strength / hiit
  'upper': 'Upper',
  'lower': 'Lower',
  'legs': 'Legs',
  'push': 'Push',
  'pull': 'Pull',
  'core': 'Core',
  'arms': 'Arms',
  'full': 'Full',
  'cardio': 'Cardio',
  // yoga / pilates
  'flexibility': 'Flexibility',
  'mobility': 'Mobility',
  'balance': 'Balance',
  'strength': 'Strength',
  'mindfulness': 'Mindfulness',
  'posture': 'Posture',
  // mobility
  'hips': 'Hips',
  'shoulders': 'Shoulders',
  'spine': 'Spine',
  'ankles': 'Ankles',
  // sport
  'football': 'Football',
  'basketball': 'Basketball',
  'cricket': 'Cricket',
  'rugby': 'Rugby',
  'netball': 'Netball',
  'tennis': 'Tennis',
  'volleyball': 'Volleyball',
  'other': 'Other',
};

class WorkoutCategoryOption {
  final String key;
  final String label;

  const WorkoutCategoryOption({required this.key, required this.label});
}

class WorkoutTypeSpec {
  final String label;

  /// Valid categories for this type. Empty for the cardio / distance sports —
  /// those send `category: ''` because the backend rejects a mismatched one.
  final List<WorkoutCategoryOption> categories;
  final List<String> fields;

  /// True when the type is tracked in measured units rather than described.
  final bool measured;

  const WorkoutTypeSpec({
    required this.label,
    this.categories = const [],
    this.fields = const [],
    this.measured = false,
  });

  factory WorkoutTypeSpec.fromJson(String key, Map<String, dynamic> json) {
    return WorkoutTypeSpec(
      label: (json['label'] as String?)?.isNotEmpty == true
          ? json['label'] as String
          : titleCase(key),
      categories: _categoryOptions(json['categories']),
      fields: _normalizeFields(json['fields']),
      measured: json['measured'] is bool
          ? json['measured'] as bool
          : false,
    );
  }

  bool get hasCategories => categories.isNotEmpty;

  bool hasCategory(String key) =>
      categories.any((c) => c.key == key);

  /// Whether the form should render / submit this field for this type.
  bool has(String field) => visibleFields(this).contains(field);
}

class WorkoutTypeSpecs {
  /// Ordered by the canonical type list, then any server-only additions.
  final Map<String, WorkoutTypeSpec> types;

  const WorkoutTypeSpecs(this.types);

  List<String> get order => types.keys.toList();

  /// The spec for a type, falling back to a neutral generic entry.
  WorkoutTypeSpec specFor(String? key) {
    if (key != null && types[key] != null) return types[key]!;
    return types['other'] ?? localWorkoutTypes['other']!;
  }
}

/// Duration is recorded for every workout type, so it is never hidden.
List<String> withDuration(List<String> fields) {
  return fields.contains('duration_minutes')
      ? fields
      : [...fields, 'duration_minutes'];
}

/// Ordered list of the fields the form should render for a type.
List<String> visibleFields(WorkoutTypeSpec spec) {
  final allowed = withDuration(spec.fields).toSet();
  return workoutFieldOrder.where(allowed.contains).toList();
}

bool hasField(WorkoutTypeSpec spec, String field) => spec.has(field);

/// `''` whenever the type has no categories or the pick isn't in its list.
String normalizeCategory(WorkoutTypeSpec spec, String? category) {
  if (category == null || category.isEmpty) return '';
  return spec.hasCategory(category) ? category : '';
}

/// Copy for types the platform doesn't measure. Without it the form looks
/// broken — sets and reps simply never appear for a yoga log.
String? measuredNotice(WorkoutTypeSpec spec) {
  if (spec.measured) return null;
  final byDistance = spec.has('distance_km');
  return '${spec.label} isn’t tracked in sets or reps. '
      'Log ${byDistance ? 'time and distance' : 'the time'} instead.';
}

WorkoutCategoryOption _option(String key) => WorkoutCategoryOption(
      key: key,
      label: workoutCategoryLabels[key] ?? titleCase(key),
    );

List<WorkoutCategoryOption> _categoryOptions(dynamic raw) {
  if (raw is! List) return const [];
  return [
    for (final entry in raw)
      if (entry is String && entry.isNotEmpty)
        _option(entry)
      else if (entry is Map && entry['key'] is String)
        WorkoutCategoryOption(
          key: entry['key'] as String,
          label: (entry['label'] as String?)?.isNotEmpty == true
              ? entry['label'] as String
              : _option(entry['key'] as String).label,
        ),
  ];
}

/// Taxonomy fields → form fields, dropping anything the form can't render. An
/// empty list is meaningful (`fields: []`), so it is returned as-is.
List<String> _normalizeFields(dynamic raw) {
  if (raw is! List) return const [];
  final known = <String>[];
  for (final entry in raw) {
    if (entry is! String) continue;
    final field = _fieldAliases[entry] ?? entry;
    if (workoutFieldOrder.contains(field) && !known.contains(field)) {
      known.add(field);
    }
  }
  return known;
}

WorkoutTypeSpec _spec(
  String label,
  List<String> categoryKeys,
  List<String> fields, [
  bool measured = false,
]) {
  return WorkoutTypeSpec(
    label: label,
    categories: [
      for (final key in categoryKeys) _option(key),
    ],
    fields: withDuration(fields),
    measured: measured,
  );
}

/// Offline fallback — mirrors the backend `WORKOUT_TYPE_SPECS` taxonomy: the
/// same 16 keys in the same order, with the same labels, category lists and
/// measured flags.
final Map<String, WorkoutTypeSpec> localWorkoutTypes = {
  'strength': _spec(
    'Strength',
    ['upper', 'lower', 'push', 'pull', 'legs', 'arms', 'core', 'full'],
    ['exercise', 'sets', 'reps', 'weight_kg'],
    true,
  ),
  'hiit': _spec(
    'HIIT',
    ['full', 'upper', 'lower', 'core', 'cardio'],
    ['exercise', 'rounds'],
    true,
  ),
  'cardio': _spec(
    'Cardio',
    const [],
    ['distance_km', 'calories_burned'],
    true,
  ),
  'running': _spec(
    'Running',
    const [],
    ['distance_km', 'calories_burned'],
    true,
  ),
  'walking': _spec(
    'Walking',
    const [],
    ['distance_km', 'calories_burned'],
    true,
  ),
  'cycling': _spec(
    'Cycling',
    const [],
    ['distance_km', 'calories_burned'],
    true,
  ),
  'swimming': _spec(
    'Swimming',
    const [],
    ['distance_km', 'calories_burned'],
    true,
  ),
  'climbing': _spec('Climbing', const [], const []),
  'rowing': _spec('Rowing', const [], const []),
  'dance': _spec('Dance', const [], const []),
  'yoga': _spec(
    'Yoga',
    ['flexibility', 'mobility', 'balance', 'strength', 'mindfulness'],
    ['style'],
  ),
  'pilates': _spec(
    'Pilates',
    ['core', 'posture', 'flexibility', 'mobility', 'full'],
    ['style'],
  ),
  'mobility': _spec(
    'Mobility',
    ['hips', 'shoulders', 'spine', 'ankles', 'full'],
    ['focus'],
  ),
  'sport': _spec(
    'Sport',
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
    ['sport'],
  ),
  'boxing': _spec('Boxing', const [], ['style']),
  'martial_arts': _spec('Martial Arts', const [], ['style']),
  'other': _spec('Other', const [], const []),
};

final WorkoutTypeSpecs localWorkoutTypeSpecs =
    WorkoutTypeSpecs(localWorkoutTypes);

/// Spec catalogue for both declarative (watch) and imperative (share, timer
/// POST) call sites — the local fallback while the request is still in flight.
WorkoutTypeSpecs workoutTypesOrLocal(AsyncValue<WorkoutTypeSpecs> async) =>
    async.value ?? localWorkoutTypeSpecs;

/// Server spec wins for categories (an empty list is meaningful: those types
/// send `''`), falls back to local otherwise. Fields only override when the
/// server actually enumerates them, so a spec that ships `fields: []` cannot
/// strip the duration every log needs.
WorkoutTypeSpec _mergeSpec(
  String key,
  dynamic raw, [
  WorkoutTypeSpec? local,
]) {
  if (raw is! Map) return local ?? localWorkoutTypes['other']!;
  final json = raw.cast<String, dynamic>();
  final remoteCategories = json.containsKey('categories')
      ? _categoryOptions(json['categories'])
      : null;
  final remoteFields = json.containsKey('fields')
      ? _normalizeFields(json['fields'])
      : null;
  // `exercise` is a stored column but not a taxonomy field — keep it wherever
  // the local spec offers it so a strength log still names the exercise.
  if (local != null &&
      local.has('exercise') &&
      !(remoteFields ?? local.fields).contains('exercise')) {
    remoteFields?.insert(0, 'exercise');
  }
  return WorkoutTypeSpec(
    label: (json['label'] as String?)?.isNotEmpty == true
        ? json['label'] as String
        : (local?.label ?? titleCase(key)),
    categories: remoteCategories ?? local?.categories ?? const [],
    fields: withDuration(remoteFields ?? local?.fields ?? const []),
    measured: json['measured'] is bool
        ? json['measured'] as bool
        : (local?.measured ?? false),
  );
}

/// Merge a fetched catalogue payload over the local fallback. Accepts both
/// `{types: {...}}` and the envelope's `{workout_types: {...}}` shapes.
WorkoutTypeSpecs mergeWorkoutTypes(dynamic payload) {
  Map<String, dynamic>? remote;
  if (payload is Map) {
    final types = payload['types'] ?? payload['workout_types'];
    if (types is Map) remote = types.cast<String, dynamic>();
  }
  final merged = <String, WorkoutTypeSpec>{};
  for (final key in localWorkoutTypes.keys) {
    merged[key] = remote != null && remote.containsKey(key)
        ? _mergeSpec(key, remote[key], localWorkoutTypes[key])
        : localWorkoutTypes[key]!;
  }
  if (remote != null) {
    for (final key in remote.keys) {
      if (!merged.containsKey(key)) {
        merged[key] = _mergeSpec(key, remote[key]);
      }
    }
  }
  return WorkoutTypeSpecs(merged);
}

/// The catalogue for the forms. Renders the local fallback immediately and
/// swaps in the server copy once the cached request resolves; `AsyncValue.value`
/// is therefore never null, so a form can always pick a spec.
final workoutTypesProvider = FutureProvider<WorkoutTypeSpecs>((ref) async {
  try {
    final res = await ApiClient().dio.get<dynamic>('/analytics/workout-types/');
    final body = res.data;
    final data = body is Map && body['data'] is Map
        ? (body['data'] as Map).cast<String, dynamic>()
        : body;
    if (data is! Map) return localWorkoutTypeSpecs;
    final merged = mergeWorkoutTypes(data);
    return merged.order.isEmpty ? localWorkoutTypeSpecs : merged;
  } catch (_) {
    // The catalogue is public and non-critical — never block the form on it.
    return localWorkoutTypeSpecs;
  }
});