import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/asset_connection/screens/banks_searching_screen.dart';
import '../../features/asset_connection/screens/banks_linking_screen.dart';
import '../../features/profiling/screens/profiling_intro_screen.dart';
import '../../features/profiling/screens/profiling_questions_screen.dart';
import '../../features/profiling/screens/profiling_status_screen.dart';
import '../screens/no_internet_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/pan_screen.dart';
import '../../features/auth/screens/pan_otp_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/intro_screen.dart';
import '../../features/auth/screens/notification_permission_screen.dart';
import '../../features/auth/screens/dob_screen.dart';
import '../../features/auth/screens/name_screen.dart';
import '../../features/auth/screens/aa_stocks_otp_screen.dart';
import '../../features/auth/screens/aa_stocks_fetching_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/chat/screens/chat_history_screen.dart';
import 'package:flutter/material.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/user_profile_screen.dart';
import '../widgets/app_shell.dart';
import '../widgets/corner_fade_reveal_transition.dart';

/// GoRouter configuration with auth state redirection.
/// Follows navigation patterns in dart-flutter-patterns.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState is AuthAuthenticated;
      final loc = state.matchedLocation;

      final isOnboardingRoute = loc == '/login' ||
          loc == '/intro' ||
          loc == '/splash' ||
          loc == '/pan' ||
          loc == '/pan-otp' ||
          loc == '/otp' ||
          loc == '/notification-permission' ||
          loc == '/dob' ||
          loc == '/name' ||
          loc == '/aa-stocks-otp' ||
          loc == '/aa-stocks-fetching' ||
          loc == '/banks-searching' ||
          loc == '/banks-linking' ||
          loc == '/profiling-intro' ||
          loc == '/profiling-questions' ||
          loc == '/profiling-status' ||
          loc == '/no-internet';

      if (!isLoggedIn && !isOnboardingRoute) return '/intro';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/intro',
        pageBuilder: (context, state) {
          // Accept a preloaded video controller from the splash screen
          final preloadedController = state.extra as dynamic;
          
          return CustomTransitionPage(
            key: state.pageKey,
            child: IntroScreen(preloadedController: preloadedController),
            transitionDuration: const Duration(milliseconds: 1200),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return CornerFadeRevealTransition(
                animation: animation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 1200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return CornerFadeRevealTransition(
              animation: animation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: '/pan',
        builder: (context, state) => const PanVerificationScreen(),
      ),
      GoRoute(
        path: '/pan-otp',
        builder: (context, state) => const PanOtpVerificationScreen(),
      ),
      GoRoute(
        path: '/notification-permission',
        builder: (context, state) => const NotificationPermissionScreen(),
      ),
      GoRoute(
        path: '/dob',
        builder: (context, state) => const DobScreen(),
      ),
      GoRoute(
        path: '/name',
        builder: (context, state) => const NameScreen(),
      ),
      GoRoute(
        path: '/aa-stocks-otp',
        builder: (context, state) => const AaStocksOtpScreen(),
      ),
      GoRoute(
        path: '/aa-stocks-fetching',
        builder: (context, state) => const AaStocksFetchingScreen(),
      ),
      GoRoute(
        path: '/banks-searching',
        builder: (context, state) => const BanksSearchingScreen(),
      ),
      GoRoute(
        path: '/banks-linking',
        builder: (context, state) => const BanksLinkingScreen(),
      ),
      GoRoute(
        path: '/chat-history',
        builder: (context, state) => const ChatHistoryScreen(),
      ),

      GoRoute(
        path: '/profiling-intro',
        builder: (context, state) => const ProfilingIntroScreen(),
      ),
      GoRoute(
        path: '/profiling-questions',
        builder: (context, state) => const ProfilingQuestionsScreen(),
      ),
      GoRoute(
        path: '/profiling-status',
        builder: (context, state) => const ProfilingStatusScreen(),
      ),
      GoRoute(
        path: '/no-internet',
        builder: (context, state) {
          final returnRoute = state.extra as String?;
          return NoInternetScreen(returnRoute: returnRoute);
        },
      ),
      GoRoute(
        path: '/user-profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
