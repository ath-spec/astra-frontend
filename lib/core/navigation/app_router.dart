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
import '../../features/auth/screens/verify_pan_screen.dart';
import '../../features/auth/screens/mf_fetch_confirm_screen.dart';
import '../../features/auth/screens/mf_central_otp_screen.dart';
import '../../features/auth/screens/mf_central_cas_screen.dart';
import '../../features/auth/screens/mf_fetch_loading_screen.dart';
import '../../features/auth/screens/mf_edit_phone_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/intro_screen.dart';
import '../../features/auth/screens/notification_permission_screen.dart';
import '../../features/auth/screens/dob_screen.dart';
import '../../features/auth/screens/name_screen.dart';
import '../../features/auth/screens/aa_stocks_otp_screen.dart';
import '../../features/auth/screens/aa_stocks_fetching_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/chat/screens/chat_history_screen.dart';
import 'package:flutter/material.dart';
import '../../features/news/screens/news_screen.dart';
import '../../features/learnings/screens/learnings_screen.dart';
import '../../features/learnings/screens/modules/module_details_screen.dart';
import '../../features/learnings/screens/modules/chapter_list_screen.dart';
import '../../features/learnings/screens/modules/chapter_reader_screen.dart';
import '../../features/learnings/screens/videos/video_reader_screen.dart';
import '../../features/learnings/models/video_models.dart';
import '../../features/budget/presentation/screens/budget_onboarding_intro_screen.dart';
import '../../features/budget/presentation/screens/budget_control_screen.dart';
import '../../features/recurring/presentation/screens/recurring_intro_screen.dart';
import '../../features/recurring/presentation/screens/recurring_control_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/user_profile_screen.dart';
import '../../features/profile/screens/account_details_screen.dart';
import '../../features/profile/screens/nominee_list_screen.dart';
import '../../features/profile/screens/mf_report_screen.dart';
import '../../features/profile/screens/mf_report_list_screen.dart';
import '../../features/asset_connection/screens/manage_bank_accounts_screen.dart';
import '../../features/asset_connection/screens/linked_bank_accounts_screen.dart';
import '../../features/asset_connection/screens/bank_account_details_screen.dart';
import 'package:astra_frontend/features/portfolio_analysis/screens/analysis_walk_screen.dart';
import 'package:astra_frontend/features/portfolio_analysis/screens/portfolio_analysis_screen.dart';
import 'package:astra_frontend/features/portfolio_analysis/screens/insights_screen.dart';
import '../../features/mf/screens/mf_container_screen.dart';
import '../../features/stocks/screens/owned_stocks_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../widgets/app_shell.dart';
import '../widgets/corner_fade_reveal_transition.dart';
import 'nav_keys.dart';

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
          loc == '/mf-fetch-confirm' ||
          loc == '/mf-central-otp' ||
          loc == '/mf-central-cas' ||
          loc == '/mf-fetch-loading' ||
          loc == '/mf-edit-phone' ||
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
        builder: (context, state) {
          final isOnboarding = (state.extra as Map<String, dynamic>?)?['isOnboarding'] as bool? ?? false;
          return PanVerificationScreen(isOnboarding: isOnboarding);
        },
      ),
      GoRoute(
        path: '/pan-otp',
        builder: (context, state) => const PanOtpVerificationScreen(),
      ),
      GoRoute(
        path: '/verify-pan',
        builder: (context, state) => const VerifyPanScreen(),
      ),
      GoRoute(
        path: '/mf-fetch-confirm',
        builder: (context, state) {
          final isOnboarding = (state.extra as Map<String, dynamic>?)?['isOnboarding'] as bool? ?? false;
          return MfFetchConfirmScreen(isOnboarding: isOnboarding);
        },
      ),
      GoRoute(
        path: '/mf-central-otp',
        builder: (context, state) {
          final isOnboarding = (state.extra as Map<String, dynamic>?)?['isOnboarding'] as bool? ?? false;
          return MfCentralOtpScreen(isOnboarding: isOnboarding);
        },
      ),
      GoRoute(
        path: '/mf-central-cas',
        builder: (context, state) {
          final isOnboarding = (state.extra as Map<String, dynamic>?)?['isOnboarding'] as bool? ?? false;
          return MfCentralCasScreen(isOnboarding: isOnboarding);
        },
      ),
      GoRoute(
        path: '/mf-fetch-loading',
        builder: (context, state) {
          final isOnboarding = (state.extra as Map<String, dynamic>?)?['isOnboarding'] as bool? ?? false;
          return MfFetchLoadingScreen(isOnboarding: isOnboarding);
        },
      ),
      GoRoute(
        path: '/mf-edit-phone',
        builder: (context, state) => const MfEditPhoneScreen(),
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
        builder: (context, state) {
          final isOnboarding = (state.extra as Map<String, dynamic>?)?['isOnboarding'] as bool? ?? false;
          return AaStocksOtpScreen(isOnboarding: isOnboarding);
        },
      ),
      GoRoute(
        path: '/aa-stocks-fetching',
        builder: (context, state) {
          final isOnboarding = (state.extra as Map<String, dynamic>?)?['isOnboarding'] as bool? ?? false;
          return AaStocksFetchingScreen(isOnboarding: isOnboarding);
        },
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
        path: '/manage-bank-accounts',
        builder: (context, state) => const ManageBankAccountsScreen(),
      ),
      GoRoute(
        path: '/linked-bank-accounts',
        builder: (context, state) => const LinkedBankAccountsScreen(),
      ),
      GoRoute(
        path: '/bank-account-details',
        builder: (context, state) {
          final bankAccount = state.extra as dynamic;
          return BankAccountDetailsScreen(bankAccount: bankAccount);
        },
      ),
      GoRoute(
        path: '/chat-history',
        builder: (context, state) => const ChatHistoryScreen(),
      ),
      GoRoute(
        path: '/stocks',
        builder: (context, state) => const StocksScreen(),
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
        path: '/init-budget',
        builder: (context, state) => const BudgetOnboardingIntroScreen(),
      ),
      GoRoute(
        path: '/budget-control',
        builder: (context, state) => const BudgetControlScreen(),
      ),
      GoRoute(
        path: '/recurring-intro',
        builder: (context, state) => const RecurringIntroScreen(),
      ),
      GoRoute(
        path: '/recurring-control',
        builder: (context, state) => const RecurringControlScreen(),
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
      GoRoute(
        path: '/account-details',
        builder: (context, state) => const AccountDetailsScreen(),
      ),
      GoRoute(
        path: '/nominee-list',
        builder: (context, state) => const NomineeListScreen(),
      ),
      GoRoute(
        path: '/mf-report',
        builder: (context, state) => const MfReportScreen(),
      ),
      GoRoute(
        path: '/mf-report-list',
        builder: (context, state) {
          final title = state.extra as String? ?? 'REPORT';
          return MfReportListScreen(title: title);
        },
      ),
      GoRoute(
        path: '/analysis-walkthrough',
        builder: (context, state) => const AnalysisWalkScreen(),
      ),
      GoRoute(
        path: '/portfolio-analysis',
        builder: (context, state) {
          final tabStr = state.uri.queryParameters['tab'];
          final initialTab = tabStr != null ? int.tryParse(tabStr) ?? 0 : 0;
          return PortfolioAnalysisScreen(initialTab: initialTab);
        },
      ),
      GoRoute(
        path: '/insights',
        builder: (context, state) {
          final initialInsightStr = state.uri.queryParameters['initial'];
          final initialInsight = initialInsightStr != null ? int.tryParse(initialInsightStr) ?? 0 : 0;
          return InsightsScreen(initialInsight: initialInsight);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: homeNavKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: mfNavKey,
            routes: [
              GoRoute(
                path: '/mf',
                builder: (context, state) => const MfContainerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: chatNavKey,
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: newsNavKey,
            routes: [
              GoRoute(
                path: '/news',
                builder: (context, state) => const NewsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: learningsNavKey,
            routes: [
              GoRoute(
                path: '/learnings',
                builder: (context, state) => const LearningsScreen(),
                routes: [
                  GoRoute(
                    path: 'module-details',
                    builder: (context, state) {
                      final module = state.extra as dynamic;
                      return ModuleDetailsScreen(module: module);
                    },
                  ),
                  GoRoute(
                    path: 'chapter-list',
                    builder: (context, state) {
                      final data = state.extra as Map<String, dynamic>;
                      return ChapterListScreen(
                        module: data['module'] as dynamic,
                        level: data['level'] as String,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'chapter-reader',
                    builder: (context, state) {
                      final map = state.extra as Map<String, dynamic>? ?? {};
                      return ChapterReaderScreen(
                        module: map['module'],
                        chapter: map['chapter'],
                        allChapters: map['allChapters'],
                      );
                    },
                  ),
                  GoRoute(
                    path: 'video-reader',
                    builder: (context, state) {
                      final module = state.extra as VideoModule;
                      return VideoReaderScreen(module: module);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
