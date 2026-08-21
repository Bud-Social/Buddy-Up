/// Country-aware age gating for content categories.
///
/// Buddy-Up exposes a separate "Mature" (18+/16+) category for adult fitness
/// content: adult-only live sessions, adult marketplace items, etc.
/// The minimum age to view the category is
/// country-dependent:
///
/// * 18+ for the vast majority of countries (including Kenya).
/// * 16+ only where local law sets the relevant age floor at 16 and the
///   platform has confirmed, via legal review, that 16-year-olds may lawfully
///   access such content.
///
/// When in doubt the platform defaults to 18+.
class AgeGating {
  /// Content rating values shared across content models.
  static const String contentGeneral = 'general';
  static const String contentMature = 'mature';

  static const int defaultMinAge = 18;

  /// Countries where local law sets the mature-content age floor at 16.
  /// Empty by default. Extend after legal review confirms a lower threshold.
  static const Set<String> minAge16Countries = {};

  /// Computes an integer age from a [DateTime] date of birth.
  static int calculateAge(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  /// Minimum age required to access mature content for a [country].
  /// Returns 18+ for unknown countries.
  static int matureContentMinAge(String? country) {
    final normalized = (country ?? '').trim().toLowerCase();
    if (minAge16Countries.contains(normalized)) return 16;
    return defaultMinAge;
  }

  /// Whether a user of [age] may access mature content for [country].
  static bool canAccessMature({int? age, String? country}) {
    if (age == null) return false;
    return age >= matureContentMinAge(country);
  }
}
