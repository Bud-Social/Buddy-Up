import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import Messages from '../Messages';
import { messagingApi, type Conversation, type Message } from '@/api/messaging';
import { ToastProvider } from '@/components/ui/Toast';

window.matchMedia = ((query: string) => ({
  matches: false,
  media: query,
  onchange: null,
  addEventListener: vi.fn(),
  removeEventListener: vi.fn(),
  addListener: vi.fn(),
  removeListener: vi.fn(),
  dispatchEvent: vi.fn(),
})) as unknown as typeof window.matchMedia;

Element.prototype.scrollIntoView = vi.fn();

vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual<typeof import('react-router-dom')>('react-router-dom');
  return { ...actual, useNavigate: () => vi.fn() };
});

vi.mock('@/api/messaging', () => ({
  messagingApi: {
    getConversations: vi.fn(),
    getMessages: vi.fn(),
    getConversation: vi.fn(),
    markRead: vi.fn(),
    linkPreview: vi.fn(),
    sendMessage: vi.fn(),
  },
}));

/** The socket transport is a seam here: the hook decides whether it is OPEN. */
const chat = vi.hoisted(() => ({
  sendMessage: vi.fn(),
  onEvent: null as null | ((e: unknown) => void),
}));

vi.mock('@/hooks/useChatSocket', () => ({
  useChatSocket: ({ onEvent }: { onEvent: (e: unknown) => void }) => {
    chat.onEvent = onEvent;
    return {
      sendMessage: chat.sendMessage,
      sendTypingStart: vi.fn(),
      sendTypingStop: vi.fn(),
      sendRead: vi.fn(),
      sendReact: vi.fn(),
      sendCallSignal: vi.fn(),
    };
  },
}));

vi.mock('@/hooks/useLiveKitCall', () => ({
  useLiveKitCall: () => ({
    callState: 'idle', callType: 'audio', tiles: [], cameraError: null, sessionId: null,
    myUserId: 'me', identityName: 'Test', identityAvatar: '',
    joinCall: vi.fn(), leaveCall: vi.fn(), toggleMic: vi.fn(), toggleCamera: vi.fn(), toggleScreenShare: vi.fn(),
  }),
}));

vi.mock('@/hooks/usePresence', () => ({
  usePresence: () => ({}),
  formatLastSeen: () => '',
}));

vi.mock('@/store/authStore', () => ({
  useAuthStore: (sel: (s: unknown) => unknown) =>
    sel({ profile: { user_id: 'user-me', display_name: 'Me', username: 'me' } }),
}));

vi.mock('@/store/callStore', () => ({
  useCallStore: (sel: (s: unknown) => unknown) => sel({ acceptedInvite: null, setAcceptedInvite: vi.fn() }),
}));

vi.mock('@/store/sidebarStore', () => ({
  useSidebarStore: (sel: (s: unknown) => unknown) => sel({ openMobile: vi.fn() }),
}));

vi.mock('@/store/chatPreferencesStore', () => ({
  useChatPreferences: () => ({ background: '#000', senderBubbleColor: '#111', receiverBubbleColor: '#222', perConversationThemes: {} }),
}));

vi.mock('@/components/chat/CallRoom', () => ({ CallRoom: () => null }));
vi.mock('@/components/chat/AttachmentMenu', () => ({ AttachmentMenu: () => null }));
vi.mock('@/components/chat/VoiceNoteRecorder', () => ({ VoiceNoteRecorder: () => null }));
vi.mock('@/components/chat/CameraCapture', () => ({ CameraCapture: () => null }));
vi.mock('@/components/chat/CustomAudioPlayer', () => ({ CustomAudioPlayer: () => null }));
vi.mock('@/components/chat/ChatThemePicker', () => ({ ChatThemePicker: () => null }));
vi.mock('@/components/chat/DocumentPreview', () => ({ default: () => null }));
vi.mock('emoji-picker-react', () => ({ default: () => null }));

const api = messagingApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

const ME = 'user-me';
const THEM = 'u-2';
const CONVO_ID = 'c1';

const CONVO: Conversation = {
  id: CONVO_ID,
  is_group: false,
  group_name: '',
  group_avatar_url: '',
  group_gym_id: null,
  sub_channel: '',
  call_in_progress: false,
  participants_data: [
    { user_id: ME, username: 'me', display_name: 'Me', avatar_url: '', verification_status: '', role: 'user' },
    { user_id: THEM, username: 'dawn', display_name: 'Dawn', avatar_url: '', verification_status: '', role: 'user' },
  ],
  unread_count: 0,
  last_message: null,
  last_message_at: '',
  created_at: '',
  promotion_id: null,
  promotion_requested_by: null,
} as Conversation;

/** What the endpoint answers with: the same payload under a real id. */
function saved(over: Partial<Message> = {}): Message {
  return {
    id: 'real-1',
    conversation_id: CONVO_ID,
    sender_id: ME,
    message_type: 'text',
    body: 'hello there',
    media_url: '',
    media_mime: '',
    file_name: '',
    reply_to_id: null,
    metadata: {},
    is_read: false,
    deleted_for: [],
    sender_data: CONVO.participants_data[0],
    reply_data: null,
    reactions: {},
    created_at: '2026-10-06T09:00:00Z',
    ...over,
  } as Message;
}

beforeEach(() => {
  vi.clearAllMocks();
  chat.onEvent = null;
  api.getConversations.mockResolvedValue({ data: [CONVO] });
  api.getMessages.mockResolvedValue({ data: [] });
  api.getConversation.mockResolvedValue({ data: null });
  api.markRead.mockResolvedValue({ data: {} });
  api.linkPreview.mockResolvedValue({ data: {} });
  api.sendMessage.mockResolvedValue({ data: saved() });
});

function renderMessages() {
  return render(
    <ToastProvider>
      <MemoryRouter initialEntries={[`/messages/${CONVO_ID}`]}>
        <Routes>
          <Route path="/messages" element={<Messages />} />
          <Route path="/messages/:conversationId" element={<Messages />} />
        </Routes>
      </MemoryRouter>
    </ToastProvider>,
  );
}

/** The composer's primary button — the last one in the input's row (icon only). */
function sendButton(input: HTMLElement): HTMLButtonElement {
  const row = input.closest('div.flex-1')?.parentElement;
  const buttons = Array.from(row?.querySelectorAll('button') ?? []);
  const btn = buttons[buttons.length - 1] as HTMLButtonElement | undefined;
  if (!btn) throw new Error('send button not found');
  return btn;
}

async function typeAndSend(body: string) {
  const input = await screen.findByPlaceholderText('Message...');
  await userEvent.type(input, body);
  await userEvent.click(sendButton(input));
  return input;
}

describe('Messages — sending when the socket is not OPEN', () => {
  it('falls back to the REST endpoint instead of discarding the message', async () => {
    chat.sendMessage.mockReturnValue(false); // socket not OPEN
    renderMessages();

    await typeAndSend('hello there');

    await waitFor(() => expect(api.sendMessage).toHaveBeenCalledTimes(1));
    expect(api.sendMessage).toHaveBeenCalledWith(CONVO_ID, {
      body: 'hello there',
      message_type: 'text',
      media_url: '',
      media_mime: '',
      file_name: '',
      reply_to_id: undefined,
      metadata: {},
    });
    // The optimistic bubble is replaced by the server's copy — one, not two.
    await waitFor(() => expect(screen.getAllByText('hello there')).toHaveLength(1));
    expect(chat.sendMessage).toHaveBeenCalledTimes(1);
  });

  it('leaves no duplicate when the group echo wins the race against the response', async () => {
    chat.sendMessage.mockReturnValue(false);
    let release: (() => void) | null = null;
    api.sendMessage.mockImplementation(() => new Promise((resolve) => {
      release = () => resolve({ data: saved() });
    }));
    renderMessages();

    await typeAndSend('hello there');
    await waitFor(() => expect(api.sendMessage).toHaveBeenCalled());
    expect(screen.getAllByText('hello there')).toHaveLength(1); // optimistic

    // The endpoint also broadcasts to the conversation group, so the echo can
    // land before the HTTP response does.
    await waitFor(() => expect(chat.onEvent).not.toBeNull());
    chat.onEvent?.({ type: 'message', ...saved() });
    expect(screen.getAllByText('hello there')).toHaveLength(1);

    release?.();
    await waitFor(() => expect(screen.getAllByText('hello there')).toHaveLength(1));
  });

  it('drops the optimistic bubble and tells the user when the endpoint refuses', async () => {
    chat.sendMessage.mockReturnValue(false);
    api.sendMessage.mockRejectedValue({ response: { data: { message: 'You are not a member of this conversation.' } } });
    renderMessages();

    await typeAndSend('hello there');

    expect(await screen.findByText('You are not a member of this conversation.')).toBeDefined();
    expect(screen.queryByText('hello there')).toBeNull();
  });
});

describe('Messages — sending over an OPEN socket', () => {
  it('uses the socket and leaves the REST endpoint alone', async () => {
    chat.sendMessage.mockReturnValue(true);
    renderMessages();

    await typeAndSend('hello there');

    await waitFor(() => expect(chat.sendMessage).toHaveBeenCalledTimes(1));
    expect(chat.sendMessage).toHaveBeenCalledWith({
      body: 'hello there',
      message_type: 'text',
      media_url: '',
      media_mime: '',
      file_name: '',
      reply_to_id: undefined,
      metadata: {},
    });
    expect(api.sendMessage).not.toHaveBeenCalled();
    expect(screen.getAllByText('hello there')).toHaveLength(1);
  });

  it('does not duplicate the bubble when the echo reconciles it', async () => {
    chat.sendMessage.mockReturnValue(true);
    renderMessages();

    await typeAndSend('hello there');
    expect(screen.getAllByText('hello there')).toHaveLength(1);

    await waitFor(() => expect(chat.onEvent).not.toBeNull());
    chat.onEvent?.({ type: 'message', ...saved() });

    await waitFor(() => expect(screen.getAllByText('hello there')).toHaveLength(1));
  });
});