/**
 * AudienceSheet — visibility, comments on/off, and a content-rating note.
 * Visibility options mirror the existing composer constants.
 */
import { Dumbbell, Globe, Lock, MessageCircle, Users } from 'lucide-react';
import type { Visibility } from '@/types';

interface AudienceSheetProps {
  visibility: Visibility;
  commentsDisabled: boolean;
  onVisibilityChange: (v: Visibility) => void;
  onCommentsDisabledChange: (disabled: boolean) => void;
}

const OPTIONS: Array<{ value: Visibility; label: string; desc: string; icon: React.ElementType }> = [
  { value: 'public', label: 'Public', desc: 'Anyone on BuddyUp', icon: Globe },
  { value: 'buddies', label: 'Buddies', desc: 'People you follow & your followers', icon: Users },
  { value: 'gym_members', label: 'Gym Members', desc: 'Members of your tagged gym', icon: Dumbbell },
  { value: 'private', label: 'Only Me', desc: 'Private — visible to you only', icon: Lock },
];

export function AudienceSheet({ visibility, commentsDisabled, onVisibilityChange, onCommentsDisabledChange }: AudienceSheetProps) {
  return (
    <div className="space-y-4">
      <div role="radiogroup" aria-label="Who can watch" className="space-y-2">
        {OPTIONS.map(({ value, label, desc, icon: Icon }) => (
          <button
            key={value}
            role="radio"
            aria-checked={visibility === value}
            onClick={() => onVisibilityChange(value)}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-2xl text-left transition-colors ${
              visibility === value
                ? 'bg-buddy-green/15 ring-1 ring-buddy-green/40'
                : 'bg-buddy-surface-raised hover:bg-buddy-surface'
            }`}
          >
            <span className={`p-2 rounded-full ${visibility === value ? 'bg-buddy-green/20 text-buddy-green' : 'bg-buddy-surface text-buddy-text-secondary'}`}>
              <Icon size={16} />
            </span>
            <span className="flex-1 min-w-0">
              <span className={`block text-sm font-semibold ${visibility === value ? 'text-buddy-green' : 'text-buddy-text-primary'}`}>{label}</span>
              <span className="block text-[11px] text-buddy-text-secondary truncate">{desc}</span>
            </span>
            <span
              className={`w-4 h-4 rounded-full border-2 shrink-0 ${
                visibility === value ? 'border-buddy-green bg-buddy-green' : 'border-buddy-text-secondary/40'
              }`}
            />
          </button>
        ))}
      </div>

      <button
        onClick={() => onCommentsDisabledChange(!commentsDisabled)}
        className="w-full flex items-center gap-3 px-4 py-3 rounded-2xl bg-buddy-surface-raised text-left"
        aria-pressed={!commentsDisabled}
      >
        <span className="p-2 rounded-full bg-buddy-surface text-buddy-text-secondary">
          <MessageCircle size={16} />
        </span>
        <span className="flex-1">
          <span className="block text-sm font-semibold text-buddy-text-primary">Allow comments</span>
          <span className="block text-[11px] text-buddy-text-secondary">
            {commentsDisabled ? 'Comments are off for this post' : 'Everyone who can watch can comment'}
          </span>
        </span>
        <span className={`relative inline-flex h-6 w-11 shrink-0 rounded-full transition-colors ${!commentsDisabled ? 'bg-buddy-green' : 'bg-buddy-surface'}`}>
          <span
            className={`absolute top-0.5 left-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform ${!commentsDisabled ? 'translate-x-5' : ''}`}
          />
        </span>
      </button>

      <p className="text-[11px] text-buddy-text-secondary px-1">
        All posts follow our community guidelines — content must be rated general. Mature content is not
        supported in the studio yet.
      </p>
    </div>
  );
}
