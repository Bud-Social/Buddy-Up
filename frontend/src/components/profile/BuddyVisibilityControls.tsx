import { useEffect, useState } from 'react';
import { Toggle } from '@/components/ui/Toggle';
import { profilesApi, BUDDY_VISIBILITY } from '@/api/profiles';
import { useToast } from '@/components/ui/Toast';

/** Buddy-search visibility + incognito switch (EditProfile privacy card). */
export function BuddyVisibilityControls() {
  const { toast } = useToast();
  const [visibility, setVisibility] = useState('public');
  const [incognito, setIncognito] = useState(false);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    profilesApi.getSearchProfile().then((res) => {
      const sp = res.data;
      if (sp) {
        setVisibility(sp.visibility || 'public');
        setIncognito(!!sp.incognito);
      }
    }).catch(() => {}).finally(() => setLoaded(true));
  }, []);

  const save = async (patch: { visibility?: string; incognito?: boolean }) => {
    try {
      await profilesApi.updateSearchProfile(patch);
    } catch {
      toast('error', 'Could not update buddy visibility.');
    }
  };

  if (!loaded) return null;

  return (
    <>
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm">Buddy Search Visibility</p>
          <p className="text-xs text-buddy-text-secondary">Who can find you looking for a buddy</p>
        </div>
        <select value={visibility}
          onChange={(e) => { setVisibility(e.target.value); save({ visibility: e.target.value }); }}
          className="bg-buddy-surface-raised text-sm rounded-lg px-3 py-1.5 border border-buddy-surface text-buddy-text-primary outline-none">
          {BUDDY_VISIBILITY.map((v) => (
            <option key={v} value={v}>{v === 'buddies' ? 'Buddies only' : v[0].toUpperCase() + v.slice(1)}</option>
          ))}
        </select>
      </div>
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm">Incognito Browsing</p>
          <p className="text-xs text-buddy-text-secondary">Browse unseen — hides your online status and last seen</p>
        </div>
        <Toggle checked={incognito}
          onCheckedChange={(v) => { setIncognito(v); save({ incognito: v }); }}
          label="Incognito browsing" />
      </div>
    </>
  );
}
