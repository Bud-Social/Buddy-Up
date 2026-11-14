import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Dumbbell, Plus, Loader2, Users, Percent, ChevronRight, Settings } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { gymsApi } from '@/api/gyms';
import type { Gym } from '@/types';
import { VerifiedGymBadge } from '@/components/gym/VerifiedGymBadge';

/**
 * Every gym the signed-in user owns or co-owns, with a one-click path into
 * the management console. This is the answer to "how do I manage the gyms I
 * created?" — the sidebar's single "My Gym" link only worked for the first
 * one, and a multi-gym owner had no page that admitted the rest existed.
 */
export default function ManagedGymsPage() {
  const navigate = useNavigate();
  const [gyms, setGyms] = useState<Gym[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    gymsApi.list({ my: true })
      .then((res) => {
        if (cancelled) return;
        const rows: Gym[] = Array.isArray(res?.data) ? res.data : (res?.data as { results?: Gym[] })?.results ?? [];
        // Only gyms the viewer can actually manage — owners and co-owners.
        // Moderators/trainers could technically run the console for roles
        // the badge claims, but management pages own members and money, so
        // co-ownership is the bar.
        setGyms(rows.filter((g) => g.membership_role === 'owner' || g.membership_role === 'co_owner'));
      })
      .catch(() => {
        if (cancelled) return;
        setError('Could not load the gyms you manage right now.');
        setGyms([]);
      });
    return () => { cancelled = true; };
  }, []);

  if (gyms === null) {
    return (
      <div className="p-8 flex items-center justify-center gap-2 text-buddy-text-secondary">
        <Loader2 size={20} className="animate-spin" />
        <span className="text-sm">Loading your gyms…</span>
      </div>
    );
  }

  return (
    <div className="p-4 max-w-5xl mx-auto space-y-4">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-bold flex items-center gap-2">
            <Dumbbell size={22} className="text-buddy-green" /> My Gyms
          </h1>
          <p className="text-sm text-buddy-text-secondary mt-0.5">
            Gyms you own or co-own. Open one to manage members, locations,
            online coaching, announcements and business setup.
          </p>
        </div>
        <Button size="sm" onClick={() => navigate('/gyms/create')}>
          <Plus size={14} className="mr-1" /> New gym
        </Button>
      </div>

      {error && (
        <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red text-sm rounded-xl px-3 py-2" role="alert">
          {error}
        </div>
      )}

      {gyms.length === 0 ? (
        <Card className="p-10 text-center">
          <Dumbbell size={36} className="mx-auto text-buddy-text-secondary/30 mb-3" />
          <p className="text-buddy-text-secondary text-sm font-medium">You don't own any gyms yet</p>
          <p className="text-buddy-text-secondary/70 text-xs mt-1">
            Create one and you'll get its management console — real member roster, locations,
            online coaching and business registration.
          </p>
          <Button className="mt-4" onClick={() => navigate('/gyms/create')}>
            <Plus size={14} className="mr-1" /> Create a gym
          </Button>
        </Card>
      ) : (
        <div className="space-y-2">
          {gyms.map((gym) => (
            <Link
              key={gym.id}
              to={`/gyms/${gym.handle}/manage`}
              className="block focus:outline-none focus:ring-2 focus:ring-buddy-green/40 rounded-2xl"
            >
              <Card className="p-4 flex items-center gap-3 hover:bg-buddy-surface-raised transition-colors">
                <div className="w-12 h-12 rounded-xl bg-buddy-green/10 flex items-center justify-center text-buddy-green overflow-hidden">
                  {gym.logo_url
                    ? <img src={gym.logo_url} alt="" className="w-full h-full object-contain" />
                    : <Dumbbell size={22} />}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-sm font-semibold truncate">{gym.name}</p>
                    <VerifiedGymBadge verified={gym.is_verified} tier={gym.tier} />
                    {gym.registration_status === 'verified' && (
                      <span className="text-[10px] font-bold uppercase tracking-wider text-buddy-blue bg-buddy-blue/10 border border-buddy-blue/30 rounded-full px-1.5 py-0.5">
                        Registered
                      </span>
                    )}
                  </div>
                  <p className="text-xs text-buddy-text-secondary truncate">
                    @{gym.handle}
                    {gym.tier && ` · ${gym.tier}`}
                    {' · '}
                    {gym.membership_role === 'co_owner' ? 'co-owner' : 'owner'}
                  </p>
                  <div className="flex flex-wrap items-center gap-x-3 gap-y-1 mt-1 text-[11px] text-buddy-text-secondary">
                    <span className="flex items-center gap-1"><Users size={11} /> {gym.member_count} members</span>
                    {gym.online_capacity > 0 && <span>{gym.online_capacity} online seats</span>}
                    {gym.physical_capacity > 0 && <span>{gym.physical_capacity} physical seats</span>}
                    {gym.currently_serving > 0 && <span>{gym.currently_serving} serving</span>}
                    {gym.offers_online_coaching && <span className="flex items-center gap-1"><Percent size={11} /> Online coaching</span>}
                  </div>
                </div>
                <div className="flex items-center gap-2 flex-shrink-0">
                  <Button size="sm" variant="outline">
                    <Settings size={13} className="mr-1" /> Manage
                  </Button>
                  <ChevronRight size={18} className="text-buddy-text-secondary" />
                </div>
              </Card>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
