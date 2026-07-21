import { create } from 'zustand';

interface SidebarState {
  collapsed: boolean;
  toggle: () => void;
}

const getInit = (): boolean => {
  if (typeof window === 'undefined') return false;
  const s = localStorage.getItem('buddyup-sidebar-collapsed');
  return s === 'true';
};

export const useSidebarStore = create<SidebarState>((set) => ({
  collapsed: getInit(),
  toggle: () =>
    set((s) => {
      const next = !s.collapsed;
      localStorage.setItem('buddyup-sidebar-collapsed', String(next));
      return { collapsed: next };
    }),
}));
