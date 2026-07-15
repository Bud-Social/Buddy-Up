import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/Button';
import { profilesApi } from '@/api';
import type { Profile } from '@/types';

type BuddyState = 'none' | 'pending_sent' | 'pending_received' | 'confirmed';

interface BuddyButtonProps {
  profile: Profile;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
  showMessage?: boolean;
}

function getBuddyState(profile: Profile): BuddyState {
  if (profile.is_buddy) return 'confirmed';
  if (profile.buddy_status === 'pending') return 'pending_received';
  return 'none';
}

export function BuddyButton({ profile, size = 'md', className, showMessage = true }: BuddyButtonProps) {
  const navigate = useNavigate();
  const [state, setState] = useState<BuddyState>(getBuddyState(profile));
  const [isLoading, setIsLoading] = useState(false);

  const handleBuddyAction = async () => {
    if (!profile.username) return;
    setIsLoading(true);
    try {
      if (state === 'confirmed') {
        await profilesApi.removeBuddy(profile.username);
        setState('none');
      } else if (state === 'none') {
        await profilesApi.sendBuddyRequest(profile.username);
        setState('pending_sent');
      } else if (state === 'pending_received') {
        await profilesApi.acceptBuddyRequest(profile.username);
        setState('confirmed');
      }
    } catch {} finally {
      setIsLoading(false);
    }
  };

  const handleMessage = () => {
    if (state === 'confirmed') navigate(`/messages?user=${profile.username}`);
  };

  const labels: Record<BuddyState, string> = {
    none: 'Buddy Up',
    pending_sent: 'Requested',
    pending_received: 'Buddy Back',
    confirmed: 'Buddied ✓',
  };

  const variants: Record<BuddyState, 'primary' | 'outline' | 'secondary'> = {
    none: 'primary',
    pending_sent: 'outline',
    pending_received: 'secondary',
    confirmed: 'outline',
  };

  return (
    <div className={`flex gap-2 ${className || ''}`}>
      <Button
        variant={variants[state]}
        size={size}
        onClick={handleBuddyAction}
        isLoading={isLoading}
        className="flex-1"
      >
        {labels[state]}
      </Button>
      {state === 'confirmed' && showMessage && (
        <Button variant="outline" size={size} onClick={handleMessage} className="flex-shrink-0">
          Message
        </Button>
      )}
    </div>
  );
}
