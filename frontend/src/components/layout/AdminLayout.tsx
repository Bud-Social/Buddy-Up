import { Outlet, Link, NavLink } from 'react-router-dom';
import {
  ArrowLeft, BarChart3, BrainCircuit, Building2, CreditCard, Dumbbell, LayoutDashboard,
  RadioTower, ShieldCheck, BadgeCheck, ShoppingCart, Users, UsersRound, Bike,
  Gavel, ScrollText, Mail, KeyRound, UserCheck,
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
  'inline-flex items-center gap-1.5 text-xs font-semibold px-3 py-2 rounded-lg transition-colors';

interface NavItem {
  to: string;
  label: string;
  icon: typeof Users;
  end?: boolean;
}

/** Domains first, then the pre-existing operational tools. */
const PRIMARY_NAV: NavItem[] = [
  // Overview leads: it is the platform-health probe and the page a staff user
  // should land on. It was reachable only by a Sidebar deep link, so the
  // console's front door used to open the model registry instead.
  { to: '/admin', label: 'Overview', icon: LayoutDashboard, end: true },
  { to: '/admin/models', label: 'Models', icon: BrainCircuit },
  { to: '/admin/analytics', label: 'Analytics', icon: BarChart3 },
  { to: '/admin/users', label: 'Users', icon: Users },
  { to: '/admin/shops', label: 'Shops', icon: Building2 },
  { to: '/admin/orders', label: 'Orders', icon: ShoppingCart },
  { to: '/admin/gyms', label: 'Gyms', icon: Dumbbell },
  { to: '/admin/communities', label: 'Communities', icon: UsersRound },
  { to: '/admin/stations', label: 'Stations', icon: RadioTower },
  { to: '/admin/delivery', label: 'Delivery', icon: Bike },
  { to: '/admin/wallet', label: 'Wallet', icon: CreditCard },
];

/**
 * Operational tools, separated from the domain pages by the divider in the nav.
 *
 * The split is not cosmetic. Everything above this line reads and acts on a
 * domain; everything on it decides *who may use* the domains above, or records
 * what was done. A support agent opening the console should be able to see at a
 * glance that granting, approving and the audit trail are a different kind of
 * surface from adjusting an order's status — and they are, because those pages
 * enforce two-person rules that the domain pages do not.
 */
const OPS_NAV: NavItem[] = [
  { to: '/admin/moderation', label: 'Moderation', icon: ShieldCheck },
  { to: '/admin/appeals', label: 'Appeals', icon: Gavel },
  { to: '/admin/approvals', label: 'Approvals', icon: UserCheck },
  { to: '/admin/audit', label: 'Audit', icon: ScrollText },
  { to: '/admin/email', label: 'Email', icon: Mail },
  { to: '/admin/staff', label: 'Staff', icon: KeyRound },
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
        {/*
          * Wraps rather than scrolls. Eighteen pills on one non-wrapping row
          * overflowed past the viewport with the scrollbar deliberately hidden,
          * so on a narrow screen the last several sections were simply
          * unreachable — and the divider between the domain pages and the
          * operational tools was usually off-screen too, quietly erasing the
          * distinction the split exists to make.
          *
          * `gap-2` for the spacing, `flex-shrink-0` so a pill never compresses
          * into an unreadable sliver, and `py-2` to bring the hit area up from
          * ~28px. The wider `gap-4` around the divider keeps the two groups
          * reading as separate surfaces rather than one long list.
          */}
        <nav className="flex flex-wrap items-center gap-2 px-4 max-w-6xl mx-auto pb-4 pt-1">
          {PRIMARY_NAV.map(({ to, label, icon: Icon, end }) => (
            <NavLink
              key={to}
              to={to}
              end={end}
              className={({ isActive }) => `${navClass(isActive)} flex-shrink-0`}
            >
              <Icon size={14} className="flex-shrink-0" /> {label}
            </NavLink>
          ))}
          <span className="w-px h-5 bg-buddy-surface-raised mx-2 flex-shrink-0" aria-hidden="true" />
          {OPS_NAV.map(({ to, label, icon: Icon }) => (
            <NavLink
              key={to}
              to={to}
              className={({ isActive }) => `${navClass(isActive)} flex-shrink-0`}
            >
              <Icon size={14} className="flex-shrink-0" /> {label}
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
          You are signed in as yourself. Actions here are recorded against your staff account — read them
          back any time under <Link to="/admin/audit" className="text-buddy-green hover:underline">Audit</Link>.
        </p>
      </footer>
    </div>
  );
}