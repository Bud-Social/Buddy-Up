import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { AlertCircle, CheckCircle2, Dumbbell, X } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { marketplaceApi, Shop, gymLinksApi, GymLinkRequest } from '@/api/marketplace';

/**
 * Seller hub — your shops + the gym link approval queue.
 *
 * A gym requesting to link your shop lands here as a pending GymLinkRequest.
 * Shop owner AND managers approve (via the /respond/ endpoint). Accepting
 * flips the link to `active`, which unlocks the combined "gym × shop" view
 * downstream (revenue, analytics, Gym members-only offer plane).
 */
export default function MyShops() {
  const navigate = useNavigate();
  const [tab, setTabState] = useState<'shops' | 'gym-links'>(() => {
    try {
      const q = new URLSearchParams(window.location.search).get('tab');
      return q === 'gym-links' ? 'gym-links' : 'shops';
    } catch { return 'shops'; }
  });
  const setTab = (next: 'shops' | 'gym-links') => {
    setTabState(next);
    const url = new URL(window.location.href);
    if (next === 'gym-links') url.searchParams.set('tab', 'gym-links');
    else url.searchParams.delete('tab');
    window.history.replaceState({}, '', url.toString());
  };
  const [shops, setShops] = useState<Shop[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [links, setLinks] = useState<GymLinkRequest[]>([]);
  const [linksLoading, setLinksLoading] = useState(false);
  const [respondingId, setRespondingId] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);

  useEffect(() => {
    marketplaceApi.getMyShops().then((res) => setShops(res.data || [])).finally(() => setIsLoading(false));
  }, []);

  const loadLinks = useCallback(async () => {
    setLinksLoading(true);
    try {
      const res = await gymLinksApi.list();
      setLinks(Array.isArray(res.data) ? res.data : []);
    } catch {
      setLinks([]);
    } finally {
      setLinksLoading(false);
    }
  }, []);

  useEffect(() => {
    if (tab === 'gym-links') loadLinks();
  }, [tab, loadLinks]);

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

  const pendingCount = links.filter((l) => l.status === 'pending').length;

  return (
    <div className="max-w-md lg:max-w-2xl xl:max-w-3xl mx-auto p-4 pb-24 space-y-6">
      <div className="flex items-center gap-3">
        <button onClick={() => navigate(-1)} className="p-2 rounded-full hover:bg-buddy-surface">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <h1 className="font-display text-2xl font-extrabold flex-1">My Shops</h1>
        <Button size="sm" onClick={() => navigate('/marketplace/shops/create')}>Create New</Button>
      </div>

      <div className="flex rounded-xl bg-buddy-surface p-1">
        {[
          { key: 'shops' as const, label: 'My shops' },
          { key: 'gym-links' as const, label: `Gym requests${pendingCount ? ` (${pendingCount})` : ''}` },
        ].map(({ key, label }) => (
          <button key={key} onClick={() => setTab(key)} className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors ${tab === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary'}`}>
            {label}
          </button>
        ))}
      </div>

      {tab === 'shops' && (
        isLoading ? (
          <div className="flex justify-center p-8 text-buddy-text-secondary">Loading...</div>
        ) : shops.length === 0 ? (
          <div className="text-center py-12 space-y-4">
            <p className="text-buddy-text-secondary">You don't have any shops yet.</p>
            <Button onClick={() => navigate('/marketplace/shops/create')}>Start Your First Shop</Button>
          </div>
        ) : (
          <div className="space-y-3">
            {shops.map(shop => (
              <Card key={shop.id} className="p-4 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-buddy-surface-raised rounded-full overflow-hidden">
                    {shop.logo_url && <img src={shop.logo_url} alt="logo" className="w-full h-full object-cover" />}
                  </div>
                  <div>
                    <p className="font-bold flex items-center gap-1">
                      {shop.name}
                      {shop.is_certified && (
                        <svg className="text-buddy-electric w-3 h-3" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                      )}
                    </p>
                    <p className="text-xs text-buddy-text-secondary">@{shop.handle}</p>
                  </div>
                </div>
                <Button size="sm" variant="outline" onClick={() => navigate(`/shops/${shop.handle}`)}>View</Button>
              </Card>
            ))}
          </div>
        )
      )}

      {tab === 'gym-links' && (
        linksLoading ? (
          <div className="flex justify-center p-8 text-buddy-text-secondary">Loading requests…</div>
        ) : links.length === 0 ? (
          <Card className="p-10 text-center">
            <Dumbbell size={36} className="mx-auto text-buddy-text-secondary/30 mb-3" />
            <p className="text-buddy-text-secondary text-sm font-medium">No gym link requests yet</p>
            <p className="text-buddy-text-secondary/70 text-xs mt-1">
              When a gym asks to link your shop for attribution, it lands here for
              you or a manager to approve.
            </p>
          </Card>
        ) : (
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
        )
      )}
    </div>
  );
}
