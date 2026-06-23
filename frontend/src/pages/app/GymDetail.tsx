import { useParams } from 'react-router-dom';
import { Button } from '@/components/ui/Button';

export default function GymDetail() {
  const { slug } = useParams();
  return (
    <div className="max-w-lg mx-auto p-4">
      <h1 className="font-display text-2xl font-extrabold mb-6">@{slug}</h1>
      <div className="bg-buddy-surface rounded-2xl p-6">
        <p className="text-buddy-text-secondary">Gym details</p>
      </div>
    </div>
  );
}
