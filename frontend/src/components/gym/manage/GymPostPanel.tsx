import { useEffect, useState } from 'react';
import { Megaphone, Pin, Dumbbell } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { PostComposer } from '@/components/features/feed/PostComposer';
import { GymDiscoursePost } from '@/components/features/gyms/GymDiscoursePost';
import { gymsApi } from '@/api/gyms';
import type { Post } from '@/types';

interface GymPostPanelProps {
  slug: string;
  gymName: string;
  gymId: string;
  canManage: boolean;
  /** "announce" = only gym posts tagged announcement, pinned; "post" = every gym post. */
  mode: 'post' | 'announce';
  memberCount?: number;
}

/**
 * Gym-authored feed panel: composer + \u201cdiscourse\u201d list, used for both the
 * Posts (\u201cPost as gym\u201d) and Announce tabs.
 *
 * Gym posts appear in the home feed with the gym identity. The Announce
 * tab just filters the discourse to announcement-tagged posts, which are
 * what every member sees pinned at the top of the gym.
 */
export function GymPostPanel({ slug, gymName, gymId, canManage, mode, memberCount }: GymPostPanelProps) {
  const [posts, setPosts] = useState<Post[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [announceTitle, setAnnounceTitle] = useState('');
  const [announceBody, setAnnounceBody] = useState('');
  const [notifyMembers, setNotifyMembers] = useState(true);
  const [sending, setSending] = useState(false);
  const [announcementSent, setAnnouncementSent] = useState<string>('');

  const load = async () => {
    try {
      const res = await gymsApi.getGymFeed(slug);
      const rows: Post[] = Array.isArray(res.data) ? res.data : (res.data as { results?: Post[] })?.results ?? [];
      setPosts(mode === 'announce' ? rows.filter((p) => (p.tags || []).includes('announcement')) : rows);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not load gym feed.');
      setPosts([]);
    }
  };

  useEffect(() => { load(); }, [slug, mode]); // eslint-disable-line react-hooks/exhaustive-deps

  const sendAnnouncement = async () => {
    if (!announceTitle.trim() || !announceBody.trim()) return;
    setSending(true);
    setError(null);
    try {
      await gymsApi.announce(slug, {
        title: announceTitle.trim(),
        body: announceBody.trim(),
        notify_members: notifyMembers,
      });
      setAnnouncementSent('Announcement pinned to your gym feed');
      setAnnounceTitle('');
      setAnnounceBody('');
      await load();
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not post that announcement.');
    } finally {
      setSending(false);
    }
  };

  const onPin = (postId: string, pinned: boolean) => {
    // Optimistic UI toggle — gym discourse in the manage console mirrors the
    // same approach the public gym feed uses (deleting/pinning locally); the
    // backend pin endpoint toggles globally and is not gym-scoped yet.
    setPosts((prev) => prev?.map((p) => (p.id === postId ? { ...p, is_pinned: pinned } : p)) ?? null);
  };

  const onDelete = (postId: string) => {
    if (!window.confirm('Hide this post from the gym feed?')) return;
    setPosts((prev) => prev?.filter((p) => p.id !== postId) ?? null);
  };

  return (
    <section className="space-y-3">
      {/* Composer */}
      {canManage && mode === 'post' && (
        <Card className="p-3">
          <div className="flex items-center gap-2 mb-2">
            <Dumbbell size={14} className="text-buddy-green" />
            <p className="text-xs font-semibold">Posting to the home feed as <span className="text-buddy-green">{gymName}</span></p>
          </div>
          <PostComposer gymId={gymId} gymName={gymName} onPost={() => load()} />
        </Card>
      )}

      {canManage && mode === 'announce' && (
        <Card className="p-3 space-y-2">
          <div className="flex items-center justify-between gap-2">
            <div className="flex items-center gap-2">
              <Megaphone size={14} className="text-buddy-green" />
              <p className="text-xs font-semibold">Post an announcement</p>
            </div>
            {typeof memberCount === 'number' && (
              <span className="text-[10px] text-buddy-text-secondary">{memberCount} members will see it</span>
            )}
          </div>
          <input
            value={announceTitle}
            onChange={(e) => setAnnounceTitle(e.target.value)}
            placeholder="Title"
            maxLength={120}
            className="w-full bg-buddy-surface rounded-xl px-3 py-2 text-xs placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-1 focus:ring-buddy-green/40"
          />
          <textarea
            value={announceBody}
            onChange={(e) => setAnnounceBody(e.target.value)}
            placeholder="What's happening at the gym?"
            rows={3}
            maxLength={1000}
            className="w-full bg-buddy-surface rounded-xl px-3 py-2 text-xs placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-1 focus:ring-buddy-green/40 resize-none"
          />
          <div className="flex items-center justify-between gap-2">
            <label className="flex items-center gap-2 text-[10px] text-buddy-text-secondary cursor-pointer select-none">
              <input type="checkbox" checked={notifyMembers} onChange={(e) => setNotifyMembers(e.target.checked)} className="accent-buddy-green" />
              Notify {typeof memberCount === 'number' ? memberCount : 'all'} active members
            </label>
            <Button size="sm" isLoading={sending} disabled={!announceTitle.trim() || !announceBody.trim()} onClick={sendAnnouncement}>Pin & post</Button>
          </div>
          {announcementSent && <p className="text-[10px] text-buddy-green">{announcementSent}</p>}
        </Card>
      )}

      {error && <p className="text-[11px] text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-2 py-1.5" role="alert">{error}</p>}

      {/* Discourse */}
      <div className="space-y-2">
        <p className="text-[10px] uppercase text-buddy-text-secondary">
          {mode === 'announce' ? 'Announcements (pinned)' : 'Gym feed'} · {posts?.length ?? 0}
        </p>
        {posts === null ? (
          <Card className="h-20 animate-pulse bg-buddy-surface-raised" />
        ) : posts.length === 0 ? (
          <Card className="p-8 text-center text-buddy-text-secondary text-xs">
            {mode === 'announce' ? 'No announcements yet. Pin one above — it shows up first in the gym feed too.' : 'No gym posts yet. Post above and it appears on the home feed as your gym.'}
          </Card>
        ) : (
          posts.map((post) => (
            <div key={post.id} className="relative">
              {post.is_pinned && (
                <span className="absolute -top-2 left-3 z-10 inline-flex items-center gap-1 rounded-full bg-buddy-green px-2 py-0.5 text-[9px] font-bold text-buddy-black">
                  <Pin size={9} /> PINNED
                </span>
              )}
              <GymDiscoursePost
                post={post}
                isAdmin={canManage}
                gymName={gymName}
                onPin={onPin}
                onDelete={onDelete}
              />
            </div>
          ))
        )}
      </div>
    </section>
  );
}
