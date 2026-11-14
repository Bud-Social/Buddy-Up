import { useState } from 'react';
import { Megaphone, Send } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { gymsApi } from '@/api/gyms';

interface AnnouncementsTabProps {
  slug: string;
  canManage: boolean;
  memberCount: number;
}

interface SentAnnouncement {
  id: string;
  title: string;
  body: string;
  notified: number;
  sentAt: string;
}

/**
 * Gym announcements.
 *
 * Posts into the gym's member-visible feed and pushes a notification to every
 * active member. The recipient count is reported back so the sender can see
 * whether the message reached anybody.
 */
export function AnnouncementsTab({ slug, canManage, memberCount }: AnnouncementsTabProps) {
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [notifyMembers, setNotifyMembers] = useState(true);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [sent, setSent] = useState<SentAnnouncement[]>([]);

  const submit = async () => {
    if (!title.trim() || !body.trim()) return;
    setSending(true);
    setError(null);
    try {
      const res = await gymsApi.announce(slug, {
        title: title.trim(),
        body: body.trim(),
        notify_members: notifyMembers,
      });
      setSent((prev) => [{
        id: res.data.post_id,
        title: title.trim(),
        body: body.trim(),
        notified: res.data.notified,
        sentAt: new Date().toISOString(),
      }, ...prev]);
      setTitle('');
      setBody('');
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not post that announcement.');
    } finally {
      setSending(false);
    }
  };

  return (
    <section className="space-y-3">
      <h2 className="text-sm font-bold text-buddy-text-secondary uppercase">Announcements</h2>

      {error && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2" role="alert">
          {error}
        </div>
      )}

      <Card className="p-4 space-y-3">
        <div className="flex items-center gap-2">
          <Megaphone size={16} className="text-buddy-green" />
          <p className="text-sm font-medium">Post to the gym wall</p>
        </div>
        <p className="text-xs text-buddy-text-secondary">
          Members see this in the gym feed. With notifications on, all
          {memberCount > 0 ? ` ${memberCount}` : ''} active members also get a push.
        </p>
        <Input
          label="Title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="New weekend hours"
          maxLength={150}
        />
        <div>
          <label htmlFor="announcement-body" className="block text-sm font-medium text-buddy-text-secondary mb-1">
            Message
          </label>
          <textarea
            id="announcement-body"
            value={body}
            onChange={(e) => setBody(e.target.value)}
            rows={4}
            maxLength={2000}
            placeholder="What do members need to know?"
            className="w-full bg-buddy-surface border border-buddy-surface-raised rounded-xl p-3 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
          />
          <p className="text-[10px] text-buddy-text-secondary/50 text-right">{body.length}/2000</p>
        </div>
        <label className="flex items-center gap-2 text-xs text-buddy-text-secondary">
          <input
            type="checkbox"
            checked={notifyMembers}
            onChange={(e) => setNotifyMembers(e.target.checked)}
            className="rounded border-buddy-surface-raised"
          />
          Send a push notification to members
        </label>
        <Button
          className="w-full"
          onClick={submit}
          isLoading={sending}
          disabled={!canManage || !title.trim() || !body.trim()}
        >
          <Send size={14} className="mr-1" /> Post announcement
        </Button>
      </Card>

      {sent.length > 0 && (
        <div className="space-y-2">
          <p className="text-xs text-buddy-text-secondary uppercase font-semibold">Sent this session</p>
          {sent.map((item) => (
            <Card key={item.id} className="p-3 space-y-1">
              <div className="flex items-center justify-between gap-2">
                <p className="text-sm font-medium truncate">{item.title}</p>
                <span className="text-[10px] text-buddy-text-secondary flex-shrink-0">
                  {item.notified} notified
                </span>
              </div>
              <p className="text-xs text-buddy-text-secondary whitespace-pre-wrap">{item.body}</p>
            </Card>
          ))}
        </div>
      )}
    </section>
  );
}

export default AnnouncementsTab;
