import Messages from './Messages';

/**
 * Buddy chats — their own inbox.
 *
 * The buddy conversations are kept apart from the rest of the messaging:
 * the server files them under their own kind, so a chat opened from the
 * buddy finder never turns up in the main inbox, and a chat promoted to a
 * buddy relationship moves here rather than appearing in both.
 */
export default function BuddyMessages() {
  return <Messages scope="discovery" />;
}
