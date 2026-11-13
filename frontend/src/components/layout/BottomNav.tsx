import { NavLink, useLocation } from 'react-router-dom';
import { Home, Search, Radio, Map as MapIcon, User } from 'lucide-react';

const items = [
  { to: '/feed', icon: Home, label: 'Home' },
  { to: '/discover', icon: Search, label: 'Find' },
  { to: '/lives', icon: Radio, label: 'Live', center: true } as { to: string; icon: typeof Home; label: string; center?: boolean },
  { to: '/activities', icon: MapIcon, label: 'Activities' },
  { to: '/profile', icon: User, label: 'Profile' },
];

/**
 * The mobile navigation.
 *
 * The active item reads as active through a tinted pill as well as the
 * colour, so the state does not rely on the label colour alone — green on
 * a near-black bar is thin, and the centre button's label used to be
 * white-on-green, which is barely legible.
 */
export function BottomNav() {
  const loc = useLocation();
  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-buddy-black/95 backdrop-blur-lg border-t border-buddy-surface z-40">
      <div className="flex items-center justify-around h-16 max-w-lg mx-auto">
        {items.map(({ to, icon: Icon, label, center }) => {
          const active = loc.pathname.startsWith(to);
          return (
            <NavLink
              key={to}
              to={to}
              aria-current={active ? 'page' : undefined}
              className={`relative flex flex-col items-center justify-center gap-0.5 min-w-[56px] min-h-[48px] ${center ? 'relative -mt-3' : ''}`}
            >
              {center ? (
                <div
                  className={`flex items-center justify-center w-12 h-12 rounded-full transition-colors ${
                    active ? 'bg-buddy-green text-buddy-black' : 'bg-buddy-green/80 text-buddy-black'
                  } shadow-lg shadow-buddy-green/25`}
                >
                  <Icon size={22} strokeWidth={2.5} />
                </div>
              ) : (
                <span
                  className={`flex items-center justify-center w-9 h-9 rounded-full transition-colors ${
                    active ? 'bg-buddy-green/15' : ''
                  }`}
                >
                  <Icon
                    size={22}
                    strokeWidth={active ? 2.5 : 1.5}
                    className={active ? 'text-buddy-green' : 'text-buddy-text-secondary'}
                  />
                </span>
              )}
              <span
                className={`text-[10px] font-semibold leading-none ${
                  center ? 'mt-0.5' : ''
                } ${active ? 'text-buddy-text-primary' : 'text-buddy-text-secondary'}`}
              >
                {label}
              </span>
            </NavLink>
          );
        })}
      </div>
    </nav>
  );
}
