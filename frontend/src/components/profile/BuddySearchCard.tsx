import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Footprints, EyeOff } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { profilesApi, type BuddySearchProfile } from '@/api/profiles';

interface Props {
  /** Omit for own card (uses my search profile). */
  username?: string;
}

/**
 * "Looking for a buddy" card for profile pages. Own card links to setup;
 * others' cards show intents/modes/availability (visibility-aware server-side).
 */
export function BuddySearchCard({ username }: Props) {
  const navigate = useNavigate();
  const [sp, setSp] = useState<(BuddySearchProfile & { display_name?: string }) | null>(null);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    const req = username
      ? profilesApi.getUserSearchProfile(username)
      : profilesApi.getSearchProfile();
    req.then((res) => setSp((res.data as BuddySearchProfile) || null)).catch(() => setSp(null))
      .finally(() => setLoaded(true));
  }, [username]);

  if (!loaded) return null;

  if (!sp || (!sp.intents?.length && !sp.available_now)) {
    if (username) return null;
    return (
      <div className="rounded-xl border border-dashed border-buddy-surface-raised px-4 py-3 text-center mb-4">
        <p className="text-xs text-buddy-text-secondary mb-1.5 flex items-center justify-center gap-1.5">
          <Footprints size={13} className="text-buddy-green" /> Let buddies find you for walks, runs, gym sessions…
        </p>
        <Button size="sm" variant="outline" onClick={() => navigate('/buddies/find')}>Set up buddy search</Button>
      </div>
    );
  }

  return (
    <Card className="p-4 mb-4">
      <div className="flex items-center justify-between mb-2">
        <p className="text-xs font-semibold text-buddy-text-secondary uppercase tracking-wider flex items-center gap-1.5">
          <Footprints size={13} className="text-buddy-green" /> Looking for a buddy
        </p>
        {!username && (
          <button onClick={() => navigate('/buddies/find')} className="text-xs text-buddy-green hover:underline">Manage</button>
        )}
      </div>
      {sp.bio && <p className="text-sm mb-2">{sp.bio}</p>}
      <div className="flex flex-wrap gap-1.5">
        {(sp.intents || []).map((i) => (
          <Badge key={i} variant="green" label={i.replace('_', ' ')} size="sm" />
        ))}
        {sp.custom_intent && <Badge variant="gold" label={sp.custom_intent} size="sm" />}
        {sp.available_now && <Badge variant="green" label="Available now" size="sm" />}
        {sp.age_band && <Badge variant="silver" label={sp.age_band} size="sm" />}
        {!username && sp.incognito && (
          <span className="inline-flex items-center gap-1 text-[11px] text-buddy-text-secondary"><EyeOff size={11} /> Incognito</span>
        )}
      </div>
      {(sp.modes?.length > 0) && (
        <p className="text-xs text-buddy-text-secondary mt-2 capitalize">{sp.modes.join(' · ').replace(/_/g, ' ')}</p>
      )}
      {username && (
        <Button size="sm" variant="outline" className="mt-3 w-full" onClick={() => navigate('/buddies/find')}>
          Find buddies like {sp.display_name || 'them'}
        </Button>
      )}
    </Card>
  );
}
