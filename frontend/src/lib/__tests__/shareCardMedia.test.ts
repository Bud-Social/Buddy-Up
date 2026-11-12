import { describe, it, expect } from 'vitest';
import { hasVideoMedia, selectCardMedia } from '../shareCard';
import type { Post } from '@/types';

/**
 * The card and the server have to agree on which clip goes into a video
 * card: the browser lays the media block out around the clip it expects,
 * and the backend composites the first *video* attachment it finds. When
 * they disagree the clip lands in a block sized for something else.
 */

const base = {
  id: 'post-1',
  body: 'A post',
  author_data: { username: 'demo', display_name: 'Demo' },
} as unknown as Post;

describe('selectCardMedia', () => {
  it('picks the first video attachment when a post has several', () => {
    const post = {
      ...base,
      media: [
        { url: 'https://cdn/photo.webp', media_type: 'image' },
        { url: 'https://cdn/clip.mp4', media_type: 'video' },
      ],
    } as unknown as Post;

    const media = selectCardMedia(post);
    expect(media?.type).toBe('video');
    expect(media?.url).toBe('https://cdn/clip.mp4');
  });

  it('keeps the reported dimensions so the block matches the clip', () => {
    const post = {
      ...base,
      media: [
        { url: 'https://cdn/clip.mp4', media_type: 'video', width: 1920, height: 1080 },
      ],
    } as unknown as Post;

    const media = selectCardMedia(post);
    expect(media?.width).toBe(1920);
    expect(media?.height).toBe(1080);
  });

  it('falls back to the first attachment for a photo post', () => {
    const post = {
      ...base,
      media: [{ url: 'https://cdn/photo.webp', media_type: 'image' }],
    } as unknown as Post;

    const media = selectCardMedia(post);
    expect(media?.type).toBe('image');
    expect(media?.url).toBe('https://cdn/photo.webp');
  });

  it('reads the media_urls list when there are no structured attachments', () => {
    const post = {
      ...base,
      post_type: 'short_video',
      media: [],
      media_urls: ['https://cdn/clip.webm'],
    } as unknown as Post;

    const media = selectCardMedia(post);
    expect(media?.type).toBe('video');
    expect(media?.url).toBe('https://cdn/clip.webm');
  });

  it('treats a video file extension as a video', () => {
    const post = {
      ...base,
      media: [],
      media_urls: ['https://cdn/clip.mov'],
    } as unknown as Post;

    expect(selectCardMedia(post)?.type).toBe('video');
  });

  it('returns nothing for a post without media', () => {
    const post = { ...base, media: [], media_urls: [] } as unknown as Post;
    expect(selectCardMedia(post)).toBeNull();
  });
});

describe('hasVideoMedia', () => {
  it('is true for a post whose clip is a video attachment', () => {
    const post = {
      ...base,
      media: [{ url: 'https://cdn/clip.mp4', media_type: 'video' }],
    } as unknown as Post;
    expect(hasVideoMedia(post)).toBe(true);
  });

  it('is false for a photo post', () => {
    const post = {
      ...base,
      media: [{ url: 'https://cdn/photo.webp', media_type: 'image' }],
    } as unknown as Post;
    expect(hasVideoMedia(post)).toBe(false);
  });
});
