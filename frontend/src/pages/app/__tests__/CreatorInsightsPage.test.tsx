import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import CreatorInsightsPage from '@/pages/app/CreatorInsightsPage';
import { feedApi } from '@/api/feed';

vi.mock('@/api/feed', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/feed')>()),
  feedApi: {
    ...(await importOriginal<typeof import('@/api/feed')>()).feedApi,
    getCreatorInsights: vi.fn(),
  },
}));

const api = feedApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

const items = [
  {
    post_id: 'a1'.repeat(8),
    post_type: 'photo',
    body: 'Karura morning tempo run',
    media_url: 'https://cdn.example.com/a.jpg',
    views: 1200, likes: 40, comments: 12, reposts: 3, saves: 15, shares: 6,
    interactions: 76, focus_sessions: 5, total_focus_ms: 5000, watch_ms: 0,
    avg_focus_ms: 1000, created_at: '2026-11-10T08:00:00Z', visibility: 'public',
  },
  {
    post_id: 'b2'.repeat(8),
    post_type: 'short_video',
    body: 'Form check: squat depth',
    media_url: 'https://cdn.example.com/b.mp4',
    views: 450, likes: 90, comments: 20, reposts: 8, saves: 30, shares: 12,
    interactions: 160, focus_sessions: 10, total_focus_ms: 20000, watch_ms: 90000,
    avg_focus_ms: 2000, created_at: '2026-11-12T08:00:00Z', visibility: 'buddies',
  },
];

describe('CreatorInsightsPage', () => {
  beforeEach(() => vi.clearAllMocks());

  it('shows the account rollup and per-post previews', async () => {
    api.getCreatorInsights.mockResolvedValue({
      data: {
        items,
        summary: { posts: 2, views: 1650, interactions: 236, engagement_rate_pct: 14.3 },
      },
      success: true,
    });
    render(<CreatorInsightsPage />);

    await waitFor(() => expect(screen.getByText('Creator Insights')).toBeInTheDocument());
    expect(screen.getByText('14.3%')).toBeInTheDocument();
    expect(screen.getAllByText('Karura morning tempo run').length).toBeGreaterThanOrEqual(1);
    expect(screen.getAllByText('Form check: squat depth').length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText('Top posts')).toBeInTheDocument();
    expect(screen.getByText('Best performer')).toBeInTheDocument();
  });

  it('sorts by interactions on request', async () => {
    api.getCreatorInsights.mockResolvedValue({ data: { items }, success: true });
    const user = userEvent.setup();
    render(<CreatorInsightsPage />);
    await waitFor(() => expect(screen.getAllByText('Karura morning tempo run').length).toBeGreaterThanOrEqual(1));

    await user.click(screen.getByRole('button', { name: 'Interactions' }));
    // The video post has more interactions and should now lead the per-post list.
    const section = screen.getByText(/Per-post performance/).closest('section')!;
    const rows = within(section).getAllByText(/run|Form check/);
    expect(rows[0].textContent).toContain('Form check');
  });

  it('explains itself when there is nothing to show', async () => {
    api.getCreatorInsights.mockResolvedValue({ data: { items: [] }, success: true });
    render(<CreatorInsightsPage />);
    expect(await screen.findByText(/Post something and check back/)).toBeInTheDocument();
  });
});
