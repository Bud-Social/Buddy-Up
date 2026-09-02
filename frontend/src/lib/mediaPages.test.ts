import { describe, it, expect } from 'vitest';
import { mediaPagesFromPost, postIsPhotoMode, firstVideoPage, detectUrlType } from './mediaPages';

describe('mediaPagesFromPost', () => {
  it('prefers structured post.media', () => {
    const pages = mediaPagesFromPost({
      media: [
        { url: 'https://cdn/a.mp4', media_type: 'video', poster_url: 'https://cdn/a.jpg', alt_text: 'Clip', duration_ms: 9000 },
        { url: 'https://cdn/b.webp', media_type: 'image' },
      ],
      media_urls: ['https://legacy/ignored.png'],
    });
    expect(pages).toHaveLength(2);
    expect(pages[0]).toMatchObject({
      url: 'https://cdn/a.mp4',
      type: 'video',
      poster_url: 'https://cdn/a.jpg',
      alt_text: 'Clip',
      duration_ms: 9000,
    });
    expect(pages[1]).toMatchObject({ url: 'https://cdn/b.webp', type: 'image' });
  });

  it('falls back to media_urls with extension detection', () => {
    const pages = mediaPagesFromPost({
      media_urls: ['https://cdn/clip.mp4?v=2', 'https://cdn/song.mp3', 'https://cdn/doc.pdf', 'https://cdn/photo.png'],
    });
    expect(pages.map((p) => p.type)).toEqual(['video', 'audio', 'document', 'image']);
  });

  it('returns empty for posts without media', () => {
    expect(mediaPagesFromPost({})).toEqual([]);
    expect(mediaPagesFromPost({ media_urls: [] })).toEqual([]);
  });
});

describe('detectUrlType', () => {
  it('detects common extensions', () => {
    expect(detectUrlType('https://x/a.mov')).toBe('video');
    expect(detectUrlType('https://x/a.webm')).toBe('video');
    expect(detectUrlType('https://x/a.wav')).toBe('audio');
    expect(detectUrlType('https://x/a.xlsx')).toBe('document');
    expect(detectUrlType('https://x/a.jpeg')).toBe('image');
  });
});

describe('postIsPhotoMode', () => {
  it('is true for multiple items or any image', () => {
    expect(postIsPhotoMode([{ url: 'a.mp4', type: 'video' }, { url: 'b.mp4', type: 'video' }])).toBe(true);
    expect(postIsPhotoMode([{ url: 'a.png', type: 'image' }])).toBe(true);
  });

  it('is false for a single video page', () => {
    expect(postIsPhotoMode([{ url: 'a.mp4', type: 'video' }])).toBe(false);
    expect(postIsPhotoMode([])).toBe(false);
  });
});

describe('firstVideoPage', () => {
  it('returns the first video page or null', () => {
    const video = { url: 'a.mp4', type: 'video' as const };
    expect(firstVideoPage([{ url: 'a.png', type: 'image' }, video])).toBe(video);
    expect(firstVideoPage([{ url: 'a.png', type: 'image' }])).toBeNull();
  });
});
