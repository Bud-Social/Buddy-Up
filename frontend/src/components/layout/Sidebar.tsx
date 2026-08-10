import { NavLink } from 'react-router-dom';
import { Home, Search, Radio, Dumbbell, Users, ShoppingBag, Calendar, MessageCircle, Bell, Wallet, User, Settings, HelpCircle, ChevronLeft, ChevronRight, BrainCircuit, Activity } from 'lucide-react';
import { useNotificationStore } from '@/store/notificationStore';
import { useSidebarStore } from '@/store/sidebarStore';
import { useAuthStore } from '@/store/authStore';
import { Logo } from '@/components/ui/Logo';

const main = [
  { to: '/feed', icon: Home, label: 'Home' },
  { to: '/discover', icon: Search, label: 'Discover' },
  { to: '/analytics', icon: Activity, label: 'Analytics' },
  { to: '/lives', icon: Radio, label: 'Lives' }, { to: '/gyms', icon: Dumbbell, label: 'Gyms' },
  { to: '/trainers', icon: Users, label: 'Trainers' }, { to: '/marketplace', icon: ShoppingBag, label: 'Marketplace' },
  { to: '/sessions', icon: Calendar, label: 'Sessions' }, { to: '/messages', icon: MessageCircle, label: 'Messages' },
  { to: '/notifications', icon: Bell, label: 'Notifications' }, { to: '/wallet', icon: Wallet, label: 'Wallet' },
  { to: '/profile', icon: User, label: 'Profile' },
];
const bottom = [{ to: '/settings', icon: Settings, label: 'Settings' }, { to: '/help', icon: HelpCircle, label: 'Help' }];

export function Sidebar() {
  const unread = useNotificationStore((s) => s.unreadCount);
  const collapsed = useSidebarStore((s) => s.collapsed);
  const toggle = useSidebarStore((s) => s.toggle);
  const isStaff = useAuthStore((s) => s.user?.is_staff);
  const navItems = isStaff ? [...main, { to: '/admin', icon: BrainCircuit, label: 'ML Admin' }] : main;
  return (
    <aside className={`fixed left-0 top-0 h-full ${collapsed ? 'w-16' : 'w-64'} bg-buddy-surface border-r border-buddy-surface-raised flex flex-col z-30 transition-all duration-300`}>
      <div className="h-20 border-b border-buddy-surface-raised flex items-center justify-center overflow-hidden">
        <Logo size="sidebar" className={`${collapsed ? 'h-8 w-8' : 'h-full w-full object-contain'} transition-all duration-300`} />
      </div>
      <nav className="flex-1 overflow-y-auto py-3 px-3 scrollbar-hide">
        {navItems.map(({ to, icon: Icon, label }) => (
          <NavLink key={to} to={to} className={({ isActive }) => `flex items-center justify-center lg:justify-start gap-3 px-3 py-2.5 rounded-xl mb-1 text-sm font-medium transition-colors ${isActive ? 'bg-buddy-green/15 text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary hover:bg-buddy-surface-raised'}`}>
            <Icon size={18} /><span className={`${collapsed ? 'hidden' : ''} transition-all duration-300`}>{label}</span>
            {!collapsed && label === 'Notifications' && unread > 0 && <span className="ml-auto bg-buddy-red text-white text-xs font-bold px-1.5 py-0.5 rounded-full min-w-[20px] text-center">{unread > 99 ? '99+' : unread}</span>}
          </NavLink>
        ))}
      </nav>
      <div className="p-3 border-t border-buddy-surface-raised">
        {bottom.map(({ to, icon: Icon, label }) => (
          <NavLink key={to} to={to} className={({ isActive }) => `flex items-center justify-center lg:justify-start gap-3 px-3 py-2.5 rounded-xl mb-1 text-sm font-medium transition-colors ${isActive ? 'bg-buddy-green/15 text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary hover:bg-buddy-surface-raised'}`}>
            <Icon size={18} /><span className={`${collapsed ? 'hidden' : ''} transition-all duration-300`}>{label}</span>
          </NavLink>
        ))}
        <button onClick={toggle} className="flex items-center justify-center lg:justify-start gap-3 w-full px-3 py-2.5 rounded-xl text-sm font-medium text-buddy-text-secondary hover:text-buddy-text-primary hover:bg-buddy-surface-raised transition-colors mt-1">
          {collapsed ? <ChevronRight size={18} /> : <ChevronLeft size={18} />}<span className={`${collapsed ? 'hidden' : ''} transition-all duration-300`}>{collapsed ? 'Expand' : 'Collapse'}</span>
        </button>
      </div>
    </aside>
  );
}
