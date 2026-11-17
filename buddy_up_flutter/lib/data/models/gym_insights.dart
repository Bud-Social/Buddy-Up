/// Hand-written, defensive decoders for the gym console insights endpoints.
///
/// The backend renders artifact quantities and decimal-ish figures through
/// DRF's JSON encoder as strings in some paths, so every number goes
/// through num coercion. A payload that does not match expectations degrades
/// to zeros/empty rather than throwing inside a panel.
class DailyCount {
  final DateTime? day;
  final double count;

  const DailyCount({required this.day, required this.count});

  factory DailyCount.fromJson(Map<String, dynamic> json) => DailyCount(
        day: DateTime.tryParse(json['date']?.toString() ?? ''),
        count: _asDouble(json['count']),
      );
}

class SessionsSummary {
  final int sessions30d;
  final int upcoming30d;
  final int cancelled30d;
  final int noShows30d;
  final int checkIns30d;
  final int uniqueAttendees30d;

  const SessionsSummary({
    this.sessions30d = 0,
    this.upcoming30d = 0,
    this.cancelled30d = 0,
    this.noShows30d = 0,
    this.checkIns30d = 0,
    this.uniqueAttendees30d = 0,
  });

  factory SessionsSummary.fromJson(Map<String, dynamic> json) =>
      SessionsSummary(
        sessions30d: _asInt(json['sessions_30d']),
        upcoming30d: _asInt(json['upcoming_30d']),
        cancelled30d: _asInt(json['cancelled_30d']),
        noShows30d: _asInt(json['no_shows_30d']),
        checkIns30d: _asInt(json['check_ins_30d']),
        uniqueAttendees30d: _asInt(json['unique_attendees_30d']),
      );
}

class GymInsightBooking {
  final String id;
  final String clientDisplay;
  final String clientAvatar;
  final String trainerDisplay;
  final String trainerAvatar;
  final String sessionType;
  final String status;
  final DateTime? scheduledAt;
  final int? durationMinutes;

  const GymInsightBooking({
    this.id = '',
    this.clientDisplay = '',
    this.clientAvatar = '',
    this.trainerDisplay = '',
    this.trainerAvatar = '',
    this.sessionType = '',
    this.status = '',
    this.scheduledAt,
    this.durationMinutes,
  });

  factory GymInsightBooking.fromJson(Map<String, dynamic> json) =>
      GymInsightBooking(
        id: json['id']?.toString() ?? '',
        clientDisplay: json['client_display']?.toString() ?? '',
        clientAvatar: json['client_avatar']?.toString() ?? '',
        trainerDisplay: json['trainer_display']?.toString() ?? '',
        trainerAvatar: json['trainer_avatar']?.toString() ?? '',
        sessionType: json['session_type']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        scheduledAt: DateTime.tryParse(json['scheduled_at']?.toString() ?? ''),
        durationMinutes: _asIntOrNull(json['duration_minutes']),
      );
}

class GymSessionsData {
  final SessionsSummary summary;
  final List<GymInsightBooking> bookings;
  final List<DailyCount> checkInsDaily;

  const GymSessionsData({
    required this.summary,
    this.bookings = const [],
    this.checkInsDaily = const [],
  });

  factory GymSessionsData.fromJson(Map<String, dynamic> json) =>
      GymSessionsData(
        summary: SessionsSummary.fromJson(_mapOf(json['summary'])),
        bookings: _mapList(json['bookings']).map(GymInsightBooking.fromJson).toList(),
        checkInsDaily: _mapList(json['check_ins_daily']).map(DailyCount.fromJson).toList(),
      );
}

class GymMessageMember {
  final String username;
  final String displayName;
  final String avatarUrl;
  final String role;

  const GymMessageMember({
    this.username = '',
    this.displayName = '',
    this.avatarUrl = '',
    this.role = '',
  });

  factory GymMessageMember.fromJson(Map<String, dynamic> json) =>
      GymMessageMember(
        username: json['username']?.toString() ?? '',
        displayName: json['display_name']?.toString() ?? '',
        avatarUrl: json['avatar_url']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
      );
}

class GymMessageConversation {
  final String id;
  final String kind;
  final String name;
  final List<GymMessageMember> members;
  final DateTime? lastMessageAt;
  final String lastMessage;
  final bool isCommunity;

  const GymMessageConversation({
    this.id = '',
    this.kind = 'direct',
    this.name = '',
    this.members = const [],
    this.lastMessageAt,
    this.lastMessage = '',
    this.isCommunity = false,
  });

  factory GymMessageConversation.fromJson(Map<String, dynamic> json) =>
      GymMessageConversation(
        id: json['id']?.toString() ?? '',
        kind: json['kind']?.toString() ?? 'direct',
        name: json['name']?.toString() ?? '',
        members: _mapList(json['members']).map(GymMessageMember.fromJson).toList(),
        lastMessageAt: DateTime.tryParse(json['last_message_at']?.toString() ?? ''),
        lastMessage: json['last_message']?.toString() ?? '',
        isCommunity: json['is_community'] == true,
      );
}

class GymInboundMessage {
  final String id;
  final String body;
  final String senderDisplay;
  final String senderAvatar;
  final DateTime? sentAt;
  final String conversation;

  const GymInboundMessage({
    this.id = '',
    this.body = '',
    this.senderDisplay = '',
    this.senderAvatar = '',
    this.sentAt,
    this.conversation = '',
  });

  factory GymInboundMessage.fromJson(Map<String, dynamic> json) =>
      GymInboundMessage(
        id: json['id']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        senderDisplay: json['sender_display']?.toString() ?? '',
        senderAvatar: json['sender_avatar']?.toString() ?? '',
        sentAt: DateTime.tryParse(json['sent_at']?.toString() ?? ''),
        conversation: json['conversation']?.toString() ?? '',
      );
}

class GymMessagesData {
  final List<GymMessageConversation> conversations;
  final List<GymInboundMessage> recentInbound;
  final int communityChats;
  final int groupChats;
  final int directThreads;
  final int inbound7d;

  const GymMessagesData({
    this.conversations = const [],
    this.recentInbound = const [],
    this.communityChats = 0,
    this.groupChats = 0,
    this.directThreads = 0,
    this.inbound7d = 0,
  });

  factory GymMessagesData.fromJson(Map<String, dynamic> json) {
    final summary = _mapOf(json['summary']);
    return GymMessagesData(
      conversations: _mapList(json['conversations'])
          .map(GymMessageConversation.fromJson)
          .toList(),
      recentInbound: _mapList(json['recent_inbound'])
          .map(GymInboundMessage.fromJson)
          .toList(),
      communityChats: _asInt(summary['community_chats']),
      groupChats: _asInt(summary['group_chats']),
      directThreads: _asInt(summary['direct_threads']),
      inbound7d: _asInt(summary['inbound_7d']),
    );
  }
}

class GymLinkedCommunity {
  final String id;
  final String name;
  final String description;
  final String avatarUrl;
  final int memberCount;
  final int postCount;
  final bool isPublic;
  final bool isPrimary;
  final bool isMember;
  final bool isGymFormed;

  const GymLinkedCommunity({
    this.id = '',
    this.name = '',
    this.description = '',
    this.avatarUrl = '',
    this.memberCount = 0,
    this.postCount = 0,
    this.isPublic = true,
    this.isPrimary = false,
    this.isMember = false,
    this.isGymFormed = false,
  });

  factory GymLinkedCommunity.fromJson(Map<String, dynamic> json) =>
      GymLinkedCommunity(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        avatarUrl: json['avatar_url']?.toString() ?? '',
        memberCount: _asInt(json['member_count']),
        postCount: _asInt(json['post_count']),
        isPublic: json['is_public'] != false,
        isPrimary: json['is_primary'] == true,
        isMember: json['is_member'] == true,
        isGymFormed: json['is_gym_formed'] == true,
      );
}

class GymDiscoverableCommunity {
  final String id;
  final String name;
  final String description;
  final String avatarUrl;
  final int memberCount;

  const GymDiscoverableCommunity({
    this.id = '',
    this.name = '',
    this.description = '',
    this.avatarUrl = '',
    this.memberCount = 0,
  });

  factory GymDiscoverableCommunity.fromJson(Map<String, dynamic> json) =>
      GymDiscoverableCommunity(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        avatarUrl: json['avatar_url']?.toString() ?? '',
        memberCount: _asInt(json['member_count']),
      );
}

class GymCommunitiesData {
  final List<GymLinkedCommunity> linked;
  final List<GymDiscoverableCommunity> discoverable;
  final int primaryCount;

  const GymCommunitiesData({
    this.linked = const [],
    this.discoverable = const [],
    this.primaryCount = 0,
  });

  factory GymCommunitiesData.fromJson(Map<String, dynamic> json) =>
      GymCommunitiesData(
        linked: _mapList(json['linked']).map(GymLinkedCommunity.fromJson).toList(),
        discoverable:
            _mapList(json['discoverable']).map(GymDiscoverableCommunity.fromJson).toList(),
        primaryCount: _asInt(json['primary_count']),
      );
}

class GymAnalyticsKpis {
  final int activeMembers;
  final int newMembers30d;
  final int churned30d;
  final double retentionRate30d;
  final double activationRate30d;
  final int checkIns30d;
  final double avgCheckInsPerDay;
  final int uniqueAttendees30d;
  final double visitRate30d;
  final int bookings30d;
  final int completedBookings30d;
  final int messages30d;
  final int inboundClientMessages30d;
  final int communityMembers;
  final int revenue30dArtifacts;
  final int revenueLifetimeArtifacts;
  final int posts30d;
  final int joinRequests30d;
  final int joinRequestsApproved30d;
  final double joinConversion30d;
  final int eventsHosted;
  final int eventsHosted30d;
  final int productsSold;
  final int productsSold30d;
  final int programmesSold;
  final int programmesSold30d;
  final int mealPlansSold;
  final int mealPlansSold30d;
  final int shopOrders30d;

  const GymAnalyticsKpis({
    this.activeMembers = 0,
    this.newMembers30d = 0,
    this.churned30d = 0,
    this.retentionRate30d = 0,
    this.activationRate30d = 0,
    this.checkIns30d = 0,
    this.avgCheckInsPerDay = 0,
    this.uniqueAttendees30d = 0,
    this.visitRate30d = 0,
    this.bookings30d = 0,
    this.completedBookings30d = 0,
    this.messages30d = 0,
    this.inboundClientMessages30d = 0,
    this.communityMembers = 0,
    this.revenue30dArtifacts = 0,
    this.revenueLifetimeArtifacts = 0,
    this.posts30d = 0,
    this.joinRequests30d = 0,
    this.joinRequestsApproved30d = 0,
    this.joinConversion30d = 0,
    this.eventsHosted = 0,
    this.eventsHosted30d = 0,
    this.productsSold = 0,
    this.productsSold30d = 0,
    this.programmesSold = 0,
    this.programmesSold30d = 0,
    this.mealPlansSold = 0,
    this.mealPlansSold30d = 0,
    this.shopOrders30d = 0,
  });

  factory GymAnalyticsKpis.fromJson(Map<String, dynamic> json) =>
      GymAnalyticsKpis(
        activeMembers: _asInt(json['active_members']),
        newMembers30d: _asInt(json['new_members_30d']),
        churned30d: _asInt(json['churned_30d']),
        retentionRate30d: _asDouble(json['retention_rate_30d']),
        activationRate30d: _asDouble(json['activation_rate_30d']),
        checkIns30d: _asInt(json['check_ins_30d']),
        avgCheckInsPerDay: _asDouble(json['avg_check_ins_per_day']),
        uniqueAttendees30d: _asInt(json['unique_attendees_30d']),
        visitRate30d: _asDouble(json['visit_rate_30d']),
        bookings30d: _asInt(json['bookings_30d']),
        completedBookings30d: _asInt(json['completed_bookings_30d']),
        messages30d: _asInt(json['messages_30d']),
        inboundClientMessages30d: _asInt(json['inbound_client_messages_30d']),
        communityMembers: _asInt(json['community_members']),
        revenue30dArtifacts: _asInt(json['revenue_30d_artifacts']),
        revenueLifetimeArtifacts: _asInt(json['revenue_lifetime_artifacts']),
        posts30d: _asInt(json['posts_30d']),
        joinRequests30d: _asInt(json['join_requests_30d']),
        joinRequestsApproved30d: _asInt(json['join_requests_approved_30d']),
        joinConversion30d: _asDouble(json['join_conversion_30d']),
        eventsHosted: _asInt(json['events_hosted']),
        eventsHosted30d: _asInt(json['events_hosted_30d']),
        productsSold: _asInt(json['products_sold']),
        productsSold30d: _asInt(json['products_sold_30d']),
        programmesSold: _asInt(json['programmes_sold']),
        programmesSold30d: _asInt(json['programmes_sold_30d']),
        mealPlansSold: _asInt(json['meal_plans_sold']),
        mealPlansSold30d: _asInt(json['meal_plans_sold_30d']),
        shopOrders30d: _asInt(json['shop_orders_30d']),
      );
}

class GymAnalyticsGrowth {
  final double audiencePct;
  final double checkInsPct;
  final double bookingsPct;
  final double postsPct;
  final double messagesPct;
  final double revenuePct;

  const GymAnalyticsGrowth({
    this.audiencePct = 0,
    this.checkInsPct = 0,
    this.bookingsPct = 0,
    this.postsPct = 0,
    this.messagesPct = 0,
    this.revenuePct = 0,
  });

  factory GymAnalyticsGrowth.fromJson(Map<String, dynamic> json) =>
      GymAnalyticsGrowth(
        audiencePct: _asDouble(json['audience_pct']),
        checkInsPct: _asDouble(json['check_ins_pct']),
        bookingsPct: _asDouble(json['bookings_pct']),
        postsPct: _asDouble(json['posts_pct']),
        messagesPct: _asDouble(json['messages_pct']),
        revenuePct: _asDouble(json['revenue_pct']),
      );
}

class GymAnalyticsData {
  final GymAnalyticsKpis kpis;
  final GymAnalyticsGrowth growth;
  final List<DailyCount> checkIns;
  final List<DailyCount> newMembers;
  final List<DailyCount> posts;
  final List<DailyCount> revenueArtifacts;
  final List<DailyCount> messages;
  final List<DailyCount> bookings;
  final String shareCard;

  const GymAnalyticsData({
    required this.kpis,
    required this.growth,
    this.checkIns = const [],
    this.newMembers = const [],
    this.posts = const [],
    this.revenueArtifacts = const [],
    this.messages = const [],
    this.bookings = const [],
    this.shareCard = '',
  });

  factory GymAnalyticsData.fromJson(Map<String, dynamic> json) {
    final ts = _mapOf(json['timeseries']);
    return GymAnalyticsData(
      kpis: GymAnalyticsKpis.fromJson(_mapOf(json['kpis'])),
      growth: GymAnalyticsGrowth.fromJson(_mapOf(json['growth'])),
      checkIns: _mapList(ts['check_ins']).map(DailyCount.fromJson).toList(),
      newMembers: _mapList(ts['new_members']).map(DailyCount.fromJson).toList(),
      posts: _mapList(ts['posts']).map(DailyCount.fromJson).toList(),
      revenueArtifacts:
          _mapList(ts['revenue_artifacts']).map(DailyCount.fromJson).toList(),
      messages: _mapList(ts['messages']).map(DailyCount.fromJson).toList(),
      bookings: _mapList(ts['bookings']).map(DailyCount.fromJson).toList(),
      shareCard: json['share_card']?.toString() ?? '',
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}'.split('.').first) ?? 0;
}

int? _asIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value'.split('.').first);
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

Map<String, dynamic> _mapOf(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<Map<String, dynamic>> _mapList(dynamic value) =>
    value is List ? value.whereType<Map>().map(Map<String, dynamic>.from).toList() : const [];
