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
import 'features/marketplace/screens/create_meal_plan_screen.dart';
import 'features/marketplace/screens/create_programme_screen.dart';
import 'features/marketplace/screens/create_event_screen.dart';
import 'features/wallet/screens/wallet_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/verification/screens/verification_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/sessions/screens/trainer_list_screen.dart';
import 'features/sessions/screens/trainer_profile_screen.dart';
import 'features/sessions/screens/booking_screen.dart';
import 'features/sessions/screens/my_sessions_screen.dart';
import 'features/sessions/screens/availability_screen.dart';
import 'features/sessions/screens/programme_weeks_screen.dart';
import 'features/messaging/screens/conversation_list_screen.dart';
import 'features/messaging/screens/chat_screen.dart';

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
        '/login', '/signup', '/verify-registration-otp', '/verify-age',
        '/forgot-password', '/reset-password', '/totp-setup', '/totp-challenge',
        '/onboarding', '/terms', '/privacy', '/cookie-policy', '/community-guidelines',
      ];

      if (!isAuthenticated && !publicRoutes.contains(location)) {
        return '/login';
      }

      if (isAuthenticated && publicRoutes.contains(location) && location != '/onboarding') {
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
          return VerifyRegistrationOtpScreen(registrationToken: token, email: email);
        },
      ),
      GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
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
      GoRoute(path: '/terms', builder: (_, _) => _legalPage('Terms of Service')),
      GoRoute(path: '/privacy', builder: (_, _) => _legalPage('Privacy Policy')),
      GoRoute(path: '/cookie-policy', builder: (_, _) => _legalPage('Cookie Policy')),
      GoRoute(path: '/community-guidelines', builder: (_, _) => _legalPage('Community Guidelines')),
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
        path: '/marketplace/meal-plans/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const CreateMealPlanScreen(),
      ),
      GoRoute(
        path: '/marketplace/programmes/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const CreateProgrammeScreen(),
      ),
      GoRoute(
        path: '/marketplace/events/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const CreateEventScreen(),
      ),
      // Wallet routes
      GoRoute(
        path: '/wallet',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const WalletScreen(),
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
          return ProgrammeWeeksScreen(programmeId: programmeId, programmeTitle: title);
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
          return SessionReviewScreen(bookingId: bookingId, trainerUsername: trainerUsername);
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, _, child) => _AppShell(child: child),
        routes: [
          GoRoute(path: '/feed', builder: (_, _) => const FeedScreen()),
          GoRoute(path: '/discover', builder: (_, _) => const DiscoverPeopleScreen()),
          GoRoute(path: '/lives', builder: (_, _) => const LiveBrowserScreen()),
          GoRoute(path: '/gyms', builder: (_, _) => const GymListScreen()),
          GoRoute(path: '/messages', builder: (_, _) => const ConversationListScreen()),
          GoRoute(
            path: '/messages/:conversationId',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (_, state) {
              final conversationId = state.pathParameters['conversationId'] ?? '';
              return ChatScreen(conversationId: conversationId);
            },
          ),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
          GoRoute(path: '/buddies', builder: (_, _) => const BuddyListScreen(username: 'me')),
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

Widget _placeholder(String title) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('$title — Coming soon', style: const TextStyle(color: BuddyColors.textSecondary)),
        ],
      ),
    ),
  );
}

Widget _legalPage(String title) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: const Center(
      child: Text('Content placeholder', style: TextStyle(color: BuddyColors.textSecondary)),
    ),
  );
}

class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateIndex(context),
        onTap: (i) {
          final routes = ['/feed', '/discover', '/lives', '/gyms', '/messages'];
          if (i < routes.length) {
            context.go(routes[i]);
          } else if (i == 4) {
            context.go('/profile');
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.videocam_outlined), activeIcon: Icon(Icons.videocam), label: 'Lives'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), activeIcon: Icon(Icons.fitness_center), label: 'Gyms'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/feed')) return 0;
    if (location.startsWith('/discover')) return 1;
    if (location.startsWith('/lives')) return 2;
    if (location.startsWith('/gyms')) return 3;
    if (location.startsWith('/profile') || location.startsWith('/settings')) return 4;
    return 0;
  }
}
