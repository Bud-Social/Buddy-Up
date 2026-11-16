import { useCallback, useEffect, useState } from 'react';
import { AlertCircle, CheckCircle2, Dumbbell, X } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { gymLinksApi, type GymLinkRequest } from '@/api/marketplace';

interface GymLinkRequestsPanelProps {
  /** When set, only show requests addressed to this shop handle. */
  shop?: string;
}

/**
 * The two-step gym→shop approval panel: gym asks, shop owner/manager answers.
 * Shared by My Shops (cross-shop inbox) and the per-shop manage console.
 */
export function GymLinkRequestsPanel({ shop }: GymLinkRequestsPanelProps) {
  const [links, setLinks] = useState<GymLinkRequest[]>([]);
  const [linksLoading, setLinksLoading] = useState(true);
  const [respondingId, setRespondingId] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);

  const loadLinks = useCallback(async () => {
    setLinksLoading(true);
    try {
      const res = await gymLinksApi.list(undefined, shop);
      setLinks(Array.isArray(res.data) ? res.data : []);
    } catch {
      setLinks([]);
    } finally {
      setLinksLoading(false);
    }
  }, [shop]);

  useEffect(() => { loadLinks(); }, [loadLinks]);

  const respond = async (linkId: string, action: 'accept' | 'decline') => {
    setRespondingId(linkId);
    setActionError(null);
    try {
      await gymLinksApi.respond(linkId, action);
      await loadLinks();
    } catch (err: any) {
      setActionError(err?.response?.data?.message || 'Could not send your response.');
    } finally {
      setRespondingId(null);
    }
  };

  if (linksLoading) {
    return <div className="flex justify-center p-8 text-buddy-text-secondary">Loading requests…</div>;
  }

  if (links.length === 0) {
    return (
      <Card className="p-10 text-center">
        <Dumbbell size={36} className="mx-auto text-buddy-text-secondary/30 mb-3" />
        <p className="text-buddy-text-secondary text-sm font-medium">No gym link requests yet</p>
        <p className="text-buddy-text-secondary/70 text-xs mt-1">
          When a gym asks to link your shop for attribution, it lands here for
          you or a manager to approve.
        </p>
      </Card>
    );
  }

  return (
    <div className="space-y-3">
      {actionError && (
        <p className="text-xs text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-3 py-2 flex items-center gap-1.5" role="alert">
          <AlertCircle size={13} /> {actionError}
        </p>
      )}
      {links.map((link) => (
        <Card key={link.id} className="p-4">
          <div className="flex items-start gap-3">
            <div className="w-12 h-12 bg-buddy-green/15 rounded-xl flex items-center justify-center text-buddy-green overflow-hidden">
              {link.gym_avatar
                ? <img src={link.gym_avatar} alt="" className="w-full h-full object-contain" />
                : <Dumbbell size={20} />}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-semibold truncate">{link.gym_name}</p>
              <p className="text-[11px] text-buddy-text-secondary truncate">@{link.gym_handle}{link.requested_by ? ` · requested by @${link.requested_by}` : ''}</p>
              <p className="text-[10px] text-buddy-text-secondary/70 mt-1">
                {link.status === 'pending' ? 'Pending your approval — attribution blocked until you act.'
                  : link.status === 'active' ? 'Linked — your shop’s sales feed the gym’s revenue tab.'
                  : 'You declined this request.'}
              </p>
            </div>
            {link.status === 'pending' ? (
              <div className="flex flex-col gap-1 shrink-0">
                <Button size="sm" onClick={() => respond(link.id, 'accept')} isLoading={respondingId === link.id}>
                  <CheckCircle2 size={13} className="mr-1" /> Approve
                </Button>
                <Button size="sm" variant="outline" onClick={() => respond(link.id, 'decline')} isLoading={respondingId === link.id} className="text-buddy-red">
                  <X size={13} className="mr-1" /> Decline
                </Button>
              </div>
            ) : link.status === 'active' ? (
              <span className="text-[10px] uppercase text-buddy-green bg-buddy-green/10 border border-buddy-green/20 rounded-full px-2 py-0.5 shrink-0 self-start font-bold flex items-center gap-1">
                <CheckCircle2 size={10} /> Linked
              </span>
            ) : (
              <span className="text-[10px] uppercase text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-full px-2 py-0.5 shrink-0 self-start font-bold flex items-center gap-1">
                <X size={10} /> Declined
              </span>
            )}
          </div>
        </Card>
      ))}
    </div>
  );
}

export default GymLinkRequestsPanel;
