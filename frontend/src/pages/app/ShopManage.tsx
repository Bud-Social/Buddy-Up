import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import {
  Store, ExternalLink, ShieldCheck, UserCog, UserMinus, UserPlus,
  ChevronRight, BadgeCheck, AlertCircle, Dumbbell,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Avatar } from '@/components/ui/Avatar';
import { Input } from '@/components/ui/Input';
import { marketplaceApi, type ShopFull, type ShopMember } from '@/api/marketplace';
import { GymLinkRequestsPanel } from '@/components/marketplace/GymLinkRequestsPanel';
import { RoleDashboardShell, RoleSectionTitle } from './roles/RoleShell';

type Tab = 'overview' | 'team' | 'gym-links';
const TABS: { key: Tab; label: string }[] = [
  { key: 'overview', label: 'Overview' },
  { key: 'team', label: 'Team' },
  { key: 'gym-links', label: 'Gym requests' },
];

/**
 * Per-shop management console.
 *
 * The gym business console proved the pattern: deep-linkable tabs, a staff
 * roster with the same promotion grammar (owner → manager → staff), and the
 * gym↔shop link queue right where the person who answers it works. This
 * page is that console for the shop side.
 */
export default function ShopManage() {
  const { handle } = useParams<{ handle: string }>();
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();

  const tabFromUrl = (searchParams.get('tab') || '') as Tab | '';
  const [tab, setTabState] = useState<Tab>(TABS.some((t) => t.key === tabFromUrl) ? (tabFromUrl as Tab) : 'overview');
  const setTab = (next: Tab) => {
    setTabState(next);
    if (next === 'overview') searchParams.delete('tab'); else searchParams.set('tab', next);
    setSearchParams(searchParams, { replace: true });
    try { window.scrollTo({ top: 0 }); } catch { /* noop */ }
  };

  const [shop, setShop] = useState<ShopFull | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);
  const [busyUsername, setBusyUsername] = useState<string | null>(null);

  const [inviteUsername, setInviteUsername] = useState('');
  const [inviteRole, setInviteRole] = useState<'manager' | 'staff'>('staff');
  const [inviteBusy, setInviteBusy] = useState(false);

  const load = useCallback(async () => {
    if (!handle) return;
    setLoading(true);
    setError(null);
    try {
      const res = await marketplaceApi.getShopManage(handle);
      setShop(res.data ?? null);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not load this shop.');
      setShop(null);
    } finally {
      setLoading(false);
    }
  }, [handle]);

  useEffect(() => { load(); }, [load]);

  const members = shop?.members ?? [];
  const myRole = shop?.my_role ?? null;
  const isOwner = myRole === 'owner';
  const canManage = isOwner;

  const counts = members.reduce((acc: Record<string, number>, m) => {
    acc[m.role] = (acc[m.role] || 0) + 1;
    return acc;
  }, {});

  const invite = async () => {
    const username = inviteUsername.trim().replace(/^@/, '');
    if (!username || !handle) return;
    setInviteBusy(true);
    setActionError(null);
    setNotice(null);
    try {
      await marketplaceApi.addShopMember(handle, username, inviteRole);
      setNotice(`${username} added as ${inviteRole}.`);
      setInviteUsername('');
      await load();
    } catch (e: any) {
      setActionError(e?.response?.data?.message || 'Could not add that member.');
    } finally {
      setInviteBusy(false);
    }
  };

  const toggleRole = async (member: ShopMember) => {
    const username = member.profile_data?.username;
    if (!username || !handle) return;
    const next = member.role === 'staff' ? 'manager' : 'staff';
    setBusyUsername(username);
    setActionError(null);
    try {
      await marketplaceApi.addShopMember(handle, username, next);
      setNotice(`${username} is now a ${next}.`);
      await load();
    } catch (e: any) {
      setActionError(e?.response?.data?.message || 'Could not change that role.');
    } finally {
      setBusyUsername(null);
    }
  };

  const removeMember = async (member: ShopMember) => {
    const username = member.profile_data?.username;
    if (!username || !handle) return;
    if (!window.confirm(`Remove @${username} from ${shop?.name}? They lose access immediately.`)) return;
    setBusyUsername(username);
    setActionError(null);
    setNotice(null);
    try {
      await marketplaceApi.removeShopMember(handle, username);
      setNotice(`${username} removed.`);
      await load();
    } catch (e: any) {
      setActionError(e?.response?.data?.message || 'Could not remove that member.');
    } finally {
      setBusyUsername(null);
    }
  };

  if (loading) {
    return (
      <div className="max-w-md lg:max-w-2xl xl:max-w-3xl mx-auto p-4 pb-24">
        <Card className="h-28 animate-pulse bg-buddy-surface-raised" />
      </div>
    );
  }

  if (error || !shop) {
    return (
      <div className="max-w-md lg:max-w-2xl xl:max-w-3xl mx-auto p-4 pb-24 space-y-4">
        <p className="text-xs text-buddy-red bg-buddy-red/5 border border-buddy-red/20 rounded-xl px-3 py-2 flex items-center gap-1.5" role="alert">
          <AlertCircle size={13} /> {error || 'Shop not found.'}
        </p>
        <Button variant="outline" onClick={() => navigate('/marketplace/shops')}>Back to My Shops</Button>
      </div>
    );
  }

  // The console is owner/manager/staff equipment. Anyone else gets a clear
  // boundary, never the roster or the approval queue.
  if (!shop.my_role) {
    return (
      <div className="max-w-md lg:max-w-2xl xl:max-w-3xl mx-auto p-4 pb-24 space-y-4">
        <p className="text-xs text-buddy-text-secondary bg-buddy-surface rounded-xl px-3 py-2" role="alert">
          You are not a member of @{shop.handle}. The management console is for the shop's owner, managers and staff.
        </p>
        <Button variant="outline" onClick={() => navigate(`/shops/${shop.handle}`)}>View shop instead</Button>
      </div>
    );
  }

  return (
    <RoleDashboardShell
      title={shop.name}
      subtitle={`Manage @${shop.handle}`}
      onBack={() => navigate('/marketplace/shops')}
      actions={<Button size="sm" variant="outline" onClick={() => navigate(`/shops/${shop.handle}`)}><ExternalLink size={12} className="mr-1" /> View shop</Button>}
    >
      {!canManage && (
        <div className="bg-buddy-orange/10 border border-buddy-orange/20 text-buddy-orange text-xs rounded-xl px-3 py-2">
          Only the shop owner can make changes here.
          <span className="block text-[10px] opacity-80 mt-0.5">You are signed in as {myRole ?? 'an observer'}.</span>
        </div>
      )}
      {actionError && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2" role="alert">{actionError}</div>
      )}
      {notice && (
        <div className="bg-buddy-green/10 border border-buddy-green/20 text-buddy-green text-xs rounded-xl px-3 py-2" role="status">{notice}</div>
      )}

      <div className="flex rounded-xl bg-buddy-surface p-1" role="tablist" aria-label="Shop manage tabs">
        {TABS.map(({ key, label }) => (
          <button
            key={key}
            role="tab"
            aria-selected={tab === key}
            onClick={() => setTab(key)}
            className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors ${tab === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary'}`}
          >
            {label}
          </button>
        ))}
      </div>

      {tab === 'overview' && (
        <section className="space-y-3">
          <Card className="p-4 flex items-center gap-3">
            <div className="w-16 h-16 rounded-2xl flex items-center justify-center overflow-hidden shrink-0" style={{ background: `${shop.accent_color || '#6366f1'}22` }}>
              {shop.logo_url ? <img src={shop.logo_url} alt="" className="w-full h-full object-contain" /> : <Store size={26} className="text-buddy-green" />}
            </div>
            <div className="flex-1 min-w-0">
              <p className="font-bold text-lg leading-tight flex items-center gap-1.5">
                {shop.name}
                {shop.verification_status === 'verified' && <ShieldCheck size={16} className="text-buddy-blue" />}
              </p>
              <p className="text-xs text-buddy-text-secondary">@{shop.handle}</p>
              <div className="flex gap-1.5 mt-1 flex-wrap">
                <Badge size="sm" variant={shop.verification_status === 'verified' ? 'green' : 'silver'} label={shop.verification_status === 'verified' ? 'Verified shop' : 'Unverified'} />
                <Badge size="sm" variant={shop.is_active ? 'green' : 'red'} label={shop.is_active ? 'Live' : 'Inactive'} />
              </div>
            </div>
          </Card>

          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
            {[
              ['Products', shop.product_count],
              ['Programmes', shop.programme_count],
              ['Meal plans', shop.meal_plan_count],
              ['Events', shop.event_count],
            ].map(([label, value]) => (
              <Card key={label as string} className="p-3 text-center">
                <p className="text-2xl font-extrabold font-display leading-none">{(value as number) ?? 0}</p>
                <p className="text-[10px] text-buddy-text-secondary uppercase mt-1">{label as string}</p>
              </Card>
            ))}
          </div>

          <button onClick={() => setTab('gym-links')} className="w-full text-left bg-buddy-green/5 border border-buddy-green/20 hover:border-buddy-green/40 rounded-xl p-3 flex items-center gap-2 transition-colors">
            <Dumbbell size={16} className="text-buddy-green shrink-0" />
            <div className="flex-1 min-w-0 text-xs text-buddy-text-secondary">
              <span className="font-semibold text-buddy-text-primary">Gym partners</span> — approve link requests to feed attribution into the gym's revenue tab.
            </div>
            <ChevronRight size={14} className="text-buddy-text-secondary shrink-0" />
          </button>
        </section>
      )}

      {tab === 'team' && (
        <section className="space-y-3">
          <RoleSectionTitle>Team ({members.length})</RoleSectionTitle>
          <p className="text-[10px] text-buddy-text-secondary px-0.5">
            Owners can change anyone's role. Managers run the shop day-to-day (approve gym links,
            publish posts). Staff work the front — the register, the counter, fulfilling orders.
            Only the owner can invite or remove people.
          </p>

          <div className="grid grid-cols-3 gap-2">
            {(['owner', 'manager', 'staff'] as const).map((role) => (
              <Card key={role} className="p-3 text-center">
                <p className="text-lg font-extrabold font-display leading-none">{counts[role] || 0}</p>
                <p className="text-[10px] text-buddy-text-secondary uppercase mt-1">{role}s</p>
              </Card>
            ))}
          </div>

          {isOwner && (
            <Card className="p-3 space-y-2">
              <p className="text-xs font-semibold flex items-center gap-1.5"><UserPlus size={13} /> Invite to the shop</p>
              <div className="flex gap-2">
                <Input
                  value={inviteUsername}
                  onChange={(e) => setInviteUsername(e.target.value)}
                  placeholder="username"
                  aria-label="Username to invite"
                  className="flex-1"
                />
                <select
                  value={inviteRole}
                  onChange={(e) => setInviteRole(e.target.value as 'manager' | 'staff')}
                  className="bg-buddy-surface border border-buddy-surface-raised rounded-xl px-3 text-xs focus:outline-none"
                  aria-label="Role"
                >
                  <option value="staff">Staff</option>
                  <option value="manager">Manager</option>
                </select>
                <Button size="sm" onClick={invite} isLoading={inviteBusy} disabled={!inviteUsername.trim()}>Add</Button>
              </div>
            </Card>
          )}

          {members.length === 0 ? (
            <Card className="p-8 text-center text-buddy-text-secondary text-xs">No staff yet. Invite your first manager or team member above.</Card>
          ) : (
            <div className="space-y-2">
              {[...members].sort((a, b) => {
                const order = { owner: 0, manager: 1, staff: 2 } as const;
                return (order[a.role as keyof typeof order] ?? 3) - (order[b.role as keyof typeof order] ?? 3);
              }).map((member) => {
                const username = member.profile_data?.username || 'unknown';
                const display = member.profile_data?.display_name || username;
                const editable = isOwner && member.role !== 'owner';
                return (
                  <Card key={member.id} className="p-3 flex items-center gap-3">
                    <Avatar src={member.profile_data?.avatar_url} alt={display} size="sm" />
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium truncate">{display}</p>
                      <p className="text-[10px] text-buddy-text-secondary">@{username} · joined {new Date(member.created_at).toLocaleDateString()}</p>
                    </div>
                    <Badge size="sm" variant={member.role === 'owner' ? 'gold' : member.role === 'manager' ? 'blue' : 'silver'} label={member.role} />
                    {editable && (
                      <div className="flex items-center gap-1 shrink-0">
                        <Button
                          size="sm"
                          variant="ghost"
                          disabled={busyUsername === username}
                          aria-label={`Toggle ${username} between staff and manager`}
                          onClick={() => toggleRole(member)}
                        >
                          <UserCog size={14} />
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          disabled={busyUsername === username}
                          aria-label={`Remove ${username}`}
                          onClick={() => removeMember(member)}
                          className="text-buddy-red"
                        >
                          <UserMinus size={14} />
                        </Button>
                      </div>
                    )}
                    {member.role === 'owner' && isOwner && (
                      <BadgeCheck size={14} className="text-buddy-gold shrink-0" aria-label="Owner" />
                    )}
                  </Card>
                );
              })}
            </div>
          )}
        </section>
      )}

      {tab === 'gym-links' && (
        <section className="space-y-3">
          <RoleSectionTitle>Gym requests</RoleSectionTitle>
          <GymLinkRequestsPanel shop={shop.handle} />
        </section>
      )}
    </RoleDashboardShell>
  );
}
