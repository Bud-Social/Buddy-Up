import { useEffect } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import { Menu, X } from 'lucide-react';
import { BottomNav } from './BottomNav';
import { Sidebar } from './Sidebar';
import { IncomingCallOverlay } from '@/components/chat/IncomingCallOverlay';
import { useMediaQuery } from '@/hooks/useMediaQuery';
import { useSidebarStore } from '@/store/sidebarStore';

export function AppShell() {
  const location = useLocation();
  const isDesktop = useMediaQuery('(min-width: 1024px)');
  const isTablet = useMediaQuery('(min-width: 768px)');
  const collapsed = useSidebarStore((s) => s.collapsed);
  const toggle = useSidebarStore((s) => s.toggle);
  const setCollapsed = useSidebarStore((s) => s.setCollapsed);
  const mobileOpen = useSidebarStore((s) => s.mobileOpen);
  const openMobile = useSidebarStore((s) => s.openMobile);
  const closeMobile = useSidebarStore((s) => s.closeMobile);

  const pathname = location.pathname;
  // Tablet: collapsed icon rail by default (hamburger enlarges it).
  useEffect(() => {
    if (isTablet && !isDesktop) setCollapsed(true);
  }, [isTablet, isDesktop, setCollapsed]);

  // Close the mobile drawer on navigation.
  useEffect(() => {
    closeMobile();
  }, [pathname, closeMobile]);

  // Immersive routes that manage their own headers — no shell top bar.
  const hideTopBar =
    pathname.startsWith('/live/') ||
    pathname.startsWith('/messages') ||
    pathname === '/videos';

  const sidebarMargin = isTablet ? (collapsed ? 'md:ml-16' : 'md:ml-64') : '';
  const onMenu = isTablet ? toggle : openMobile;

  return (
    <div className="min-h-screen bg-buddy-black flex">
      {isTablet && <Sidebar />}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Mobile / tablet top bar with hamburger */}
        {!hideTopBar && !isDesktop && (
          <header className="sticky top-0 z-40 flex items-center gap-3 h-12 px-3 bg-buddy-black/90 backdrop-blur-md border-b border-buddy-surface">
            <button
              onClick={onMenu}
              className="p-2 -ml-1 rounded-lg text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-surface transition-colors"
              aria-label="Toggle navigation"
            >
              {mobileOpen && !isTablet ? <X size={20} /> : <Menu size={20} />}
            </button>
            <span className="font-display font-bold text-sm text-buddy-text-primary">BuddyUp</span>
          </header>
        )}
        <main className={`flex-1 pb-20 md:pb-0 transition-all duration-300 ${sidebarMargin}`}>
          <Outlet />
        </main>
      </div>
      {!isTablet && <BottomNav />}

      {/* Mobile drawer */}
      {!isTablet && mobileOpen && (
        <div className="fixed inset-0 z-50 md:hidden">
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={closeMobile} />
          <div className="absolute left-0 top-0 h-full w-64 shadow-2xl">
            <Sidebar inDrawer />
          </div>
        </div>
      )}

      <IncomingCallOverlay />
    </div>
  );
}