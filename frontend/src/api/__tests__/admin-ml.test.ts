import { describe, expect, it, vi, beforeEach } from 'vitest';
import { apiClient } from '@/api/client';
import { adminApi, TEST_ROUTES } from '@/api/admin';

vi.mock('@/api/client', () => ({
  apiClient: { post: vi.fn(), delete: vi.fn(), get: vi.fn() },
}));

const getMock = apiClient.get as unknown as ReturnType<typeof vi.fn>;
const postMock = apiClient.post as unknown as ReturnType<typeof vi.fn>;

beforeEach(() => {
  vi.clearAllMocks();
  getMock.mockResolvedValue({ data: { success: true, data: [] } });
  postMock.mockResolvedValue({ data: { success: true, data: null } });
});

describe('adminApi data-operations endpoints', () => {
  it('fetches scrapers and loaders from the dashboard namespace', async () => {
    await adminApi.getScrapers();
    expect(getMock).toHaveBeenCalledWith('/admin/dashboard/scrapers/');
    await adminApi.getLoaders();
    expect(getMock).toHaveBeenCalledWith('/admin/dashboard/loaders/');
  });

  it('registers a model version with activation flags', async () => {
    await adminApi.registerModel({ name: 'nsfw_classifier', version: '2.0.0', activate: true, deactivate_others: true });
    expect(postMock).toHaveBeenCalledWith(
      '/admin/dashboard/models/register/',
      expect.objectContaining({ name: 'nsfw_classifier', activate: true }),
    );
  });

  it('posts test probes as multipart with the route included', async () => {
    await adminApi.testModel('/api/v1/moderation/text', { text: 'hi' });
    expect(postMock).toHaveBeenCalledWith(
      '/admin/dashboard/models/test/',
      expect.any(FormData),
      expect.objectContaining({ timeout: 150000 }),
    );
  });

  it('covers every served model family with a test route', () => {
    const models = new Set(TEST_ROUTES.map((r) => r.model));
    for (const name of ['toxicity_classifier', 'nsfw_classifier', 'matching_embeddings',
                        'food_calorie_regressor', 'form_analyzer', 'feed_ranker', 'workout_forecast']) {
      expect(models.has(name)).toBe(true);
    }
  });
});
