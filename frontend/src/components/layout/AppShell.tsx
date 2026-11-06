import { useEffect } from 'react';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';
import { Menu, X, Bell } from 'lucide-react';
import { BottomNav } from './BottomNav';
import { Sidebar } from './Sidebar';
import { StandingBanner } from './StandingBanner';
import { IncomingCallOverlay } from '@/components/chat/IncomingCallOverlay';
import { AlarmWatcher } from './AlarmWatcher';
import { UploadPill } from './UploadPill';
import { useMediaQuery } from '@/hooks/useMediaQuery';
import { useSidebarStore } from '@/store/sidebarStore';
import { useNotificationStore } from '@/store/notificationStore';

export function AppShell() {
  const location = useLocation();
  const navigate = useNavigate();
  const unread = useNotificationStore((s) => s.unreadCount);
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

  const NotificationBell = () => (
    <button
      onClick={() => navigate('/notifications')}
      className="relative p-2 rounded-full text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-surface transition-colors"
      aria-label="Notifications"
    >
      <Bell size={20} />
      {unread > 0 && (
        <span className="absolute top-0.5 right-0.5 w-4 h-4 rounded-full bg-buddy-red text-white text-[10px] font-bold flex items-center justify-center">
          {unread > 9 ? '9+' : unread}
        </span>
      )}
    </button>
  );

  return (
    <div className="min-h-screen bg-buddy-black flex">
      {isTablet && <Sidebar />}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Mobile / tablet top bar with hamburger */}
        {!hideTopBar && !isDesktop && (
          <header className="sticky top-0 z-40 flex items-center gap-3 h-16 px-4 bg-buddy-black/90 backdrop-blur-md border-b border-buddy-surface">
            <button
              onClick={onMenu}
              className="p-2 -ml-1 rounded-lg text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-surface transition-colors"
              aria-label="Toggle navigation"
            >
              {mobileOpen && !isTablet ? <X size={24} /> : <Menu size={24} />}
            </button>
            <span className="font-display font-bold text-base text-buddy-text-primary tracking-tight flex-1">BuddyUp Fit</span>
            <NotificationBell />
          </header>
        )}
        {/* Desktop slim top bar */}
        {!hideTopBar && isDesktop && (
          <header className={`sticky top-0 z-40 flex items-center justify-end h-14 px-6 bg-buddy-black/90 backdrop-blur-md border-b border-buddy-surface transition-all duration-300 ${sidebarMargin}`}>
            <NotificationBell />
          </header>
        )}
        <main className={`flex-1 pb-20 md:pb-0 transition-all duration-300 ${sidebarMargin}`}>
          <StandingBanner />
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
      <AlarmWatcher />
      <UploadPill />
    </div>
  );
}