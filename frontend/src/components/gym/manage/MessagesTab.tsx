import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { MessagesSquare, Users, Inbox, Send } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Avatar } from '@/components/ui/Avatar';
import { gymInsightsApi, type GymMessagesPayload } from '@/api/gyms';

interface MessagesTabProps {
  slug: string;
}

const KIND_BADGE: Record<string, { label: string; cls: string }> = {
  community: { label: 'Community', cls: 'bg-buddy-blue/10 text-buddy-blue border-buddy-blue/20' },
  group: { label: 'Group', cls: 'bg-buddy-gold/10 text-buddy-gold border-buddy-gold/20' },
  direct: { label: 'Direct', cls: 'bg-buddy-surface text-buddy-text-secondary border-buddy-surface-raised' },
};

function timeAgo(iso: string | null) {
  if (!iso) return '';
  const s = Math.max(0, (Date.now() - new Date(iso).getTime()) / 1000);
  if (s < 60) return 'just now';
  if (s < 3600) return `${Math.floor(s / 60)}m ago`;
  if (s < 86400) return `${Math.floor(s / 3600)}h ago`;
  if (s < 7 * 86400) return `${Math.floor(s / 86400)}d ago`;
  return new Date(iso).toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
}

/**
 * Gym inbox — the conversations the gym sits inside (community chats, gym
 * group chats, and direct threads staff hold with members), plus the latest
 * messages that came from people who are not gym staff.
 */
export function MessagesTab({ slug }: MessagesTabProps) {
  const navigate = useNavigate();
  const [payload, setPayload] = useState<GymMessagesPayload | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<'all' | 'community' | 'group' | 'direct'>('all');

  useEffect(() => {
    if (!slug) return;
    setLoading(true);
    setError(null);
    gymInsightsApi.messages(slug)
      .then((res) => setPayload(res.data ?? null))
      .catch((e: any) => setError(e?.response?.data?.message || 'Could not load the gym inbox.'))
      .finally(() => setLoading(false));
  }, [slug]);

  const conversations = useMemo(
    () => (payload?.conversations ?? []).filter((c) => filter === 'all' || c.kind === filter),
    [payload, filter],
  );

  const summary = payload?.summary;

  if (loading) {
    return (
      <div className="grid gap-3 animate-pulse">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
          {Array.from({ length: 4 }).map((_, i) => <div key={i} className="h-16 bg-buddy-surface rounded-2xl" />)}
        </div>
        <div className="h-56 bg-buddy-surface rounded-2xl" />
        <div className="h-40 bg-buddy-surface rounded-2xl" />
      </div>
    );
  }

  return (
    <section className="space-y-3">
      <div className="flex items-center justify-between gap-2 flex-wrap">
        <p className="text-[10px] uppercase text-buddy-text-secondary flex items-center gap-1.5"><Inbox size={12} /> Gym inbox &amp; community chats</p>
      </div>

      {error && <p className="text-[11px] text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-2 py-1.5" role="alert">{error}</p>}

      {/* Summary strip */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
        {[
          { label: 'Community chats', value: summary?.community_chats ?? 0 },
          { label: 'Group chats', value: summary?.group_chats ?? 0 },
          { label: 'Direct threads', value: summary?.direct_threads ?? 0 },
          { label: 'Client messages · 7d', value: summary?.inbound_7d ?? 0 },
        ].map(({ label, value }) => (
          <Card key={label} className="p-3">
            <p className="text-[9px] uppercase text-buddy-text-secondary">{label}</p>
            <p className="text-xl font-extrabold font-display tabular-nums mt-1">{value}</p>
          </Card>
        ))}
      </div>

      {/* Conversations */}
      <Card className="overflow-hidden">
        <div className="flex items-center justify-between gap-2 px-4 pt-3 pb-2 flex-wrap">
          <p className="text-[10px] uppercase text-buddy-text-secondary flex items-center gap-1.5"><MessagesSquare size={12} /> Conversations · {conversations.length}</p>
          <div className="flex rounded-lg bg-buddy-surface p-0.5" role="group" aria-label="Filter conversations">
            {([['all', 'All'], ['community', 'Community'], ['group', 'Groups'], ['direct', 'Direct']] as const).map(([key, label]) => (
              <button
                key={key}
                onClick={() => setFilter(key)}
                aria-pressed={filter === key}
                className={`px-2.5 py-1 rounded-md text-[10px] font-semibold transition-colors ${filter === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary'}`}
              >
                {label}
              </button>
            ))}
          </div>
        </div>
        {conversations.length > 0 ? (
          <div className="max-h-80 overflow-y-auto divide-y divide-buddy-surface-raised">
            {conversations.map((conv) => {
              const badge = KIND_BADGE[conv.kind] ?? KIND_BADGE.direct;
              return (
                <button
                  key={conv.id}
                  onClick={() => navigate(`/messages/${conv.id}`)}
                  className="w-full text-left flex items-center gap-2.5 px-4 py-2.5 hover:bg-buddy-surface/60 transition-colors"
                >
                  <div className="relative shrink-0">
                    {conv.members[0] ? (
                      <Avatar src={conv.members[0].avatar_url} alt={conv.name} size="md" />
                    ) : (
                      <div className="w-10 h-10 rounded-full bg-buddy-surface flex items-center justify-center"><Users size={16} className="text-buddy-text-secondary" /></div>
                    )}
                    {conv.is_community && (
                      <span className="absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 bg-buddy-blue rounded-full border-2 border-buddy-black flex items-center justify-center">
                        <span className="text-[6px] font-bold text-buddy-black">#</span>
                      </span>
                    )}
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2">
                      <p className="text-[11px] font-semibold truncate flex-1">{conv.name}</p>
                      <span className={`text-[9px] uppercase font-semibold border rounded-full px-1.5 py-0.5 whitespace-nowrap ${badge.cls}`}>{badge.label}</span>
                    </div>
                    <p className="text-[9px] text-buddy-text-secondary truncate mt-0.5">
                      {conv.members.length} member{conv.members.length === 1 ? '' : 's'}{conv.last_message ? ` · ${conv.last_message}` : ''}
                    </p>
                  </div>
                  {conv.last_message_at && <span className="text-[9px] text-buddy-text-secondary/60 tabular-nums shrink-0">{timeAgo(conv.last_message_at)}</span>}
                </button>
              );
            })}
          </div>
        ) : (
          <p className="px-4 pb-4 text-[11px] text-buddy-text-secondary/70">
            {filter === 'all'
              ? 'No conversations yet. Community chats you belong to — and DMs staff hold with members — will show up here.'
              : `No ${filter} conversations yet.`}
          </p>
        )}
      </Card>

      {/* Messages from real clients */}
      <Card className="overflow-hidden">
        <div className="flex items-center justify-between px-4 pt-3 pb-2">
          <p className="text-[10px] uppercase text-buddy-text-secondary flex items-center gap-1.5"><Send size={12} /> From real clients</p>
        </div>
        {payload && payload.recent_inbound.length > 0 ? (
          <div className="max-h-72 overflow-y-auto divide-y divide-buddy-surface-raised">
            {payload.recent_inbound.map((m) => (
              <button
                key={m.id}
                onClick={() => navigate(`/messages/${m.conversation}`)}
                className="w-full text-left flex items-start gap-2.5 px-4 py-2.5 hover:bg-buddy-surface/60 transition-colors"
              >
                <Avatar src={m.sender_avatar} alt={m.sender_display} size="sm" />
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-2">
                    <p className="text-[11px] font-semibold truncate flex-1">{m.sender_display}</p>
                    <span className="text-[9px] text-buddy-text-secondary/60 tabular-nums shrink-0">{timeAgo(m.sent_at)}</span>
                  </div>
                  <p className="text-[11px] text-buddy-text-secondary mt-0.5 line-clamp-2">{m.body}</p>
                </div>
              </button>
            ))}
          </div>
        ) : (
          <p className="px-4 pb-4 text-[11px] text-buddy-text-secondary/70">No client messages yet. When a member messages you — about classes, pricing, or a coach — it lands here.</p>
        )}
      </Card>
    </section>
  );
}
