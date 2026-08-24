/**
 * conversationDisplay.ts — resolve the display name + avatar for a conversation.
 *
 * Group chats and communities must always present their OWN identity
 * (group_name / group_avatar_url), never a random participant's personal
 * profile. Only 1:1 DMs fall back to the partner's identity.
 */
import type { Conversation, ParticipantData } from '@/api/messaging';

export interface ConversationIdentity {
  name: string;
  avatarUrl: string;
  isGroup: boolean;
  /** Verification badge only applies to 1:1 partners. */
  verificationStatus: string;
  /** The other participant (1:1 only; null for groups or when self is the only member). */
  partner: ParticipantData | null;
}

type IdentitySource = Pick<
  Conversation,
  'is_group' | 'group_name' | 'group_avatar_url' | 'participants_data'
> & { is_community?: boolean };

export function getConversationIdentity(
  convo: IdentitySource,
  myUserId?: string,
): ConversationIdentity {
  const partner =
    convo.participants_data.find((p) => p.user_id !== myUserId) ??
    convo.participants_data[0] ??
    null;

  const isGroup = convo.is_group || convo.is_community === true;
  if (isGroup) {
    return {
      name: (convo.group_name || '').trim() || 'Group',
      avatarUrl: convo.group_avatar_url || '',
      isGroup: true,
      verificationStatus: '',
      partner,
    };
  }

  return {
    name: partner?.display_name || 'Conversation',
    avatarUrl: partner?.avatar_url || '',
    isGroup: false,
    verificationStatus: partner?.verification_status || '',
    partner,
  };
}

/** Searchable text: group/community name plus every participant's name. */
export function conversationSearchText(convo: IdentitySource): string {
  const parts = [convo.group_name || ''];
  for (const p of convo.participants_data) {
    parts.push(p.display_name || '', p.username || '');
  }
  return parts.join(' ').toLowerCase();
}
