import { NavLink, useLocation } from 'react-router-dom';
import { Home, Search, Radio, Bell, User } from 'lucide-react';
import { useNotificationStore } from '@/store/notificationStore';

const items = [
  { to: '/feed', icon: Home, label: 'Home' },
  { to: '/discover', icon: Search, label: 'Find' },
  { to: '/lives', icon: Radio, label: 'Live', center: true } as { to: string; icon: typeof Home; label: string; center?: boolean },
  { to: '/notifications', icon: Bell, label: 'Notif.' },
  { to: '/profile', icon: User, label: 'Profile' },
];

export function BottomNav() {
  const unread = useNotificationStore((s) => s.unreadCount);
  const loc = useLocation();
  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-buddy-black/95 backdrop-blur-lg border-t border-buddy-surface z-40">
      <div className="flex items-center justify-around h-16 max-w-lg mx-auto">
        {items.map(({ to, icon: Icon, label, center }) => {
          const active = loc.pathname.startsWith(to);
          return (
            <NavLink key={to} to={to} className={`relative flex flex-col items-center justify-center gap-0.5 min-w-[48px] min-h-[48px] ${center ? 'relative -mt-5' : ''}`}>
              {center ? (
                <div className={`flex items-center justify-center w-12 h-12 rounded-full ${active ? 'bg-buddy-green' : 'bg-buddy-green/80'} text-buddy-white shadow-lg shadow-buddy-green/25`}>
                  <Icon size={22} strokeWidth={2.5} />
                </div>
              ) : (
                <Icon size={22} strokeWidth={active ? 2.5 : 1.5} className={active ? 'text-buddy-green' : 'text-buddy-text-secondary'} />
              )}
              {label === 'Notif.' && unread > 0 && <span className="absolute top-1 right-1/4 w-4 h-4 rounded-full bg-buddy-red text-white text-[10px] font-bold flex items-center justify-center">{unread > 9 ? '9+' : unread}</span>}
              {!center && <span className={`text-[10px] font-medium ${active ? 'text-buddy-green' : 'text-buddy-text-secondary'}`}>{label}</span>}
            </NavLink>
          );
        })}
      </div>
    </nav>
  );
}
