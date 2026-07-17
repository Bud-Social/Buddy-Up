import { createBrowserRouter, Navigate, Outlet, useLocation } from 'react-router-dom';
import { lazy, Suspense } from 'react';
import { AppShell } from '@/components/layout/AppShell';
import { Skeleton } from '@/components/ui/Skeleton';
import { useAuthStore } from '@/store/authStore';

const PUBLIC_ROUTES = [
  '/', '/login', '/signup', '/verify-registration-otp', '/verify-age',
  '/forgot-password', '/reset-password',
  '/terms', '/privacy', '/community-guidelines', '/cookie-policy',
  '/totp-setup', '/totp-challenge',
];

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
const VerifyRegistrationOtp = lazy(() => import('@/pages/auth/VerifyRegistrationOtp'));
const VerifyAge = lazy(() => import('@/pages/auth/VerifyAge'));
const Onboarding = lazy(() => import('@/pages/auth/Onboarding'));
const ForgotPassword = lazy(() => import('@/pages/auth/ForgotPassword'));
const ResetPasswordConfirm = lazy(() => import('@/pages/auth/ResetPasswordConfirm'));
const TotpSetup = lazy(() => import('@/pages/auth/TotpSetup'));
const TotpChallenge = lazy(() => import('@/pages/auth/TotpChallenge'));

const Feed = lazy(() => import('@/pages/app/Feed'));
const Discover = lazy(() => import('@/pages/app/Discover'));
const Lives = lazy(() => import('@/pages/app/Lives'));
const Gyms = lazy(() => import('@/pages/app/Gyms'));
const GymDetail = lazy(() => import('@/pages/app/GymDetail'));
const Trainers = lazy(() => import('@/pages/app/Trainers'));
const TrainerProfile = lazy(() => import('@/pages/app/TrainerProfile'));
const Marketplace = lazy(() => import('@/pages/app/Marketplace'));
const EventDetail = lazy(() => import('@/pages/app/EventDetail'));
const CreateEvent = lazy(() => import('@/pages/app/CreateEvent'));
const MyEventTickets = lazy(() => import('@/pages/app/MyEventTickets'));
const CartPage = lazy(() => import('@/pages/app/CartPage'));
const CreatorStudio = lazy(() => import('@/pages/app/CreatorStudio'));
const MealPlanDetail = lazy(() => import('@/pages/app/MealPlanDetail'));
const CreateMealPlan = lazy(() => import('@/pages/app/CreateMealPlan'));
const ProgrammeDetail = lazy(() => import('@/pages/app/ProgrammeDetail'));
const CreateProgramme = lazy(() => import('@/pages/app/CreateProgramme'));
const ProductDetail = lazy(() => import('@/pages/app/ProductDetail'));
const CreateProduct = lazy(() => import('@/pages/app/CreateProduct'));
const Sessions = lazy(() => import('@/pages/app/Sessions'));
const CreateSessionOffering = lazy(() => import('@/pages/app/CreateSessionOffering'));
const SessionDetail = lazy(() => import('@/pages/app/SessionDetail'));
const Messages = lazy(() => import('@/pages/app/Messages'));
const Wallet = lazy(() => import('@/pages/app/Wallet'));
const Notifications = lazy(() => import('@/pages/app/Notifications'));
const Profile = lazy(() => import('@/pages/app/Profile'));
const EditProfile = lazy(() => import('@/pages/app/EditProfile'));
const UserProfile = lazy(() => import('@/pages/app/UserProfile'));
const Settings = lazy(() => import('@/pages/app/Settings'));
const BuddiesPage = lazy(() => import('@/pages/app/BuddiesPage'));
const CreateGymPage = lazy(() => import('@/pages/app/CreateGymPage'));
const LiveRoom = lazy(() => import('@/pages/app/LiveRoom'));
const HealthInsights = lazy(() => import('@/pages/app/HealthInsights'));
const WorkoutForm = lazy(() => import('@/pages/app/WorkoutForm'));
const Verification = lazy(() => import('@/pages/app/Verification'));

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
  { path: '/verify-registration-otp', element: <SWrapper><VerifyRegistrationOtp /></SWrapper> },
  { path: '/verify-age', element: <SWrapper><VerifyAge /></SWrapper> },
  { path: '/onboarding', element: <SWrapper><Onboarding /></SWrapper> },
  { path: '/forgot-password', element: <SWrapper><ForgotPassword /></SWrapper> },
  { path: '/reset-password', element: <SWrapper><ResetPasswordConfirm /></SWrapper> },
  { path: '/totp-setup', element: <SWrapper><TotpSetup /></SWrapper> },
  { path: '/totp-challenge', element: <SWrapper><TotpChallenge /></SWrapper> },
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
          { path: '/gyms/create', element: <SWrapper><CreateGymPage /></SWrapper> },
          { path: '/gyms/:slug', element: <SWrapper><GymDetail /></SWrapper> },
          { path: '/trainers', element: <SWrapper><Trainers /></SWrapper> },
          { path: '/trainers/:slug', element: <SWrapper><TrainerProfile /></SWrapper> },
          { path: '/marketplace', element: <SWrapper><Marketplace /></SWrapper> },
          { path: '/marketplace/creator', element: <SWrapper><CreatorStudio /></SWrapper> },
          { path: '/marketplace/cart', element: <SWrapper><CartPage /></SWrapper> },
          { path: '/marketplace/events/create', element: <SWrapper><CreateEvent /></SWrapper> },
          { path: '/marketplace/events/my-tickets', element: <SWrapper><MyEventTickets /></SWrapper> },
          { path: '/marketplace/events/:eventId', element: <SWrapper><EventDetail /></SWrapper> },
          { path: '/marketplace/meal-plans/create', element: <SWrapper><CreateMealPlan /></SWrapper> },
          { path: '/marketplace/meal-plans/:planId', element: <SWrapper><MealPlanDetail /></SWrapper> },
          { path: '/marketplace/programmes/create', element: <SWrapper><CreateProgramme /></SWrapper> },
          { path: '/marketplace/programmes/:programmeId', element: <SWrapper><ProgrammeDetail /></SWrapper> },
          { path: '/marketplace/products/create', element: <SWrapper><CreateProduct /></SWrapper> },
          { path: '/marketplace/products/:productId', element: <SWrapper><ProductDetail /></SWrapper> },
          { path: '/sessions', element: <SWrapper><Sessions /></SWrapper> },
          { path: '/sessions/offering', element: <SWrapper><CreateSessionOffering /></SWrapper> },
          { path: '/sessions/:bookingId', element: <SWrapper><SessionDetail /></SWrapper> },
          { path: '/messages', element: <SWrapper><Messages /></SWrapper> },
          { path: '/messages/:conversationId', element: <SWrapper><Messages /></SWrapper> },
          { path: '/wallet', element: <SWrapper><Wallet /></SWrapper> },
          { path: '/notifications', element: <SWrapper><Notifications /></SWrapper> },
          { path: '/profile', element: <SWrapper><Profile /></SWrapper> },
          { path: '/profile/edit', element: <SWrapper><EditProfile /></SWrapper> },
          { path: '/buddies', element: <SWrapper><BuddiesPage /></SWrapper> },
          { path: '/settings', element: <SWrapper><Settings /></SWrapper> },
          { path: '/health-insights', element: <SWrapper><HealthInsights /></SWrapper> },
          { path: '/workout-form', element: <SWrapper><WorkoutForm /></SWrapper> },
          { path: '/verification', element: <SWrapper><Verification /></SWrapper> },
        ],
      },
      { path: '/live/:liveId', element: <SWrapper><LiveRoom /></SWrapper> },
      { path: '/:username', element: <SWrapper><UserProfile /></SWrapper> },
    ],
  },
  { path: '*', element: <Navigate to="/" replace /> },
]);
