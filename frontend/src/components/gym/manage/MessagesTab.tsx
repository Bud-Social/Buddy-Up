import { FormEvent, useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Loader2, MessagesSquare, Users, Inbox, Send, ArrowLeft, MessageSquarePlus, Megaphone,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import { gymInsightsApi, gymInboxApi, gymsApi, type GymMessagesPayload, type GymInboxConversation, type GymInboxMessage } from '@/api/gyms';
import type { GymMembership } from '@/types';

interface MessagesTabProps {
  slug: string;
}

const KIND_BADGE: Record<string, { label: string; cls: string }> = {
  community: { label: 'Community', cls: 'bg-buddy-blue/10 text-buddy-blue border-buddy-blue/20' },
  group: { label: 'Group', cls: 'bg-buddy-gold/10 text-buddy-gold border-buddy-gold/20' },
  direct: { label: 'Direct', cls: 'bg-buddy-surface text-buddy-text-secondary border-buddy-surface-raised' },
};

const AUDIENCE_BADGE: Record<string, { label: string; cls: string }> = {
  member: { label: 'Member', cls: 'bg-buddy-surface-raised text-buddy-text-secondary border border-buddy-surface-raised' },
  team: { label: 'Team', cls: 'bg-buddy-blue/10 text-buddy-blue border-buddy-blue/20' },
  client: { label: 'Client', cls: 'bg-buddy-gold/10 text-buddy-gold border-buddy-gold/20' },
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
 * Gym inbox — everything that came into the gym
 *
 * `gyms` chats (open conversations with members / team / clients) live in a
 * contained subservice, `/gyms/:slug/inbox/*`, never in the owner's personal
 * DMs. This console holds the full thread + composer here.
 */
export function MessagesTab({ slug }: MessagesTabProps) {
  const navigate = useNavigate();

  const [payload, setPayload] = useState<GymMessagesPayload | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<'all' | 'community' | 'group' | 'direct'>('all');

  // Contained inbox
  const [inbox, setInbox] = useState<GymInboxConversation[] | null>(null);
  const [inboxLoading, setInboxLoading] = useState(true);

  // Thread view
  const [view, setView] = useState<'list' | 'thread'>('list');
  const [activeConv, setActiveConv] = useState<GymInboxConversation | null>(null);
  const [thread, setThread] = useState<GymInboxMessage[]>([]);
  const [threadLoading, setThreadLoading] = useState(false);
  const [threadError, setThreadError] = useState<string | null>(null);
  const [draft, setDraft] = useState('');
  const [sendBusy, setSendBusy] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  // New chat modal
  const [newChatOpen, setNewChatOpen] = useState(false);
  const [members, setMembers] = useState<GymMembership[] | null>(null);
  const [memberQuery, setMemberQuery] = useState('');
  const [memberBusyId, setMemberBusyId] = useState<string | null>(null);
  const [teamBusy, setTeamBusy] = useState(false);

  useEffect(() => {
    if (!slug) return;
    setLoading(true);
    gymInsightsApi.messages(slug)
      .then((res) => setPayload(res.data ?? null))
      .catch((e: any) => setError(e?.response?.data?.message || 'Could not load the gym inbox.'))
      .finally(() => setLoading(false));
    setInboxLoading(true);
    gymInboxApi.list(slug)
      .then(setInbox)
      .catch(() => setInbox([]))
      .finally(() => setInboxLoading(false));
  }, [slug]);

  useEffect(() => {
    if (scrollRef.current) scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
  }, [thread]);

  const conversations = useMemo(
    () => (payload?.conversations ?? []).filter((c) => filter === 'all' || c.kind === filter),
    [payload, filter],
  );

  const openThread = async (conv: GymInboxConversation) => {
    setActiveConv(conv);
    setView('thread');
    setThreadError(null);
    setThreadLoading(true);
    try {
      const msgs = await gymInboxApi.messages(slug, conv.id);
      setThread(msgs);
    } catch (e: any) {
      setThreadError(e?.response?.data?.message || 'Could not load that conversation.');
      setThread([]);
    } finally {
      setThreadLoading(false);
    }
  };

  const closeThread = () => {
    setView('list');
    setActiveConv(null);
    // Unread badge needs a fresh list after we've read the thread.
    gymInboxApi.list(slug).then(setInbox).catch(() => {});
  };

  const sendMessage = async (e: FormEvent) => {
    e.preventDefault();
    if (!activeConv || !draft.trim()) return;
    setSendBusy(true);
    setThreadError(null);
    const body = draft.trim();
    setDraft('');
    try {
      const msg = await gymInboxApi.send(slug, activeConv.id, body);
      if (msg) setThread((prev) => [...prev, msg]);
    } catch (e: any) {
      setDraft(body);
      setThreadError(e?.response?.data?.message || 'Could not send that message.');
    } finally {
      setSendBusy(false);
    }
  };

  const openTeamChat = async () => {
    setTeamBusy(true);
    try {
      const conv = await gymInboxApi.open(slug, { audience: 'team' });
      if (conv) openThread(conv);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not open the team chat.');
    } finally {
      setTeamBusy(false);
    }
  };

  const openMemberPicker = () => {
    setNewChatOpen(true);
    setMemberQuery('');
    setMembers(null);
    gymsApi.getMembers(slug)
      .then((res) => setMembers(res.data ?? []))
      .catch(() => setMembers([]));
  };

  const startMemberChat = async (member: GymMembership) => {
    setMemberBusyId(member.member_id);
    try {
      const conv = await gymInboxApi.open(slug, { audience: 'member', participant_id: member.member_id });
      setNewChatOpen(false);
      if (conv) openThread(conv);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not open that chat.');
    } finally {
      setMemberBusyId(null);
    }
  };

  const filteredMembers = useMemo(() => {
    if (!members) return [];
    const q = memberQuery.trim().toLowerCase();
    if (!q) return members;
    return members.filter((m) =>
      (m.member_data?.username || '').toLowerCase().includes(q) ||
      (m.member_data?.display_name || '').toLowerCase().includes(q),
    );
  }, [members, memberQuery]);

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

  // ── Thread view ──────────────────────────────────────────────────────
  if (view === 'thread' && activeConv) {
    const isTeam = activeConv.conversation_kind === 'team';
    const partner = activeConv.audience_member ?? null;
    const partnerName = isTeam ? (activeConv.group_name || 'Team chat') : (partner?.display_name || partner?.username || 'Member');
    return (
      <section className="space-y-2">
        <div className="flex items-center gap-2">
          <button onClick={closeThread} className="p-2 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary" aria-label="Back to inbox">
            <ArrowLeft size={18} />
          </button>
          <Avatar src={isTeam ? activeConv.group_avatar_url : partner?.avatar_url} alt={partnerName} size="md" />
          <div className="min-w-0 flex-1">
            <p className="text-sm font-bold truncate">{partnerName}</p>
            <p className="text-[9px] uppercase text-buddy-text-secondary">Gym <span className="text-buddy-green">{AUDIENCE_BADGE[activeConv.conversation_kind]?.label ?? 'DM'}</span> · this conversation belongs to the gym, not your DMs</p>
          </div>
        </div>

        {threadError && <p className="text-[11px] text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-2 py-1.5" role="alert">{threadError}</p>}

        <div ref={scrollRef} className="h-[55vh] overflow-y-auto rounded-2xl border border-buddy-surface-raised bg-buddy-surface p-3 space-y-2">
          {threadLoading ? (
            <div className="flex items-center justify-center h-full text-buddy-text-secondary text-xs"><Loader2 size={14} className="animate-spin mr-1" /> Loading…</div>
          ) : thread.length === 0 ? (
            <div className="h-full flex flex-col items-center justify-center text-center">
              <MessagesSquare size={22} className="text-buddy-text-secondary/40 mb-1" />
              <p className="text-xs text-buddy-text-secondary">No messages yet — say hello.</p>
            </div>
          ) : thread.map((m) => {
            // For 1:1 member/client chats every staff member renders on the
            // gym side; for the team chat everyone is gym-side too.
            const isMine = !partner || m.sender_username !== partner.username;
            return (
              <div key={m.id} className={`flex ${isMine ? 'justify-end' : 'justify-start'}`}>
                <div className={`max-w-[75%] rounded-2xl px-3 py-2 text-[12px] whitespace-pre-wrap ${isMine ? 'bg-buddy-green/15 text-buddy-text-primary rounded-br-sm' : 'bg-buddy-surface-raised text-buddy-text-primary rounded-bl-sm'}`}>
                  <p className={`text-[9px] mb-0.5 ${isMine ? 'text-buddy-green' : 'text-buddy-text-secondary'}`}>{isMine ? `${m.sender_display} (gym)` : m.sender_display}</p>
                  {m.body}
                  <p className="text-[8px] text-buddy-text-secondary/70 mt-1">{timeAgo(m.created_at)}</p>
                </div>
              </div>
            );
          })}
        </div>

        <form onSubmit={sendMessage} className="flex items-center gap-2">
          <input
            value={draft}
            onChange={(e) => setDraft(e.target.value)}
            placeholder={`Message ${isTeam ? 'the team' : partnerName}…`}
            className="flex-1 min-w-0 bg-buddy-surface rounded-xl px-3 py-2.5 text-[13px] placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-1 focus:ring-buddy-green/40"
            maxLength={2000}
          />
          <Button type="submit" size="sm" isLoading={sendBusy} disabled={!draft.trim()} aria-label="Send message"><Send size={14} /></Button>
        </form>
      </section>
    );
  }

  // ── List view ────────────────────────────────────────────────────────
  return (
    <section className="space-y-3">
      <div className="flex items-center justify-between gap-2 flex-wrap">
        <p className="text-[10px] uppercase text-buddy-text-secondary flex items-center gap-1.5"><Inbox size={12} /> Gym inbox &amp; community chats</p>
      </div>

      {error && <p className="text-[11px] text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-2 py-1.5" role="alert">{error}</p>}

      {/* Summary strip */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
        {[
          { label: 'Communities linked', value: summary?.community_chats ?? 0 },
          { label: 'Gym team', value: summary?.group_chats ?? 0 },
          { label: 'Gym DMs', value: summary?.direct_threads ?? 0 },
          { label: 'Client messages · 7d', value: summary?.inbound_7d ?? 0 },
        ].map(({ label, value }) => (
          <Card key={label} className="p-3">
            <p className="text-[9px] uppercase text-buddy-text-secondary">{label}</p>
            <p className="text-xl font-extrabold font-display tabular-nums mt-1">{value}</p>
          </Card>
        ))}
      </div>

      {/* Contained gym inbox — never redirects into the owner's personal DMs */}
      <Card className="overflow-hidden">
        <div className="flex items-center justify-between gap-2 px-4 pt-3 pb-2 flex-wrap">
          <p className="text-[10px] uppercase text-buddy-text-secondary flex items-center gap-1.5"><Inbox size={12} /> Gym inbox · {inbox?.length ?? 0}</p>
          <div className="flex items-center gap-1.5">
            <button onClick={openTeamChat} disabled={teamBusy} className="px-2 py-1.5 rounded-lg text-[10px] font-semibold bg-buddy-blue/10 text-buddy-blue hover:bg-buddy-blue/20 disabled:opacity-60 flex items-center gap-1">
              {teamBusy ? <Loader2 size={11} className="animate-spin" /> : <Megaphone size={11} />} Team chat
            </button>
            <button onClick={openMemberPicker} className="px-2 py-1.5 rounded-lg text-[10px] font-semibold bg-buddy-green text-buddy-black flex items-center gap-1"><MessageSquarePlus size={11} /> New chat</button>
          </div>
        </div>
        {inboxLoading ? (
          <div className="px-4 pb-4 text-[11px] text-buddy-text-secondary/70 flex items-center gap-1"><Loader2 size={12} className="animate-spin" />Loading inbox…</div>
        ) : inbox && inbox.length > 0 ? (
          <div className="max-h-80 overflow-y-auto divide-y divide-buddy-surface-raised">
            {inbox.map((conv) => {
              const isTeam = conv.conversation_kind === 'team';
              const partner = conv.audience_member ?? null;
              const name = isTeam ? conv.group_name : (partner?.display_name || partner?.username || 'Member');
              const audience = AUDIENCE_BADGE[conv.conversation_kind] ?? AUDIENCE_BADGE.member;
              return (
                <button
                  key={conv.id}
                  onClick={() => openThread(conv)}
                  className="w-full text-left flex items-center gap-2.5 px-4 py-2.5 hover:bg-buddy-surface/60 transition-colors"
                >
                  <Avatar src={isTeam ? conv.group_avatar_url : partner?.avatar_url} alt={name} size="md" />
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2">
                      <p className="text-[11px] font-semibold truncate flex-1">{name}</p>
                      <span className={`text-[9px] uppercase font-semibold rounded-full px-1.5 py-0.5 whitespace-nowrap ${audience.cls}`}>{audience.label}</span>
                      {conv.unread_count > 0 && <span className="text-[9px] font-bold rounded-full bg-buddy-green text-buddy-black px-1.5 py-0.5 tabular-nums">{conv.unread_count}</span>}
                    </div>
                    <p className="text-[9px] text-buddy-text-secondary truncate mt-0.5">{conv.is_group ? `Team of ${conv.member_count}` : (conv.last_message || 'Say hello')}{conv.last_message_at ? ` · ${timeAgo(conv.last_message_at)}` : ''}</p>
                  </div>
                </button>
              );
            })}
          </div>
        ) : (
          <p className="px-4 pb-4 text-[11px] text-buddy-text-secondary/70">No gym conversations yet. Open the Team chat, message a member, or wait for a client to reach out through the gym page.</p>
        )}
      </Card>

      {/* Community / group conversations — community surfaces open in the regular messaging app */}
      <Card className="overflow-hidden">
        <div className="flex items-center justify-between gap-2 px-4 pt-3 pb-2 flex-wrap">
          <p className="text-[10px] uppercase text-buddy-text-secondary flex items-center gap-1.5"><MessagesSquare size={12} /> Community chats · {conversations.length}</p>
          <div className="flex rounded-lg bg-buddy-surface p-0.5" role="group" aria-label="Filter communities">
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
          <div className="max-h-64 overflow-y-auto divide-y divide-buddy-surface-raised">
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
            {filter === 'all' ? 'No community conversations yet.' : `No ${filter} conversations yet.`}
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

      {/* New chat member picker */}
      <Modal isOpen={newChatOpen} onClose={() => setNewChatOpen(false)} title="Message a member" size="md">
        <div className="space-y-2">
          <input
            value={memberQuery}
            onChange={(e) => setMemberQuery(e.target.value)}
            placeholder="Search members…"
            className="w-full bg-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-1 focus:ring-buddy-green/40"
            autoFocus
          />
          {members === null ? (
            <p className="text-[11px] text-buddy-text-secondary flex items-center gap-1.5 py-2"><Loader2 size={12} className="animate-spin" /> Loading members…</p>
          ) : filteredMembers.length === 0 ? (
            <p className="text-[11px] text-buddy-text-secondary py-2">No members match.</p>
          ) : (
            <div className="max-h-72 overflow-y-auto divide-y divide-buddy-surface-raised">
              {filteredMembers.map((m) => (
                <div key={m.member_id} className="flex items-center gap-2.5 py-2">
                  <Avatar src={m.member_data?.avatar_url} alt={m.member_data?.display_name || m.member_data?.username} size="sm" />
                  <div className="min-w-0 flex-1">
                    <p className="text-[11px] font-semibold truncate">{m.member_data?.display_name || m.member_data?.username}</p>
                    <p className="text-[9px] text-buddy-text-secondary">@{m.member_data?.username} · {m.role}</p>
                  </div>
                  <button
                    onClick={() => startMemberChat(m)}
                    disabled={memberBusyId === m.member_id}
                    className="px-3 py-1.5 rounded-lg text-[10px] font-semibold bg-buddy-green text-buddy-black disabled:opacity-60 flex items-center gap-1"
                  >
                    {memberBusyId === m.member_id ? <Loader2 size={11} className="animate-spin" /> : <Send size={11} />} Chat
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      </Modal>
    </section>
  );
}
