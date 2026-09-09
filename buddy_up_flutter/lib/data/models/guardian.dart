/// Guardian-link models for /auth/guardians/.
/// Manual fromJson — tolerant of missing/null fields.
library;

class GuardianPerson {
  final String username;
  final String displayName;
  final String avatarUrl;

  const GuardianPerson({
    required this.username,
    required this.displayName,
    required this.avatarUrl,
  });

  factory GuardianPerson.fromJson(Map<String, dynamic> json) {
    return GuardianPerson(
      username: json['username']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
    );
  }
}

class GuardianLink {
  final int id;
  final String role; // 'guardian' | 'teen'
  final String status; // 'pending' | 'accepted' | ...
  final String inviteEmail;
  final Map<String, dynamic> permissions;
  final String createdAt;
  final String? acceptedAt;
  final GuardianPerson? teen;
  final GuardianPerson? guardian;

  const GuardianLink({
    required this.id,
    required this.role,
    required this.status,
    required this.inviteEmail,
    required this.permissions,
    required this.createdAt,
    this.acceptedAt,
    this.teen,
    this.guardian,
  });

  factory GuardianLink.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> readPerson(String key) {
      final raw = json[key];
      return raw is Map<String, dynamic> ? raw : const {};
    }

    final rawPerms = json['permissions'];
    return GuardianLink(
      id: (json['id'] as num?)?.toInt() ?? 0,
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      inviteEmail: json['invite_email']?.toString() ?? '',
      permissions:
          rawPerms is Map<String, dynamic> ? rawPerms : const {},
      createdAt: json['created_at']?.toString() ?? '',
      acceptedAt: json['accepted_at']?.toString(),
      teen: json['teen'] is Map ? GuardianPerson.fromJson(readPerson('teen')) : null,
      guardian: json['guardian'] is Map
          ? GuardianPerson.fromJson(readPerson('guardian'))
          : null,
    );
  }
}

class GuardianDashboardEntry {
  final int linkId;
  final GuardianPerson teen;
  final int accountAgeDays;
  final String lastActive;
  final int postsLast7d;
  final int workoutsLast7d;
  final int upcomingSessions;
  final Map<String, dynamic> permissions;

  const GuardianDashboardEntry({
    required this.linkId,
    required this.teen,
    required this.accountAgeDays,
    required this.lastActive,
    required this.postsLast7d,
    required this.workoutsLast7d,
    required this.upcomingSessions,
    required this.permissions,
  });

  factory GuardianDashboardEntry.fromJson(Map<String, dynamic> json) {
    final rawTeen = json['teen'];
    final rawPerms = json['permissions'];
    return GuardianDashboardEntry(
      linkId: (json['link_id'] as num?)?.toInt() ?? 0,
      teen: rawTeen is Map<String, dynamic>
          ? GuardianPerson.fromJson(rawTeen)
          : const GuardianPerson(username: '', displayName: 'Unknown', avatarUrl: ''),
      accountAgeDays: (json['account_age_days'] as num?)?.toInt() ?? 0,
      lastActive: json['last_active']?.toString() ?? '',
      postsLast7d: (json['posts_last_7d'] as num?)?.toInt() ?? 0,
      workoutsLast7d: (json['workouts_last_7d'] as num?)?.toInt() ?? 0,
      upcomingSessions: (json['upcoming_sessions'] as num?)?.toInt() ?? 0,
      permissions: rawPerms is Map<String, dynamic> ? rawPerms : const {},
    );
  }
}

/// Extracts the payload list from the API envelope ({data: [...]}) or a bare
/// list response.
List<dynamic> extractDataList(dynamic raw) {
  if (raw is List) return raw;
  if (raw is Map<String, dynamic>) {
    final data = raw['data'];
    if (data is List) return data;
  }
  return const [];
}
