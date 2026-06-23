import { useParams } from 'react-router-dom';

export default function TrainerProfile() {
  const { slug } = useParams();
  return (
    <div className="max-w-lg mx-auto p-4">
      <h1 className="font-display text-2xl font-extrabold mb-6">@{slug}</h1>
      <p className="text-buddy-text-secondary">Trainer profile</p>
    </div>
  );
}
