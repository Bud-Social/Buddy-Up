import { createBrowserRouter, Navigate, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { lazy, Suspense } from 'react';
import { AppShell } from '@/components/layout/AppShell';
import { LandingLayout } from '@/components/layout/LandingLayout';
import { Skeleton } from '@/components/ui/Skeleton';
import { useAuthStore } from '@/store/authStore';

const PUBLIC_ROUTES = ['/', '/login', '/signup', '/verify-age', '/forgot-password', '/terms', '/privacy', '/community-guidelines', '/cookie-policy'];

function AuthGuard() {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  const isLoading = useAuthStore((s) => s.isLoading);
  const location = useLocation();

  if (isLoading) return <PageLoader />;
  if (!isAuthenticated && !PUBLIC_ROUTES.includes(location.pathname)) return <Navigate to="/login" replace />;
  return <Outlet />;
}

const Login = lazy(() => import('@/pages/auth/Login'));
const Register = lazy(() => import('@/pages/auth/Register'));
const VerifyAge = lazy(() => import('@/pages/auth/VerifyAge'));
const Onboarding = lazy(() => import('@/pages/auth/Onboarding'));
const ForgotPassword = lazy(() => import('@/pages/auth/ForgotPassword'));

const Feed = lazy(() => import('@/pages/app/Feed'));
const Discover = lazy(() => import('@/pages/app/Discover'));
const Lives = lazy(() => import('@/pages/app/Lives'));
const Gyms = lazy(() => import('@/pages/app/Gyms'));
const GymDetail = lazy(() => import('@/pages/app/GymDetail'));
const Trainers = lazy(() => import('@/pages/app/Trainers'));
const TrainerProfile = lazy(() => import('@/pages/app/TrainerProfile'));
const Marketplace = lazy(() => import('@/pages/app/Marketplace'));
const Sessions = lazy(() => import('@/pages/app/Sessions'));
const Messages = lazy(() => import('@/pages/app/Messages'));
const Wallet = lazy(() => import('@/pages/app/Wallet'));
const Notifications = lazy(() => import('@/pages/app/Notifications'));
const Profile = lazy(() => import('@/pages/app/Profile'));
const UserProfile = lazy(() => import('@/pages/app/UserProfile'));
const Settings = lazy(() => import('@/pages/app/Settings'));
const BuddiesPage = lazy(() => import('@/pages/app/BuddiesPage'));

const Terms = lazy(() => import('@/pages/legal/Terms'));
const Privacy = lazy(() => import('@/pages/legal/Privacy'));
const CommunityGuidelines = lazy(() => import('@/pages/legal/CommunityGuidelines'));
const CookiePolicy = lazy(() => import('@/pages/legal/CookiePolicy'));

const Landing = lazy(() => import('@/pages/Landing'));

function PageLoader() {
  return (
    <div className="p-4 space-y-4">
      <Skeleton className="h-8 w-1/3" />
      <Skeleton className="h-64 w-full" />
      <Skeleton className="h-4 w-full" />
      <Skeleton className="h-4 w-3/4" />
    </div>
  );
}

function SWrapper({ children }: { children: React.ReactNode }) {
  return <Suspense fallback={<PageLoader />}>{children}</Suspense>;
}

export const router = createBrowserRouter([
  {
    path: '/',
    element: <SWrapper><Landing /></SWrapper>,
  },
  { path: '/login', element: <SWrapper><Login /></SWrapper> },
  { path: '/signup', element: <SWrapper><Register /></SWrapper> },
  { path: '/verify-age', element: <SWrapper><VerifyAge /></SWrapper> },
  { path: '/onboarding', element: <SWrapper><Onboarding /></SWrapper> },
  { path: '/forgot-password', element: <SWrapper><ForgotPassword /></SWrapper> },
  { path: '/terms', element: <SWrapper><Terms /></SWrapper> },
  { path: '/privacy', element: <SWrapper><Privacy /></SWrapper> },
  { path: '/community-guidelines', element: <SWrapper><CommunityGuidelines /></SWrapper> },
  { path: '/cookie-policy', element: <SWrapper><CookiePolicy /></SWrapper> },
  {
    element: <AuthGuard />,
    children: [
      {
        element: <AppShell />,
        children: [
          { path: '/feed', element: <SWrapper><Feed /></SWrapper> },
          { path: '/discover', element: <SWrapper><Discover /></SWrapper> },
          { path: '/lives', element: <SWrapper><Lives /></SWrapper> },
          { path: '/gyms', element: <SWrapper><Gyms /></SWrapper> },
          { path: '/gyms/:slug', element: <SWrapper><GymDetail /></SWrapper> },
          { path: '/trainers', element: <SWrapper><Trainers /></SWrapper> },
          { path: '/trainers/:slug', element: <SWrapper><TrainerProfile /></SWrapper> },
          { path: '/marketplace', element: <SWrapper><Marketplace /></SWrapper> },
          { path: '/sessions', element: <SWrapper><Sessions /></SWrapper> },
          { path: '/messages', element: <SWrapper><Messages /></SWrapper> },
          { path: '/wallet', element: <SWrapper><Wallet /></SWrapper> },
          { path: '/notifications', element: <SWrapper><Notifications /></SWrapper> },
          { path: '/profile', element: <SWrapper><Profile /></SWrapper> },
          { path: '/profile/edit', element: <SWrapper><Profile /></SWrapper> },
          { path: '/buddies', element: <SWrapper><BuddiesPage /></SWrapper> },
          { path: '/settings', element: <SWrapper><Settings /></SWrapper> },
        ],
      },
      { path: '/:username', element: <SWrapper><UserProfile /></SWrapper> },
    ],
  },
  { path: '*', element: <Navigate to="/" replace /> },
]);
