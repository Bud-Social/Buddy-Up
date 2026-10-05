import { describe, expect, it, vi, beforeEach } from 'vitest';
import { apiClient } from '@/api/client';
import { messagingApi } from '@/api/messaging';

vi.mock('@/api/client', () => ({
  apiClient: { post: vi.fn(), get: vi.fn() },
}));

const postMock = apiClient.post as unknown as ReturnType<typeof vi.fn>;

beforeEach(() => {
  vi.clearAllMocks();
  postMock.mockResolvedValue({ data: { success: true, data: null } });
});

describe('messagingApi promotion endpoints', () => {
  it('asks for a promotion on the conversation', async () => {
    await messagingApi.promoteConversation('c1');
    expect(postMock).toHaveBeenCalledWith('/messaging/conversations/c1/promote/');
  });

  it('accepts via the promotion id with accept:true', async () => {
    await messagingApi.respondToPromotion('promo-9', true);
    expect(postMock).toHaveBeenCalledWith(
      '/messaging/conversations/promotions/promo-9/respond/',
      { accept: true },
    );
  });

  it('declines via the promotion id with accept:false', async () => {
    await messagingApi.respondToPromotion('promo-9', false);
    expect(postMock).toHaveBeenCalledWith(
      '/messaging/conversations/promotions/promo-9/respond/',
      { accept: false },
    );
  });

  it('returns the enveloped response payload untouched', async () => {
    postMock.mockResolvedValue({ data: { success: true, data: { id: 'promo-9', status: 'accepted' } } });
    const res = await messagingApi.respondToPromotion('promo-9', true);
    expect(res.data).toEqual({ id: 'promo-9', status: 'accepted' });
  });

  it('tags Find-a-Buddy threads as discovery origin', async () => {
    await messagingApi.startConversation(['dawn'], undefined, 'discovery');
    expect(postMock).toHaveBeenCalledWith('/messaging/conversations/start/', {
      participants: ['dawn'],
      group_name: undefined,
      origin: 'discovery',
    });
  });

  it('omits origin for the untouched call sites', async () => {
    await messagingApi.startConversation(['dawn'], 'Crew');
    expect(postMock).toHaveBeenCalledWith('/messaging/conversations/start/', {
      participants: ['dawn'],
      group_name: 'Crew',
    });
    expect(postMock.mock.calls[0][1]).not.toHaveProperty('origin');
  });
});