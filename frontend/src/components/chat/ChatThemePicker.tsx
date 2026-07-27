import { useChatPreferences, BACKGROUND_PRESETS, BUBBLE_COLOR_PRESETS } from '@/store/chatPreferencesStore';
import { X, Check, Palette } from 'lucide-react';

interface ChatThemePickerProps {
  conversationId?: string;
  onClose: () => void;
}

export default function ChatThemePicker({ conversationId, onClose }: ChatThemePickerProps) {
  const prefs = useChatPreferences();

  const convTheme = conversationId ? prefs.perConversationThemes[conversationId] : null;
  const bg = convTheme?.background ?? prefs.background;
  const senderColor = convTheme?.senderBubbleColor ?? prefs.senderBubbleColor;
  const receiverColor = convTheme?.receiverBubbleColor ?? prefs.receiverBubbleColor;

  const setBg = (v: string) => {
    if (conversationId) prefs.setConversationTheme(conversationId, { ...convTheme ?? { background: '', senderBubbleColor: '', receiverBubbleColor: '' }, background: v });
    else prefs.setGlobalBackground(v);
  };
  const setSender = (v: string) => {
    if (conversationId) prefs.setConversationTheme(conversationId, { ...convTheme ?? { background: '', senderBubbleColor: '', receiverBubbleColor: '' }, senderBubbleColor: v });
    else prefs.setSenderBubbleColor(v);
  };
  const setReceiver = (v: string) => {
    if (conversationId) prefs.setConversationTheme(conversationId, { ...convTheme ?? { background: '', senderBubbleColor: '', receiverBubbleColor: '' }, receiverBubbleColor: v });
    else prefs.setReceiverBubbleColor(v);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/60 backdrop-blur-sm" onClick={(e) => e.target === e.currentTarget && onClose()}>
      <div className="w-full max-w-lg bg-buddy-surface-raised rounded-t-3xl max-h-[85vh] flex flex-col shadow-2xl">
        {/* Header */}
        <div className="flex items-center justify-between px-5 pt-5 pb-3 shrink-0">
          <div className="flex items-center gap-2">
            <Palette size={18} className="text-buddy-green" />
            <h3 className="text-lg font-bold font-heading">Chat Theme</h3>
          </div>
          <button onClick={onClose} className="p-1.5 text-buddy-text-secondary hover:text-white rounded-full">
            <X size={20} />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-5">
          {/* Preview */}
          <div className="rounded-2xl p-4 space-y-2 border border-buddy-surface"
            style={{ backgroundColor: bg || undefined }}>
            <div className="flex justify-end">
              <div className="max-w-[70%] rounded-2xl rounded-br-sm px-3 py-2 text-sm"
                style={{ backgroundColor: senderColor || '#bef264', color: senderColor ? '#fff' : '#000' }}>
                Hey! How's it going?
              </div>
            </div>
            <div className="flex justify-start">
              <div className="max-w-[70%] rounded-2xl rounded-bl-sm px-3 py-2 text-sm text-buddy-text-primary"
                style={{ backgroundColor: receiverColor || '#2a2a2e' }}>
                I'm good, thanks! Ready for our session?
              </div>
            </div>
          </div>

          {/* Background */}
          <div>
            <label className="text-xs font-semibold text-buddy-text-secondary mb-2 block">Background</label>
            <div className="grid grid-cols-4 gap-2">
              {BACKGROUND_PRESETS.map((p) => (
                <button key={p.value}
                  onClick={() => setBg(p.value)}
                  className={`h-14 rounded-xl border-2 transition-all ${bg === p.value ? 'border-buddy-green scale-105' : 'border-transparent hover:border-white/20'}`}
                  style={{ backgroundColor: p.value || '#1a1a2e' }}
                  title={p.label}
                >
                  {bg === p.value && <Check size={16} className="mx-auto text-white drop-shadow-lg" />}
                  {!p.value && <span className="text-[9px] text-white/40 font-medium block text-center leading-[44px]">None</span>}
                </button>
              ))}
            </div>
          </div>

          {/* Sender bubble color */}
          <div>
            <label className="text-xs font-semibold text-buddy-text-secondary mb-2 block">Your bubble color</label>
            <div className="grid grid-cols-4 gap-2">
              {BUBBLE_COLOR_PRESETS.map((p) => (
                <button key={p.mine}
                  onClick={() => setSender(p.mine)}
                  className={`h-10 rounded-xl border-2 transition-all flex items-center justify-center ${senderColor === p.mine ? 'border-buddy-green scale-105' : 'border-transparent hover:border-white/20'}`}
                  style={{ backgroundColor: p.mine }}
                >
                  {senderColor === p.mine && <Check size={14} className={p.mine === '#ffffff' ? 'text-black' : 'text-white'} />}
                </button>
              ))}
            </div>
          </div>

          {/* Receiver bubble color */}
          <div>
            <label className="text-xs font-semibold text-buddy-text-secondary mb-2 block">Their bubble color</label>
            <div className="grid grid-cols-4 gap-2">
              {BUBBLE_COLOR_PRESETS.map((p) => (
                <button key={p.theirs}
                  onClick={() => setReceiver(p.theirs)}
                  className={`h-10 rounded-xl border-2 transition-all flex items-center justify-center ${receiverColor === p.theirs ? 'border-buddy-green scale-105' : 'border-transparent hover:border-white/20'}`}
                  style={{ backgroundColor: p.theirs }}
                >
                  {receiverColor === p.theirs && <Check size={14} className="text-white" />}
                </button>
              ))}
            </div>
          </div>

          {/* Conversation-specific actions */}
          {conversationId && (
            <div className="flex gap-2 pt-2">
              <button onClick={() => prefs.resetConversationTheme(conversationId)}
                className="flex-1 py-2.5 rounded-xl border border-buddy-surface text-sm text-buddy-text-secondary hover:text-buddy-text-primary transition-colors">
                Reset to global
              </button>
            </div>
          )}

          {/* Reset all */}
          <div className="text-center pt-1">
            <button onClick={() => { prefs.resetAll(); }}
              className="text-xs text-buddy-text-secondary hover:text-red-400 transition-colors">
              Reset all preferences
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
