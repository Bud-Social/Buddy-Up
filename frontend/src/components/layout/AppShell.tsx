import { Outlet } from 'react-router-dom';
import { BottomNav } from './BottomNav';
import { Sidebar } from './Sidebar';
import { IncomingCallOverlay } from '@/components/chat/IncomingCallOverlay';
import { useMediaQuery } from '@/hooks/useMediaQuery';
import { useSidebarStore } from '@/store/sidebarStore';
export function AppShell() {
  const isDesktop = useMediaQuery('(min-width: 1024px)');
  const collapsed = useSidebarStore((s) => s.collapsed);
  return (
    <div className="min-h-screen bg-buddy-black flex">
      {isDesktop && <Sidebar />}
      <main className={`flex-1 pb-20 lg:pb-0 transition-all duration-300 ${isDesktop ? (collapsed ? 'lg:ml-16' : 'lg:ml-64') : ''}`}><Outlet /></main>
      {!isDesktop && <BottomNav />}
      <IncomingCallOverlay />
    </div>
  );
}
