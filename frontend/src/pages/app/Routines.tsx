import { useState } from 'react';
import { Calendar, MapPin, Activity, Dumbbell, Heart, X, Plus } from 'lucide-react';

const ROUTINE_TYPES = [
  { key: 'walk', label: 'Walking', icon: MapPin, color: 'text-buddy-green', bg: 'bg-buddy-green/10' },
  { key: 'run', label: 'Running', icon: MapPin, color: 'text-buddy-red', bg: 'bg-buddy-red/10' },
  { key: 'cycle', label: 'Cycling', icon: Activity, color: 'text-buddy-electric', bg: 'bg-buddy-electric/10' },
  { key: 'hike', label: 'Hiking', icon: MapPin, color: 'text-buddy-orange', bg: 'bg-buddy-orange/10' },
  { key: 'workout', label: 'Workout', icon: Dumbbell, color: 'text-buddy-gold', bg: 'bg-buddy-gold/10' },
];

const ROUTINE_DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const ROUTINE_ICONS: Record<string, typeof MapPin> = {
  walk: MapPin,
  run: MapPin,
  cycle: Activity,
  hike: MapPin,
  workout: Dumbbell,
};

function RoutineIcon({ type, size = 20 }: { type: string; size?: number }) {
  const Icon = ROUTINE_ICONS[type] || MapPin;
  return <Icon size={size} />;
}

export default function Routines() {
  const [routines, setRoutines] = useState<Array<{
    id: string;
    type: string;
    name: string;
    target: number;
    unit: string;
    days: number[];
    streak: number;
    completedToday: boolean;
  }>>([
    { id: '1', type: 'walk', name: 'Morning Walk', target: 5000, unit: 'steps', days: [0,1,2,3,4,5,6], streak: 5, completedToday: false },
    { id: '2', type: 'workout', name: 'Gym Session', target: 45, unit: 'min', days: [1,3,5], streak: 3, completedToday: true },
  ]);

  const toggleDay = (routineId: string, dayIndex: number) => {
    setRoutines(routines.map(r => {
      if (r.id !== routineId) return r;
      const days = r.days.includes(dayIndex)
        ? r.days.filter(d => d !== dayIndex)
        : [...r.days, dayIndex].sort((a, b) => a - b);
      return { ...r, days };
    }));
  };

  const addRoutine = () => {
    const id = String(Date.now());
    setRoutines([...routines, {
      id, type: 'walk', name: 'New Routine', target: 30, unit: 'min',
      days: [], streak: 0, completedToday: false,
    }]);
  };

  const deleteRoutine = (id: string) => {
    if (!window.confirm('Delete this routine?')) return;
    setRoutines(routines.filter(r => r.id !== id));
  };

  const isDayActive = (routine: { days: number[] }, dayIndex: number) =>
    routine.days.includes(dayIndex);

  const today = new Date().getDay();

  return (
    <div className="p-4 max-w-5xl mx-auto space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-bold">Routines</h1>
          <p className="text-sm text-buddy-text-secondary mt-0.5">
            Build recurring habits — walking, running, workouts and more. Set targets and track your streak.
          </p>
        </div>
        <button
          onClick={addRoutine}
          className="flex items-center gap-2 px-3 py-2 bg-buddy-green hover:bg-buddy-green/90 text-white rounded-lg text-sm font-medium transition-colors"
        >
          <Plus size={16} /> New Routine
        </button>
      </div>

      <div className="bg-buddy-surface rounded-xl border border-buddy-border p-5 space-y-4">
        <h3 className="font-semibold text-buddy-text-primary">Your Routines</h3>
        {routines.length === 0 ? (
          <div className="text-center py-12 text-buddy-text-secondary">
            <Calendar size={48} className="mx-auto mb-3 opacity-50" />
            <p>No routines yet. Create one to start building habits.</p>
          </div>
        ) : (
          <div className="space-y-3">
            {routines.map((routine) => {
              const typeInfo = ROUTINE_TYPES.find(t => t.key === routine.type) || ROUTINE_TYPES[0];
              return (
                <div
                  key={routine.id}
                  className={`p-4 rounded-xl border ${routine.completedToday ? 'bg-buddy-green/10 border-buddy-green/30' : 'border-buddy-border bg-buddy-bg'} transition-colors`}
                >
                  <div className="flex items-start justify-between gap-4">
                    <div className="flex items-center gap-3 shrink-0">
                      <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${typeInfo.bg} ${typeInfo.color}`}>
                        <RoutineIcon type={routine.type} size={20} />
                      </div>
                      <div>
                        <h4 className={`font-medium text-buddy-text-primary ${routine.completedToday ? 'line-through text-buddy-text-secondary' : ''}`}>
                          {routine.name}
                        </h4>
                        <p className="text-xs text-buddy-text-secondary">
                          {routine.target} {routine.unit} • Streak: {routine.streak} day{routine.streak !== 1 ? 's' : ''}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-end gap-2">
                      <span className={`text-2xl font-display font-bold ${routine.completedToday ? 'text-buddy-green' : typeInfo.color}`}>
                        {routine.completedToday ? '✓' : routine.streak}
                      </span>
                      <button
                        onClick={() => deleteRoutine(routine.id)}
                        className="p-1.5 rounded-lg text-buddy-text-secondary hover:text-buddy-red hover:bg-buddy-red/5 transition-colors"
                        title="Delete routine"
                      >
                        <X size={14} />
                      </button>
                    </div>
                  </div>

                  <div className="mt-4 flex gap-1">
                    {ROUTINE_DAYS.map((day, i) => (
                      <button
                        key={day}
                        onClick={() => toggleDay(routine.id, i)}
                        className={`w-6 h-6 rounded-md text-xs font-medium transition-colors flex items-center justify-center ${
                          isDayActive(routine, i)
                            ? (i === today ? 'bg-buddy-green text-white' : 'bg-buddy-surface text-buddy-text-secondary border border-buddy-border')
                            : 'bg-buddy-surface/50 text-buddy-text-secondary/50 border border-buddy-border/50 hover:bg-buddy-surface/50'
                        } ${i === today ? 'ring-2 ring-buddy-green' : ''}`}
                      >
                        {day}
                      </button>
                    ))}
                  </div>

                  {routine.completedToday && (
                    <div className="mt-3 flex items-center gap-2 text-xs text-buddy-green">
                      <Heart size={14} className="fill-buddy-green" />
                      <span>Completed today</span>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>

      <div className="bg-buddy-surface rounded-xl border border-buddy-border p-5">
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-semibold text-buddy-text-primary">Routine Types</h3>
          <span className="text-xs text-buddy-text-secondary">Pick a type to start tracking</span>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-3 lg:grid-cols-5 gap-3">
          {ROUTINE_TYPES.map((t) => (
            <button
              key={t.key}
              onClick={() => {
                const id = String(Date.now());
                setRoutines([...routines, {
                  id, type: t.key, name: t.label, target: t.key === 'walk' ? 5000 : t.key === 'run' ? 5 : t.key === 'cycle' ? 10 : t.key === 'hike' ? 5 : 30,
                  unit: t.key === 'walk' ? 'steps' : t.key === 'run' || t.key === 'cycle' || t.key === 'hike' ? 'km' : 'min',
                  days: [], streak: 0, completedToday: false,
                }]);
              }}
              className={`flex flex-col items-center gap-2 p-4 rounded-xl border border-buddy-border transition-all duration-200 hover:border-buddy-green hover:shadow-lg ${t.bg} ${t.color}`}
            >
              <div className={`w-10 h-10 rounded-2xl flex items-center justify-center ${t.bg.replace('/10', '/20')} ${t.color}`}>
                <RoutineIcon type={t.key} size={24} />
              </div>
              <div className="font-medium text-sm text-buddy-text-primary">{t.label}</div>
              <div className="text-xs text-buddy-text-secondary text-center">{t.key === 'walk' ? '5,000 steps' : t.key === 'run' ? '5 km' : t.key === 'cycle' ? '10 km' : t.key === 'hike' ? '5 km' : '30 min'}</div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
