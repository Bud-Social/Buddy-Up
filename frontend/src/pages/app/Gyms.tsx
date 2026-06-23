import { Plus } from 'lucide-react';
import { Button } from '@/components/ui/Button';

export default function Gyms() {
  return (
    <div className="max-w-lg mx-auto p-4">
      <div className="flex items-center justify-between mb-6">
        <h1 className="font-display text-2xl font-extrabold">Gyms</h1>
        <Button size="sm" variant="outline" className="gap-1.5">
          <Plus size={16} /> Create Gym
        </Button>
      </div>
      <div className="bg-buddy-surface rounded-2xl p-6 text-center">
        <p className="text-buddy-text-secondary">No gyms joined yet. Discover or create a gym community!</p>
      </div>
    </div>
  );
}
