import { Radio } from 'lucide-react';
import { Button } from '@/components/ui/Button';

export default function Lives() {
  return (
    <div className="max-w-lg mx-auto p-4">
      <div className="flex items-center justify-between mb-6">
        <h1 className="font-display text-2xl font-extrabold">Buddy Lives</h1>
        <Button size="sm" className="gap-1.5">
          <Radio size={16} /> Go Live
        </Button>
      </div>

      <div className="bg-buddy-surface rounded-2xl p-6 text-center">
        <p className="text-buddy-text-secondary text-lg">No live sessions right now</p>
        <p className="text-buddy-text-secondary/50 text-sm mt-1">
          Be the first to start a Buddy Live!
        </p>
      </div>
    </div>
  );
}
