import { NavLink, useLocation } from 'react-router-dom';
import { Home, Search, Radio, Timer, User } from 'lucide-react';

const items = [
  { to: '/feed', icon: Home, label: 'Home' },
  { to: '/discover', icon: Search, label: 'Find' },
  { to: '/lives', icon: Radio, label: 'Live', center: true } as { to: string; icon: typeof Home; label: string; center?: boolean },
  { to: '/countdowns', icon: Timer, label: 'Countdowns' },
  { to: '/profile', icon: User, label: 'Profile' },
];

export function BottomNav() {
  const loc = useLocation();
  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-buddy-black/95 backdrop-blur-lg border-t border-buddy-surface z-40">
      <div className="flex items-center justify-around h-16 max-w-lg mx-auto">
        {items.map(({ to, icon: Icon, label, center }) => {
          const active = loc.pathname.startsWith(to);
          return (
            <NavLink key={to} to={to} className={`relative flex flex-col items-center justify-center gap-0.5 min-w-[48px] min-h-[48px] ${center ? 'relative -mt-3' : ''}`}>
              {center ? (
                <div className={`flex items-center justify-center w-12 h-12 rounded-full ${active ? 'bg-buddy-green' : 'bg-buddy-green/80'} text-buddy-white shadow-lg shadow-buddy-green/25`}>
                  <Icon size={22} strokeWidth={2.5} />
                </div>
              ) : (
                <Icon size={22} strokeWidth={active ? 2.5 : 1.5} className={active ? 'text-buddy-green' : 'text-buddy-text-secondary'} />
              )}
              <span className={`text-[10px] font-medium ${center ? 'mt-0.5' : ''} ${active ? 'text-buddy-green' : 'text-buddy-text-secondary'}`}>{label}</span>
            </NavLink>
          );
        })}
      </div>
    </nav>
  );
}
