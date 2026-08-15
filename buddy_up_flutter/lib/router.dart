import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'features/profile/buddy_list_screen.dart';
import 'features/profile/user_profile_screen.dart';
import 'features/discover/discover_people_screen.dart';
import 'features/feed/screens/feed_screen.dart';
import 'features/feed/screens/post_detail_screen.dart';
import 'features/feed/screens/post_composer_screen.dart';
import 'features/feed/screens/health_insights_screen.dart';
import 'features/feed/screens/workout_form_screen.dart';
import 'features/gym/screens/gym_list_screen.dart';
import 'features/gym/screens/gym_detail_screen.dart';
import 'features/gym/screens/create_gym_screen.dart';
import 'features/live/screens/live_browser_screen.dart';
import 'features/live/screens/live_room_screen.dart';
import 'features/live/screens/create_live_screen.dart';
import 'features/live/screens/random_drop_screen.dart';
import 'features/marketplace/screens/marketplace_screen.dart';
import 'features/marketplace/screens/meal_plan_detail_screen.dart';
import 'features/marketplace/screens/programme_detail_screen.dart';
import 'features/marketplace/screens/product_detail_screen.dart';
import 'features/marketplace/screens/event_detail_screen.dart';
import 'features/marketplace/screens/event_tickets_screen.dart';
import 'features/marketplace/screens/cart_screen.dart';
import 'features/marketplace/screens/creator_studio_screen.dart';
import 'features/marketplace/screens/discount_codes_screen.dart';
import 'features/marketplace/screens/create_meal_plan_screen.dart';
import 'features/marketplace/screens/create_programme_screen.dart';
import 'features/marketplace/screens/create_event_screen.dart';
import 'features/marketplace/screens/my_shops_screen.dart';
import 'features/marketplace/screens/shop_detail_screen.dart';
import 'features/marketplace/screens/create_shop_screen.dart';
import 'features/marketplace/screens/programme_activity_focus_screen.dart';
import 'features/wallet/screens/wallet_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/verification/screens/verification_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/settings/screens/adult_content_policy_screen.dart';
import 'features/analytics/screens/analytics_screen.dart';
import 'features/sessions/screens/trainer_list_screen.dart';
import 'features/sessions/screens/trainer_profile_screen.dart';
import 'features/sessions/screens/booking_screen.dart';
import 'features/sessions/screens/my_sessions_screen.dart';
import 'features/sessions/screens/availability_screen.dart';
import 'features/sessions/screens/programme_weeks_screen.dart';
import 'features/messaging/screens/conversation_list_screen.dart';
import 'features/messaging/screens/chat_screen.dart';
import 'shared/navigation/app_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(WidgetRef ref, AuthState authState) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/feed',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final location = state.matchedLocation;

      if (isLoading) return null;

      final publicRoutes = [
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

      if (!isAuthenticated && !publicRoutes.contains(location)) {
        return '/login';
      }

      if (isAuthenticated &&
          publicRoutes.contains(location) &&
          location != '/onboarding') {
        return '/feed';
      }

      return null;
    },
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
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/terms',
        builder: (_, _) => _legalPage('Terms of Service'),
      ),
      GoRoute(
        path: '/privacy',
        builder: (_, _) => _legalPage('Privacy Policy'),
      ),
      GoRoute(
        path: '/cookie-policy',
        builder: (_, _) => _legalPage('Cookie Policy'),
      ),
      GoRoute(
        path: '/community-guidelines',
        builder: (_, _) => _legalPage('Community Guidelines'),
      ),
      GoRoute(
        path: '/medical-disclaimer',
        builder: (_, _) => _legalPage('Medical & Wellness Disclaimer'),
      ),
      GoRoute(
        path: '/sponsorship-policy',
        builder: (_, _) => _legalPage('Sponsorship & Disclosure Policy'),
      ),
      GoRoute(
        path: '/adult-content-policy',
        builder: (_, _) => const AdultContentPolicyScreen(),
      ),
      GoRoute(
        path: '/feed/post',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const PostComposerScreen(),
      ),
      GoRoute(
        path: '/feed/:postId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final postId = state.pathParameters['postId'] ?? '';
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/health-insights',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const HealthInsightsScreen(),
      ),
      GoRoute(
        path: '/workout-form',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const WorkoutFormScreen(),
      ),
      // Gym routes
      GoRoute(
        path: '/gyms/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const CreateGymScreen(),
      ),
      GoRoute(
        path: '/gyms/:slug',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return GymDetailScreen(slug: slug);
        },
      ),
      // Live routes
      GoRoute(
        path: '/lives/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const CreateLiveScreen(),
      ),
      GoRoute(
        path: '/lives/random-drop',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const RandomDropScreen(),
      ),
      GoRoute(
        path: '/lives/:liveId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final liveId = state.pathParameters['liveId'] ?? '';
          return LiveRoomScreen(liveId: liveId);
        },
      ),
      // Marketplace routes
      GoRoute(
        path: '/marketplace',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const MarketplaceScreen(),
      ),
      GoRoute(
        path: '/marketplace/meal-plans/:planId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final planId = state.pathParameters['planId'] ?? '';
          return MealPlanDetailScreen(planId: planId);
        },
      ),
      GoRoute(
        path: '/marketplace/programmes/:programmeId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final programmeId = state.pathParameters['programmeId'] ?? '';
          return ProgrammeDetailScreen(programmeId: programmeId);
        },
      ),
      GoRoute(
        path: '/marketplace/products/:productId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final productId = state.pathParameters['productId'] ?? '';
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/marketplace/events/:eventId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final eventId = state.pathParameters['eventId'] ?? '';
          return EventDetailScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/marketplace/tickets',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const EventTicketsScreen(),
      ),
      GoRoute(
        path: '/marketplace/cart',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const CartScreen(),
      ),
      GoRoute(
        path: '/marketplace/creator-studio',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const CreatorStudioScreen(),
      ),
      GoRoute(
        path: '/marketplace/creator/discount-codes',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const DiscountCodesScreen(),
      ),
      GoRoute(
        path: '/marketplace/meal-plans/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final shopHandle = state.uri.queryParameters['shop'];
          return CreateMealPlanScreen(shopHandle: shopHandle);
        },
      ),
      GoRoute(
        path: '/marketplace/programmes/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final shopHandle = state.uri.queryParameters['shop'];
          return CreateProgrammeScreen(shopHandle: shopHandle);
        },
      ),
      GoRoute(
        path: '/marketplace/events/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final shopHandle = state.uri.queryParameters['shop'];
          return CreateEventScreen(shopHandle: shopHandle);
        },
      ),
      // Shop routes
      GoRoute(
        path: '/marketplace/shops',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const MyShopsScreen(),
      ),
      GoRoute(
        path: '/marketplace/shops/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const CreateShopScreen(),
      ),
      GoRoute(
        path: '/marketplace/shops/:handle',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final handle = state.pathParameters['handle'] ?? '';
          return ShopDetailScreen(handle: handle);
        },
      ),
      // Programme activity focus
      GoRoute(
        path: '/marketplace/programmes/:programmeId/activity',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final programmeId = state.pathParameters['programmeId'] ?? '';
          final weekIndex =
              int.tryParse(state.uri.queryParameters['week'] ?? '0') ?? 0;
          final day = state.uri.queryParameters['day'] ?? 'Monday';
          final activityIndex =
              int.tryParse(state.uri.queryParameters['activity'] ?? '0') ?? 0;
          return ProgrammeActivityFocusScreen(
            programmeId: programmeId,
            weekIndex: weekIndex,
            day: day,
            activityIndex: activityIndex,
          );
        },
      ),
      // Wallet routes
      GoRoute(
        path: '/wallet',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const WalletScreen(),
      ),
      // Analytics
      GoRoute(
        path: '/analytics',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const AnalyticsScreen(),
      ),
      // Notifications
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/notifications/preferences',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const NotificationPreferencesScreen(),
      ),
      // Verification
      GoRoute(
        path: '/verification',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const VerificationScreen(),
      ),
      // Trainers
      GoRoute(
        path: '/trainers',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const TrainerListScreen(),
      ),
      GoRoute(
        path: '/trainers/:username',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final username = state.pathParameters['username'] ?? '';
          return TrainerProfileScreen(username: username);
        },
      ),
      GoRoute(
        path: '/book/:username',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final username = state.pathParameters['username'] ?? '';
          return BookingScreen(trainerUsername: username);
        },
      ),
      // Sessions
      GoRoute(
        path: '/sessions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const MySessionsScreen(),
      ),
      GoRoute(
        path: '/sessions/availability',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const AvailabilityScreen(),
      ),
      GoRoute(
        path: '/my-enrollments',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const MyEnrollmentsScreen(),
      ),
      GoRoute(
        path: '/programmes/:programmeId/weeks',
        parentNavigatorKey: _rootNavigatorKey,
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
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final bookingId = state.pathParameters['bookingId'] ?? '';
          return SessionDetailScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/sessions/:bookingId/review',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final bookingId = state.pathParameters['bookingId'] ?? '';
          final trainerUsername = state.uri.queryParameters['trainer'] ?? '';
          return SessionReviewScreen(
            bookingId: bookingId,
            trainerUsername: trainerUsername,
          );
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, _, child) => _AppShell(child: child),
        routes: [
          GoRoute(path: '/feed', builder: (_, _) => const FeedScreen()),
          GoRoute(
            path: '/feed/following',
            builder: (_, _) => const FeedScreen(initialTab: 'following'),
          ),
          GoRoute(
            path: '/feed/bud-press',
            builder: (_, _) => const FeedScreen(initialTab: 'videos'),
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
            path: '/messages/:conversationId',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (_, state) {
              final conversationId =
                  state.pathParameters['conversationId'] ?? '';
              return ChatScreen(conversationId: conversationId);
            },
          ),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
          GoRoute(
            path: '/buddies',
            builder: (_, _) => const BuddyListScreen(username: 'me'),
          ),
          GoRoute(
            path: '/:username',
            builder: (_, state) {
              final username = state.pathParameters['username'] ?? '';
              return UserProfileScreen(username: username);
            },
          ),
        ],
      ),
    ],
  );
}


Widget _legalPage(String title) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: const Center(
      child: Text(
        'Content placeholder',
        style: TextStyle(color: BuddyColors.textSecondary),
      ),
    ),
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
    _NavDestination('/feed', Icons.home_outlined, Icons.home, 'Home'),
    _NavDestination(
      '/discover',
      Icons.explore_outlined,
      Icons.explore,
      'Discover',
    ),
    _NavDestination('/lives', Icons.videocam_outlined, Icons.videocam, 'Lives'),
    _NavDestination(
      '/gyms',
      Icons.fitness_center_outlined,
      Icons.fitness_center,
      'Gyms',
    ),
    _NavDestination(
      '/messages',
      Icons.chat_bubble_outline,
      Icons.chat_bubble,
      'Messages',
    ),
    _NavDestination('/profile', Icons.person_outline, Icons.person, 'Profile'),
    _NavDestination(
      '/settings',
      Icons.settings_outlined,
      Icons.settings,
      'Settings',
    ),
  ];

  static const _phoneDestinations = <_NavDestination>[
    _NavDestination('/feed', Icons.home_outlined, Icons.home, 'Home'),
    _NavDestination(
      '/discover',
      Icons.explore_outlined,
      Icons.explore,
      'Discover',
    ),
    _NavDestination('/lives', Icons.videocam_outlined, Icons.videocam, 'Lives'),
    _NavDestination(
      '/gyms',
      Icons.fitness_center_outlined,
      Icons.fitness_center,
      'Gyms',
    ),
    _NavDestination('/profile', Icons.person_outline, Icons.person, 'Profile'),
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
                    child: Icon(
                      Icons.fitness_center,
                      color: BuddyColors.green,
                      size: 28,
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
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Scaffold(
      key: appShellScaffoldKey,
      drawer: const AppNavDrawer(),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateIndex(context, _phoneDestinations),
        onTap: (i) => context.go(_phoneDestinations[i].route),
        type: BottomNavigationBarType.fixed,
        items: _phoneDestinations
            .map(
              (d) => BottomNavigationBarItem(
                icon: Icon(d.icon),
                activeIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
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
    if (location.startsWith('/buddies') ||
        location.startsWith('/settings') ||
        location.startsWith('/:username')) {
      if (profileIndex >= 0) return profileIndex;
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
