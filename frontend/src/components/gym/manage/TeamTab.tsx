import { Crown, ShieldCheck, Dumbbell, UserCog, UserMinus, Users, X } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import type { GymMembership } from '@/types';

interface TeamTabProps {
  members: GymMembership[];
  /** Mirror of the server rule: owners/co-owners can edit anyone below them. */
  currentRole: string | null | undefined;
  onChangeRole: (membership: GymMembership, role: 'member' | 'trainer' | 'moderator') => void;
  onRemove: (membership: GymMembership) => void;
  busyId: string | null;
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
 */
export function TeamTab({ members, currentRole, onChangeRole, onRemove, busyId }: TeamTabProps) {
  const canManage = currentRole === 'owner' || currentRole === 'co_owner';
  const staff = members
    .filter((m) => (ROLE_ORDER as string[]).includes(m.role) && m.role !== 'member')
    .sort((a, b) => ROLE_ORDER.indexOf(a.role) - ROLE_ORDER.indexOf(b.role));

  const counts: Record<string, number> = {};
  for (const m of members) counts[m.role] = (counts[m.role] || 0) + 1;

  return (
    <section className="space-y-3">
      <h2 className="text-sm font-bold text-buddy-text-secondary uppercase flex items-center gap-2">
        <Users size={14} /> Team ({staff.length})
      </h2>

      <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
        {['owner', 'co_owner', 'moderator', 'trainer'].map((role) => {
          const meta = ROLE_META[role];
          const Icon = meta.icon;
          return (
            <Card key={role} className="p-3 text-center">
              <Icon size={16} className="mx-auto text-buddy-green mb-1" />
              <p className="text-lg font-extrabold font-display leading-none">{counts[role] || 0}</p>
              <p className="text-[10px] text-buddy-text-secondary uppercase mt-0.5">{meta.label}s</p>
            </Card>
          );
        })}
      </div>
      <p className="text-[10px] text-buddy-text-secondary px-0.5">
        Promote a member to Trainer to post routines under the gym. Moderators can triage the queue
        but cannot touch tier, wallet or deletion. Only owners and co-owners can change these roles.
      </p>

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
