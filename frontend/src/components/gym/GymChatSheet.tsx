import { FormEvent, useEffect, useRef, useState } from 'react';
import { X, Send, MessagesSquare, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { gymInboxApi, type GymInboxConversation, type GymInboxMessage } from '@/api/gyms';
import { useAuthStore } from '@/store/authStore';

interface GymChatSheetProps {
  open: boolean;
  onClose: () => void;
  gymSlug: string;
  gymName: string;
  gymLogoUrl?: string;
}

/**
 * Member-side conversation with the gym. The gym's inbox lives inside the
 * gym console; this sheet is its counterpart for members and clients —
 * the 1:1 gym chat is created on first send, never leaks into anyone's
 * personal DMs, and is answered by whoever is on duty at the gym.
 */
export function GymChatSheet({ open, onClose, gymSlug, gymName, gymLogoUrl }: GymChatSheetProps) {
  const [conv, setConv] = useState<GymInboxConversation | null>(null);
  const [messages, setMessages] = useState<GymInboxMessage[]>([]);
  const [loading, setLoading] = useState(false);
  const [draft, setDraft] = useState('');
  const [sendBusy, setSendBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const scrollRef = useRef<HTMLDivElement>(null);
  const profile = useAuthStore((s) => s.profile);

  useEffect(() => {
    if (!open) return;
    setLoading(true);
    setError(null);
    gymInboxApi.open(gymSlug, {})
      .then(async (c) => {
        setConv(c);
        const msgs = await gymInboxApi.messages(gymSlug, c.id);
        setMessages(msgs);
      })
      .catch((e: any) => setError(e?.response?.data?.message || 'Could not open the conversation.'))
      .finally(() => setLoading(false));
  }, [open, gymSlug]);

  useEffect(() => {
    if (scrollRef.current) scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
  }, [messages]);

  const send = async (e: FormEvent) => {
    e.preventDefault();
    if (!conv || !draft.trim()) return;
    setSendBusy(true);
    setError(null);
    const body = draft.trim();
    setDraft('');
    try {
      const msg = await gymInboxApi.send(gymSlug, conv.id, body);
      if (msg) setMessages((prev) => [...prev, msg]);
    } catch (e: any) {
      setDraft(body);
      setError(e?.response?.data?.message || 'Could not send that.');
    } finally {
      setSendBusy(false);
    }
  };

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex flex-col justify-end" role="dialog" aria-modal="true" aria-label={`Chat with ${gymName}`}>
      <div className="absolute inset-0 bg-buddy-black/60" onClick={onClose} />
      <div className="relative w-full sm:max-w-lg sm:mx-auto h-[70vh] bg-buddy-black border-t border-buddy-surface-raised rounded-t-3xl flex flex-col shadow-[0_-12px_44px_rgba(0,0,0,0.55)]">
        <div className="flex justify-center pt-3 pb-1"><div className="w-12 h-1.5 bg-buddy-surface-raised rounded-full" /></div>
        <div className="flex items-center gap-3 px-4 pb-3 border-b border-buddy-surface">
          <Avatar src={gymLogoUrl} alt={gymName} size="md" />
          <div className="min-w-0 flex-1">
            <p className="text-sm font-bold truncate">{gymName}</p>
            <p className="text-[10px] uppercase text-buddy-text-secondary">Answered by the whole team on duty</p>
          </div>
          <button onClick={onClose} aria-label="Close" className="p-2 rounded-lg text-buddy-text-secondary hover:text-buddy-text-primary hover:bg-buddy-surface">
            <X size={18} />
          </button>
        </div>

        {error && <p className="mx-4 mt-2 text-[11px] text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-2 py-1.5" role="alert">{error}</p>}

        <div ref={scrollRef} className="flex-1 overflow-y-auto p-4 space-y-2">
          {loading ? (
            <div className="h-full flex items-center justify-center text-buddy-text-secondary text-xs"><Loader2 size={14} className="animate-spin mr-1" /> Loading…</div>
          ) : messages.length === 0 ? (
            <div className="h-full flex flex-col items-center justify-center text-center gap-2">
              <MessagesSquare size={26} className="text-buddy-text-secondary/40" />
              <p className="text-xs text-buddy-text-secondary max-w-[220px]">Say hello to the team — they see your message instantly, and it stays with the gym (never in anyone's DMs).</p>
            </div>
          ) : (
            messages.map((m) => {
              const mine = profile?.username && m.sender_username === profile.username;
              return (
                <div key={m.id} className={`flex ${mine ? 'justify-end' : 'justify-start'}`}>
                  <div className={`max-w-[78%] rounded-2xl px-3 py-2 text-[13px] whitespace-pre-wrap ${mine ? 'bg-buddy-green/15 rounded-br-sm text-buddy-text-primary' : 'bg-buddy-surface rounded-bl-sm text-buddy-text-primary'}`}>
                    {!mine && <p className="text-[9px] text-buddy-green mb-0.5">{m.sender_display} · {gymName}</p>}
                    {m.body}
                  </div>
                </div>
              );
            })
          )}
        </div>

        <form onSubmit={send} className="border-t border-buddy-surface p-3 flex items-center gap-2">
          <input
            value={draft}
            onChange={(e) => setDraft(e.target.value)}
            placeholder={`Message ${gymName}…`}
            className="flex-1 min-w-0 bg-buddy-surface rounded-xl px-3 py-2.5 text-[13px] placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-1 focus:ring-buddy-green/40"
            maxLength={2000}
          />
          <Button type="submit" size="sm" isLoading={sendBusy} disabled={!draft.trim()} aria-label="Send message"><Send size={14} /></Button>
        </form>
      </div>
    </div>
  );
}
