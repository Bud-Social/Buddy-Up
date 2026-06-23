import { useState, useEffect, useRef, useCallback } from 'react';
import { useSearchParams } from 'react-router-dom';
import { ArrowLeft, Send, Phone, Video, MoreVertical, Smile, Paperclip, Image, Mic } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { messagingApi } from '@/api/messaging';
import { useAuthStore } from '@/store/authStore';
import type { Conversation, Message as MsgType } from '@/api/messaging';

export default function Messages() {
  const [searchParams] = useSearchParams();
  const profile = useAuthStore((s) => s.profile);
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [activeConvo, setActiveConvo] = useState<Conversation | null>(null);
  const [messages, setMessages] = useState<MsgType[]>([]);
  const [body, setBody] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const fetchConversations = useCallback(async () => {
    try {
      const res = await messagingApi.getConversations();
      setConversations(res.data || []);
    } catch {} finally { setIsLoading(false); }
  }, []);

  useEffect(() => { fetchConversations(); }, [fetchConversations]);

  const openConversation = async (convo: Conversation) => {
    setActiveConvo(convo);
    try {
      const res = await messagingApi.getMessages(convo.id);
      setMessages(res.data || []);
      messagingApi.markRead(convo.id);
    } catch {}
  };

  useEffect(() => {
    const user = searchParams.get('user');
    if (user && conversations.length > 0) {
      const convo = conversations.find((c) =>
        c.participants_data?.some((p) => p.username === user) && !c.is_group
      );
      if (convo) openConversation(convo);
    }
  }, [conversations, searchParams]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSend = async () => {
    if (!body.trim() || !activeConvo) return;
    const text = body.trim();
    setBody('');
    try {
      const res = await messagingApi.sendMessage(activeConvo.id, { body: text, message_type: 'text' });
      setMessages((prev) => [...prev, res.data]);
    } catch {}
  };

  const otherParticipant = (convo: Conversation) => {
    if (convo.is_group) return null;
    return convo.participants_data?.find((p) => p.username !== profile?.username);
  };

  if (activeConvo) {
    const other = otherParticipant(activeConvo);
    return (
      <div className="flex flex-col h-screen bg-buddy-black max-w-lg mx-auto">
        <div className="flex items-center gap-3 p-4 border-b border-buddy-surface">
          <button onClick={() => setActiveConvo(null)} className="p-1 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary">
            <ArrowLeft size={22} />
          </button>
          <Avatar src={other?.avatar_url} alt={other?.display_name || activeConvo.group_name} size="md" />
          <div className="flex-1 min-w-0">
            <h3 className="font-heading font-semibold text-sm">{other?.display_name || activeConvo.group_name}</h3>
            <p className="text-xs text-buddy-text-secondary">@{other?.username || 'Group'}</p>
          </div>
          <div className="flex gap-1">
            <button className="p-2 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary"><Phone size={18} /></button>
            <button className="p-2 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary"><Video size={18} /></button>
          </div>
        </div>

        <div className="flex-1 overflow-y-auto px-4 py-4 space-y-3">
          {messages.length === 0 && (
            <div className="text-center py-20 text-buddy-text-secondary text-sm">
              <p>No messages yet.</p>
              <p className="text-xs mt-1">Send a message to start the conversation!</p>
            </div>
          )}
          {messages.map((msg) => {
            const isMine = msg.sender_data?.username === profile?.username;
            return (
              <div key={msg.id} className={`flex ${isMine ? 'justify-end' : 'justify-start'}`}>
                <div className={`max-w-[80%] ${isMine ? 'order-1' : ''}`}>
                  {!isMine && (
                    <p className="text-xs text-buddy-text-secondary mb-0.5 ml-1">{msg.sender_data?.display_name}</p>
                  )}
                  <div className={`px-4 py-2.5 rounded-2xl text-sm ${
                    isMine ? 'bg-buddy-green text-buddy-black rounded-br-md' : 'bg-buddy-surface rounded-bl-md'
                  }`}>
                    {msg.body}
                  </div>
                  <div className={`flex items-center gap-2 mt-0.5 ${isMine ? 'justify-end' : 'justify-start'} px-1`}>
                    <span className="text-[10px] text-buddy-text-secondary">
                      {new Date(msg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </span>
                    {isMine && (
                      <span className="text-[10px] text-buddy-text-secondary">
                        {msg.is_read ? '✓✓' : '✓'}
                      </span>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
          <div ref={messagesEndRef} />
        </div>

        <div className="p-4 border-t border-buddy-surface">
          <div className="flex items-center gap-2">
            <button className="p-2 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary"><Paperclip size={20} /></button>
            <button className="p-2 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary"><Image size={20} /></button>
            <div className="flex-1 relative">
              <input
                type="text"
                value={body}
                onChange={(e) => setBody(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                placeholder="Type a message..."
                className="w-full bg-buddy-surface rounded-xl pl-4 pr-12 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
              />
              <button onClick={handleSend} disabled={!body.trim()} className="absolute right-2 top-1/2 -translate-y-1/2 p-1.5 rounded-lg bg-buddy-green text-buddy-black disabled:opacity-50">
                <Send size={16} />
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-lg mx-auto p-4">
      <h1 className="font-display text-2xl font-extrabold mb-4">Messages</h1>

      {isLoading ? (
        <div className="space-y-2">
          {Array.from({ length: 5 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-12 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : conversations.length === 0 ? (
        <div className="text-center py-20">
          <Send size={48} className="mx-auto text-buddy-text-secondary/30 mb-4" />
          <p className="text-buddy-text-secondary text-lg">No conversations yet</p>
          <p className="text-buddy-text-secondary/50 text-sm mt-1">Buddy up with someone to start a conversation!</p>
        </div>
      ) : (
        <div className="space-y-1">
          {conversations.map((convo) => {
            const other = otherParticipant(convo);
            return (
              <Card key={convo.id} className="p-3 flex items-center gap-3 hover:bg-buddy-surface-raised transition-colors cursor-pointer"
                onClick={() => openConversation(convo)}>
                <Avatar src={other?.avatar_url || ''} alt={other?.display_name || convo.group_name || 'Group'} size="md" />
                <div className="flex-1 min-w-0">
                  <div className="flex justify-between items-baseline">
                    <p className="text-sm font-medium truncate">
                      {convo.is_group ? convo.group_name : other?.display_name || 'Unknown'}
                    </p>
                    <span className="text-[10px] text-buddy-text-secondary">
                      {convo.last_message_at ? new Date(convo.last_message_at).toLocaleDateString() : ''}
                    </span>
                  </div>
                  <div className="flex justify-between items-center">
                    <p className="text-xs text-buddy-text-secondary truncate">
                      {convo.last_message?.body || 'No messages yet'}
                    </p>
                    {convo.unread_count > 0 && (
                      <span className="bg-buddy-green text-buddy-black text-[10px] font-bold px-1.5 py-0.5 rounded-full min-w-[18px] text-center">
                        {convo.unread_count > 99 ? '99+' : convo.unread_count}
                      </span>
                    )}
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
