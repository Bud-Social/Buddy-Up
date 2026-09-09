import { useState } from 'react';
import { Card } from '@/components/ui/Card';
import { Toggle } from '@/components/ui/Toggle';
import { useToast } from '@/components/ui/Toast';
import { useAuthStore } from '@/store/authStore';
import { profilesApi } from '@/api';
import {
  isProfanityFilterEnabled, setProfanityFilterEnabled,
} from '@/lib/profanity';
import { SectionShell } from './SectionShell';

export default function Content() {
  const { toast } = useToast();
  const profile = useAuthStore((s) => s.profile);
  const user = useAuthStore((s) => s.user);
  const setProfile = useAuthStore((s) => s.setProfile);

  const [mature, setMature] = useState(profile?.content_rating === 'mature');
  const [matureSaving, setMatureSaving] = useState(false);
  const [profanity, setProfanity] = useState(isProfanityFilterEnabled());

  const isAdult = Boolean(user?.is_adult);

  const handleMature = async (checked: boolean) => {
    if (!isAdult) {
      toast('error', 'Mature content requires age verification as 18+.');
      return;
    }
    const previous = mature;
    setMature(checked);
    setMatureSaving(true);
    try {
      const res = await profilesApi.updateProfile({ content_rating: checked ? 'mature' : 'general' });
      setProfile(res.data);
    } catch {
      setMature(previous);
      toast('error', 'Failed to update mature content setting');
    } finally {
      setMatureSaving(false);
    }
  };

  const handleProfanity = (checked: boolean) => {
    setProfanity(checked);
    setProfanityFilterEnabled(checked);
  };

  return (
    <SectionShell title="Content Preferences">
      <div className="space-y-4">
        <Card className="p-4 space-y-4">
          <div className="flex items-center justify-between">
            <div className="pr-3">
              <p className="text-sm font-medium">Mature content</p>
              <p className="text-xs text-buddy-text-secondary">
                {isAdult
                  ? 'Show sensitive health & transformation content (18+) in your feed'
                  : 'Available once your account is age-verified as 18+'}
              </p>
            </div>
            <Toggle
              checked={mature}
              onCheckedChange={handleMature}
              disabled={!isAdult || matureSaving}
              label="Mature content"
            />
          </div>
          {!isAdult && (
            <p className="text-[11px] text-buddy-text-secondary">
              Mature content is disabled for under-18 accounts. Verify your age from Verifications if this is incorrect.
            </p>
          )}
          <div className="flex items-center justify-between">
            <div className="pr-3">
              <p className="text-sm font-medium">Profanity filter</p>
              <p className="text-xs text-buddy-text-secondary">Mask explicit language in post text on this device</p>
            </div>
            <Toggle checked={profanity} onCheckedChange={handleProfanity} label="Profanity filter" />
          </div>
        </Card>
        <p className="text-[11px] text-buddy-text-secondary">
          These preferences apply to this browser only. The mature content rating also syncs to your account.
        </p>
      </div>
    </SectionShell>
  );
}
