import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Store, Globe, Mail, Phone, MapPin, ChevronLeft, ChevronRight, Star, Users, ShoppingCart, Dumbbell, Utensils, Video, Calendar, ShieldCheck, ExternalLink } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { marketplaceApi } from '@/api/marketplace';
import type { UserShopResponse, MarketplaceEvent, MealPlan, TrainingProgrammeMP, ProductMP } from '@/api/marketplace';

type Tab = 'meal_plans' | 'programmes' | 'events' | 'products';

export default function ShopDetail() {
  const { handle } = useParams();
  const navigate = useNavigate();
  const [data, setData] = useState<UserShopResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<Tab>('meal_plans');

  useEffect(() => {
    if (!handle) return;
    marketplaceApi.getUserShop(handle)
      .then(res => setData(res.data))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, [handle]);

  if (isLoading) return (
    <div className="max-w-xl mx-auto p-4 animate-pulse">
      <div className="h-48 bg-buddy-surface rounded-2xl mb-4" />
      <div className="flex items-center gap-4 px-4 -mt-12 mb-6">
        <div className="w-24 h-24 rounded-full bg-buddy-surface border-4 border-buddy-background" />
        <div className="flex-1 space-y-2"><div className="h-6 w-2/3 bg-buddy-surface rounded" /><div className="h-4 w-1/2 bg-buddy-surface rounded" /></div>
      </div>
    </div>
  );

  if (!data) return (
    <div className="max-w-xl mx-auto p-4 text-center">
      <p className="text-buddy-text-secondary mb-4">Shop not found.</p>
      <Button onClick={() => navigate('/marketplace')}>Back to Marketplace</Button>
    </div>
  );

  const { shop, meal_plans, programmes, events, products } = data;
  const hasItems = meal_plans.length > 0 || programmes.length > 0 || events.length > 0 || products.length > 0;
  const tabs: { key: Tab; label: string; count: number; icon: React.ReactNode }[] = [
    { key: 'meal_plans', label: 'Meal Plans', count: meal_plans.length, icon: <Utensils size={16} /> },
    { key: 'programmes', label: 'Programmes', count: programmes.length, icon: <Dumbbell size={16} /> },
    { key: 'events', label: 'Events', count: events.length, icon: <Calendar size={16} /> },
    { key: 'products', label: 'Products', count: products.length, icon: <ShoppingCart size={16} /> },
  ];

  const renderStars = (rating: number) => (
    <div className="flex items-center gap-0.5">
      {[1, 2, 3, 4, 5].map(i => (
        <Star key={i} size={12} className={i <= Math.round(rating) ? 'text-buddy-gold fill-buddy-gold' : 'text-buddy-surface-raised'} />
      ))}
    </div>
  );

  const renderItem = (item: MealPlan | TrainingProgrammeMP | MarketplaceEvent | ProductMP, type: string) => {
    const isMealPlan = 'diet_type' in item;
    const isProgramme = 'category' in item && !('event_type' in item);
    const isEvent = 'event_type' in item;
    const isProduct = 'brand' in item;

    const title = isProduct ? (item as ProductMP).name : (item as any).title || 'Untitled';
    const imageUrl = (item as any).cover_image_url || (item as ProductMP).image_url || '';
    const id = item.id;
    const link = isEvent ? `/marketplace/events/${id}`
      : isMealPlan ? `/marketplace/meal-plans/${id}`
      : isProgramme ? `/marketplace/programmes/${id}`
      : `/marketplace/products/${id}`;

    return (
      <Card key={id} className="p-0 overflow-hidden cursor-pointer hover:shadow-lg transition-shadow" onClick={() => navigate(link)}>
        {imageUrl && <div className="w-full h-32 bg-buddy-surface"><img src={imageUrl} alt={title} className="w-full h-full object-cover" /></div>}
        <div className="p-3 space-y-1.5">
          <p className="font-bold text-sm truncate">{title}</p>
          <div className="flex items-center justify-between">
            {isMealPlan && <p className="text-[11px] text-buddy-text-secondary">{(item as MealPlan).diet_type}</p>}
            {isProgramme && <p className="text-[11px] text-buddy-text-secondary">{(item as TrainingProgrammeMP).category}</p>}
            {isEvent && <Badge variant="blue" label={(item as MarketplaceEvent).event_type.replace('_', ' ')} size="sm" className="capitalize" />}
            {isProduct && <p className="text-[11px] text-buddy-text-secondary">{(item as ProductMP).brand}</p>}
          </div>
          <div className="flex items-center justify-between">
            {isMealPlan && <div className="flex items-center gap-1">{renderStars((item as MealPlan).average_rating)}<span className="text-[10px] text-buddy-text-secondary">({(item as MealPlan).review_count})</span></div>}
            <p className="text-xs font-bold text-buddy-green">{(item as any).purchase_count || (item as any).click_count || 0} sold</p>
          </div>
        </div>
      </Card>
    );
  };

  return (
    <div className="max-w-xl mx-auto pb-24">
      {/* Banner */}
      <div className="relative h-48 w-full bg-gradient-to-br from-buddy-electric/30 to-buddy-surface">
        {shop.banner_url && <img src={shop.banner_url} alt="" className="w-full h-full object-cover" />}
        <div className="absolute inset-0 bg-gradient-to-t from-buddy-black/70 via-transparent to-transparent" />
        <button onClick={() => navigate(-1)} className="absolute top-4 left-4 p-2 bg-black/50 backdrop-blur-md text-white rounded-full z-10 hover:bg-black/70 transition-colors">
          <ArrowLeft size={20} />
        </button>
      </div>

      {/* Shop Info */}
      <div className="px-4 -mt-16 relative z-10">
        <div className="flex items-end gap-4 mb-4">
          <div className="w-24 h-24 rounded-full border-4 border-buddy-background bg-buddy-surface overflow-hidden shrink-0 shadow-xl">
            {shop.logo_url && <img src={shop.logo_url} alt={shop.name} className="w-full h-full object-cover" />}
          </div>
          <div className="flex-1 min-w-0 pb-1">
            <div className="flex items-center gap-2">
              <h1 className="font-display text-2xl font-extrabold truncate">{shop.name}</h1>
              {shop.verification_status === 'verified' && <ShieldCheck size={20} className="text-buddy-electric shrink-0" />}
            </div>
            <p className="text-sm text-buddy-text-secondary">@{shop.handle}</p>
          </div>
        </div>

        {shop.description && (
          <p className="text-sm text-buddy-text-secondary mb-4 leading-relaxed">{shop.description}</p>
        )}

        {/* Contact & Social */}
        <div className="flex flex-wrap gap-2 mb-4">
          {shop.contact_email && (
            <a href={`mailto:${shop.contact_email}`} className="flex items-center gap-1.5 text-xs bg-buddy-surface px-3 py-1.5 rounded-full text-buddy-text-secondary hover:text-buddy-electric transition-colors">
              <Mail size={12} /><span>Email</span>
            </a>
          )}
          {shop.contact_phone && (
            <a href={`tel:${shop.contact_phone}`} className="flex items-center gap-1.5 text-xs bg-buddy-surface px-3 py-1.5 rounded-full text-buddy-text-secondary hover:text-buddy-electric transition-colors">
              <Phone size={12} /><span>Call</span>
            </a>
          )}
          {shop.website_url && (
            <a href={shop.website_url} target="_blank" rel="noopener noreferrer" className="flex items-center gap-1.5 text-xs bg-buddy-surface px-3 py-1.5 rounded-full text-buddy-text-secondary hover:text-buddy-electric transition-colors">
              <Globe size={12} /><span>Website</span><ExternalLink size={10} />
            </a>
          )}
          {Object.entries(shop.social_links || {}).filter(([, v]) => v).map(([platform, url]) => (
            <a key={platform} href={url} target="_blank" rel="noopener noreferrer" className="flex items-center gap-1.5 text-xs bg-buddy-surface px-3 py-1.5 rounded-full text-buddy-text-secondary hover:text-buddy-electric transition-colors capitalize">
              <Store size={12} /><span>{platform}</span>
            </a>
          ))}
        </div>
      </div>

      {/* Items */}
      {!hasItems ? (
        <div className="px-4 text-center py-12">
          <Store size={48} className="mx-auto text-buddy-surface-raised mb-3" />
          <p className="text-buddy-text-secondary font-medium">This shop has no items yet.</p>
        </div>
      ) : (
        <div className="px-4">
          <div className="flex gap-1 bg-buddy-surface rounded-xl p-1 mb-4 overflow-x-auto">
            {tabs.filter(t => t.count > 0).map(tab => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-bold transition-all whitespace-nowrap ${
                  activeTab === tab.key
                    ? 'bg-buddy-electric text-buddy-black shadow-lg'
                    : 'text-buddy-text-secondary hover:text-buddy-text-primary'
                }`}
              >
                {tab.icon}
                <span>{tab.label}</span>
                <span className="text-[10px] opacity-70">({tab.count})</span>
              </button>
            ))}
          </div>

          <div className="grid grid-cols-2 gap-3">
            {activeTab === 'meal_plans' && meal_plans.map(mp => renderItem(mp, 'meal_plan'))}
            {activeTab === 'programmes' && programmes.map(p => renderItem(p, 'programme'))}
            {activeTab === 'events' && events.map(e => renderItem(e, 'event'))}
            {activeTab === 'products' && products.map(p => renderItem(p, 'product'))}
          </div>
        </div>
      )}
    </div>
  );
}
