import { useEffect, useState } from 'react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { useToast } from '@/components/ui/Toast';
import { Toggle } from '@/components/ui/Toggle';
import { useAuthStore } from '@/store/authStore';
import { profilesApi } from '@/api';
import type { ContentRating } from '@/types';
import { SectionShell } from './SectionShell';

export default function Privacy() {
  const { toast } = useToast();
  const profile = useAuthStore((s) => s.profile);
  const user = useAuthStore((s) => s.user);
  const setProfile = useAuthStore((s) => s.setProfile);

  const [privacyForm, setPrivacyForm] = useState({
    privacy_level: profile?.privacy_level || 'public' as 'public' | 'private',
    show_active_status: profile?.show_active_status ?? true,
    is_anonymous_posting: profile?.is_anonymous_posting ?? false,
    content_rating: (profile?.content_rating || 'general') as ContentRating,
  });
  const [privacySaving, setPrivacySaving] = useState(false);
  const [privacySaved, setPrivacySaved] = useState(false);

  useEffect(() => {
    setPrivacyForm({
      privacy_level: profile?.privacy_level || 'public',
      show_active_status: profile?.show_active_status ?? true,
      is_anonymous_posting: profile?.is_anonymous_posting ?? false,
      content_rating: (profile?.content_rating || 'general') as ContentRating,
    });
  }, [profile]);

  const handlePrivacySave = async () => {
    setPrivacySaving(true);
    setPrivacySaved(false);
    try {
      const res = await profilesApi.updateProfile(privacyForm);
      setProfile(res.data);
      setPrivacySaved(true);
      toast('success', 'Privacy settings saved');
      setTimeout(() => setPrivacySaved(false), 2000);
    } catch {
      toast('error', 'Failed to save privacy settings');
    } finally {
      setPrivacySaving(false);
    }
  };

  return (
    <SectionShell title="Privacy">
      <div className="space-y-4">
        {privacySaved && <p className="text-xs text-buddy-green">Privacy settings saved.</p>}
        <Card className="p-4 space-y-4">
          <div className="flex items-center justify-between">
            <div><p className="text-sm font-medium">Account visibility</p><p className="text-xs text-buddy-text-secondary">Who can see your profile</p></div>
            <select value={privacyForm.privacy_level} onChange={(e) => setPrivacyForm(p => ({ ...p, privacy_level: e.target.value as 'public' | 'private' }))}
              className="bg-buddy-surface-raised text-sm rounded-lg px-3 py-1.5 border border-buddy-surface text-buddy-text-primary outline-none">
              <option value="public">Public</option>
              <option value="private">Private</option>
            </select>
          </div>
          <div className="flex items-center justify-between">
            <div><p className="text-sm font-medium">Show activity status</p><p className="text-xs text-buddy-text-secondary">Display when you're online</p></div>
            <Toggle
              checked={privacyForm.show_active_status}
              onCheckedChange={(v) => setPrivacyForm(p => ({ ...p, show_active_status: v }))}
              label="Show activity status"
            />
          </div>
          <div className="flex items-center justify-between">
            <div><p className="text-sm font-medium">Anonymous posting</p><p className="text-xs text-buddy-text-secondary">Post without showing your identity</p></div>
            <Toggle
              checked={privacyForm.is_anonymous_posting}
              onCheckedChange={(v) => setPrivacyForm(p => ({ ...p, is_anonymous_posting: v }))}
              label="Anonymous posting"
            />
          </div>
          <div className="flex items-center justify-between">
            <div className="pr-3">
              <p className="text-sm font-medium">Mature content</p>
              <p className="text-xs text-buddy-text-secondary">
                {user?.is_adult
                  ? 'Show sensitive health & transformation content (18+)'
                  : 'Available once your account is age-verified as 18+'}
              </p>
            </div>
            <select
              value={privacyForm.content_rating}
              disabled={!user?.is_adult && privacyForm.content_rating !== 'mature'}
              onChange={(e) => setPrivacyForm(p => ({ ...p, content_rating: e.target.value as ContentRating }))}
              className="bg-buddy-surface-raised text-sm rounded-lg px-3 py-1.5 border border-buddy-surface text-buddy-text-primary outline-none disabled:opacity-40 disabled:cursor-not-allowed"
              aria-label="Mature content rating"
            >
              <option value="general">General</option>
              <option value="mature" disabled={!user?.is_adult}>Mature (18+)</option>
            </select>
          </div>
          {!user?.is_adult && (
            <p className="text-[11px] text-buddy-text-secondary">
              Mature content is disabled for under-18 accounts. Verify your age from Verifications if this is incorrect.
            </p>
          )}
        </Card>
        <Button variant="outline" className="w-full" size="sm" onClick={handlePrivacySave} isLoading={privacySaving}>Save Privacy Settings</Button>
      </div>
    </SectionShell>
  );
}
