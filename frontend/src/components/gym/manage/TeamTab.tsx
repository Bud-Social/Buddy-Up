import { useCallback, useEffect, useRef, useState } from 'react';
import {
  Crown, ShieldCheck, Dumbbell, UserCog, UserMinus, Users, X, Search, Plus,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import { gymsApi } from '@/api/gyms';
import { profilesApi } from '@/api/profiles';
import type { Profile } from '@/types';
import type { GymMembership } from '@/types';

interface TeamTabProps {
  members: GymMembership[];
  /** Mirror of the server rule: owners/co-owners can edit anyone below them. */
  currentRole: string | null | undefined;
  onChangeRole: (membership: GymMembership, role: 'member' | 'trainer' | 'moderator') => void;
  onRemove: (membership: GymMembership) => void;
  busyId: string | null;
  slug: string;
  /** Reload the membership list after a mutation that happens inside this tab. */
  onReload: () => Promise<void>;
}

const ROLE_ORDER = ['owner', 'co_owner', 'moderator', 'trainer', 'member'];

const ROLE_META: Record<string, { label: string; variant: 'gold' | 'green' | 'blue' | 'silver'; icon: typeof Crown; blurb: string }> = {
  owner: { label: 'Owner', variant: 'gold', icon: Crown, blurb: 'Full control — tier, wallet, registration, deletion.' },
  co_owner: { label: 'Co-owner', variant: 'blue', icon: ShieldCheck, blurb: 'Manages everything except transferring or deleting the gym.' },
  moderator: { label: 'Moderator', variant: 'blue', icon: UserCog, blurb: 'Triage reviews, announcements and schedule; reads the action log.' },
  trainer: { label: 'Trainer', variant: 'green', icon: Dumbbell, blurb: 'Posts routines and shows the Trainer badge on the gym profile.' },
};

/**
 * Staff roster only — the members directory is the Members tab. This tab
 * answers "who runs this gym, and at what power level?" and is the
 * dedicated home for promoting/demoting between moderator and trainer.
 *
 * The add-member flow uses the same look-up + select the online coaching
 * module uses: start typing, pick a member from the dropdown, click Add.
 */
export function TeamTab({ members, currentRole, onChangeRole, onRemove, busyId, slug, onReload }: TeamTabProps) {
  const canManage = currentRole === 'owner' || currentRole === 'co_owner';
  const staff = members
    .filter((m) => (ROLE_ORDER as string[]).includes(m.role) && m.role !== 'member')
    .sort((a, b) => ROLE_ORDER.indexOf(a.role) - ROLE_ORDER.indexOf(b.role));

  const counts: Record<string, number> = {};
  for (const m of members) counts[m.role] = (counts[m.role] || 0) + 1;

  // ── Adding a new team member ──────────────────────────────────────────
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<Profile[]>([]);
  const [searching, setSearching] = useState(false);
  const [selected, setSelected] = useState<Profile | null>(null);
  const [role, setRole] = useState<'trainer' | 'moderator'>('trainer');
  const [adding, setAdding] = useState(false);
  const [addError, setAddError] = useState<string | null>(null);
  const [addNotice, setAddNotice] = useState<string | null>(null);
  const searchDebounce = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => () => {
    if (searchDebounce.current) clearTimeout(searchDebounce.current);
  }, []);

  const onQueryChange = useCallback((value: string) => {
    setQuery(value);
    setSelected(null);
    setResults([]);
    setAddError(null);
    setAddNotice(null);
    if (searchDebounce.current) clearTimeout(searchDebounce.current);
    const q = value.trim();
    if (q.length < 2) {
      setSearching(false);
      return;
    }
    setSearching(true);
    searchDebounce.current = setTimeout(async () => {
      try {
        const res = await profilesApi.searchProfiles({ q, limit: 6 });
        setResults(res.data || []);
      } catch {
        setResults([]);
      } finally {
        setSearching(false);
      }
    }, 250);
  }, []);

  const add = useCallback(async () => {
    const target = selected ?? (query.trim() ? { username: query.trim() } as Partial<Profile> : null);
    if (!target || !target.username) {
      setAddError('Pick a team member from the suggestions, or type a username.');
      return;
    }
    setAdding(true);
    setAddError(null);
    setAddNotice(null);
    try {
      const res = await gymsApi.addToTeam(slug, { username: target.username, role });
      setAddNotice(res.message || `${target.username} added as ${role}.`);
      setQuery('');
      setResults([]);
      setSelected(null);
      await onReload();
    } catch (e: any) {
      setAddError(e?.response?.data?.message || 'Could not add that member.');
    } finally {
      setAdding(false);
    }
  }, [selected, query, slug, role, onReload]);

  return (
    <section className="space-y-3">
      <h2 className="text-sm font-bold text-buddy-text-secondary uppercase flex items-center gap-2">
        <Users size={14} /> Team ({staff.length})
      </h2>

      <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
        {['owner', 'co_owner', 'moderator', 'trainer'].map((roleCount) => {
          const meta = ROLE_META[roleCount];
          const Icon = meta.icon;
          return (
            <Card key={roleCount} className="p-3 text-center">
              <Icon size={16} className="mx-auto text-buddy-green mb-1" />
              <p className="text-lg font-extrabold font-display leading-none">{counts[roleCount] || 0}</p>
              <p className="text-[10px] text-buddy-text-secondary uppercase mt-0.5">{meta.label}s</p>
            </Card>
          );
        })}
      </div>
      <p className="text-[10px] text-buddy-text-secondary px-0.5">
        Promote a member to Trainer to post routines under the gym. Moderators can triage the queue
        but cannot touch tier, wallet or deletion. Only owners and co-owners can change these roles.
      </p>

      {/* Add to team — looks like the online-coaching picker */}
      {canManage && (
        <Card className="p-3 space-y-2">
          <p className="text-[10px] uppercase tracking-wider text-buddy-text-secondary font-semibold flex items-center gap-1.5">
            <Plus size={12} /> Add to team
          </p>
          <div className="relative">
            <Search size={14} className="absolute left-2.5 top-1/2 -translate-y-1/2 text-buddy-text-secondary pointer-events-none z-[1]" />
            {selected ? (
              <div className="flex items-center gap-2 bg-buddy-surface rounded-xl pl-8 pr-3 py-2 border border-buddy-green/40">
                <Avatar src={selected.avatar_url} alt={selected.display_name || selected.username} size="xs" />
                <div className="flex-1 min-w-0">
                  <p className="text-xs font-medium truncate">{selected.display_name || selected.username}</p>
                  <p className="text-[9px] text-buddy-text-secondary truncate">@{selected.username}{selected.role ? ` · ${selected.role}` : ''}</p>
                </div>
                <button
                  onClick={() => { setSelected(null); setQuery(''); }}
                  aria-label="Clear selection"
                  className="text-buddy-text-secondary hover:text-buddy-text-primary p-1"
                >
                  <X size={14} />
                </button>
              </div>
            ) : (
              <input
                value={query}
                onChange={(e) => onQueryChange(e.target.value)}
                placeholder="Start typing a name or username…"
                aria-label="Search for a team member"
                className="w-full bg-buddy-surface rounded-xl pl-8 pr-8 py-2 text-xs placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
              />
            )}
            {!selected && searching && (
              <div className="absolute right-2 top-1/2 -translate-y-1/2 w-3.5 h-3.5 border-2 border-buddy-green/30 border-t-buddy-green rounded-full animate-spin pointer-events-none" />
            )}
            {!selected && results.length > 0 && (
              <div className="absolute z-20 top-full mt-1 w-full bg-buddy-surface-raised rounded-xl border border-buddy-surface overflow-hidden shadow-2xl max-h-48 overflow-y-auto">
                {results.map((p) => (
                  <button
                    key={p.user_id}
                    onMouseDown={(e) => {
                      e.preventDefault();
                      setSelected(p);
                      setQuery(p.username);
                      setResults([]);
                    }}
                    className="flex w-full items-center gap-2 px-2 py-1.5 text-left hover:bg-buddy-surface"
                  >
                    <Avatar src={p.avatar_url} alt={p.display_name || p.username} size="xs" />
                    <span className="min-w-0 flex-1">
                      <span className="block text-xs font-medium truncate">{p.display_name || p.username}</span>
                      <span className="block text-[9px] text-buddy-text-secondary truncate">@{p.username}{p.role ? ` · ${p.role}` : ''}</span>
                    </span>
                  </button>
                ))}
              </div>
            )}
          </div>
          {addError && <p className="text-[10px] text-buddy-red bg-buddy-red/5 border border-buddy-red/20 rounded-md px-2 py-1" role="alert">{addError}</p>}
          {addNotice && <p className="text-[10px] text-buddy-green bg-buddy-green/5 border border-buddy-green/20 rounded-md px-2 py-1" role="status">{addNotice}</p>}
          <div className="flex items-center gap-2 flex-wrap">
            <div className="flex rounded-lg bg-buddy-surface p-0.5" role="group" aria-label="Role">
              {(['trainer', 'moderator'] as const).map((r) => (
                <button
                  key={r}
                  onClick={() => setRole(r)}
                  aria-pressed={role === r}
                  className={`px-2.5 py-1 rounded-md text-[10px] font-semibold transition-colors ${role === r ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary'}`}
                >
                  {r === 'trainer' ? 'Trainer' : 'Moderator'}
                </button>
              ))}
            </div>
            <Button size="sm" onClick={add} isLoading={adding} disabled={(!selected && !query.trim()) || adding}>
              <Plus size={12} className="mr-1" /> Add to team
            </Button>
          </div>
        </Card>
      )}

      {staff.length === 0 ? (
        <Card className="p-8 text-center text-buddy-text-secondary text-xs">
          No staff yet. Promote a member here from the Members tab once they accept your invite.
        </Card>
      ) : (
        <div className="space-y-2">
          {staff.map((m) => {
            const meta = ROLE_META[m.role] ?? ROLE_META.trainer;
            const editable = canManage && !['owner', 'co_owner'].includes(m.role);
            return (
              <Card key={m.id} className="p-3 flex items-center gap-3">
                <Avatar src={m.member_data?.avatar_url} alt={m.member_data?.display_name || 'Member'} size="sm" />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">{m.member_data?.display_name || 'Unnamed member'}</p>
                  <p className="text-[10px] text-buddy-text-secondary">@{m.member_data?.username} · {meta.blurb}</p>
                </div>
                <Badge variant={meta.variant} size="sm" label={meta.label} />
                {editable && (
                  <div className="flex items-center gap-1 shrink-0">
                    <Button
                      size="sm"
                      variant="ghost"
                      disabled={busyId === m.id}
                      aria-label={`Demote ${m.member_data?.display_name || 'member'} to regular member`}
                      onClick={() => onChangeRole(m, 'member')}
                      className="text-buddy-orange border border-buddy-orange/30 bg-buddy-orange/5 gap-1 rounded-full px-2.5"
                    >
                      <UserMinus size={12} /> Demote
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      disabled={busyId === m.id}
                      aria-label={`Toggle ${m.member_data?.display_name || 'member'} between moderator and trainer`}
                      onClick={() => onChangeRole(m, m.role === 'trainer' ? 'moderator' : 'trainer')}
                      className="text-buddy-text-primary border border-buddy-surface-raised bg-buddy-surface gap-1 rounded-full px-2.5"
                    >
                      <UserCog size={12} /> Toggle
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      disabled={busyId === m.id}
                      aria-label={`Remove ${m.member_data?.display_name || 'member'} from the gym`}
                      onClick={() => onRemove(m)}
                      className="text-buddy-red border border-buddy-red/30 bg-buddy-red/5 gap-1 rounded-full px-2.5"
                    >
                      <X size={12} /> Remove
                    </Button>
                  </div>
                )}
              </Card>
            );
          })}
        </div>
      )}
    </section>
  );
}

export default TeamTab;
