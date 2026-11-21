import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'core/auth/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/verify_registration_otp_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'features/auth/verify_age_screen.dart';
import 'features/auth/totp_setup_screen.dart';
import 'features/auth/totp_challenge_screen.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/profile/edit_profile_screen.dart';
import 'features/profile/buddy_list_screen.dart';
import 'features/buddies/buddy_nearby_screen.dart';
import 'features/buddies/buddy_find_profile_screen.dart';
import 'features/buddies/buddy_messages_screen.dart';
import 'features/profile/user_profile_screen.dart';
import 'features/auth/activate_account_screen.dart';
import 'features/auth/staff_invite_screen.dart';
import 'features/discover/discover_people_screen.dart';
import 'features/feed/screens/feed_screen.dart';
import 'features/feed/screens/bud_press_feed_screen.dart';
import 'features/feed/screens/post_detail_screen.dart';
import 'features/feed/screens/post_composer_screen.dart';
import 'features/feed/screens/health_insights_screen.dart';
import 'features/feed/screens/workout_form_screen.dart';
import 'features/info/screens/about_screen.dart';
import 'features/info/screens/careers_screen.dart';
import 'features/info/screens/contact_screen.dart';
import 'features/info/screens/help_centre_screen.dart';
import 'features/info/screens/services_screen.dart';
import 'features/info/screens/cookie_policy_screen.dart';
import 'features/info/screens/community_guidelines_screen.dart';
import 'features/info/screens/medical_disclaimer_screen.dart';
import 'features/info/screens/privacy_policy_screen.dart';
import 'features/info/screens/sponsorship_policy_screen.dart';
import 'features/info/screens/terms_screen.dart';
import 'features/gym/screens/gym_list_screen.dart';
import 'features/gym/screens/gym_detail_screen.dart';
import 'features/gym/screens/create_gym_screen.dart';
import 'features/gym/screens/gym_manage_screen.dart';
import 'features/gym/screens/coach_invite_respond_screen.dart';
import 'features/gym/screens/my_gyms_screen.dart';
import 'features/live/screens/live_browser_screen.dart';
import 'features/live/screens/live_room_screen.dart';
import 'features/live/screens/create_live_screen.dart';
import 'features/live/screens/random_drop_screen.dart';
import 'features/marketplace/screens/marketplace_screen.dart';
import 'features/marketplace/screens/meal_plan_detail_screen.dart';
import 'features/marketplace/screens/programme_detail_screen.dart';
import 'features/marketplace/screens/create_product_screen.dart';
import 'features/marketplace/screens/product_detail_screen.dart';
import 'features/marketplace/screens/event_detail_screen.dart';
import 'features/marketplace/screens/event_tickets_screen.dart';
import 'features/marketplace/screens/cart_screen.dart';
import 'features/marketplace/screens/orders_screen.dart';
import 'features/marketplace/screens/order_detail_screen.dart';
import 'features/marketplace/screens/creator_studio_screen.dart';
import 'features/marketplace/screens/discount_codes_screen.dart';
import 'features/marketplace/screens/create_meal_plan_screen.dart';
import 'features/marketplace/screens/create_programme_screen.dart';
import 'features/marketplace/screens/create_event_screen.dart';
import 'features/marketplace/screens/my_shops_screen.dart';
import 'features/marketplace/screens/shop_detail_screen.dart';
import 'features/marketplace/screens/shop_manage_screen.dart';
import 'features/marketplace/screens/create_shop_screen.dart';
import 'features/marketplace/screens/programme_activity_focus_screen.dart';
import 'features/wallet/screens/wallet_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/verification/screens/verification_screen.dart';
import 'features/verification/screens/category_application_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/settings/screens/account_screen.dart';
import 'features/settings/screens/security_screen.dart';
import 'features/settings/screens/privacy_screen.dart';
import 'features/settings/screens/data_screen.dart';
import 'features/settings/screens/family_screen.dart';
import 'features/settings/screens/family_accept_screen.dart';
import 'features/settings/screens/appearance_screen.dart';
import 'features/settings/screens/alarm_center_screen.dart';
import 'features/settings/screens/activity_log_screen.dart';
import 'features/settings/screens/billing_screen.dart';
import 'features/settings/screens/content_prefs_screen.dart';
import 'features/settings/screens/blocked_screen.dart';
import 'features/settings/screens/notification_prefs_screen.dart';
import 'features/settings/screens/adult_content_policy_screen.dart';
import 'features/analytics/screens/analytics_screen.dart';
import 'features/analytics/screens/activities_screen.dart';
import 'features/analytics/screens/gps_tracker_screen.dart';
import 'features/countdowns/screens/countdowns_screen.dart';
import 'features/routines/screens/routines_screen.dart';
import 'features/routines/screens/routine_editor_screen.dart';
import 'features/feed/screens/creator_insights_screen.dart';
import 'features/sessions/screens/trainer_list_screen.dart';
import 'features/sessions/screens/trainer_profile_screen.dart';
import 'features/sessions/screens/booking_screen.dart';
import 'features/sessions/screens/my_sessions_screen.dart';
import 'features/sessions/screens/schedule_screen.dart';
import 'features/sessions/screens/availability_screen.dart';
import 'features/sessions/screens/programme_weeks_screen.dart';
import 'features/messaging/screens/conversation_list_screen.dart';
import 'features/messaging/screens/story_create_screen.dart';
import 'features/messaging/screens/chat_screen.dart';
import 'features/community/screens/communities_screen.dart';
import 'features/community/screens/community_detail_screen.dart';
import 'features/marketplace/screens/checkout_screen.dart';
import 'features/marketplace/screens/delivery_personnel_screen.dart';
import 'features/marketplace/screens/manage_stations_screen.dart';
import 'features/marketplace/screens/station_application_screen.dart';
import 'features/marketplace/screens/courier_dashboard_screen.dart';
import 'features/marketplace/screens/event_organiser_screen.dart';
import 'features/admin/screens/admin_console_screen.dart';
import 'features/admin/screens/admin_users_screen.dart';
import 'features/admin/screens/admin_shops_screen.dart';
import 'features/admin/screens/admin_orders_screen.dart';
import 'features/admin/screens/admin_gyms_screen.dart';
import 'features/admin/screens/admin_communities_screen.dart';
import 'features/admin/screens/admin_stations_screen.dart';
import 'features/admin/screens/admin_delivery_screen.dart';
import 'features/admin/screens/admin_wallet_screen.dart';
import 'features/admin/screens/admin_moderation_screen.dart';
import 'features/admin/screens/admin_approvals_screen.dart';
import 'features/admin/screens/admin_audit_screen.dart';
import 'features/admin/screens/admin_email_screen.dart';
import 'features/admin/screens/admin_staff_screen.dart';
import 'features/admin/screens/admin_verification_screen.dart';
import 'features/admin/screens/admin_analytics_overview_screen.dart';
import 'features/admin/screens/admin_analytics_trends_screen.dart';
import 'features/admin/screens/admin_analytics_trending_screen.dart';
import 'features/admin/screens/admin_analytics_ai_quality_screen.dart';
import 'features/admin/screens/admin_analytics_predictive_screen.dart';
import 'features/settings/screens/moderation_screen.dart';
import 'features/settings/widgets/standing_banner.dart';
import 'shared/navigation/app_nav.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _rootNavigatorKey = rootNavigatorKey;
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Routes that may be reached without a signed-in session.
const publicRoutes = <String>[
  '/login',
  '/signup',
  '/verify-registration-otp',
  '/verify-age',
  '/forgot-password',
  '/reset-password',
  '/totp-setup',
  '/totp-challenge',
  '/onboarding',
  '/terms',
  '/privacy',
  '/cookie-policy',
  '/community-guidelines',
  '/medical-disclaimer',
  '/sponsorship-policy',
  '/adult-content-policy',
];

/// Where navigation to [location] should actually land, or null to allow it.
///
/// Split out of `buildRouter` so the rules can be tested as a pure function.
/// go_router's `redirect` closes over the router and a `GoRouterState`, and
/// asserting on it meant constructing a whole app -- which is how the admin
/// gate below went missing in the first place.
String? redirectFor(String location, AuthState authState) {
  final isAuthenticated = authState.isAuthenticated;

  if (authState.isLoading) return null;

  final isPublicFlow =
      location.startsWith('/staff-invite/') ||
      location.startsWith('/settings/family/accept');
  if (!isAuthenticated && !publicRoutes.contains(location) && !isPublicFlow) {
    return '/login';
  }

  // Required-once onboarding: incomplete accounts (new Google/Apple sign-ups,
  // or fresh registrations) are routed through the onboarding pipeline --
  // consent first, then preferences -- before anything else. Mirrors the web
  // router guard. profile can be null right after a cold start before it
  // loads; skip the gate until it arrives.
  final profile = authState.profile;
  if (isAuthenticated &&
      profile != null &&
      !profile.onboardingCompleted &&
      location != '/onboarding') {
    return '/onboarding';
  }

  if (isAuthenticated &&
      publicRoutes.contains(location) &&
      location != '/onboarding') {
    return '/feed';
  }

  // Admin console gate. `AdminConsoleScreen` refuses to render for a non-staff
  // user, but that only protects the index: the console is a set of
  // deep-linkable routes, and a number of the screens behind it never re-check
  // `isStaff` in build. Deep-linking straight to /admin/wallet therefore
  // rendered the screen for anyone signed in and relied on the server's 403 to
  // be the thing that stopped them. Mirrors the web `AdminGuard`, which wraps
  // every /admin/* route.
  //
  // `startsWith('/admin')` would also swallow a future `/administration`, so
  // the prefix has to end at a segment boundary.
  final isAdminPath = location == '/admin' || location.startsWith('/admin/');
  if (isAdminPath && !(authState.user?.isStaff ?? false)) {
    return '/feed';
  }

  return null;
}

GoRouter buildRouter(WidgetRef ref, AuthState authState) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/feed',
    redirect: (context, state) => redirectFor(state.matchedLocation, authState),
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/verify-registration-otp',
        builder: (_, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyRegistrationOtpScreen(
            registrationToken: token,
            email: email,
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
      ),
      GoRoute(path: '/verify-age', builder: (_, _) => const VerifyAgeScreen()),
      GoRoute(path: '/totp-setup', builder: (_, _) => const TotpSetupScreen()),
      GoRoute(
        path: '/totp-challenge',
        builder: (_, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return TotpChallengeScreen(tempToken: token);
        },
      ),
      GoRoute(
        path: '/staff-invite/:token',
        builder: (_, state) =>
            StaffInviteScreen(token: state.pathParameters['token'] ?? ''),
      ),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/terms', builder: (_, _) => const TermsOfServiceScreen()),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyPolicyScreen()),
      GoRoute(
        path: '/cookie-policy',
        builder: (_, _) => const CookiePolicyScreen(),
      ),
      GoRoute(
        path: '/community-guidelines',
        builder: (_, _) => const CommunityGuidelinesScreen(),
      ),
      GoRoute(
        path: '/medical-disclaimer',
        builder: (_, _) => const MedicalDisclaimerScreen(),
      ),
      GoRoute(
        path: '/sponsorship-policy',
        builder: (_, _) => const SponsorshipPolicyScreen(),
      ),
      GoRoute(
        path: '/adult-content-policy',
        builder: (_, _) => const AdultContentPolicyScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, _, child) => _AppShell(child: child),
        routes: [
          // Web path aliases — keep deep links from the site working in-app.
          GoRoute(path: '/app/analytics', redirect: (_, _) => '/analytics'),
          GoRoute(
            path: '/live/:liveId',
            redirect: (_, state) =>
                '/lives/${state.pathParameters['liveId'] ?? ''}',
          ),
          GoRoute(
            path: '/shops/:slug',
            redirect: (_, state) =>
                '/marketplace/shops/${state.pathParameters['slug'] ?? ''}',
          ),
          GoRoute(path: '/buddies/find', redirect: (_, _) => '/buddies/nearby'),
          GoRoute(path: '/creator-insights', redirect: (_, _) => '/insights'),
          GoRoute(
            path: '/marketplace/creator',
            redirect: (_, _) => '/marketplace/creator-studio',
          ),
          GoRoute(
            path: '/marketplace/events/my-tickets',
            redirect: (_, _) => '/marketplace/tickets',
          ),
          GoRoute(
            path: '/sessions/offering',
            redirect: (_, _) => '/sessions/availability',
          ),
          GoRoute(
            path: '/verification/categories',
            redirect: (_, _) => '/verification/apply',
          ),
          GoRoute(
            path: '/marketplace/delivery/register',
            redirect: (_, _) => '/marketplace/delivery-personnel',
          ),
          GoRoute(path: '/admin/email', redirect: (_, _) => '/admin/emails'),
          GoRoute(
            path: '/admin/staff',
            redirect: (_, _) => '/admin/staff-roles',
          ),
          GoRoute(
            path: '/admin/appeals',
            redirect: (_, _) => '/admin/moderation',
          ),
          GoRoute(path: '/admin/overview', redirect: (_, _) => '/admin'),
          GoRoute(
            path: '/admin/models',
            redirect: (_, _) => '/admin/analytics',
          ),
          GoRoute(
            path: '/profile/edit',
            builder: (_, state) {
              final profile = authState.profile;
              if (profile == null) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return EditProfileScreen(profile: profile);
            },
          ),
          GoRoute(
            path: '/profile/:username/buddies',
            builder: (_, state) => BuddyListScreen(
              username: state.pathParameters['username'] ?? 'me',
            ),
          ),
          GoRoute(
            path: '/profile/:username/followers',
            builder: (_, state) => BuddyListScreen(
              username: state.pathParameters['username'] ?? 'me',
              initialTab: 'followers',
            ),
          ),
          GoRoute(
            path: '/profile/:username/following',
            builder: (_, state) => BuddyListScreen(
              username: state.pathParameters['username'] ?? 'me',
              initialTab: 'following',
            ),
          ),
          GoRoute(
            path: '/:username/following',
            builder: (_, state) {
              final username = state.pathParameters['username'] ?? 'me';
              return BuddyListScreen(
                username: username,
                initialTab: 'following',
              );
            },
          ),
          GoRoute(
            path: '/:username/followers',
            builder: (_, state) {
              final username = state.pathParameters['username'] ?? 'me';
              return BuddyListScreen(
                username: username,
                initialTab: 'followers',
              );
            },
          ),
          GoRoute(
            path: '/activate',
            builder: (_, _) => const ActivateAccountScreen(),
          ),
          GoRoute(path: '/help', builder: (_, _) => const HelpCentreScreen()),
          GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),
          GoRoute(path: '/careers', builder: (_, _) => const CareersScreen()),
          GoRoute(path: '/contact', builder: (_, _) => const ContactScreen()),
          GoRoute(path: '/services', builder: (_, _) => const ServicesScreen()),
          GoRoute(
            path: '/activities',
            builder: (_, _) => const ActivitiesScreen(),
          ),
          GoRoute(
            path: '/activities/new',
            builder: (_, _) => const GpsTrackerScreen(),
          ),
          GoRoute(path: '/feed', builder: (_, _) => const FeedScreen()),
          GoRoute(
            path: '/create',
            builder: (_, _) => const PostComposerScreen(),
          ),
          GoRoute(
            path: '/videos',
            builder: (_, state) => BudPressFeedScreen(
              initialPostId: state.uri.queryParameters['start'],
            ),
          ),
          GoRoute(
            path: '/feed/following',
            builder: (_, _) => const FeedScreen(initialTab: 'following'),
          ),
          GoRoute(path: '/feed/videos', redirect: (_, _) => '/videos'),
          GoRoute(
            path: '/feed/bud-press',
            builder: (_, state) => BudPressFeedScreen(
              initialPostId: state.uri.queryParameters['post'],
            ),
          ),
          GoRoute(
            path: '/feed/communities',
            builder: (_, _) => const FeedScreen(initialTab: 'communities'),
          ),
          GoRoute(
            path: '/discover',
            builder: (_, _) => const DiscoverPeopleScreen(),
          ),
          GoRoute(path: '/lives', builder: (_, _) => const LiveBrowserScreen()),
          GoRoute(path: '/gyms', builder: (_, _) => const GymListScreen()),
          GoRoute(
            path: '/messages',
            builder: (_, _) => const ConversationListScreen(),
          ),
          GoRoute(
            path: '/messages/story/create',
            builder: (_, _) => const StoryCreateScreen(),
          ),
          GoRoute(
            path: '/messages/:conversationId',
            // No parentNavigatorKey — inherit the shell's key. Pointing at
            // the root navigator from inside a ShellRoute violates go_router's
            // sub-route/parent key rule.
            builder: (_, state) {
              final conversationId =
                  state.pathParameters['conversationId'] ?? '';
              // ?call=audio|video auto-starts the call after the thread
              // loads — the Calls tab's Rejoin pill lands here.
              final autoCall = state.uri.queryParameters['call'];
              return ChatScreen(
                conversationId: conversationId,
                autoStartCall: (autoCall == 'audio' || autoCall == 'video')
                    ? autoCall
                    : null,
              );
            },
          ),
          GoRoute(
            path: '/communities',
            builder: (_, _) => const CommunitiesScreen(),
          ),
          GoRoute(
            path: '/communities/:communityId',
            builder: (_, state) {
              final communityId = state.pathParameters['communityId'] ?? '';
              return CommunityDetailScreen(communityId: communityId);
            },
          ),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
          GoRoute(
            path: '/buddies',
            builder: (_, _) => const BuddyListScreen(username: 'me'),
          ),
          GoRoute(
            path: '/buddies/nearby',
            builder: (_, _) => const BuddyNearbyScreen(),
          ),
          // Buddy search card on its own page, then the discovery threads it
          // can start. Declared before `/:username` so `find` is never read
          // as a username.
          GoRoute(
            path: '/buddies/find/:username',
            builder: (_, state) {
              final username = state.pathParameters['username'] ?? '';
              return BuddyFindProfileScreen(username: username);
            },
          ),
          GoRoute(
            path: '/buddies/messages',
            builder: (_, _) => const BuddyMessagesScreen(),
          ),
          GoRoute(
            path: '/buddies/messages/:conversationId',
            // Same key-inheritance rule as /messages/:conversationId.
            builder: (_, state) {
              final conversationId =
                  state.pathParameters['conversationId'] ?? '';
              return ChatScreen(
                conversationId: conversationId,
                fromBuddyMessages: true,
              );
            },
          ),
          GoRoute(
            path: '/:username',
            builder: (_, state) {
              final username = state.pathParameters['username'] ?? '';
              return UserProfileScreen(username: username);
            },
          ),
          GoRoute(
            path: '/feed/post',
            builder: (_, _) => const PostComposerScreen(),
          ),
          GoRoute(
            path: '/feed/:postId',
            builder: (_, state) {
              final postId = state.pathParameters['postId'] ?? '';
              return PostDetailScreen(postId: postId);
            },
          ),
          GoRoute(
            path: '/health-insights',
            builder: (_, _) => const HealthInsightsScreen(),
          ),
          GoRoute(
            path: '/workout-form',
            builder: (_, _) => const WorkoutFormScreen(),
          ),
          // Gym routes
          GoRoute(path: '/my-gyms', builder: (_, _) => const MyGymsScreen()),
          GoRoute(
            path: '/gyms/create',
            builder: (_, _) => const CreateGymScreen(),
          ),
          // Declared BEFORE `/gyms/:slug` so `manage` is never read as a slug.
          // Without a real route here, the "Manage" button on a gym detail page sent
          // owners into their own profile — the same dead link the web had.
          GoRoute(
            path: '/gyms/:slug/coaches/:coachId/respond',
            builder: (_, state) {
              final slug = state.pathParameters['slug'] ?? '';
              final coachId = state.pathParameters['coachId'] ?? '';
              return CoachInviteRespondScreen(slug: slug, coachId: coachId);
            },
          ),
          GoRoute(
            path: '/gyms/:slug/manage',
            builder: (_, state) {
              final slug = state.pathParameters['slug'] ?? '';
              return GymManageScreen(slug: slug);
            },
          ),
          GoRoute(
            path: '/gyms/:slug',
            builder: (_, state) {
              final slug = state.pathParameters['slug'] ?? '';
              return GymDetailScreen(slug: slug);
            },
          ),
          // Live routes
          GoRoute(
            path: '/lives/create',
            builder: (_, _) => const CreateLiveScreen(),
          ),
          GoRoute(
            path: '/lives/random-drop',
            builder: (_, _) => const RandomDropScreen(),
          ),
          GoRoute(
            path: '/lives/:liveId',
            builder: (_, state) {
              final liveId = state.pathParameters['liveId'] ?? '';
              return LiveRoomScreen(liveId: liveId);
            },
          ),
          // Marketplace routes
          GoRoute(
            path: '/marketplace',
            builder: (_, _) => const MarketplaceScreen(),
          ),
          GoRoute(
            path: '/marketplace/meal-plans/:planId',
            builder: (_, state) {
              final planId = state.pathParameters['planId'] ?? '';
              return MealPlanDetailScreen(planId: planId);
            },
          ),
          GoRoute(
            path: '/marketplace/programmes/:programmeId',
            builder: (_, state) {
              final programmeId = state.pathParameters['programmeId'] ?? '';
              return ProgrammeDetailScreen(programmeId: programmeId);
            },
          ),
          // Create route must precede the parameterized :productId route so
          // go_router does not treat 'create' as an ID.
          GoRoute(
            path: '/marketplace/products/create',
            builder: (_, state) {
              final editId = state.uri.queryParameters['edit'];
              return CreateProductScreen(
                editProductId: (editId != null && editId.isNotEmpty)
                    ? editId
                    : null,
              );
            },
          ),
          GoRoute(
            path: '/marketplace/products/:productId',
            builder: (_, state) {
              final productId = state.pathParameters['productId'] ?? '';
              return ProductDetailScreen(productId: productId);
            },
          ),
          // Create and the organiser dashboard must both precede
          // `/marketplace/events/:eventId`, or go_router reads `create` as an event
          // id — the same ordering rule the product routes above already follow.
          GoRoute(
            path: '/marketplace/events',
            builder: (_, _) => const EventOrganiserScreen(),
          ),
          GoRoute(
            path: '/marketplace/events/create',
            builder: (_, state) {
              final shopHandle = state.uri.queryParameters['shop'];
              return CreateEventScreen(shopHandle: shopHandle);
            },
          ),
          GoRoute(
            path: '/marketplace/events/:eventId',
            builder: (_, state) {
              final eventId = state.pathParameters['eventId'] ?? '';
              return EventDetailScreen(eventId: eventId);
            },
          ),
          GoRoute(
            path: '/marketplace/tickets',
            builder: (_, _) => const EventTicketsScreen(),
          ),
          GoRoute(
            path: '/marketplace/cart',
            builder: (_, _) => const CartScreen(),
          ),
          // Checkout is its own screen so the flow is deep-linkable and the payment /
          // station / address choices are never squeezed into a bottom sheet.
          GoRoute(
            path: '/marketplace/checkout',
            builder: (_, _) => const CheckoutScreen(),
          ),
          // Fulfillment logistics: register as a courier, run your deliveries, apply
          // to become a pickup station, and manage the stations you own.
          GoRoute(
            path: '/marketplace/delivery',
            builder: (_, _) => const CourierDashboardScreen(),
          ),
          GoRoute(
            path: '/marketplace/delivery-personnel',
            builder: (_, _) => const DeliveryPersonnelScreen(),
          ),
          GoRoute(
            path: '/marketplace/stations/apply',
            builder: (_, _) => const StationApplicationScreen(),
          ),
          GoRoute(
            path: '/marketplace/stations',
            builder: (_, _) => const ManageStationsScreen(),
          ),
          GoRoute(
            path: '/marketplace/orders',
            builder: (_, _) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/marketplace/orders/:orderId',
            builder: (_, state) =>
                OrderDetailScreen(orderId: state.pathParameters['orderId']!),
          ),
          GoRoute(
            path: '/marketplace/creator-studio',
            builder: (_, _) => const CreatorStudioScreen(),
          ),
          GoRoute(
            path: '/marketplace/creator/discount-codes',
            builder: (_, _) => const DiscountCodesScreen(),
          ),
          GoRoute(
            path: '/marketplace/meal-plans/create',
            builder: (_, state) {
              final shopHandle = state.uri.queryParameters['shop'];
              final editId = state.uri.queryParameters['edit'];
              return CreateMealPlanScreen(
                shopHandle: shopHandle,
                editId: (editId != null && editId.isNotEmpty) ? editId : null,
              );
            },
          ),
          GoRoute(
            path: '/marketplace/programmes/create',
            builder: (_, state) {
              final shopHandle = state.uri.queryParameters['shop'];
              final editId = state.uri.queryParameters['edit'];
              return CreateProgrammeScreen(
                shopHandle: shopHandle,
                editId: (editId != null && editId.isNotEmpty) ? editId : null,
              );
            },
          ),
          // `/marketplace/events/create` is declared above, next to the organiser
          // dashboard, so both precede `/marketplace/events/:eventId`.
          // Shop routes
          GoRoute(
            path: '/marketplace/shops',
            builder: (_, state) => MyShopsScreen(
              initialTab: state.uri.queryParameters['tab'] ?? 'shops',
            ),
          ),
          GoRoute(
            path: '/marketplace/shops/create',
            builder: (_, _) => const CreateShopScreen(),
          ),
          // Shop manage — owner/manager console scoped to one shop; precedes
          // the public shop detail route so the 4-segment path always wins.
          GoRoute(
            path: '/marketplace/shops/:handle/manage',
            builder: (_, state) => ShopManageScreen(
              handle: state.pathParameters['handle'] ?? '',
              initialTab: state.uri.queryParameters['tab'],
            ),
          ),
          GoRoute(
            path: '/marketplace/shops/:handle',
            builder: (_, state) {
              final handle = state.pathParameters['handle'] ?? '';
              return ShopDetailScreen(handle: handle);
            },
          ),
          // Programme activity focus
          GoRoute(
            path: '/marketplace/programmes/:programmeId/activity',
            builder: (_, state) {
              final programmeId = state.pathParameters['programmeId'] ?? '';
              final weekIndex =
                  int.tryParse(state.uri.queryParameters['week'] ?? '0') ?? 0;
              final day = state.uri.queryParameters['day'] ?? 'Monday';
              final activityIndex =
                  int.tryParse(state.uri.queryParameters['activity'] ?? '0') ??
                  0;
              return ProgrammeActivityFocusScreen(
                programmeId: programmeId,
                weekIndex: weekIndex,
                day: day,
                activityIndex: activityIndex,
              );
            },
          ),
          // Wallet routes
          GoRoute(path: '/wallet', builder: (_, _) => const WalletScreen()),
          // Analytics
          GoRoute(
            path: '/analytics',
            builder: (_, _) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/countdowns',
            builder: (_, _) => const CountdownsScreen(),
          ),
          GoRoute(path: '/routines', builder: (_, _) => const RoutinesScreen()),
          GoRoute(
            path: '/routines/create',
            builder: (_, _) => const RoutineEditorScreen(),
          ),
          GoRoute(
            path: '/routines/:routineId/edit',
            builder: (_, state) => RoutineEditorScreen(
              routineId: state.pathParameters['routineId'],
            ),
          ),
          GoRoute(
            path: '/insights',
            builder: (_, _) => const CreatorInsightsScreen(),
          ),
          // Notifications
          GoRoute(
            path: '/notifications',
            builder: (_, _) => const NotificationsScreen(),
          ),
          // Settings sub-screens (hub lives in the shell at /settings)
          GoRoute(
            path: '/settings/account',
            builder: (_, _) => const AccountScreen(),
          ),
          GoRoute(
            path: '/settings/security',
            builder: (_, _) => const SecurityScreen(),
          ),
          GoRoute(
            path: '/settings/privacy',
            builder: (_, _) => const PrivacyScreen(),
          ),
          GoRoute(
            path: '/settings/notifications',
            builder: (_, _) => const NotificationPrefsScreen(),
          ),
          GoRoute(
            path: '/settings/family',
            builder: (_, _) => const FamilyScreen(),
          ),
          GoRoute(
            path: '/settings/appearance',
            builder: (_, _) => const AppearanceScreen(),
          ),
          GoRoute(
            path: '/settings/alarms',
            builder: (_, _) => const AlarmCenterScreen(),
          ),
          GoRoute(
            path: '/settings/activity',
            builder: (_, _) => const ActivityLogScreen(),
          ),
          GoRoute(
            path: '/settings/billing',
            builder: (_, _) => const BillingScreen(),
          ),
          GoRoute(
            path: '/settings/content',
            builder: (_, _) => const ContentPrefsScreen(),
          ),
          GoRoute(
            path: '/settings/data',
            builder: (_, _) => const DataScreen(),
          ),
          GoRoute(
            path: '/settings/blocked',
            builder: (_, _) => const BlockedScreen(),
          ),
          GoRoute(
            path: '/notifications/preferences',
            builder: (_, _) => const NotificationPrefsScreen(),
          ),
          // Verification
          GoRoute(
            path: '/verification',
            builder: (_, _) => const VerificationScreen(),
          ),
          // Trainers
          GoRoute(
            path: '/trainers',
            builder: (_, _) => const TrainerListScreen(),
          ),
          GoRoute(
            path: '/trainers/:username',
            builder: (_, state) {
              final username = state.pathParameters['username'] ?? '';
              return TrainerProfileScreen(username: username);
            },
          ),
          GoRoute(
            path: '/book/:username',
            builder: (_, state) {
              final username = state.pathParameters['username'] ?? '';
              return BookingScreen(trainerUsername: username);
            },
          ),
          // Sessions
          GoRoute(path: '/schedule', builder: (_, _) => const ScheduleScreen()),
          GoRoute(
            path: '/sessions',
            builder: (_, _) => const MySessionsScreen(),
          ),
          GoRoute(
            path: '/sessions/availability',
            builder: (_, _) => const AvailabilityScreen(),
          ),
          GoRoute(
            path: '/my-enrollments',
            builder: (_, _) => const MyEnrollmentsScreen(),
          ),
          GoRoute(
            path: '/programmes/:programmeId/weeks',
            builder: (_, state) {
              final programmeId = state.pathParameters['programmeId'] ?? '';
              final title = state.uri.queryParameters['title'] ?? 'Programme';
              return ProgrammeWeeksScreen(
                programmeId: programmeId,
                programmeTitle: title,
              );
            },
          ),
          GoRoute(
            path: '/sessions/:bookingId',
            builder: (_, state) {
              final bookingId = state.pathParameters['bookingId'] ?? '';
              return SessionDetailScreen(bookingId: bookingId);
            },
          ),
          GoRoute(
            path: '/sessions/:bookingId/review',
            builder: (_, state) {
              final bookingId = state.pathParameters['bookingId'] ?? '';
              final trainerUsername =
                  state.uri.queryParameters['trainer'] ?? '';
              return SessionReviewScreen(
                bookingId: bookingId,
                trainerUsername: trainerUsername,
              );
            },
          ),
          // Admin console (staff only, gated on user.is_staff like the web AdminGuard).
          GoRoute(
            path: '/admin',
            builder: (_, _) => const AdminConsoleScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (_, _) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: '/admin/shops',
            builder: (_, _) => const AdminShopsScreen(),
          ),
          GoRoute(
            path: '/admin/orders',
            builder: (_, _) => const AdminOrdersScreen(),
          ),
          GoRoute(
            path: '/admin/gyms',
            builder: (_, _) => const AdminGymsScreen(),
          ),
          GoRoute(
            path: '/admin/communities',
            builder: (_, _) => const AdminCommunitiesScreen(),
          ),
          GoRoute(
            path: '/admin/stations',
            builder: (_, _) => const AdminStationsScreen(),
          ),
          GoRoute(
            path: '/admin/delivery',
            builder: (_, _) => const AdminDeliveryScreen(),
          ),
          GoRoute(
            path: '/admin/wallet',
            builder: (_, _) => const AdminWalletScreen(),
          ),
          // Governance: the two-person surface. Gated by the `/admin` redirect
          // above, not by per-screen checks: several of these screens do not test
          // `isStaff` themselves, so the guard has to live in the router to be
          // true for a deep link as well as for navigation from the console.
          GoRoute(
            path: '/admin/moderation',
            builder: (_, _) => const AdminModerationScreen(),
          ),
          GoRoute(
            path: '/admin/approvals',
            builder: (_, _) => const AdminApprovalsScreen(),
          ),
          GoRoute(
            path: '/admin/audit',
            builder: (_, _) => const AdminAuditScreen(),
          ),
          GoRoute(
            path: '/admin/emails',
            builder: (_, _) => const AdminEmailScreen(),
          ),
          GoRoute(
            path: '/admin/staff-roles',
            builder: (_, _) => const AdminStaffScreen(),
          ),
          // Verification review. Two-person: `review/` queues a decision and
          // applies nothing, `decide/` is the only call that writes a status, a
          // role or a gym verification.
          GoRoute(
            path: '/admin/verification',
            builder: (_, _) => const AdminVerificationScreen(),
          ),
          // Platform analytics. Five reports under `/portal/analytics/**`.
          // Staff-gated by the `/admin` redirect above; the analytics screens do
          // not each re-check `isStaff`.
          GoRoute(
            path: '/admin/analytics',
            builder: (_, _) => const AdminAnalyticsOverviewScreen(),
          ),
          GoRoute(
            path: '/admin/analytics/trends',
            builder: (_, _) => const AdminAnalyticsTrendsScreen(),
          ),
          GoRoute(
            path: '/admin/analytics/trending',
            builder: (_, _) => const AdminAnalyticsTrendingScreen(),
          ),
          GoRoute(
            path: '/admin/analytics/ai-quality',
            builder: (_, _) => const AdminAnalyticsAiQualityScreen(),
          ),
          GoRoute(
            path: '/admin/analytics/predictive',
            builder: (_, _) => const AdminAnalyticsPredictiveScreen(),
          ),
          // Applying for an elevated role. Not staff-gated — registration refuses
          // an elevated role now, so this is the only route to trainer or
          // practitioner and it belongs to the applicant, not the console.
          GoRoute(
            path: '/verification/apply',
            builder: (_, _) => const CategoryApplicationScreen(),
          ),
          // User-side moderation: their own record, appeals and commendations.
          // Not staff-gated — an action a user cannot see is one they cannot
          // appeal. `?action=` deep-links from the notification that raised the
          // action and opens the appeal form pre-filled.
          GoRoute(
            path: '/settings/family/accept',
            builder: (_, _) => const FamilyAcceptScreen(),
          ),
          GoRoute(
            path: '/settings/moderation',
            builder: (_, state) => ModerationScreen(
              appealActionId: state.uri.queryParameters['action'],
            ),
          ),
        ],
      ),
    ],
  );
}

class _AppShell extends StatefulWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  static const _tabletBreakpoint = 600.0;
  bool _railExtended = true;

  static const _railDestinations = <_NavDestination>[
    _NavDestination('/feed', LucideIcons.home, LucideIcons.home, 'Home'),
    _NavDestination(
      '/discover',
      LucideIcons.search,
      LucideIcons.search,
      'Discover',
    ),
    _NavDestination(
      '/buddies/find',
      LucideIcons.footprints,
      LucideIcons.footprints,
      'Find a Buddy',
    ),
    _NavDestination(
      '/analytics',
      LucideIcons.activity,
      LucideIcons.activity,
      'Analytics',
    ),
    _NavDestination(
      '/countdowns',
      LucideIcons.timer,
      LucideIcons.timer,
      'Countdowns',
    ),
    _NavDestination(
      '/activities',
      LucideIcons.map,
      LucideIcons.map,
      'Activities',
    ),
    _NavDestination('/lives', LucideIcons.radio, LucideIcons.radio, 'Lives'),
    _NavDestination(
      '/gyms',
      LucideIcons.dumbbell,
      LucideIcons.dumbbell,
      'Gyms',
    ),
    _NavDestination(
      '/trainers',
      LucideIcons.users,
      LucideIcons.users,
      'Trainers',
    ),
    _NavDestination(
      '/marketplace',
      LucideIcons.shoppingBag,
      LucideIcons.shoppingBag,
      'Marketplace',
    ),
    _NavDestination(
      '/routines',
      LucideIcons.calendarDays,
      LucideIcons.calendarDays,
      'Routines',
    ),
    _NavDestination(
      '/sessions',
      LucideIcons.calendar,
      LucideIcons.calendar,
      'Sessions',
    ),
    _NavDestination(
      '/messages',
      LucideIcons.messageCircle,
      LucideIcons.messageCircle,
      'Messages',
    ),
    _NavDestination(
      '/communities',
      LucideIcons.users,
      LucideIcons.users,
      'Communities',
    ),
    _NavDestination(
      '/wallet',
      LucideIcons.wallet,
      LucideIcons.wallet,
      'Wallet',
    ),
    _NavDestination('/profile', LucideIcons.user, LucideIcons.user, 'Profile'),
    _NavDestination(
      '/settings',
      LucideIcons.settings,
      LucideIcons.settings,
      'Settings',
    ),
  ];

  static const _phoneDestinations = <_NavDestination>[
    _NavDestination('/feed', LucideIcons.home, LucideIcons.home, 'Home'),
    _NavDestination(
      '/discover',
      LucideIcons.search,
      LucideIcons.search,
      'Find',
    ),
    _NavDestination('/lives', LucideIcons.radio, LucideIcons.radio, 'Live'),
    _NavDestination(
      '/activities',
      LucideIcons.map,
      LucideIcons.map,
      'Activities',
    ),
    _NavDestination('/profile', LucideIcons.user, LucideIcons.user, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= _tabletBreakpoint;

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _calculateIndex(context, _railDestinations),
              onDestinationSelected: (i) =>
                  context.go(_railDestinations[i].route),
              extended: _railExtended,
              leading: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _railExtended ? Icons.menu_open : Icons.menu,
                      color: BuddyColors.textSecondary,
                    ),
                    tooltip: _railExtended ? 'Collapse' : 'Expand',
                    onPressed: () =>
                        setState(() => _railExtended = !_railExtended),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Image(
                      image: AssetImage('assets/logo-dark.png'),
                      height: 28,
                      width: 28,
                    ),
                  ),
                ],
              ),
              backgroundColor: BuddyColors.black,
              indicatorColor: BuddyColors.green.withValues(alpha: 0.2),
              selectedIconTheme: const IconThemeData(color: BuddyColors.green),
              selectedLabelTextStyle: const TextStyle(
                color: BuddyColors.green,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: BuddyColors.textSecondary,
              ),
              destinations: _railDestinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            // The standing notice sits above the shell content on both
            // layouts. A suspension that only exists on a Settings sub-page is
            // one the user finds out about by failing to post, so it has to be
            // in front of them wherever they are.
            Expanded(
              child: Column(
                children: [
                  const StandingBanner(),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: appShellScaffoldKey,
      drawer: const AppNavDrawer(),
      body: Column(
        children: [
          const StandingBanner(),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: _WebBottomNav(
        destinations: _phoneDestinations,
        currentIndex: _calculateIndex(context, _phoneDestinations),
        onTap: (i) => context.go(_phoneDestinations[i].route),
      ),
    );
  }

  /// Top-level route prefixes known to the router. Any single-segment path
  /// outside this set is a username profile route (GoRoute `/:username`).
  static const _knownTopLevelRoutes = <String>{
    '/login',
    '/signup',
    '/verify-registration-otp',
    '/verify-age',
    '/forgot-password',
    '/reset-password',
    '/totp-setup',
    '/totp-challenge',
    '/onboarding',
    '/terms',
    '/privacy',
    '/cookie-policy',
    '/community-guidelines',
    '/medical-disclaimer',
    '/sponsorship-policy',
    '/adult-content-policy',
    '/feed',
    '/health-insights',
    '/workout-form',
    '/gyms',
    '/lives',
    '/marketplace',
    '/wallet',
    '/analytics',
    '/countdowns',
    '/routines',
    '/notifications',
    '/verification',
    '/trainers',
    '/book',
    '/sessions',
    '/my-enrollments',
    '/programmes',
    '/schedule',
    '/discover',
    '/messages',
    '/communities',
    '/profile',
    '/settings',
    '/buddies',
    '/admin',
  };

  bool _isUsernameRoute(String location) {
    if (!location.startsWith('/') || location == '/') return false;
    final segments = location.substring(1).split('/');
    if (segments.length != 1 || segments.first.isEmpty) return false;
    return !_knownTopLevelRoutes.contains('/${segments.first}');
  }

  int _calculateIndex(
    BuildContext context,
    List<_NavDestination> destinations,
  ) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < destinations.length; i++) {
      if (location.startsWith(destinations[i].route)) return i;
    }
    final profileIndex = destinations.indexWhere((d) => d.route == '/profile');
    if (profileIndex >= 0 &&
        (location.startsWith('/buddies') ||
            location.startsWith('/settings') ||
            location.startsWith('/messages') ||
            location.startsWith('/communities') ||
            _isUsernameRoute(location))) {
      return profileIndex;
    }
    final activitiesIndex = destinations.indexWhere(
      (d) => d.route == '/activities',
    );
    if (activitiesIndex >= 0 && location.startsWith('/gyms')) {
      return activitiesIndex;
    }
    return 0;
  }
}

class _NavDestination {
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavDestination(this.route, this.icon, this.selectedIcon, this.label);
}

/// Web-parity mobile bottom bar: five items with a raised green Live pill.
class _WebBottomNav extends StatelessWidget {
  final List<_NavDestination> destinations;
  final int currentIndex;
  final void Function(int) onTap;

  const _WebBottomNav({
    required this.destinations,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const center = 2;
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: BuddyColors.black,
        border: Border(top: BorderSide(color: BuddyColors.border, width: 0.7)),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Row(
            children: List.generate(destinations.length, (i) {
              final item = destinations[i];
              final active = i == currentIndex;
              if (i == center) {
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 36),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: active
                                ? BuddyColors.green
                                : BuddyColors.textSecondary,
                            fontSize: 10,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 21,
                        color: active
                            ? BuddyColors.green
                            : BuddyColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: active
                              ? BuddyColors.green
                              : BuddyColors.textSecondary,
                          fontSize: 10,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          Positioned(
            top: -20,
            child: GestureDetector(
              onTap: () => onTap(center),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: BuddyColors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BuddyColors.green.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  destinations[center].icon,
                  color: BuddyColors.black,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
