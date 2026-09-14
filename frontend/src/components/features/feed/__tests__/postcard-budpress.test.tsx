import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { PostCard, bucketFocusDuration } from '../PostCard';
import type { Post } from '@/types';
import type { Profile } from '@/types';
import { useAuthStore } from '@/store/authStore';

const { feedApiMock, profilesApiMock, trackMock, recordViewHookMock } = vi.hoisted(() => ({
  feedApiMock: {
    react: vi.fn(),
    unreact: vi.fn(),
    repost: vi.fn(),
    hidePost: vi.fn(),
    unhidePost: vi.fn(),
    submitReport: vi.fn(),
    muteAuthor: vi.fn(),
    unmuteAuthor: vi.fn(),
    recordView: vi.fn(),
  },
  profilesApiMock: {
    block: vi.fn(),
    unblock: vi.fn(),
    getProfile: vi.fn(),
  },
  trackMock: vi.fn(),
  recordViewHookMock: vi.fn(() => () => {}),
}));

vi.mock('@/lib/analytics', () => ({ track: trackMock }));

vi.mock('@/api/feed', () => ({
  feedApi: feedApiMock,
  REPORT_REASONS: [
    { value: 'spam', label: 'Spam' },
    { value: 'harassment', label: 'Harassment' },
    { value: 'hate_speech', label: 'Hate Speech' },
    { value: 'nudity', label: 'Nudity / Sexual Content' },
    { value: 'adult_ungated', label: 'Adult Content Outside Mature Category' },
    { value: 'violence', label: 'Violence' },
    { value: 'misinformation', label: 'Misinformation' },
    { value: 'impersonation', label: 'Impersonation' },
    { value: 'other', label: 'Other' },
  ],
}));

vi.mock('@/api/profiles', () => ({ profilesApi: profilesApiMock }));

vi.mock('../useRecordPostView', () => ({ useRecordPostView: recordViewHookMock }));

function ok<T>(data: T) {
  return { success: true, data, message: '', errors: null, pagination: null };
}

function makePost(overrides: Partial<Post> = {}): Post {
  return {
    id: 'post-1',
    author_data: {
      user_id: 'u-amy',
      username: 'coachamy',
      display_name: 'Coach Amy',
      avatar_url: '',
    },
    post_type: 'text',
    body: 'Leg day done!',
    is_anonymous: false,
    media_urls: [],
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

function renderCard(post: Post, props: Partial<React.ComponentProps<typeof PostCard>> = {}) {
  return render(
    <MemoryRouter>
      <PostCard post={post} {...props} />
    </MemoryRouter>,
  );
}

function openMenu() {
  fireEvent.click(screen.getByRole('button', { name: 'More options' }));
}

beforeEach(() => {
  vi.clearAllMocks();
  useAuthStore.setState({
    profile: {
      user_id: 'u-viewer',
      username: 'viewer1',
      display_name: 'Viewer One',
      avatar_url: 'https://cdn.example/viewer.png',
    } as unknown as Profile,
  });
});

describe('bucketFocusDuration', () => {
  it('buckets durations for low-cardinality analytics', () => {
    expect(bucketFocusDuration(200)).toBe('<1s');
    expect(bucketFocusDuration(1500)).toBe('1-3s');
    expect(bucketFocusDuration(5000)).toBe('3-10s');
    expect(bucketFocusDuration(30000)).toBe('10s+');
  });
});

describe('PostCard repost avatar overlay', () => {
  it('pops the viewer avatar into the ribbon on repost', async () => {
    feedApiMock.repost.mockResolvedValue(ok({ action: 'reposted', repost_count: 1 }));
    renderCard(makePost());

    // No ribbon before the repost.
    expect(screen.queryByTestId('repost-viewer-avatar')).toBeNull();

    fireEvent.click(screen.getByTestId('rail-repost'));

    expect(feedApiMock.repost).toHaveBeenCalledWith('post-1');
    expect(await screen.findByTestId('repost-viewer-avatar')).toBeInTheDocument();
    expect(screen.getByText('You reposted this')).toBeInTheDocument();
  });

  it('animates the viewer avatar out on unrepost', async () => {
    feedApiMock.repost
      .mockResolvedValueOnce(ok({ action: 'reposted', repost_count: 1 }))
      .mockResolvedValueOnce(ok({ action: 'unreposted', repost_count: 0 }));
    renderCard(makePost());

    fireEvent.click(screen.getByTestId('rail-repost'));
    expect(await screen.findByTestId('repost-viewer-avatar')).toBeInTheDocument();

    fireEvent.click(screen.getByTestId('rail-repost'));
    await waitFor(
      () => expect(screen.queryByTestId('repost-viewer-avatar')).not.toBeInTheDocument(),
      { timeout: 1000 },
    );
  });

  it('pops the viewer avatar into an existing reposters stack', async () => {
    feedApiMock.repost.mockResolvedValue(ok({ action: 'reposted', repost_count: 5 }));
    renderCard(
      makePost({
        id: 'post-9',
        is_repost: true,
        is_reposted_by_me: false,
        original_post_data: {
          id: 'orig-9',
          author_data: { username: 'coachamy', display_name: 'Coach Amy', avatar_url: '' },
          body: 'Original',
          media_urls: [],
          created_at: new Date().toISOString(),
          post_type: 'text',
        },
        ...( { reposters: [{ user_id: 'u-sam', display_name: 'Gym Sam', avatar_url: '' }] } as object ),
      }),
    );

    expect(screen.queryByTestId('repost-viewer-avatar')).toBeNull();
    fireEvent.click(screen.getByTestId('rail-repost'));
    expect(await screen.findByTestId('repost-viewer-avatar')).toBeInTheDocument();
  });
});

describe('PostCard three-dots menu', () => {
  it('toggles Like (💪) on the engagement target and tracks the interaction', async () => {
    feedApiMock.react.mockResolvedValue(ok({ '💪': 1 }));
    renderCard(makePost());

    openMenu();
    fireEvent.click(screen.getByRole('menuitem', { name: 'Like' }));

    expect(feedApiMock.react).toHaveBeenCalledWith('post-1', '💪');
    expect(trackMock).toHaveBeenCalledWith(
      'feed.post_interact',
      expect.objectContaining({
        object_id: 'post-1',
        properties: expect.objectContaining({ action: 'like' }),
      }),
    );
  });

  it('targets the original post id for Like on repost rows', async () => {
    feedApiMock.react.mockResolvedValue(ok({ '💪': 2 }));
    renderCard(
      makePost({
        id: 'row-2',
        is_repost: true,
        original_post_data: {
          id: 'orig-2',
          author_data: { username: 'coachamy', display_name: 'Coach Amy', avatar_url: '' },
          body: 'Original',
          media_urls: [],
          created_at: new Date().toISOString(),
          post_type: 'text',
        },
      }),
    );

    openMenu();
    fireEvent.click(screen.getByRole('menuitem', { name: 'Like' }));
    expect(feedApiMock.react).toHaveBeenCalledWith('orig-2', '💪');
  });

  it('hides the post with an inline undo row on "Not interested"', async () => {
    feedApiMock.hidePost.mockResolvedValue(ok({ hidden: true }));
    feedApiMock.unhidePost.mockResolvedValue(ok({ hidden: false }));
    renderCard(makePost());

    openMenu();
    fireEvent.click(screen.getByRole('menuitem', { name: 'Not interested' }));

    expect(feedApiMock.hidePost).toHaveBeenCalledWith('post-1');
    expect(await screen.findByText(/Post hidden/)).toBeInTheDocument();

    fireEvent.click(screen.getByRole('button', { name: 'Undo' }));
    expect(feedApiMock.unhidePost).toHaveBeenCalledWith('post-1');
    await waitFor(() => expect(screen.getByText('Leg day done!')).toBeInTheDocument());
  });

  it('keeps the card when hide hits a defensive 404', async () => {
    feedApiMock.hidePost.mockRejectedValue({
      response: { status: 404, data: { message: 'Hide is not available yet.' } },
    });
    renderCard(makePost());

    openMenu();
    fireEvent.click(screen.getByRole('menuitem', { name: 'Not interested' }));

    await waitFor(() => expect(feedApiMock.hidePost).toHaveBeenCalled());
    expect(screen.queryByText(/Post hidden/)).not.toBeInTheDocument();
    expect(screen.getByText('Leg day done!')).toBeInTheDocument();
  });

  it('submits a moderation report with author, reason, post id and canonical link', async () => {
    feedApiMock.submitReport.mockResolvedValue(ok({ id: 'report-1' }));
    renderCard(makePost());

    openMenu();
    fireEvent.click(screen.getByRole('menuitem', { name: 'Report' }));
    fireEvent.click(screen.getByRole('menuitemradio', { name: 'Harassment' }));
    fireEvent.click(screen.getByRole('button', { name: 'Submit report' }));

    await waitFor(() => expect(feedApiMock.submitReport).toHaveBeenCalled());
    expect(feedApiMock.submitReport).toHaveBeenCalledWith({
      target_user: 'u-amy',
      reason: 'harassment',
      description: expect.stringContaining('post-1'),
      content_url: expect.stringContaining('post-1'),
    });
    expect(profilesApiMock.getProfile).not.toHaveBeenCalled();
  });

  it('blocks the author after confirm and removes the card', async () => {
    profilesApiMock.block.mockResolvedValue(ok(null));
    const onRemove = vi.fn();
    renderCard(makePost(), { onRemove });

    openMenu();
    fireEvent.click(screen.getByRole('menuitem', { name: 'Block @coachamy' }));
    expect(screen.getByText('Block @coachamy?')).toBeInTheDocument();

    fireEvent.click(screen.getByRole('button', { name: 'Block' }));

    await waitFor(() => expect(profilesApiMock.block).toHaveBeenCalledWith('coachamy'));
    expect(onRemove).toHaveBeenCalledWith('post-1');
    expect(screen.queryByText('Leg day done!')).not.toBeInTheDocument();
  });

  it('mutes the creator and drops their cards via onRemoveAuthor', async () => {
    feedApiMock.muteAuthor.mockResolvedValue(ok(null));
    const onRemoveAuthor = vi.fn();
    renderCard(makePost(), { onRemoveAuthor });

    openMenu();
    fireEvent.click(screen.getByRole('menuitem', { name: /suggest this creator/ }));

    await waitFor(() => expect(feedApiMock.muteAuthor).toHaveBeenCalledWith('coachamy'));
    expect(onRemoveAuthor).toHaveBeenCalledWith('coachamy');
  });

  it('keeps the cards when mute hits a defensive 404', async () => {
    feedApiMock.muteAuthor.mockRejectedValue({
      response: { status: 404, data: { message: 'Mute is not available yet.' } },
    });
    const onRemoveAuthor = vi.fn();
    renderCard(makePost(), { onRemoveAuthor });

    openMenu();
    fireEvent.click(screen.getByRole('menuitem', { name: /suggest this creator/ }));

    await waitFor(() => expect(feedApiMock.muteAuthor).toHaveBeenCalled());
    expect(onRemoveAuthor).not.toHaveBeenCalled();
    expect(screen.getByText('Leg day done!')).toBeInTheDocument();
  });

  it('closes the menu on Escape', async () => {
    renderCard(makePost());
    openMenu();
    expect(screen.getByRole('menu')).toBeInTheDocument();
    fireEvent.keyDown(document, { key: 'Escape' });
    await waitFor(() => expect(screen.queryByRole('menu')).not.toBeInTheDocument());
  });
});

describe('PostCard header view counter', () => {
  it('records on real focus and updates the header count live', () => {
    renderCard(makePost());

    // Hook wired with focus recording for this post.
    expect(recordViewHookMock).toHaveBeenCalledWith(
      'post-1',
      expect.objectContaining({ active: true }),
    );

    expect(screen.getByTestId('header-views')).toHaveTextContent('10');

    const opts = recordViewHookMock.mock.calls[0][1] as { onRecorded: (n: number) => void };
    act(() => opts.onRecorded(99));

    expect(screen.getByTestId('header-views')).toHaveTextContent('99');
    expect(screen.getByTestId('header-views')).toHaveAttribute('aria-label', '99 views');
  });
});
