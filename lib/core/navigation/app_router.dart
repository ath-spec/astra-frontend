import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/asset_connection/screens/banks_searching_screen.dart';
import '../../features/asset_connection/screens/connecting_assets_screen.dart';
import '../../features/asset_connection/screens/mutual_funds_status_screen.dart';
import '../../features/asset_connection/screens/stocks_connection_screen.dart';
import '../../features/asset_connection/screens/stocks_searching_screen.dart';
import '../../features/asset_connection/screens/stocks_status_screen.dart';
import '../../features/asset_connection/screens/stocks_verifying_screen.dart';
import '../../features/asset_connection/screens/banks_linking_screen.dart';
import '../../features/asset_connection/screens/banks_linking_progress_screen.dart';
import '../../features/profiling/screens/profiling_intro_screen.dart';
import '../../features/profiling/screens/profiling_questions_screen.dart';
import '../../features/profiling/screens/profiling_status_screen.dart';
import '../screens/no_internet_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/pan_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/home/screens/home_screen.dart';

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
          loc == '/splash' ||
          loc == '/pan' ||
          loc == '/otp' ||
          loc == '/connect-assets' ||
          loc == '/mf-status' ||
          loc == '/stocks-otp' ||
          loc == '/stocks-verifying' ||
          loc == '/stocks-searching' ||
          loc == '/stocks-status' ||
          loc == '/banks-searching' ||
          loc == '/banks-linking' ||
          loc == '/banks-linking-progress' ||
          loc == '/profiling-intro' ||
          loc == '/profiling-questions' ||
          loc == '/profiling-status' ||
          loc == '/no-internet';

      if (!isLoggedIn && !isOnboardingRoute) return '/splash';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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
        path: '/connect-assets',
        builder: (context, state) => const ConnectingAssetsScreen(),
      ),
      GoRoute(
        path: '/mf-status',
        builder: (context, state) => const MutualFundsStatusScreen(),
      ),
      GoRoute(
        path: '/stocks-otp',
        builder: (context, state) => const StocksConnectionScreen(),
      ),
      GoRoute(
        path: '/stocks-verifying',
        builder: (context, state) => const StocksVerifyingScreen(),
      ),
      GoRoute(
        path: '/stocks-searching',
        builder: (context, state) => const StocksSearchingScreen(),
      ),
      GoRoute(
        path: '/stocks-status',
        builder: (context, state) => const StocksStatusScreen(),
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
        path: '/banks-linking-progress',
        builder: (context, state) => const BanksLinkingProgressScreen(),
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
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
