import '../../../data/models/messaging.dart';

/// Resolved display identity for a conversation.
///
/// Group chats and communities always present their OWN identity
/// (groupName / groupAvatarUrl) — never a random participant's personal
/// profile. Only 1:1 DMs fall back to the partner's identity, and the
/// partner is the first participant that is not me.
class ConversationIdentity {
  final String name;
  final String avatarUrl;
  final bool isGroup;
  final ParticipantData? partner;

  const ConversationIdentity({
    required this.name,
    required this.avatarUrl,
    required this.isGroup,
    this.partner,
  });

  static ConversationIdentity of(Conversation? convo, String? myUserId) {
    if (convo == null) {
      return const ConversationIdentity(name: 'Chat', avatarUrl: '', isGroup: false);
    }
    ParticipantData? partner;
    for (final p in convo.participantsData) {
      if (p.userId != myUserId) {
        partner = p;
        break;
      }
    }
    partner ??= convo.participantsData.isNotEmpty ? convo.participantsData.first : null;

    final isGroup = convo.isGroup || convo.isCommunity;
    if (isGroup) {
      return ConversationIdentity(
        name: convo.groupName.trim().isNotEmpty ? convo.groupName.trim() : 'Group',
        avatarUrl: convo.groupAvatarUrl,
        isGroup: true,
        partner: partner,
      );
    }
    return ConversationIdentity(
      name: (partner?.displayName.isNotEmpty ?? false) ? partner!.displayName : 'Chat',
      avatarUrl: partner?.avatarUrl ?? '',
      isGroup: false,
      partner: partner,
    );
  }

  /// Searchable text: group/community name plus every participant's names.
  String get searchText {
    final parts = <String>[name];
    // name already contains groupName for groups; include partners too so
    // users can find a community by a member's name.
    return parts.join(' ').toLowerCase();
  }
}

/// Search text across group name AND all member names/usernames.
String conversationSearchText(Conversation convo) {
  final parts = <String>[convo.groupName];
  for (final p in convo.participantsData) {
    parts.add(p.displayName);
    parts.add(p.username);
  }
  return parts.join(' ').toLowerCase();
}
