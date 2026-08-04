import { useState } from 'react';
import { Heart } from 'lucide-react';
import { feedApi } from '@/api';
import { toEmoji } from '@/utils/emojiUtils';

const REACTIONS = [
  { type: 'pump', emoji: '💪', label: 'Pump' },
  { type: 'fire', emoji: '🔥', label: 'Fire' },
  { type: 'respect', emoji: '🤝', label: 'Respect' },
  { type: 'grind', emoji: '😤', label: 'Grind' },
  { type: 'lets_go', emoji: '🏋️', label: "Let's Go" },
  { type: 'haha', emoji: '😂', label: 'Haha' },
  { type: 'too_hard', emoji: '💀', label: 'Too Hard' },
];

interface ReactionBarProps {
  postId: string;
  reactionCounts: Record<string, number>;
  userReaction?: string | null;
  topReactions: [string, number][];
  totalReactions: number;
}

export function ReactionBar({ postId, userReaction, totalReactions }: ReactionBarProps) {
  const [showPicker, setShowPicker] = useState(false);
  const [currentReaction, setCurrentReaction] = useState<string | null>(userReaction ? toEmoji(userReaction) : null);
  const [isLoading, setIsLoading] = useState(false);

  const handleReact = async (emoji: string) => {
    setIsLoading(true);
    try {
      if (currentReaction === emoji) {
        await feedApi.unreact(postId);
        setCurrentReaction(null);
      } else {
        await feedApi.react(postId, emoji);
        setCurrentReaction(emoji);
      }
    } catch {} finally {
      setIsLoading(false);
      setShowPicker(false);
    }
  };

  return (
    <div className="relative">
      <button
        onClick={(e) => { e.stopPropagation(); setShowPicker(true); }}
        onMouseEnter={() => setShowPicker(true)}
        className="flex items-center gap-1 text-buddy-text-secondary hover:text-buddy-green transition-colors text-sm"
      >
        {currentReaction ? (
          <span className="text-base">{toEmoji(currentReaction)}</span>
        ) : (
          <Heart size={16} />
        )}
        <span>{totalReactions || ''}</span>
      </button>

      {showPicker && (
        <div
          className="absolute bottom-full left-0 mb-2 flex gap-1 bg-buddy-surface-raised border border-buddy-surface rounded-2xl p-2 shadow-2xl z-50"
          onMouseLeave={() => setShowPicker(false)}
          onClick={(e) => e.stopPropagation()}
        >
          {REACTIONS.map(({ type, emoji, label }) => (
            <button
              key={type}
              onClick={() => handleReact(emoji)}
              disabled={isLoading}
              className={`w-10 h-10 flex items-center justify-center rounded-full text-lg transition-all hover:scale-125 hover:bg-buddy-surface ${
                currentReaction === emoji ? 'scale-110 bg-buddy-green/20 ring-2 ring-buddy-green' : ''
              }`}
              title={label}
            >
              {emoji}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
