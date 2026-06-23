import { Bell } from 'lucide-react';

export default function Notifications() {
  return (
    <div className="max-w-lg mx-auto p-4">
      <h1 className="font-display text-2xl font-extrabold mb-6">Notifications</h1>
      <div className="bg-buddy-surface rounded-2xl p-6 text-center">
        <Bell size={48} className="mx-auto text-buddy-text-secondary/30 mb-4" />
        <p className="text-buddy-text-secondary">No notifications yet</p>
      </div>
    </div>
  );
}
