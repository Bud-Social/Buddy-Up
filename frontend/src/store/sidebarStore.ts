import { create } from 'zustand';

interface SidebarState {
  collapsed: boolean;
  toggle: () => void;
  setCollapsed: (v: boolean) => void;
  mobileOpen: boolean;
  openMobile: () => void;
  closeMobile: () => void;
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
  setCollapsed: (v) =>
    set(() => {
      localStorage.setItem('buddyup-sidebar-collapsed', String(v));
      return { collapsed: v };
    }),
  mobileOpen: false,
  openMobile: () => set({ mobileOpen: true }),
  closeMobile: () => set({ mobileOpen: false }),
}));