import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { Button } from '@/components/ui/Button';

export default function Wallet() {
  return (
    <div className="max-w-lg mx-auto p-4">
      <h1 className="font-display text-2xl font-extrabold mb-6">Wallet</h1>

      <div className="bg-buddy-surface rounded-2xl p-6 mb-6">
        <p className="text-sm text-buddy-text-secondary mb-3">Your Artifact Balance</p>
        <div className="grid grid-cols-4 gap-3">
          {['dumbbell', 'barbell', 'burpee', 'sprint'].map((a) => (
            <div key={a} className="text-center bg-buddy-surface-raised rounded-xl py-3">
              <ArtifactIcon artifact={a} size={24} />
              <p className="font-mono text-sm mt-1">0</p>
            </div>
          ))}
        </div>
      </div>

      <Button className="w-full" size="lg">Buy Artifacts</Button>
    </div>
  );
}
