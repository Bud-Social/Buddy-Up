import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { PostShareSheet, canonicalPostUrl, isVideoPost, trackedShareUrl } from '../PostShareSheet';
import { feedApi } from '@/api/feed';
import type { Post } from '@/types';

vi.mock('@/api/feed', () => ({
  feedApi: { sharePost: vi.fn(), getPostShares: vi.fn() },
}));

const mockSharePost = feedApi.sharePost as unknown as ReturnType<typeof vi.fn>;
const mockGetShares = (feedApi as unknown as { getPostShares: ReturnType<typeof vi.fn> }).getPostShares;

function makePost(overrides: Partial<Post> = {}): Post {
  return {
    id: 'post-123',
    author_data: {
      username: 'coachamy',
      display_name: 'Coach Amy',
      avatar_url: '',
    },
    post_type: 'short_video',
    body: 'Leg day!',
    is_anonymous: false,
    media_urls: ['https://cdn.example/v.mp4'],
    tags: [],
    workout_log_data: null,
    meal_data: null,
    progress_data: null,
    location_label: '',
    view_count: 10,
    reaction_counts: {},
    user_reaction: null,
    comment_count: 0,
    repost_count: 0,
    is_repost: false,
    is_reposted_by_me: false,
    original_post_id: null,
    quote_body: '',
    is_saved: false,
    visibility: 'public',
    moderation_status: 'ok',
    gym_tag_id: null,
    content_rating: 'general',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    ...overrides,
  } as Post;
}

function renderSheet(post: Post, props: Partial<React.ComponentProps<typeof PostShareSheet>> = {}) {
  return render(
    <MemoryRouter>
      <PostShareSheet
        post={post}
        isOpen
        onClose={vi.fn()}
        isSaved={false}
        onToggleSave={vi.fn()}
        isReposted={false}
        onRepost={vi.fn()}
        {...props}
      />
    </MemoryRouter>,
  );
}

describe('isVideoPost / canonicalPostUrl', () => {
  it('detects video posts by type, structured media, or URL', () => {
    expect(isVideoPost(makePost())).toBe(true);
    expect(isVideoPost(makePost({ post_type: 'text', media_urls: [] }))).toBe(false);
    expect(
      isVideoPost(makePost({ post_type: 'photo', media_urls: ['https://cdn.example/a.mov'] })),
    ).toBe(true);
  });

  it('builds the fullscreen deep link for video posts', () => {
    expect(canonicalPostUrl(makePost(), 'https://app.example')).toBe(
      'https://app.example/videos?start=post-123',
    );
  });

  it('falls back to a feed permalink for non-video posts', () => {
    const post = makePost({ post_type: 'text', media_urls: [] });
    expect(canonicalPostUrl(post, 'https://app.example')).toBe('https://app.example/feed?post=post-123');
  });
});

describe('PostShareSheet share action', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockGetShares.mockResolvedValue({ success: true, data: [], message: '', errors: null, pagination: null });
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText: vi.fn().mockResolvedValue(undefined) },
      configurable: true,
    });
  });

  it('records the share and reports the authoritative count on copy', async () => {
    mockSharePost.mockResolvedValue({
      success: true,
      data: { share_count: 6, code: 'abc123' },
      message: '',
      errors: null,
      pagination: null,
    });
    const onShared = vi.fn();
    renderSheet(makePost(), { onShared });

    fireEvent.click(screen.getByRole('button', { name: 'Copy post link' }));

    await waitFor(() => expect(mockSharePost).toHaveBeenCalledWith('post-123', 'copy'));
    await waitFor(() => expect(onShared).toHaveBeenCalledWith(6));
    expect(await screen.findByText('Link copied!')).toBeDefined();
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith(
      expect.stringContaining('ref=abc123'),
    );
  });

  it('shows an inline error and keeps stale state untouched on failure', async () => {
    mockSharePost.mockRejectedValue(new Error('network down'));
    const onShared = vi.fn();
    renderSheet(makePost(), { onShared });

    fireEvent.click(screen.getByRole('button', { name: 'Copy post link' }));

    expect(await screen.findByRole('alert')).toHaveTextContent('Could not record share');
    expect(onShared).not.toHaveBeenCalled();
  });

  it('builds tracked referral links', () => {
    expect(trackedShareUrl('https://app.example/videos?start=p1', 'abc'))
      .toBe('https://app.example/videos?start=p1&ref=abc');
    expect(trackedShareUrl('https://app.example/feed/p1', 'abc'))
      .toBe('https://app.example/feed/p1?ref=abc');
  });

  it('renders the shared-by attribution row', async () => {
    mockGetShares.mockResolvedValue({
      success: true,
      data: [{
        username: 'gymsam', display_name: 'Gym Sam', avatar_url: '',
        channel: 'whatsapp', shared_at: new Date().toISOString(),
        followed_by_viewer: true,
      }],
      message: '', errors: null, pagination: null,
    });
    renderSheet(makePost(), {});
    expect(await screen.findByText('Shared by')).toBeDefined();
    expect(await screen.findByTitle('Gym Sam (@gymsam)')).toBeDefined();
  });
});
