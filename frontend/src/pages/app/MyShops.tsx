import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { marketplaceApi, Shop } from '@/api/marketplace';

export default function MyShops() {
  const navigate = useNavigate();
  const [shops, setShops] = useState<Shop[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    marketplaceApi.getMyShops().then(res => {
      setShops(res.data || []);
    }).catch(err => {
      console.error(err);
    }).finally(() => {
      setIsLoading(false);
    });
  }, []);

  return (
    <div className="max-w-md lg:max-w-2xl xl:max-w-3xl mx-auto p-4 pb-24 space-y-6">
      <div className="flex items-center gap-3">
        <button onClick={() => navigate(-1)} className="p-2 rounded-full hover:bg-buddy-surface">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <h1 className="font-display text-2xl font-extrabold flex-1">My Shops</h1>
        <Button size="sm" onClick={() => navigate('/marketplace/shops/create')}>Create New</Button>
      </div>

      {isLoading ? (
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
              <Button size="sm" variant="outline" onClick={() => navigate(`/marketplace/shops/${shop.handle}`)}>View</Button>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
