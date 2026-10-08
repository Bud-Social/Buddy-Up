import { Outlet, Link, NavLink } from 'react-router-dom';
import {
  ArrowLeft, BrainCircuit, Building2, CreditCard, Dumbbell, LayoutDashboard,
  RadioTower, ShieldCheck, BadgeCheck, ShoppingCart, Users, UsersRound, Bike,
} from 'lucide-react';
import { Logo } from '@/components/ui/Logo';

/**
 * Admin console shell.
 *
 * The header carries a prominent mode toggle: this console and the normal app
 * are two views of the *same* signed-in staff session. There is no
 * impersonation — "Back to app" is plain navigation to /feed and the user keeps
 * their own identity, permissions and audit trail. The active side of the toggle
 * is filled so the current mode is never ambiguous.
 */

const MODE_LINK_CLS =
  'inline-flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-lg transition-colors';

interface NavItem {
  to: string;
  label: string;
  icon: typeof Users;
  end?: boolean;
}

/** Domains first, then the pre-existing operational tools. */
const PRIMARY_NAV: NavItem[] = [
  { to: '/admin', label: 'Models', icon: BrainCircuit, end: true },
  { to: '/admin/users', label: 'Users', icon: Users },
  { to: '/admin/shops', label: 'Shops', icon: Building2 },
  { to: '/admin/orders', label: 'Orders', icon: ShoppingCart },
  { to: '/admin/gyms', label: 'Gyms', icon: Dumbbell },
  { to: '/admin/communities', label: 'Communities', icon: UsersRound },
  { to: '/admin/stations', label: 'Stations', icon: RadioTower },
  { to: '/admin/delivery', label: 'Delivery', icon: Bike },
  { to: '/admin/wallet', label: 'Wallet', icon: CreditCard },
];

const OPS_NAV: NavItem[] = [
  { to: '/admin/moderation', label: 'Moderation', icon: ShieldCheck },
  { to: '/admin/verification', label: 'Verification', icon: BadgeCheck },
];

function navClass(isActive: boolean) {
  return `${MODE_LINK_CLS} ${
    isActive
      ? 'bg-buddy-green/15 text-buddy-green'
      : 'text-buddy-text-secondary hover:text-buddy-text-primary hover:bg-buddy-surface-raised'
  }`;
}

function ModeToggle() {
  return (
    <div
      className="flex items-center rounded-xl border border-buddy-surface-raised bg-buddy-surface p-0.5"
      role="group"
      aria-label="Switch between the admin console and the BuddyUp app"
    >
      {/* Not `end`: every /admin/* route is still the console, so the console
          side of the toggle stays lit the whole time. */}
      <NavLink to="/admin" className={({ isActive }) => navClass(isActive)}>
        <LayoutDashboard size={14} /> Admin
      </NavLink>
      <NavLink to="/feed" className={({ isActive }) => navClass(isActive)}>
        <ArrowLeft size={14} /> App
      </NavLink>
    </div>
  );
}

export function AdminLayout() {
  return (
    <div className="min-h-screen bg-buddy-black flex flex-col">
      <header className="sticky top-12 lg:top-0 z-30 border-b border-buddy-surface-raised bg-buddy-black/95 backdrop-blur-lg">
        <div className="max-w-6xl mx-auto px-4 h-16 flex items-center gap-4">
          <Link
            to="/feed"
            className="flex items-center gap-2 text-buddy-text-secondary hover:text-buddy-text-primary transition-colors text-sm"
          >
            <ArrowLeft size={18} />
            <span className="hidden sm:inline">Back to app</span>
          </Link>
          <div className="flex items-center gap-2 flex-1 min-w-0">
            <Logo size="sm" type="icon" />
            <div className="flex items-center gap-1.5 min-w-0">
              <LayoutDashboard size={18} className="text-buddy-green shrink-0" />
              <h1 className="font-display font-extrabold text-base sm:text-lg truncate">Admin</h1>
            </div>
            <span className="text-[10px] font-semibold uppercase tracking-wide text-buddy-green bg-buddy-green/15 px-2 py-0.5 rounded-full hidden sm:inline">
              Console
            </span>
          </div>
          <div className="flex items-center gap-2">
            <ModeToggle />
            <span className="text-[10px] sm:text-xs text-buddy-text-secondary bg-buddy-surface-raised px-2 py-1 rounded-full hidden md:inline">
              Staff only
            </span>
          </div>
        </div>
        <nav className="flex items-center gap-1 px-4 max-w-6xl mx-auto pb-3 overflow-x-auto scrollbar-hide">
          {PRIMARY_NAV.map(({ to, label, icon: Icon, end }) => (
            <NavLink key={to} to={to} end={end} className={({ isActive }) => navClass(isActive)}>
              <Icon size={14} /> {label}
            </NavLink>
          ))}
          <span className="w-px h-5 bg-buddy-surface-raised mx-1 flex-shrink-0" aria-hidden="true" />
          {OPS_NAV.map(({ to, label, icon: Icon }) => (
            <NavLink key={to} to={to} className={({ isActive }) => navClass(isActive)}>
              <Icon size={14} /> {label}
            </NavLink>
          ))}
        </nav>
      </header>
      <main className="flex-1 w-full max-w-6xl mx-auto px-4 py-6">
        <Outlet />
      </main>
      <footer className="border-t border-buddy-surface-raised py-4">
        <p className="text-center text-xs text-buddy-text-secondary">
          BuddyUp Fit Admin — people, marketplace, delivery &amp; platform health
        </p>
        <p className="text-center text-[11px] text-buddy-text-secondary/70 mt-1">
          You are signed in as yourself. Actions here are recorded against your staff account.
        </p>
      </footer>
    </div>
  );
}