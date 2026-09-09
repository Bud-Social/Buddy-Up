import { useCallback, useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  Activity, CalendarCheck, Dumbbell, Loader, Mail, ShieldCheck, UserPlus, UsersRound,
} from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { Avatar } from '@/components/ui/Avatar';
import { Toggle } from '@/components/ui/Toggle';
import { useToast } from '@/components/ui/Toast';
import { useAuthStore } from '@/store/authStore';
import { guardiansApi } from '@/api';
import type {
  GuardianDashboardEntry, GuardianLink, GuardianPermissions,
} from '@/api/guardians';
import { SectionShell } from './SectionShell';

function PartyCard({ title, person, subtitle, action }: {
  title: string;
  person?: { username: string; display_name: string; avatar_url?: string | null };
  subtitle?: string;
  action?: React.ReactNode;
}) {
  return (
    <Card className="p-3 flex items-center justify-between gap-3">
      <div className="flex items-center gap-3 min-w-0">
        <Avatar src={person?.avatar_url || undefined} alt={person?.display_name || title} size="sm" />
        <div className="min-w-0">
          <p className="text-sm font-medium truncate">{person?.display_name || title}</p>
          <p className="text-xs text-buddy-text-secondary truncate">{subtitle || (person ? `@${person.username}` : '')}</p>
        </div>
      </div>
      {action}
    </Card>
  );
}

function PermissionToggles({ link, onPatch, busy }: {
  link: GuardianLink;
  onPatch: (id: GuardianLink['id'], permissions: Partial<GuardianPermissions>) => void;
  busy: boolean;
}) {
  return (
    <div className="space-y-2 pt-2 border-t border-buddy-surface-raised mt-2">
      <div className="flex items-center justify-between">
        <span className="text-xs text-buddy-text-secondary">Direct messages</span>
        <Toggle
          checked={link.permissions.allow_direct_messages}
          onCheckedChange={() => onPatch(link.id, { allow_direct_messages: !link.permissions.allow_direct_messages })}
          disabled={busy}
          label={`Allow direct messages for ${link.teen?.display_name || 'teen'}`}
        />
      </div>
      <div className="flex items-center justify-between">
        <span className="text-xs text-buddy-text-secondary">Spends</span>
        <Toggle
          checked={link.permissions.allow_spends}
          onCheckedChange={() => onPatch(link.id, { allow_spends: !link.permissions.allow_spends })}
          disabled={busy}
          label={`Allow spends for ${link.teen?.display_name || 'teen'}`}
        />
      </div>
    </div>
  );
}

export default function Family() {
  const { toast } = useToast();
  const user = useAuthStore((s) => s.user);
  const isAdult = Boolean(user?.is_adult);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [asGuardian, setAsGuardian] = useState<GuardianLink[]>([]);
  const [asTeen, setAsTeen] = useState<GuardianLink[]>([]);
  const [dashboard, setDashboard] = useState<GuardianDashboardEntry[]>([]);

  const [inviteForm, setInviteForm] = useState({ teen_email: '', teen_name: '', teen_dob: '' });
  const [inviting, setInviting] = useState(false);

  const [busyId, setBusyId] = useState<string | number | null>(null);
  const [permBusy, setPermBusy] = useState(false);

  const load = useCallback(() => {
    setLoading(true);
    setError('');
    const requests: Array<Promise<void>> = [
      guardiansApi.links().then((res) => {
        setAsGuardian(res.data.as_guardian || []);
        setAsTeen(res.data.as_teen || []);
      }),
    ];
    if (isAdult) {
      requests.push(guardiansApi.dashboard().then((res) => setDashboard(res.data || [])));
    }
    Promise.all(requests)
      .catch(() => setError('Could not load your family links.'))
      .finally(() => setLoading(false));
  }, [isAdult]);

  useEffect(() => { load(); }, [load]);

  const handleInvite = async (e: React.FormEvent) => {
    e.preventDefault();
    const email = inviteForm.teen_email.trim();
    if (!email || !email.includes('@')) {
      toast('error', 'Enter a valid email for your teen');
      return;
    }
    setInviting(true);
    try {
      await guardiansApi.invite({
        teen_email: email,
        ...(inviteForm.teen_name.trim() ? { teen_name: inviteForm.teen_name.trim() } : {}),
        ...(inviteForm.teen_dob ? { teen_dob: inviteForm.teen_dob } : {}),
      });
      toast('success', `Invite sent to ${email}`);
      setInviteForm({ teen_email: '', teen_name: '', teen_dob: '' });
      load();
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      toast('error', data?.message || 'Failed to send invite');
    } finally {
      setInviting(false);
    }
  };

  const handleAccept = async (link: GuardianLink) => {
    setBusyId(link.id);
    try {
      await guardiansApi.acceptLink(link.id);
      toast('success', 'Family link accepted');
      load();
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      toast('error', data?.message || 'Failed to accept link');
    } finally {
      setBusyId(null);
    }
  };

  const handleUnlink = async (link: GuardianLink) => {
    setBusyId(link.id);
    try {
      await guardiansApi.deleteLink(link.id);
      toast('success', 'Family link removed');
      load();
    } catch {
      toast('error', 'Failed to remove link');
    } finally {
      setBusyId(null);
    }
  };

  const handlePermissions = async (id: GuardianLink['id'], permissions: Partial<GuardianPermissions>) => {
    setPermBusy(true);
    try {
      const res = await guardiansApi.updatePermissions(id, permissions);
      setAsGuardian((links) => links.map((l) => (l.id === id ? res.data : l)));
      toast('success', 'Permissions updated');
    } catch {
      toast('error', 'Failed to update permissions');
    } finally {
      setPermBusy(false);
    }
  };

  const dashboardFor = (link: GuardianLink) =>
    dashboard.find((d) => d.link_id === link.id);

  return (
    <SectionShell title="Family">
      {loading ? (
        <Card className="p-8 text-center"><Loader size={24} className="animate-spin text-buddy-text-secondary mx-auto" /></Card>
      ) : (
        <div className="space-y-6">
          {error && (
            <Card className="p-4 text-center">
              <p className="text-sm text-buddy-red mb-2">{error}</p>
              <Button size="sm" variant="outline" onClick={load}>Try Again</Button>
            </Card>
          )}

          {isAdult && (
            <>
              <Card className="p-4">
                <div className="flex items-center gap-2 mb-1">
                  <UserPlus size={16} className="text-buddy-green" />
                  <p className="text-sm font-medium">Invite your teen</p>
                </div>
                <p className="text-xs text-buddy-text-secondary mb-3">
                  Link a under-18 account to manage it as a parental co-owner. They accept the invite from their email.
                </p>
                <form onSubmit={handleInvite} className="space-y-2">
                  <Input type="email" value={inviteForm.teen_email} onChange={(e) => setInviteForm((f) => ({ ...f, teen_email: e.target.value }))} placeholder="Teen's email" required />
                  <Input value={inviteForm.teen_name} onChange={(e) => setInviteForm((f) => ({ ...f, teen_name: e.target.value }))} placeholder="Teen's name (optional)" />
                  <label className="block">
                    <span className="text-xs text-buddy-text-secondary">Date of birth (optional)</span>
                    <input type="date" value={inviteForm.teen_dob} onChange={(e) => setInviteForm((f) => ({ ...f, teen_dob: e.target.value }))}
                      className="mt-1 w-full bg-buddy-surface-raised text-sm rounded-lg px-3 py-2 border border-buddy-surface text-buddy-text-primary outline-none" />
                  </label>
                  <Button type="submit" variant="outline" size="sm" className="w-full" isLoading={inviting}>Send Invite</Button>
                </form>
              </Card>

              <div>
                <h3 className="font-heading text-sm font-semibold mb-2">Linked teens</h3>
                {asGuardian.length === 0 ? (
                  <Card className="p-6 text-center">
                    <UsersRound size={28} className="mx-auto text-buddy-text-secondary/30 mb-2" />
                    <p className="text-sm text-buddy-text-secondary">No teens linked yet</p>
                  </Card>
                ) : (
                  <div className="space-y-3">
                    {asGuardian.map((link) => {
                      const stats = dashboardFor(link);
                      return (
                        <Card key={link.id} className="p-4">
                          <PartyCard
                            title={link.invite_email || 'Teen'}
                            person={link.teen}
                            subtitle={link.status === 'accepted'
                              ? `@${link.teen?.username || ''} · linked`
                              : `Invite pending · ${link.invite_email}`}
                            action={(
                              <Button size="sm" variant="ghost" className="text-buddy-red" isLoading={busyId === link.id} onClick={() => handleUnlink(link)}>
                                Unlink
                              </Button>
                            )}
                          />
                          {link.status === 'accepted' && stats && (
                            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 mt-3">
                              <div className="bg-buddy-surface-raised rounded-xl p-2.5 text-center">
                                <Activity size={14} className="text-buddy-green mx-auto mb-1" />
                                <p className="text-sm font-semibold">{stats.posts_last_7d}</p>
                                <p className="text-[10px] text-buddy-text-secondary">Posts / 7d</p>
                              </div>
                              <div className="bg-buddy-surface-raised rounded-xl p-2.5 text-center">
                                <Dumbbell size={14} className="text-buddy-green mx-auto mb-1" />
                                <p className="text-sm font-semibold">{stats.workouts_last_7d}</p>
                                <p className="text-[10px] text-buddy-text-secondary">Workouts / 7d</p>
                              </div>
                              <div className="bg-buddy-surface-raised rounded-xl p-2.5 text-center">
                                <CalendarCheck size={14} className="text-buddy-green mx-auto mb-1" />
                                <p className="text-sm font-semibold">{stats.upcoming_sessions}</p>
                                <p className="text-[10px] text-buddy-text-secondary">Upcoming</p>
                              </div>
                              <div className="bg-buddy-surface-raised rounded-xl p-2.5 text-center">
                                <ShieldCheck size={14} className="text-buddy-green mx-auto mb-1" />
                                <p className="text-sm font-semibold">{stats.account_age_days}d</p>
                                <p className="text-[10px] text-buddy-text-secondary">Account age</p>
                              </div>
                            </div>
                          )}
                          {link.status === 'accepted' && (
                            <PermissionToggles link={link} onPatch={handlePermissions} busy={permBusy} />
                          )}
                        </Card>
                      );
                    })}
                  </div>
                )}
              </div>
            </>
          )}

          <div>
            <h3 className="font-heading text-sm font-semibold mb-2">
              {isAdult ? 'Linked to you as a teen' : 'Your guardian links'}
            </h3>
            {asTeen.length === 0 ? (
              <Card className="p-6 text-center">
                <UsersRound size={28} className="mx-auto text-buddy-text-secondary/30 mb-2" />
                <p className="text-sm text-buddy-text-secondary">
                  {isAdult ? 'No guardian links for your account' : 'No guardians linked yet'}
                </p>
              </Card>
            ) : (
              <div className="space-y-3">
                {asTeen.map((link) => (
                  <Card key={link.id} className="p-4">
                    <PartyCard
                      title={link.invite_email || 'Guardian'}
                      person={link.guardian}
                      subtitle={link.status === 'accepted'
                        ? `@${link.guardian?.username || ''} · co-owner`
                        : 'Wants to be your guardian'}
                    />
                    {link.status === 'pending' ? (
                      <div className="flex gap-2 mt-3">
                        <Button size="sm" variant="outline" className="flex-1" isLoading={busyId === link.id} onClick={() => handleAccept(link)}>Accept</Button>
                        <Button size="sm" variant="ghost" className="flex-1 text-buddy-red" isLoading={busyId === link.id} onClick={() => handleUnlink(link)}>Decline</Button>
                      </div>
                    ) : (
                      <div className="flex items-center gap-2 mt-3">
                        <Mail size={13} className="text-buddy-text-secondary" />
                        <p className="text-xs text-buddy-text-secondary">
                          This guardian helps manage your account. Ask them to unlink if this is wrong.
                        </p>
                      </div>
                    )}
                  </Card>
                ))}
              </div>
            )}
          </div>

          <Card className="p-4">
            <p className="text-sm font-medium mb-1">Received an invite link?</p>
            <p className="text-xs text-buddy-text-secondary">
              Open the link from your email, or{' '}
              <Link to="/settings/family/accept" className="text-buddy-green hover:text-buddy-green-deep">enter your invite token here</Link>.
            </p>
          </Card>
        </div>
      )}
    </SectionShell>
  );
}
