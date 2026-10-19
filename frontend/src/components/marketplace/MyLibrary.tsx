import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { BookOpen, Salad, ChevronRight, Coins } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { marketplaceApi, type MealPlan, type TrainingProgrammeMP } from '@/api/marketplace';

/**
 * The programmes and meal plans this account owns.
 *
 * Both read a dedicated `…/mine/` endpoint. Deriving these client-side from the
 * paginated discovery lists meant anything a buyer owned that was not on page 1
 * of a popularity-ordered list just was not there.
 */

function artifactDisplay(artifacts: Record<string, number> | null | undefined): string {
  if (!artifacts || Object.keys(artifacts).length === 0) return '';
  return Object.entries(artifacts)
    .filter(([, v]) => v > 0)
    .map(([k, v]) => `${v} ${k}`)
    .join(', ');
}

function EmptyLibrary({ kind, onBrowse }: { kind: 'programmes' | 'meal plans'; onBrowse: () => void }) {
  const Icon = kind === 'programmes' ? BookOpen : Salad;
  return (
    <div className="flex flex-col items-center justify-center py-20 text-buddy-text-secondary">
      <Icon size={48} className="mb-4 opacity-30" />
      <p className="text-lg font-medium mb-1">No {kind} yet</p>
      <p className="text-sm mb-6">
        {kind === 'programmes'
          ? 'Programmes you buy will be ready to follow here.'
          : 'Meal plans you buy will show up here.'}
      </p>
      <button onClick={onBrowse} className="text-buddy-green text-sm font-medium hover:underline">
        Browse Marketplace
      </button>
    </div>
  );
}

function LibrarySkeleton() {
  return (
    <div className="space-y-3">
      {Array.from({ length: 3 }).map((_, i) => (
        <Card key={i} className="p-4 animate-pulse">
          <div className="flex gap-3">
            <div className="h-14 w-14 rounded-xl bg-buddy-surface-raised" />
            <div className="flex-1 space-y-2">
              <div className="h-4 w-1/2 rounded bg-buddy-surface-raised" />
              <div className="h-3 w-1/3 rounded bg-buddy-surface-raised" />
            </div>
          </div>
        </Card>
      ))}
    </div>
  );
}

function LibraryRow({
  title,
  subtitle,
  coverUrl,
  artifacts,
  creatorName,
  onClick,
}: {
  title: string;
  subtitle: string;
  coverUrl?: string;
  artifacts?: Record<string, number>;
  creatorName?: string;
  onClick: () => void;
}) {
  const price = artifactDisplay(artifacts);
  return (
    <Card
      className="p-3 cursor-pointer hover:border-buddy-green/40 transition-colors"
      onClick={onClick}
    >
      <div className="flex items-center gap-3">
        {coverUrl ? (
          <img src={coverUrl} alt={title} className="h-14 w-14 rounded-xl object-cover shrink-0" />
        ) : (
          <div className="h-14 w-14 rounded-xl bg-buddy-surface-raised shrink-0" />
        )}
        <div className="min-w-0 flex-1">
          <p className="font-semibold text-sm truncate">{title}</p>
          <p className="text-xs text-buddy-text-secondary truncate">{subtitle}</p>
          {creatorName && (
            <p className="text-[11px] text-buddy-text-secondary/70 truncate">by {creatorName}</p>
          )}
          {price && (
            <p className="flex items-center gap-1 text-[11px] text-buddy-text-secondary mt-0.5">
              <Coins size={10} className="text-buddy-green" />
              {price}
            </p>
          )}
        </div>
        <ChevronRight size={16} className="text-buddy-text-secondary shrink-0" />
      </div>
    </Card>
  );
}

export function MyProgrammesList() {
  const navigate = useNavigate();
  const [programmes, setProgrammes] = useState<TrainingProgrammeMP[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    marketplaceApi.getMyProgrammes()
      .then((res) => setProgrammes(res.data || []))
      .catch(() => setProgrammes([]))
      .finally(() => setIsLoading(false));
  }, []);

  if (isLoading) return <LibrarySkeleton />;
  if (programmes.length === 0) {
    return <EmptyLibrary kind="programmes" onBrowse={() => navigate('/marketplace')} />;
  }

  return (
    <div className="space-y-3">
      {programmes.map((p) => (
        <LibraryRow
          key={p.id}
          title={p.title}
          subtitle={`${p.category?.replace(/_/g, ' ') || 'Programme'} · ${p.duration_weeks} weeks`}
          coverUrl={p.cover_image_url}
          artifacts={p.price_artifacts}
          creatorName={p.creator_data?.display_name}
          onClick={() => navigate(`/marketplace/programmes/${p.id}`)}
        />
      ))}
    </div>
  );
}

export function MyMealPlansList() {
  const navigate = useNavigate();
  const [plans, setPlans] = useState<MealPlan[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    marketplaceApi.getMyMealPlans()
      .then((res) => setPlans(res.data || []))
      .catch(() => setPlans([]))
      .finally(() => setIsLoading(false));
  }, []);

  if (isLoading) return <LibrarySkeleton />;
  if (plans.length === 0) {
    return <EmptyLibrary kind="meal plans" onBrowse={() => navigate('/marketplace')} />;
  }

  return (
    <div className="space-y-3">
      {plans.map((p) => (
        <LibraryRow
          key={p.id}
          title={p.title}
          subtitle={`${p.diet_type?.replace(/_/g, ' ') || 'Meal plan'} · ${p.duration_weeks} weeks`}
          coverUrl={p.cover_image_url}
          artifacts={p.price_artifacts}
          creatorName={p.creator_data?.display_name}
          onClick={() => navigate(`/marketplace/meal-plans/${p.id}`)}
        />
      ))}
    </div>
  );
}
