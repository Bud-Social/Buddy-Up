import { Outlet, Link, NavLink } from 'react-router-dom';
import { ArrowLeft, BrainCircuit, ShieldCheck, BadgeCheck } from 'lucide-react';
import { Logo } from '@/components/ui/Logo';

export function AdminLayout() {
  return (
    <div className="min-h-screen bg-buddy-black flex flex-col">
      <header className="sticky top-0 z-30 border-b border-buddy-surface-raised bg-buddy-black/95 backdrop-blur-lg">
        <div className="max-w-6xl mx-auto px-4 h-16 flex items-center gap-4">
          <Link
            to="/feed"
            className="flex items-center gap-2 text-buddy-text-secondary hover:text-buddy-text-primary transition-colors text-sm"
          >
            <ArrowLeft size={18} />
            <span className="hidden sm:inline">Back to app</span>
          </Link>
          <div className="flex items-center gap-2 flex-1">
            <Logo size="sm" type="icon" />
            <div className="flex items-center gap-1.5">
              <BrainCircuit size={18} className="text-buddy-green" />
              <h1 className="font-display font-extrabold text-base sm:text-lg">ML Admin</h1>
            </div>
          </div>
          <span className="text-[10px] sm:text-xs text-buddy-text-secondary bg-buddy-surface-raised px-2 py-1 rounded-full">
            Staff only
          </span>
        </div>
        <nav className="flex items-center gap-1 px-4 max-w-6xl mx-auto pb-3">
          <NavLink
            to="/admin"
            end
            className={({ isActive }) => `inline-flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-lg transition-colors ${
              isActive ? 'bg-buddy-green/15 text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary hover:bg-buddy-surface-raised'
            }`}
          >
            <BrainCircuit size={14} /> Models
          </NavLink>
          <NavLink
            to="/admin/moderation"
            className={({ isActive }) => `inline-flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-lg transition-colors ${
              isActive ? 'bg-buddy-green/15 text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary hover:bg-buddy-surface-raised'
            }`}
          >
            <ShieldCheck size={14} /> Moderation
          </NavLink>
          <NavLink
            to="/admin/verification"
            className={({ isActive }) => `inline-flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-lg transition-colors ${
              isActive ? 'bg-buddy-green/15 text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary hover:bg-buddy-surface-raised'
            }`}
          >
            <BadgeCheck size={14} /> Verification
          </NavLink>
        </nav>
      </header>
      <main className="flex-1 w-full max-w-6xl mx-auto px-4 py-6">
        <Outlet />
      </main>
      <footer className="border-t border-buddy-surface-raised py-4">
        <p className="text-center text-xs text-buddy-text-secondary">BuddyUp ML dashboard — model registry, training runs & system health</p>
      </footer>
    </div>
  );
}
