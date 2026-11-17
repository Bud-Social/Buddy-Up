import { useCallback, useEffect, useState } from 'react';
import { Check, Dumbbell, Loader2, X } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Avatar } from '@/components/ui/Avatar';
import { communityLinkApi, type GymLinkRequest } from '@/api/gyms';

interface GymLinkRequestsPanelProps {
  communityId: string;
}

/**
 * Community-side review of gym→community link requests.
 *
 * Shown to the community's owner/admin in the community detail view. The
 * gym asks to link its business page to this community; the community
 * decides. Gym logos, handle, category and member count are shown so the
 * reviewer can make a call without leaving this screen.
 */
export function GymLinkRequestsPanel({ communityId }: GymLinkRequestsPanelProps) {
  const [requests, setRequests] = useState<GymLinkRequest[] | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [busyId, setBusyId] = useState<number | null>(null);

  const load = useCallback(() => {
    setLoading(true);
    setError(null);
    communityLinkApi.list(communityId)
      .then((res) => setRequests(res.data?.requests ?? []))
      .catch((e: any) => setError(e?.response?.data?.message || 'Could not load gym requests.'))
      .finally(() => setLoading(false));
  }, [communityId]);

  useEffect(() => { load(); }, [load]);

  const decide = async (request: GymLinkRequest, decision: 'approved' | 'declined') => {
    setBusyId(request.id);
    setError(null);
    try {
      await communityLinkApi.decide(request.id, decision);
      setRequests((prev) => prev?.filter((r) => r.id !== request.id) ?? prev);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not record that decision.');
    } finally {
      setBusyId(null);
    }
  };

  if (loading) {
    return (
      <div className="grid gap-2 animate-pulse">
        {Array.from({ length: 2 }).map((_, i) => <div key={i} className="h-20 bg-buddy-surface rounded-2xl" />)}
      </div>
    );
  }

  return (
    <section className="space-y-3">
      <p className="text-[10px] uppercase text-buddy-text-secondary flex items-center gap-1.5"><Dumbbell size={12} /> Gym requests to link with this community</p>
      {error && <p className="text-[11px] text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-2 py-1.5" role="alert">{error}</p>}
      {requests && requests.length === 0 ? (
        <Card className="p-6 text-center">
          <Dumbbell size={22} className="mx-auto text-buddy-text-secondary/40 mb-2" />
          <p className="text-xs font-semibold">No pending requests</p>
          <p className="text-[10px] text-buddy-text-secondary mt-1">When a gym asks to link with this community, the request appears here for you to approve or decline.</p>
        </Card>
      ) : (
        requests?.map((request) => (
          <Card key={request.id} className="p-3">
            <div className="flex items-start gap-3">
              <Avatar src={request.gym_logo_url} alt={request.gym_name} size="md" />
              <div className="min-w-0 flex-1">
                <p className="text-sm font-bold">{request.gym_name}</p>
                <p className="text-[10px] text-buddy-text-secondary">@{request.gym_handle}{request.gym_category ? ` · ${request.gym_category}` : ''}{request.gym_member_count ? ` · ${request.gym_member_count} members` : ''}</p>
                <p className="text-[9px] text-buddy-text-secondary/80 mt-1">Asked by {request.requested_by || 'the gym owner'} · {new Date(request.created_at).toLocaleDateString()}</p>
                <div className="flex items-center gap-2 mt-2">
                  <button
                    onClick={() => decide(request, 'approved')}
                    disabled={busyId === request.id}
                    className="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-[11px] font-bold bg-buddy-green text-buddy-black disabled:opacity-60"
                  >
                    {busyId === request.id ? <Loader2 size={11} className="animate-spin" /> : <Check size={12} />} Approve
                  </button>
                  <button
                    onClick={() => decide(request, 'declined')}
                    disabled={busyId === request.id}
                    className="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-[11px] font-bold text-buddy-red/90 border border-buddy-red/30 hover:bg-buddy-red/10 disabled:opacity-60"
                  >
                    <X size={12} /> Decline
                  </button>
                </div>
              </div>
            </div>
          </Card>
        ))
      )}
    </section>
  );
}
