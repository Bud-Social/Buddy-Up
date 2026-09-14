import { describe, expect, it } from 'vitest';
import { removePostFromList, removeAuthorFromList, postShowsAuthor } from '../Feed';
import type { Post } from '@/types';

function makePost(id: string, username: string, originalUsername?: string): Post {
  return {
    id,
    author_data: { username, display_name: username, avatar_url: '' },
    ...(originalUsername
      ? {
          is_repost: true,
          original_post_data: {
            id: `${id}-orig`,
            author_data: { username: originalUsername, display_name: originalUsername, avatar_url: '' },
            body: '',
            media_urls: [],
            created_at: new Date().toISOString(),
            post_type: 'text',
          },
        }
      : {}),
  } as Post;
}

describe('Feed removal helpers', () => {
  it('removes a single post by id', () => {
    const posts = [makePost('a', 'amy'), makePost('b', 'sam')];
    expect(removePostFromList(posts, 'a').map((p) => p.id)).toEqual(['b']);
  });

  it('detects cards showing an author directly or via a repost quote', () => {
    expect(postShowsAuthor(makePost('a', 'amy'), 'amy')).toBe(true);
    expect(postShowsAuthor(makePost('b', 'sam', 'amy'), 'amy')).toBe(true);
    expect(postShowsAuthor(makePost('c', 'sam'), 'amy')).toBe(false);
  });

  it('removes every card by a muted author, including repost rows', () => {
    const posts = [makePost('a', 'amy'), makePost('b', 'sam', 'amy'), makePost('c', 'sam')];
    expect(removeAuthorFromList(posts, 'amy').map((p) => p.id)).toEqual(['c']);
  });
});
