import React, { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Maximize2, X, Send, Users, MessageCircle } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import type { ChatMessage } from '@/hooks/useLiveWebSocket';

interface PipChatPanelProps {
  liveId: string;
  roomTitle?: string;
  hostName?: string;
  viewerCount?: number;
  isAudioOnly?: boolean;
  messages: ChatMessage[];
  onSendMessage: (text: string) => void;
  onSendReaction?: (emoji: string) => void;
  onClose: () => void;
}

export const PipChatPanel: React.FC<PipChatPanelProps> = ({
  liveId,
  roomTitle,
  hostName,
  viewerCount = 1,
  isAudioOnly: _isAudioOnly = false,
  messages,
  onSendMessage,
  onSendReaction,
  onClose,
}) => {
  const navigate = useNavigate();
  const [inputText, setInputText] = useState('');
  const [isMinimized, setIsMinimized] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages.length]);

  const handleSend = (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputText.trim()) return;
    onSendMessage(inputText.trim());
    setInputText('');
  };

  const handleExpand = () => {
    navigate(`/lives/${liveId}`);
  };

  if (isMinimized) {
    return (
      <div className="fixed bottom-4 right-4 z-50 flex items-center gap-2 p-2 px-3 bg-buddy-surface/95 backdrop-blur border border-buddy-green/40 rounded-full shadow-2xl animate-fade-in">
        <span className="w-2.5 h-2.5 rounded-full bg-red-500 animate-pulse" />
        <span className="text-xs font-bold text-white truncate max-w-[120px]">{roomTitle || 'Live Stream'}</span>
        <button
          onClick={() => setIsMinimized(false)}
          className="p-1 rounded-full hover:bg-white/10 text-buddy-text-secondary hover:text-white transition-colors"
          title="Expand Chat"
        >
          <MessageCircle className="w-4 h-4 text-buddy-green" />
        </button>
        <button
          onClick={handleExpand}
          className="p-1 rounded-full hover:bg-white/10 text-buddy-text-secondary hover:text-white transition-colors"
          title="Return to Live Room"
        >
          <Maximize2 className="w-4 h-4" />
        </button>
        <button
          onClick={onClose}
          className="p-1 rounded-full hover:bg-white/10 text-buddy-text-secondary hover:text-white transition-colors"
          title="Close Live"
        >
          <X className="w-4 h-4" />
        </button>
      </div>
    );
  }

  return (
    <div className="fixed bottom-4 right-4 z-50 w-80 sm:w-96 max-h-[460px] h-[440px] bg-buddy-surface/95 backdrop-blur-md border border-buddy-surface-raised rounded-2xl shadow-2xl overflow-hidden flex flex-col transition-all duration-300">
      {/* Header */}
      <div className="flex items-center justify-between p-3 border-b border-buddy-surface-raised bg-buddy-surface/80">
        <div className="flex items-center gap-2 min-w-0">
          <span className="relative flex h-2.5 w-2.5">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75" />
            <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-red-500" />
          </span>
          <div className="truncate">
            <p className="text-xs font-bold text-white truncate">{roomTitle || 'Live Room'}</p>
            <p className="text-[10px] text-buddy-text-secondary truncate">{hostName || 'Streaming now'}</p>
          </div>
        </div>

        <div className="flex items-center gap-1">
          <div className="flex items-center gap-1 px-1.5 py-0.5 rounded-full bg-black/40 text-[10px] font-medium text-buddy-text-secondary mr-1">
            <Users className="w-3 h-3 text-buddy-green" />
            <span>{viewerCount}</span>
          </div>
          <button
            onClick={() => setIsMinimized(true)}
            className="p-1 rounded-lg hover:bg-white/10 text-buddy-text-secondary hover:text-white transition-colors"
            title="Minimize"
          >
            <span className="text-xs font-bold px-1">─</span>
          </button>
          <button
            onClick={handleExpand}
            className="p-1 rounded-lg hover:bg-white/10 text-buddy-text-secondary hover:text-white transition-colors"
            title="Full Screen / Return to Room"
          >
            <Maximize2 className="w-3.5 h-3.5" />
          </button>
          <button
            onClick={onClose}
            className="p-1 rounded-lg hover:bg-red-500/20 text-buddy-text-secondary hover:text-red-400 transition-colors"
            title="Leave Stream"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>

      {/* Messages List */}
      <div className="flex-1 p-3 overflow-y-auto space-y-2.5 text-xs">
        {messages.length === 0 ? (
          <div className="h-full flex flex-col items-center justify-center text-buddy-text-secondary">
            <MessageCircle className="w-8 h-8 opacity-40 mb-1" />
            <p className="text-xs font-medium">Chat is quiet</p>
            <p className="text-[10px] opacity-70">Say hello to the room!</p>
          </div>
        ) : (
          messages.map((msg, idx) => (
            <div key={`${msg.user_id}-${msg.timestamp}-${idx}`} className="flex items-start gap-2 animate-fade-in">
              <Avatar
                src={msg.avatar_url || ''}
                alt={msg.display_name || 'User'}
                size="xs"
                className="mt-0.5 flex-shrink-0"
              />
              <div className="min-w-0 flex-1">
                <div className="flex items-baseline gap-1.5">
                  <span className="font-semibold text-[11px] text-white truncate">
                    {msg.display_name || 'Viewer'}
                  </span>
                  <span className="text-[9px] text-buddy-text-secondary opacity-60">
                    {new Date(msg.timestamp * 1000).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                  </span>
                </div>
                <p className="text-[11px] text-buddy-text break-words mt-0.5 bg-buddy-surface-raised/60 p-1.5 rounded-lg">
                  {msg.message}
                </p>
              </div>
            </div>
          ))
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Quick Reaction Bar */}
      {onSendReaction && (
        <div className="flex items-center justify-around px-2 py-1 bg-buddy-surface-raised/40 border-t border-buddy-surface-raised/50">
          {['🔥', '❤️', '👏', '💪', '⭐'].map((emoji) => (
            <button
              key={emoji}
              onClick={() => onSendReaction(emoji)}
              className="text-base hover:scale-125 transition-transform p-1"
            >
              {emoji}
            </button>
          ))}
        </div>
      )}

      {/* Chat Input */}
      <form onSubmit={handleSend} className="p-2 border-t border-buddy-surface-raised bg-buddy-surface flex items-center gap-1.5">
        <input
          type="text"
          value={inputText}
          onChange={(e) => setInputText(e.target.value)}
          placeholder="Send a chat message..."
          className="flex-1 bg-buddy-surface-raised text-white text-xs rounded-xl px-3 py-2 outline-none border border-transparent focus:border-buddy-green transition-colors"
        />
        <Button
          type="submit"
          size="sm"
          disabled={!inputText.trim()}
          className="h-8 w-8 p-0 rounded-xl bg-buddy-green hover:bg-buddy-green-dark text-buddy-black flex items-center justify-center disabled:opacity-40"
        >
          <Send className="w-3.5 h-3.5" />
        </Button>
      </form>
    </div>
  );
};

export default PipChatPanel;
