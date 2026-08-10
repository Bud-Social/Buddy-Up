import { useEffect, useState } from 'react';
import { Utensils, Flame, Beef, Wheat, Droplet } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { StatCard } from '@/components/analytics/StatCard';
import { CHART_TOOLTIP, AXIS_TICK, GRID_STROKE, COLORS } from '@/components/analytics/chartConfig';
import { formatNumber, titleCase, formatDateTime } from '@/components/analytics/format';
import { analyticsApi } from '@/api/analytics';
import type { AnalyticsPeriod, AnalyticsSummaryData, MealLogInput } from '@/types/analytics';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts';

interface Props { period: AnalyticsPeriod; }

const MEAL_TYPES: { key: MealLogInput['meal_type']; label: string }[] = [
  { key: 'breakfast', label: 'Breakfast' },
  { key: 'lunch', label: 'Lunch' },
  { key: 'dinner', label: 'Dinner' },
  { key: 'snack', label: 'Snack' },
  { key: 'drink', label: 'Drink' },
  { key: 'other', label: 'Other' },
];

interface MealRow {
  id: string;
  meal_type: string;
  food_name: string;
  description: string;
  calories?: number | null;
  protein_g?: number | null;
  carbs_g?: number | null;
  fat_g?: number | null;
  photo_url?: string;
  logged_at: string;
}

const EMPTY: MealLogInput = {
  meal_type: 'breakfast',
  food_name: '',
  description: '',
  calories: null,
  protein_g: null,
  carbs_g: null,
  fat_g: null,
  logged_at: undefined,
};

export function MealsTab({ period }: Props) {
  const [summary, setSummary] = useState<AnalyticsSummaryData | null>(null);
  const [history, setHistory] = useState<MealRow[]>([]);
  const [form, setForm] = useState<MealLogInput>(EMPTY);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    analyticsApi.getSummary(period)
      .then((res) => setSummary(res.data))
      .catch(() => {});
  }, [period]);

  useEffect(() => {
    analyticsApi.getMeals()
      .then((res) => setHistory((res.data as MealRow[]) || []))
      .catch(() => {});
  }, []);

  const submit = async () => {
    setSaving(true);
    setError(null);
    try {
      await analyticsApi.createMeal(form);
      setForm(EMPTY);
      analyticsApi.getSummary(period).then((res) => setSummary(res.data)).catch(() => {});
      analyticsApi.getMeals().then((res) => setHistory((res.data as MealRow[]) || [])).catch(() => {});
    } catch {
      setError('Failed to save meal.');
    } finally {
      setSaving(false);
    }
  };

  const n = summary?.nutrition;
  const macroData = [
    { name: 'Protein', value: Math.round(n?.total_protein_g ?? 0), color: COLORS[0], icon: Beef },
    { name: 'Carbs', value: Math.round(n?.total_carbs_g ?? 0), color: COLORS[1], icon: Wheat },
    { name: 'Fat', value: Math.round(n?.total_fat_g ?? 0), color: COLORS[2], icon: Droplet },
  ];
  const typeData = (n?.by_type || []).map((t) => ({ name: t.label, calories: t.calories ?? 0 }));

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <StatCard label="Meals Logged" value={formatNumber(n?.count ?? 0)} icon={<Utensils size={18} />} />
        <StatCard label="Calories" value={formatNumber(n?.total_calories ?? 0)} icon={<Flame size={18} />} />
        {n?.avg_daily_calories ? (
          <StatCard label="Avg Daily" value={formatNumber(n.avg_daily_calories)} sub="kcal / day" icon={<Flame size={18} />} />
        ) : (
          <StatCard label="Protein" value={`${formatNumber(n?.total_protein_g ?? 0)} g`} icon={<Beef size={18} />} />
        )}
        <StatCard label="Carbs" value={`${formatNumber(n?.total_carbs_g ?? 0)} g`} icon={<Wheat size={18} />} />
      </div>

      {/* Macro bar */}
      <Card className="p-4">
        <h3 className="font-heading font-semibold mb-3">Macros</h3>
        <div className="flex flex-wrap gap-3">
          {macroData.map((m) => (
            <div key={m.name} className="flex-1 min-w-[140px] bg-buddy-surface-raised rounded-xl p-3">
              <div className="flex items-center gap-2">
                <m.icon size={14} style={{ color: m.color }} />
                <span className="text-xs text-buddy-text-secondary">{m.name}</span>
              </div>
              <p className="text-xl font-display font-bold mt-1">{m.value} g</p>
            </div>
          ))}
        </div>
      </Card>

      {typeData.length > 0 && (
        <Card className="p-4">
          <h3 className="font-heading font-semibold mb-3">Calories by Meal</h3>
          <div className="h-56">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={typeData} margin={{ top: 4, right: 8, left: -16, bottom: 0 }}>
                <CartesianGrid stroke={GRID_STROKE} strokeDasharray="3 3" vertical={false} />
                <XAxis dataKey="name" tick={AXIS_TICK} axisLine={false} tickLine={false} />
                <YAxis tick={AXIS_TICK} axisLine={false} tickLine={false} />
                <Tooltip {...CHART_TOOLTIP} cursor={{ fill: 'rgba(255,255,255,0.04)' }} />
                <Bar dataKey="calories" name="kcal" fill={COLORS[1]} radius={[6, 6, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </Card>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* Log meal */}
        <Card className="p-4">
          <h3 className="font-heading font-semibold mb-3">Log a Meal</h3>
          <div className="space-y-3">
            <div>
              <p className="text-sm font-medium text-buddy-text-secondary mb-1.5">Meal Type</p>
              <div className="flex flex-wrap gap-1.5">
                {MEAL_TYPES.map((t) => (
                  <button
                    key={t.key}
                    onClick={() => setForm((f) => ({ ...f, meal_type: t.key }))}
                    className={`px-3 py-1.5 rounded-full text-sm transition-colors ${
                      form.meal_type === t.key
                        ? 'bg-buddy-green text-buddy-black font-medium'
                        : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'
                    }`}
                  >
                    {t.label}
                  </button>
                ))}
              </div>
            </div>
            <Input label="Food" placeholder="e.g. Oatmeal with banana" value={form.food_name ?? ''} onChange={(e) => setForm((f) => ({ ...f, food_name: e.target.value }))} />
            <Input label="Description" placeholder="Optional note" value={form.description ?? ''} onChange={(e) => setForm((f) => ({ ...f, description: e.target.value }))} />
            <div className="grid grid-cols-2 gap-2">
              <Input label="Calories" type="number" min={0} placeholder="0" value={form.calories ?? ''} onChange={(e) => setForm((f) => ({ ...f, calories: e.target.value === '' ? null : Number(e.target.value) }))} />
              <Input label="Protein (g)" type="number" min={0} placeholder="0" value={form.protein_g ?? ''} onChange={(e) => setForm((f) => ({ ...f, protein_g: e.target.value === '' ? null : Number(e.target.value) }))} />
            </div>
            <div className="grid grid-cols-2 gap-2">
              <Input label="Carbs (g)" type="number" min={0} placeholder="0" value={form.carbs_g ?? ''} onChange={(e) => setForm((f) => ({ ...f, carbs_g: e.target.value === '' ? null : Number(e.target.value) }))} />
              <Input label="Fat (g)" type="number" min={0} placeholder="0" value={form.fat_g ?? ''} onChange={(e) => setForm((f) => ({ ...f, fat_g: e.target.value === '' ? null : Number(e.target.value) }))} />
            </div>
            {error && <p className="text-sm text-buddy-red">{error}</p>}
            <Button onClick={submit} isLoading={saving} className="w-full">
              Save Meal
            </Button>
          </div>
        </Card>

        {/* Recent meals */}
        <div>
          <h3 className="font-heading font-semibold mb-3">Recent Meals</h3>
          {history.length === 0 ? (
            <Card className="p-6 text-center text-buddy-text-secondary text-sm">
              No meals logged yet.
            </Card>
          ) : (
            <div className="space-y-2.5 max-h-[420px] overflow-y-auto pr-1">
              {history.map((r) => (
                <Card key={r.id} className="p-3 flex items-center gap-3">
                  {r.photo_url && <img src={r.photo_url} alt="" className="w-14 h-14 rounded-lg object-cover flex-shrink-0" />}
                  <div className="min-w-0 flex-1">
                    <p className="text-sm font-medium truncate">{r.food_name || titleCase(r.meal_type)}</p>
                    <p className="text-xs text-buddy-text-secondary">
                      {titleCase(r.meal_type)} · {formatDateTime(r.logged_at)}
                    </p>
                  </div>
                  <div className="text-right flex-shrink-0">
                    <p className="text-sm font-bold text-buddy-green">{Math.round(r.calories ?? 0)} kcal</p>
                    <p className="text-[11px] text-buddy-text-secondary">P {Math.round(r.protein_g ?? 0)} · C {Math.round(r.carbs_g ?? 0)} · F {Math.round(r.fat_g ?? 0)}</p>
                  </div>
                </Card>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
