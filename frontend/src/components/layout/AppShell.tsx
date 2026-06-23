import { Outlet } from 'react-router-dom';
import { BottomNav } from './BottomNav';
import { Sidebar } from './Sidebar';
import { useMediaQuery } from '@/hooks/useMediaQuery';
export function AppShell() {
  const isDesktop = useMediaQuery('(min-width: 1024px)');
  return (
    <div className="min-h-screen bg-buddy-black flex">
      {isDesktop && <Sidebar />}
      <main className="flex-1 pb-20 lg:pb-0 lg:ml-64"><Outlet /></main>
      {!isDesktop && <BottomNav />}
    </div>
  );
}
