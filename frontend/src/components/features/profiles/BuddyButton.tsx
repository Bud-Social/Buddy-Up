import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { UserPlus, Clock, UserCheck, Handshake, MessageCircle, Check } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { useToast } from '@/components/ui/Toast';
import { profilesApi } from '@/api';
import type { Profile } from '@/types';

type BuddyState = 'none' | 'pending_sent' | 'pending_received' | 'confirmed';

interface BuddyButtonProps {
  profile: Profile;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
  showMessage?: boolean;
  onStateChange?: (newState: BuddyState) => void;
}

function getBuddyState(profile: Profile): BuddyState {
  if (profile.is_buddy) return 'confirmed';
  if (profile.buddy_status === 'pending_received' || profile.buddy_status === 'pending') {
    return 'pending_received';
  }
  if (profile.buddy_status === 'pending_sent') {
    return 'pending_sent';
  }
  return 'none';
}

export function BuddyButton({
  profile,
  size = 'md',
  className,
  showMessage = true,
  onStateChange,
}: BuddyButtonProps) {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [state, setState] = useState<BuddyState>(getBuddyState(profile));
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccessPopped, setIsSuccessPopped] = useState(false);

  useEffect(() => {
    setState(getBuddyState(profile));
  }, [profile.is_buddy, profile.buddy_status]);

  const triggerSuccessAnimation = () => {
    setIsSuccessPopped(true);
    setTimeout(() => setIsSuccessPopped(false), 600);
  };

  const handleBuddyAction = async () => {
    if (!profile.username || isLoading) return;
    setIsLoading(true);
    try {
      if (state === 'confirmed') {
        await profilesApi.removeBuddy(profile.username);
        setState('none');
        onStateChange?.('none');
        toast('info', `Removed @${profile.username} from Buddies`);
      } else if (state === 'none') {
        await profilesApi.sendBuddyRequest(profile.username);
        setState('pending_sent');
        onStateChange?.('pending_sent');
        triggerSuccessAnimation();
        toast('success', `Buddy request sent to @${profile.username}! 💪`);
      } else if (state === 'pending_received') {
        await profilesApi.acceptBuddyRequest(profile.username);
        setState('confirmed');
        onStateChange?.('confirmed');
        triggerSuccessAnimation();
        toast('success', `You and @${profile.username} are now workout buddies! 🎉`);
      } else if (state === 'pending_sent') {
        toast('info', 'Buddy request is pending confirmation.');
      }
    } catch {
      toast('error', 'Failed to update buddy request. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleMessage = () => {
    if (state === 'confirmed') navigate(`/messages?user=${profile.username}`);
  };

  const config: Record<
    BuddyState,
    {
      label: string;
      icon: React.ReactNode;
      variant: 'primary' | 'outline' | 'secondary' | 'ghost';
      accentClass: string;
    }
  > = {
    none: {
      label: 'Buddy Up',
      icon: <UserPlus size={16} className="transition-transform group-hover:scale-110" />,
      variant: 'primary',
      accentClass: 'hover:brightness-105 active:scale-95 transition-all shadow-sm',
    },
    pending_sent: {
      label: 'Request Sent',
      icon: <Clock size={16} className="text-buddy-text-secondary animate-pulse" />,
      variant: 'outline',
      accentClass: 'border-buddy-surface-raised text-buddy-text-secondary hover:border-buddy-border active:scale-95 transition-all',
    },
    pending_received: {
      label: 'Accept Buddy',
      icon: <UserCheck size={16} className="text-buddy-black" />,
      variant: 'primary',
      accentClass: 'bg-buddy-green text-buddy-black ring-2 ring-buddy-green/30 animate-pulse hover:animate-none active:scale-95 transition-all',
    },
    confirmed: {
      label: 'Workout Buddies',
      icon: <Handshake size={16} className="text-buddy-green" />,
      variant: 'outline',
      accentClass: 'border-buddy-green/40 text-buddy-green hover:border-buddy-green active:scale-95 transition-all',
    },
  };

  const current = config[state];

  return (
    <div className={`flex items-center gap-2 ${className || ''}`}>
      <Button
        variant={current.variant}
        size={size}
        onClick={handleBuddyAction}
        isLoading={isLoading}
        className={`group relative flex-1 gap-2 overflow-hidden ${current.accentClass} ${
          isSuccessPopped ? 'scale-105 transition-transform duration-200' : ''
        }`}
      >
        <span className="inline-flex items-center justify-center transition-transform">
          {isSuccessPopped ? <Check size={16} className="text-buddy-green animate-bounce" /> : current.icon}
        </span>
        <span className="font-semibold tracking-wide text-xs sm:text-sm">{current.label}</span>
      </Button>

      {state === 'confirmed' && showMessage && (
        <Button
          variant="outline"
          size={size}
          onClick={handleMessage}
          className="flex-shrink-0 gap-1.5 border-buddy-border hover:border-buddy-green/50 active:scale-95 transition-all"
        >
          <MessageCircle size={15} />
          <span className="hidden sm:inline">Message</span>
        </Button>
      )}
    </div>
  );
}
