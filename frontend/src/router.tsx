import { createBrowserRouter, Navigate, Outlet, useLocation } from 'react-router-dom';
import { lazy, Suspense } from 'react';
import { AppShell } from '@/components/layout/AppShell';
import { AdminLayout } from '@/components/layout/AdminLayout';
import { Skeleton } from '@/components/ui/Skeleton';
import { useAuthStore } from '@/store/authStore';

const PUBLIC_ROUTES = [
  '/', '/login', '/signup', '/verify-registration-otp', '/verify-age',
  '/forgot-password', '/reset-password',
  '/terms', '/privacy', '/community-guidelines', '/cookie-policy',
  '/medical-disclaimer', '/sponsorship-policy', '/adult-content-policy', '/help',
  '/totp-setup', '/totp-challenge',
];

function AuthGuard() {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  const isLoading = useAuthStore((s) => s.isLoading);
  const profile = useAuthStore((s) => s.profile);
  const user = useAuthStore((s) => s.user);
  const location = useLocation();

  if (isLoading) return <PageLoader />;
  if (!isAuthenticated && !PUBLIC_ROUTES.includes(location.pathname)) return <Navigate to="/login" replace />;
  // Required-once onboarding: incomplete accounts are routed through the
  // pipeline (DOB → terms → profile → interests) before anything else.
  if (
    isAuthenticated &&
    profile &&
    profile.onboarding_completed === false &&
    location.pathname !== '/onboarding' &&
    !location.pathname.startsWith('/settings')
  ) {
    return <Navigate to={user && user.is_adult === false ? '/onboarding?step=age' : '/onboarding'} replace />;
  }
  return <Outlet />;
}

function AdminGuard() {
  const isStaff = useAuthStore((s) => s.user?.is_staff);
  if (!isStaff) return <Navigate to="/feed" replace />;
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
const FullScreenVideoFeed = lazy(() => import('@/pages/app/FullScreenVideoFeed'));
const CreateStudio = lazy(() => import('@/pages/app/CreateStudio'));
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
const OrderHistory = lazy(() => import('@/pages/app/OrderHistory'));
const OrderDetail = lazy(() => import('@/pages/app/OrderDetail'));
const CreatorStudio = lazy(() => import('@/pages/app/CreatorStudio'));
const DiscountCodes = lazy(() => import('@/pages/app/DiscountCodes'));

const DiscountCodeAnalyticsPage = lazy(() => import('@/pages/app/DiscountCodeAnalytics'));
const ShopDetail = lazy(() => import('@/pages/app/ShopDetail'));
const MealPlanDetail = lazy(() => import('@/pages/app/MealPlanDetail'));
const CreateMealPlan = lazy(() => import('@/pages/app/CreateMealPlan'));
const ProgrammeDetail = lazy(() => import('@/pages/app/ProgrammeDetail'));
const CreateProgramme = lazy(() => import('@/pages/app/CreateProgramme'));
const ProgrammeActivityFocus = lazy(() => import('@/pages/app/ProgrammeActivityFocus'));
const ProductDetail = lazy(() => import('@/pages/app/ProductDetail'));
const CreateProduct = lazy(() => import('@/pages/app/CreateProduct'));
const Sessions = lazy(() => import('@/pages/app/Sessions'));
const CreateSessionOffering = lazy(() => import('@/pages/app/CreateSessionOffering'));
const SessionDetail = lazy(() => import('@/pages/app/SessionDetail'));
const Messages = lazy(() => import('@/pages/app/Messages'));
const Communities = lazy(() => import('@/pages/app/Communities'));
const CommunityDetail = lazy(() => import('@/pages/app/CommunityDetail'));
const Wallet = lazy(() => import('@/pages/app/Wallet'));
const Notifications = lazy(() => import('@/pages/app/Notifications'));
const Profile = lazy(() => import('@/pages/app/Profile'));
const EditProfile = lazy(() => import('@/pages/app/EditProfile'));
const UserProfile = lazy(() => import('@/pages/app/UserProfile'));
const FollowListScreen = lazy(() => import('@/pages/app/FollowListScreen'));
const Settings = lazy(() => import('@/pages/app/Settings'));
const BuddiesPage = lazy(() => import('@/pages/app/BuddiesPage'));
const CreateGymPage = lazy(() => import('@/pages/app/CreateGymPage'));
const LiveRoom = lazy(() => import('@/pages/app/LiveRoom'));
const HealthInsights = lazy(() => import('@/pages/app/HealthInsights'));
const WorkoutForm = lazy(() => import('@/pages/app/WorkoutForm'));
const Verification = lazy(() => import('@/pages/app/Verification'));
const AnalyticsPage = lazy(() => import('@/pages/app/AnalyticsPage'));
const AdminDashboard = lazy(() => import('@/pages/app/AdminDashboard'));
const ModerationQueue = lazy(() => import('@/pages/app/ModerationQueue'));
const AdminVerification = lazy(() => import('@/pages/app/AdminVerification'));

const Terms = lazy(() => import('@/pages/legal/Terms'));
const Privacy = lazy(() => import('@/pages/legal/Privacy'));
const CommunityGuidelines = lazy(() => import('@/pages/legal/CommunityGuidelines'));
const CookiePolicy = lazy(() => import('@/pages/legal/CookiePolicy'));
const MedicalDisclaimer = lazy(() => import('@/pages/legal/MedicalDisclaimer'));
const SponsorshipPolicy = lazy(() => import('@/pages/legal/SponsorshipPolicy'));
const AdultContentPolicy = lazy(() => import('@/pages/legal/AdultContentPolicy'));
const Help = lazy(() => import('@/pages/legal/Help'));

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
  { path: '/medical-disclaimer', element: <SWrapper><MedicalDisclaimer /></SWrapper> },
  { path: '/sponsorship-policy', element: <SWrapper><SponsorshipPolicy /></SWrapper> },
  { path: '/adult-content-policy', element: <SWrapper><AdultContentPolicy /></SWrapper> },
  { path: '/help', element: <SWrapper><Help /></SWrapper> },
  {
    element: <AuthGuard />,
    children: [
      {
        element: <AppShell />,
        children: [
          { path: '/feed', element: <SWrapper><Feed /></SWrapper> },
          { path: '/feed/following', element: <SWrapper><Feed /></SWrapper> },
          { path: '/feed/bud-press', element: <SWrapper><Feed /></SWrapper> },
          { path: '/feed/meals', element: <SWrapper><Feed /></SWrapper> },
          { path: '/feed/progress', element: <SWrapper><Feed /></SWrapper> },
          { path: '/feed/communities', element: <SWrapper><Feed /></SWrapper> },
          { path: '/create', element: <SWrapper><CreateStudio /></SWrapper> },
          { path: '/videos', element: <SWrapper><FullScreenVideoFeed /></SWrapper> },
          { path: '/discover', element: <SWrapper><Discover /></SWrapper> },
          { path: '/lives', element: <SWrapper><Lives /></SWrapper> },
          { path: '/lives/:category', element: <SWrapper><Lives /></SWrapper> },
          { path: '/gyms', element: <SWrapper><Gyms /></SWrapper> },
          { path: '/gyms/create', element: <SWrapper><CreateGymPage /></SWrapper> },
          { path: '/gyms/:slug', element: <SWrapper><GymDetail /></SWrapper> },
          { path: '/trainers', element: <SWrapper><Trainers /></SWrapper> },
          { path: '/trainers/:slug', element: <SWrapper><TrainerProfile /></SWrapper> },
          { path: '/marketplace', element: <SWrapper><Marketplace /></SWrapper> },
          { path: '/marketplace/creator', element: <SWrapper><CreatorStudio /></SWrapper> },
          { path: '/marketplace/creator/discount-codes', element: <SWrapper><DiscountCodes /></SWrapper> },

          { path: '/marketplace/creator/discount-codes/:codeId/analytics', element: <SWrapper><DiscountCodeAnalyticsPage /></SWrapper> },
          { path: '/marketplace/cart', element: <SWrapper><CartPage /></SWrapper> },
          { path: '/marketplace/orders', element: <SWrapper><OrderHistory /></SWrapper> },
          { path: '/marketplace/orders/:orderId', element: <SWrapper><OrderDetail /></SWrapper> },
          { path: '/marketplace/events/create', element: <SWrapper><CreateEvent /></SWrapper> },
          { path: '/marketplace/events/my-tickets', element: <SWrapper><MyEventTickets /></SWrapper> },
          { path: '/marketplace/events/:eventId', element: <SWrapper><EventDetail /></SWrapper> },
          { path: '/marketplace/meal-plans/create', element: <SWrapper><CreateMealPlan /></SWrapper> },
          { path: '/marketplace/meal-plans/:planId', element: <SWrapper><MealPlanDetail /></SWrapper> },
          { path: '/marketplace/programmes/create', element: <SWrapper><CreateProgramme /></SWrapper> },
          { path: '/marketplace/programmes/:programmeId', element: <SWrapper><ProgrammeDetail /></SWrapper> },
          { path: '/marketplace/programmes/:programmeId/activity/:weekKey/:dayKey/:activityIndex', element: <SWrapper><ProgrammeActivityFocus /></SWrapper> },
          { path: '/marketplace/products/create', element: <SWrapper><CreateProduct /></SWrapper> },
          { path: '/marketplace/products/:productId', element: <SWrapper><ProductDetail /></SWrapper> },
          { path: '/sessions', element: <SWrapper><Sessions /></SWrapper> },
          { path: '/sessions/offering', element: <SWrapper><CreateSessionOffering /></SWrapper> },
          { path: '/sessions/:bookingId', element: <SWrapper><SessionDetail /></SWrapper> },
          { path: '/messages', element: <SWrapper><Messages /></SWrapper> },
          { path: '/messages/:conversationId', element: <SWrapper><Messages /></SWrapper> },
          { path: '/communities', element: <SWrapper><Communities /></SWrapper> },
          { path: '/communities/:communityId', element: <SWrapper><CommunityDetail /></SWrapper> },
          { path: '/wallet', element: <SWrapper><Wallet /></SWrapper> },
          { path: '/notifications', element: <SWrapper><Notifications /></SWrapper> },
          { path: '/profile', element: <SWrapper><Profile /></SWrapper> },
          { path: '/profile/edit', element: <SWrapper><EditProfile /></SWrapper> },
          { path: '/buddies', element: <SWrapper><BuddiesPage /></SWrapper> },
          { path: '/settings', element: <SWrapper><Settings /></SWrapper> },
          { path: '/health-insights', element: <SWrapper><HealthInsights /></SWrapper> },
          { path: '/workout-form', element: <SWrapper><WorkoutForm /></SWrapper> },
          { path: '/verification', element: <SWrapper><Verification /></SWrapper> },
          { path: '/analytics', element: <SWrapper><AnalyticsPage /></SWrapper> },
        ],
      },
      { path: '/live/:liveId', element: <SWrapper><LiveRoom /></SWrapper> },
      { path: '/shops/:handle', element: <SWrapper><ShopDetail /></SWrapper> },
      { path: '/:username/following', element: <SWrapper><FollowListScreen /></SWrapper> },
      { path: '/:username/followers', element: <SWrapper><FollowListScreen /></SWrapper> },
      { path: '/:username', element: <SWrapper><UserProfile /></SWrapper> },
      {
        element: <AdminGuard />,
        children: [
          {
            element: <AdminLayout />,
            children: [
              { path: '/admin', element: <SWrapper><AdminDashboard /></SWrapper> },
              { path: '/admin/moderation', element: <SWrapper><ModerationQueue /></SWrapper> },
              { path: '/admin/verification', element: <SWrapper><AdminVerification /></SWrapper> },
            ],
          },
        ],
      },
    ],
  },
  { path: '*', element: <Navigate to="/" replace /> },
]);
