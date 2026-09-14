import { describe, expect, it, vi, beforeEach } from 'vitest';
import { apiClient } from '@/api/client';
import { feedApi, REPORT_REASONS } from '@/api/feed';

vi.mock('@/api/client', () => ({
  apiClient: { post: vi.fn(), delete: vi.fn(), get: vi.fn() },
}));

const postMock = apiClient.post as unknown as ReturnType<typeof vi.fn>;
const deleteMock = apiClient.delete as unknown as ReturnType<typeof vi.fn>;

beforeEach(() => {
  vi.clearAllMocks();
  postMock.mockResolvedValue({ data: { success: true, data: null } });
  deleteMock.mockResolvedValue({ data: { success: true, data: null } });
});

describe('feedApi hide/mute/report endpoints', () => {
  it('hides and unhides via the same post URL', async () => {
    await feedApi.hidePost('post-1');
    expect(postMock).toHaveBeenCalledWith('/feed/post-1/hide/');
    await feedApi.unhidePost('post-1');
    expect(deleteMock).toHaveBeenCalledWith('/feed/post-1/hide/');
  });

  it('mutes and unmutes the author by username', async () => {
    await feedApi.muteAuthor('coachamy');
    expect(postMock).toHaveBeenCalledWith('/profiles/coachamy/mute/');
    await feedApi.unmuteAuthor('coachamy');
    expect(deleteMock).toHaveBeenCalledWith('/profiles/coachamy/unmute/');
  });

  it('URL-encodes usernames in mute paths', async () => {
    await feedApi.muteAuthor('coach amy');
    expect(postMock).toHaveBeenCalledWith('/profiles/coach%20amy/mute/');
  });

  it('submits moderation reports to the reports endpoint', async () => {
    const payload = {
      target_user: 'u-amy',
      reason: 'spam',
      description: 'Post post-1',
      content_url: 'https://app.example/feed?post=post-1',
    };
    await feedApi.submitReport(payload);
    expect(postMock).toHaveBeenCalledWith('/moderation/reports/', payload);
  });

  it('mirrors the backend ModerationReport reason choices', () => {
    expect(REPORT_REASONS.map((r) => r.value)).toEqual([
      'spam',
      'harassment',
      'hate_speech',
      'nudity',
      'adult_ungated',
      'violence',
      'misinformation',
      'impersonation',
      'other',
    ]);
  });
});
