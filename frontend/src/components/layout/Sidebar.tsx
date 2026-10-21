import { useState, type ReactNode } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { Home, Search, Radio, Dumbbell, Users, ShoppingBag, Calendar, CalendarDays, MessageCircle, Bell, Wallet, User, Settings, HelpCircle, ChevronLeft, ChevronRight, LayoutDashboard, Activity, UsersRound, HeartHandshake, Footprints, Bike, MapPin, CalendarRange, Store } from 'lucide-react';
import { useNotificationStore } from '@/store/notificationStore';
import { useSidebarStore } from '@/store/sidebarStore';
import { useAuthStore } from '@/store/authStore';
import { useBusinessRoles } from '@/hooks/useBusinessRoles';
import { businessEntries as businessEntryList, type BusinessRoleKey } from './sidebarBusiness';
import { Logo } from '@/components/ui/Logo';
import { SupportDialog } from '@/components/features/support/SupportDialog';

const main = [
  { to: '/feed', icon: Home, label: 'Home' },
  { to: '/discover', icon: Search, label: 'Discover' },
  { to: '/buddies/find', icon: Footprints, label: 'Find a Buddy' },
  { to: '/analytics', icon: Activity, label: 'Analytics' },
  { to: '/lives', icon: Radio, label: 'Lives' }, { to: '/gyms', icon: Dumbbell, label: 'Gyms' },
  { to: '/trainers', icon: Users, label: 'Trainers' }, { to: '/marketplace', icon: ShoppingBag, label: 'Marketplace' },
  { to: '/schedule', icon: CalendarDays, label: 'Schedule' }, { to: '/sessions', icon: Calendar, label: 'Bookings' }, { to: '/messages', icon: MessageCircle, label: 'Messages' },
  { to: '/communities', icon: UsersRound, label: 'Communities' },
  { to: '/notifications', icon: Bell, label: 'Notifications' }, { to: '/wallet', icon: Wallet, label: 'Wallet' },
  { to: '/profile', icon: User, label: 'Profile' },
];
const bottom = [{ to: '/settings', icon: Settings, label: 'Settings' }, { to: '/help', icon: HelpCircle, label: 'Help' }];

/**
 * Destinations an operator holds, derived once by `useBusinessRoles`.
 *
 * The section list and the role switcher are both built from `businessEntries`
 * in `sidebarBusiness.ts`, so a destination the operator does not hold is never
 * rendered — in one or the other.
 */
function businessEntries(roles: ReturnType<typeof useBusinessRoles>): NavEntry[] {
  const icons: Record<BusinessRoleKey, typeof Store> = {
    shop: Store,
    events: CalendarRange,
    gym: Dumbbell,
    stations: MapPin,
    courier: Bike,
  };
  return businessEntryList(roles).map((entry) => ({ ...entry, icon: icons[entry.key] }));
}

type NavEntry = { to: string; icon: typeof Store; label: string; shortLabel: string };

export function Sidebar({ inDrawer = false }: { inDrawer?: boolean }) {
  const [supportOpen, setSupportOpen] = useState(false);
  const navigate = useNavigate();
  const unread = useNotificationStore((s) => s.unreadCount);
  const collapsed = useSidebarStore((s) => s.collapsed);
  const toggle = useSidebarStore((s) => s.toggle);
  const isStaff = useAuthStore((s) => s.user?.is_staff);
  // Ownership signals are derived once and filtered here, so a destination the
  // operator does not hold is never rendered — in the list or the switcher.
  const roles = useBusinessRoles();
  const business = businessEntries(roles);
  // Staff-only entry point back into the admin console. Same session, same
  // identity — no impersonation, just navigation.
  const isCollapsed = inDrawer ? false : collapsed;
  const labelCls = inDrawer ? '' : `${collapsed ? 'hidden' : ''}`;

  const itemCls = ({ isActive }: { isActive: boolean }) =>
    `flex items-center justify-start gap-3 px-3 py-2.5 rounded-xl mb-1 text-sm font-medium transition-colors ${isActive ? 'bg-buddy-green/15 text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary hover:bg-buddy-surface-raised'}`;

  function NavItem({ to, icon: Icon, label, badge }: { to: string; icon: typeof Home; label: string; badge?: number }) {
    return (
      <NavLink to={to} className={itemCls}>
        <span className="w-[18px] shrink-0 flex justify-center"><Icon size={18} /></span><span className={`${labelCls} transition-all duration-300`}>{label}</span>
        {badge !== undefined && badge > 0 && !isCollapsed && <span className="ml-auto bg-buddy-red text-white text-xs font-bold px-1.5 py-0.5 rounded-full min-w-[20px] text-center">{badge > 99 ? '99+' : badge}</span>}
      </NavLink>
    );
  }

  function SectionLabel({ children }: { children: ReactNode }) {
    if (isCollapsed) return null;
    return <p className="px-3 pt-3 pb-1 text-[10px] font-bold uppercase tracking-wider text-buddy-text-secondary">{children}</p>;
  }

  return (
    <aside className={`fixed left-0 top-0 h-full ${isCollapsed ? 'w-16' : 'w-64'} bg-buddy-surface border-r border-buddy-surface-raised flex flex-col z-30 transition-all duration-300`}>
      <div className="h-20 border-b border-buddy-surface-raised flex items-center justify-center overflow-hidden">
        <Logo size="sidebar" className={`${isCollapsed ? 'h-8 w-8' : 'h-full w-full object-contain'} transition-all duration-300`} />
      </div>
      <nav className="flex-1 overflow-y-auto py-3 px-3 scrollbar-hide">
        <SectionLabel>Main</SectionLabel>
        {main.map(({ to, icon, label }) => (
          <NavItem key={to} to={to} icon={icon} label={label} badge={label === 'Notifications' ? unread : undefined} />
        ))}

        {/* Your business — only the roles this operator actually holds. */}
        {business.length > 0 && (
          <>
            <SectionLabel>Your business</SectionLabel>
            {/* Role switcher: a multi-role operator jumps straight to any
                destination instead of hunting for it in the list below. */}
            {!isCollapsed && business.length > 1 && (
              <div className="px-3 pb-2">
                <label htmlFor="sidebar-role-switcher" className="sr-only">Switch between your roles</label>
                <select
                  id="sidebar-role-switcher"
                  value=""
                  onChange={(e) => { if (e.target.value) navigate(e.target.value); }}
                  className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-xs font-medium text-buddy-text-primary focus:outline-none focus:border-buddy-green"
                >
                  <option value="">Switch role…</option>
                  {business.map((entry) => (
                    <option key={entry.to} value={entry.to}>{entry.shortLabel}</option>
                  ))}
                </select>
              </div>
            )}
            {business.map(({ to, icon, label }) => (
              <NavItem key={to} to={to} icon={icon} label={label} />
            ))}
          </>
        )}

        {isStaff && (
          <>
            <SectionLabel>Staff</SectionLabel>
            <NavItem to="/admin/overview" icon={LayoutDashboard} label="Admin" />
          </>
        )}
      </nav>
      <div className="p-3 border-t border-buddy-surface-raised">
        {bottom.map(({ to, icon: Icon, label }) => (
          <NavLink key={to} to={to} className={itemCls}>
            <span className="w-[18px] shrink-0 flex justify-center"><Icon size={18} /></span><span className={`${labelCls} transition-all duration-300`}>{label}</span>
          </NavLink>
        ))}
        <button
          onClick={() => setSupportOpen(true)}
          className="flex items-center justify-start gap-3 px-3 py-2.5 rounded-xl mb-1 w-full text-sm font-medium transition-colors text-buddy-text-secondary hover:text-buddy-text-primary hover:bg-buddy-surface-raised"
        >
          <span className="w-[18px] shrink-0 flex justify-center"><HeartHandshake size={18} /></span><span className={`${labelCls} transition-all duration-300`}>Fund Us</span>
        </button>
        {!inDrawer && (
          <button onClick={toggle} className="flex items-center justify-center lg:justify-start gap-3 w-full px-3 py-2.5 rounded-xl text-sm font-medium text-buddy-text-secondary hover:text-buddy-text-primary hover:bg-buddy-surface-raised transition-colors mt-1">
            <span className="w-[18px] shrink-0 flex justify-center">{collapsed ? <ChevronRight size={18} /> : <ChevronLeft size={18} />}</span><span className={`${labelCls} transition-all duration-300`}>{collapsed ? 'Expand' : 'Collapse'}</span>
          </button>
        )}
      </div>
      <SupportDialog open={supportOpen} onClose={() => setSupportOpen(false)} />
    </aside>
  );
}