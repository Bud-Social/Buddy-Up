import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import Messages from '../Messages';
import { messagingApi, type Conversation } from '@/api/messaging';
import { ToastProvider } from '@/components/ui/Toast';

const navigateMock = vi.fn();

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
  return { ...actual, useNavigate: () => navigateMock };
});

vi.mock('@/api/messaging', () => ({
  messagingApi: {
    getConversations: vi.fn(),
    getMessages: vi.fn(),
    getConversation: vi.fn(),
    markRead: vi.fn(),
    promoteConversation: vi.fn(),
    respondToPromotion: vi.fn(),
    linkPreview: vi.fn(),
  },
}));

vi.mock('@/hooks/useChatSocket', () => ({
  useChatSocket: () => ({ sendMessage: vi.fn(), sendTypingStart: vi.fn(), sendTypingStop: vi.fn(), connected: true }),
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

function convo(over: Partial<Conversation> & { id: string }): Conversation {
  return {
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
    ...over,
  } as Conversation;
}

/** Dawn asked *us* → we are the responder and get Accept/Decline. */
const PENDING_FOR_ME: Partial<Conversation> & { id: string } = {
  id: 'c1',
  origin: 'discovery',
  promotable: true,
  promotion_status: 'pending',
  promotion_id: 'promo-9',
  promotion_requested_by: THEM,
};

/** *We* asked → we are the requester and only keep the pending chip. */
const PENDING_FROM_ME: Partial<Conversation> & { id: string } = {
  ...PENDING_FOR_ME,
  promotion_requested_by: ME,
};

beforeEach(() => {
  vi.clearAllMocks();
  api.getMessages.mockResolvedValue({ data: [] });
  api.markRead.mockResolvedValue({ data: {} });
  api.getConversation.mockResolvedValue({ data: null });
  api.promoteConversation.mockResolvedValue({
    data: { id: 'promo-1', conversation_id: 'c1', status: 'pending', requested_by: ME },
  });
  api.respondToPromotion.mockResolvedValue({ data: { id: 'promo-9', conversation_id: 'c1', status: 'accepted' } });
});

function renderScope(scope: 'all' | 'discovery', entry: string) {
  return render(
    <ToastProvider>
      <MemoryRouter initialEntries={[entry]}>
        <Routes>
          <Route path="/messages" element={<Messages />} />
          <Route path="/messages/:conversationId" element={<Messages />} />
          <Route path="/buddies/messages" element={<Messages scope="discovery" />} />
          <Route path="/buddies/messages/:conversationId" element={<Messages scope="discovery" />} />
        </Routes>
      </MemoryRouter>
    </ToastProvider>,
  );
}

describe('Messages discovery scope', () => {
  it('lists only discovery chats under the buddy route', async () => {
    api.getConversations.mockResolvedValue({
      data: [
        convo({ id: 'c1', origin: 'discovery' }),
        convo({ id: 'c2', origin: 'direct' }),
        convo({ id: 'c3', origin: 'group', is_group: true, group_name: 'Crew' }),
      ],
    });
    renderScope('discovery', '/buddies/messages');

    expect(await screen.findByRole('heading', { name: 'Buddy chats' })).toBeDefined();
    await waitFor(() => expect(screen.getByText('Dawn')).toBeDefined());
    expect(screen.getAllByText('Dawn').length).toBe(1);
    expect(screen.queryByText('Crew')).toBeNull();
  });

  it('offers promotion only on a promotable discovery chat', async () => {
    api.getConversations.mockResolvedValue({
      data: [convo({ id: 'c1', origin: 'discovery', promotable: true, promotion_status: null })],
    });
    renderScope('discovery', '/buddies/messages/c1');

    const promote = await screen.findByRole('button', { name: 'Promote to main chat' });
    await userEvent.click(promote);

    await waitFor(() => expect(api.promoteConversation).toHaveBeenCalledWith('c1'));
    expect(await screen.findByText('Buddy request pending')).toBeDefined();
    // We just asked, so the Accept/Decline pair belongs to the other side.
    expect(screen.queryByRole('button', { name: 'Accept' })).toBeNull();
    expect(screen.queryByRole('button', { name: 'Decline' })).toBeNull();
  });

  it('shows the confirmed state once the other side accepts', async () => {
    api.getConversations.mockResolvedValue({
      data: [convo({ id: 'c1', origin: 'discovery', promotable: true, promotion_status: 'accepted' })],
    });
    renderScope('discovery', '/buddies/messages/c1');

    expect(await screen.findByText('Now buddies')).toBeDefined();
    expect(screen.queryByRole('button', { name: 'Promote to main chat' })).toBeNull();
  });

  it('surfaces the server refusal when promotion is rejected', async () => {
    api.getConversations.mockResolvedValue({
      data: [convo({ id: 'c1', origin: 'discovery', promotable: true, promotion_status: null })],
    });
    api.promoteConversation.mockRejectedValue({ response: { data: { message: 'You are already buddies.' } } });
    renderScope('discovery', '/buddies/messages/c1');

    await userEvent.click(await screen.findByRole('button', { name: 'Promote to main chat' }));
    await waitFor(() => expect(screen.getByRole('button', { name: 'Promote to main chat' })).toBeDefined());
  });

  it('keeps the promote action off the main messages surface', async () => {
    api.getConversations.mockResolvedValue({
      data: [convo({ id: 'c1', origin: 'discovery', promotable: true, promotion_status: null })],
    });
    renderScope('all', '/messages/c1');

    await screen.findByRole('heading', { name: 'Messages' });
    expect(screen.queryByRole('button', { name: 'Promote to main chat' })).toBeNull();
  });
});

/**
 * The payload now carries `promotion_requested_by`, so a pending thread can tell the
 * requester from the responder: only the responder (the id is somebody else) gets
 * Accept/Decline, while the requester keeps just their "Buddy request pending" chip.
 * The respond endpoint stays the authority — a 403 is surfaced verbatim via toast.
 */
describe('Messages — answering an incoming buddy request', () => {
  it('offers Accept + Decline to the responder', async () => {
    api.getConversations.mockResolvedValue({ data: [convo(PENDING_FOR_ME)] });
    renderScope('discovery', '/buddies/messages/c1');

    expect(await screen.findByRole('button', { name: 'Accept' })).toBeDefined();
    expect(screen.getByRole('button', { name: 'Decline' })).toBeDefined();
  });

  it('hides Accept + Decline from the requester, who keeps their pending chip', async () => {
    api.getConversations.mockResolvedValue({ data: [convo(PENDING_FROM_ME)] });
    renderScope('discovery', '/buddies/messages/c1');

    expect(await screen.findByText('Buddy request pending')).toBeDefined();
    expect(screen.queryByRole('button', { name: 'Accept' })).toBeNull();
    expect(screen.queryByRole('button', { name: 'Decline' })).toBeNull();
  });

  it('renders neither control when there is no promotion', async () => {
    api.getConversations.mockResolvedValue({
      data: [convo({
        id: 'c1', origin: 'discovery', promotable: true,
        promotion_status: null, promotion_id: null, promotion_requested_by: null,
      })],
    });
    renderScope('discovery', '/buddies/messages/c1');

    expect(await screen.findByRole('button', { name: 'Promote to main chat' })).toBeDefined();
    expect(screen.queryByRole('button', { name: 'Accept' })).toBeNull();
    expect(screen.queryByRole('button', { name: 'Decline' })).toBeNull();
  });

  it('confirms, then accepts the request and re-reads the conversation', async () => {
    api.getConversations.mockResolvedValue({ data: [convo(PENDING_FOR_ME)] });
    api.getConversation.mockResolvedValue({
      data: convo({
        ...PENDING_FOR_ME, origin: 'buddy', promotion_status: 'accepted', promoted_at: '2026-10-05T10:00:00Z',
      }),
    });
    renderScope('discovery', '/buddies/messages/c1');

    await userEvent.click(await screen.findByRole('button', { name: 'Accept' }));

    // Acceptance is mutual consent, so nothing is posted until the sheet confirms.
    expect(screen.getByRole('heading', { name: 'Accept buddy request?' })).toBeDefined();
    expect(api.respondToPromotion).not.toHaveBeenCalled();

    await userEvent.click(screen.getByRole('button', { name: 'Accept request' }));

    // The promotion id is the URL segment; `accept: true` is the body (asserted
    // end-to-end in api/__tests__/messaging-promotions.test.ts).
    await waitFor(() => expect(api.respondToPromotion).toHaveBeenCalledWith('promo-9', true));
    // Refreshed so `origin` flips to 'buddy' and the chip turns into the confirmed state.
    await waitFor(() => expect(api.getConversation).toHaveBeenCalledWith('c1'));
    expect(await screen.findByText('Now buddies')).toBeDefined();
    await waitFor(() => expect(screen.queryByRole('button', { name: 'Accept' })).toBeNull());
    expect(screen.queryByRole('button', { name: 'Decline' })).toBeNull();
  });

  it('declines the request without asking first', async () => {
    api.getConversations.mockResolvedValue({ data: [convo(PENDING_FOR_ME)] });
    api.respondToPromotion.mockResolvedValue({ data: { id: 'promo-9', conversation_id: 'c1', status: 'declined' } });
    renderScope('discovery', '/buddies/messages/c1');

    await userEvent.click(await screen.findByRole('button', { name: 'Decline' }));

    await waitFor(() => expect(api.respondToPromotion).toHaveBeenCalledWith('promo-9', false));
    expect(screen.queryByRole('heading', { name: 'Accept buddy request?' })).toBeNull();
    expect(await screen.findByText('Buddy request declined.')).toBeDefined();
    await waitFor(() => expect(screen.queryByRole('button', { name: 'Decline' })).toBeNull());
  });

  it('closes the confirmation without responding when cancelled', async () => {
    api.getConversations.mockResolvedValue({ data: [convo(PENDING_FOR_ME)] });
    renderScope('discovery', '/buddies/messages/c1');

    await userEvent.click(await screen.findByRole('button', { name: 'Accept' }));
    await userEvent.click(screen.getByRole('button', { name: 'Not yet' }));

    await waitFor(() =>
      expect(screen.queryByRole('heading', { name: 'Accept buddy request?' })).toBeNull(),
    );
    expect(api.respondToPromotion).not.toHaveBeenCalled();
    expect(screen.getByRole('button', { name: 'Accept' })).toBeDefined();
  });

  it("toasts the server's refusal when the endpoint outranks the payload", async () => {
    // The pair rendered, so the endpoint is still the authority — e.g. the row
    // disagrees with the payload, or the requester forced the control back on.
    api.getConversations.mockResolvedValue({ data: [convo(PENDING_FOR_ME)] });
    api.respondToPromotion.mockRejectedValue({
      response: { data: { message: 'Only the other participant can respond to this request.' } },
    });
    renderScope('discovery', '/buddies/messages/c1');

    await userEvent.click(await screen.findByRole('button', { name: 'Decline' }));

    expect(await screen.findByText('Only the other participant can respond to this request.')).toBeDefined();
    // Still pending, so nothing settled and the thread is left as it was.
    expect(screen.getByText('Buddy request pending')).toBeDefined();
    expect(screen.getByRole('button', { name: 'Accept' })).toBeDefined();
  });

  it('hides the pair when a pending request carries no promotion id', async () => {
    api.getConversations.mockResolvedValue({
      data: [convo({
        id: 'c1', origin: 'discovery', promotable: true,
        promotion_status: 'pending', promotion_id: null, promotion_requested_by: THEM,
      })],
    });
    renderScope('discovery', '/buddies/messages/c1');

    expect(await screen.findByText('Buddy request pending')).toBeDefined();
    expect(screen.queryByRole('button', { name: 'Accept' })).toBeNull();
    expect(screen.queryByRole('button', { name: 'Decline' })).toBeNull();
  });

  it('hides the pair once the request is accepted', async () => {
    api.getConversations.mockResolvedValue({
      data: [convo({
        id: 'c1', origin: 'buddy', promotable: false,
        promotion_status: 'accepted', promotion_id: 'promo-9', promotion_requested_by: THEM,
      })],
    });
    renderScope('discovery', '/buddies/messages/c1');

    expect(await screen.findByText('Now buddies')).toBeDefined();
    expect(screen.queryByRole('button', { name: 'Accept' })).toBeNull();
    expect(screen.queryByRole('button', { name: 'Decline' })).toBeNull();
  });

  it('keeps the pair off the main messages surface', async () => {
    api.getConversations.mockResolvedValue({ data: [convo(PENDING_FOR_ME)] });
    renderScope('all', '/messages/c1');

    await screen.findByRole('heading', { name: 'Messages' });
    expect(screen.queryByRole('button', { name: 'Accept' })).toBeNull();
    expect(screen.queryByRole('button', { name: 'Decline' })).toBeNull();
  });
});
