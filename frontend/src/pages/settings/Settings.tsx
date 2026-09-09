import { useNavigate } from 'react-router-dom';
import { ChevronRight, BrainCircuit } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { useAuthStore } from '@/store/authStore';
import { SETTINGS_SECTIONS } from './sections';

/** Settings hub — grid of section cards. Each section is its own route under
 * /settings/:section (see pages/settings/). */
export default function Settings() {
  const navigate = useNavigate();
  const user = useAuthStore((s) => s.user);

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
      <h1 className="font-display text-2xl font-extrabold mb-6">Settings</h1>
      <div className="space-y-2">
        {SETTINGS_SECTIONS.map(({ id, label, icon: Icon, desc }) => (
          <Card key={id} className="p-4 flex items-center gap-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer"
            onClick={() => navigate(`/settings/${id}`)}>
            <div className="w-10 h-10 rounded-xl bg-buddy-green/10 flex items-center justify-center flex-shrink-0">
              <Icon size={20} className="text-buddy-green" />
            </div>
            <div className="flex-1 min-w-0">
              <p className="font-medium text-sm">{label}</p>
              <p className="text-xs text-buddy-text-secondary">{desc}</p>
            </div>
            <ChevronRight size={18} className="text-buddy-text-secondary" />
          </Card>
        ))}
        {user?.is_staff && (
          <Card className="p-4 flex items-center gap-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer"
            onClick={() => navigate('/admin')}>
            <div className="w-10 h-10 rounded-xl bg-buddy-electric/10 flex items-center justify-center flex-shrink-0">
              <BrainCircuit size={20} className="text-buddy-electric" />
            </div>
            <div className="flex-1 min-w-0">
              <p className="font-medium text-sm">ML Admin</p>
              <p className="text-xs text-buddy-text-secondary">Model registry, training runs & system health</p>
            </div>
            <ChevronRight size={18} className="text-buddy-text-secondary" />
          </Card>
        )}
      </div>
    </div>
  );
}
