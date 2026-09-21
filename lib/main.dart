import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/error/global_error_handler.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/responsive_app_wrapper.dart';
import 'features/recurring/data/recurring_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read this before runApp so the very first frame already knows whether
  // "Track your bills" was previously unlocked — otherwise the provider's
  // async secure-storage read can resolve after a widget already read the
  // default `false`, making the feature look reset on every app launch.
  final billsTrackingUnlocked = await BillsTrackingUnlockedNotifier.readPersisted();

  // Lock app to portrait mode only (disables landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Configure native Android navigation bar & status bar for edge-to-edge experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,   // dark icons — correct for white-bg auth screens
      statusBarBrightness: Brightness.light,       // iOS: dark status bar icons on light background
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  setupGlobalErrorHandling();
  
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => ProductionErrorWidget(details);
  }

  runApp(
    ProviderScope(
      overrides: [
        billsTrackingUnlockedProvider.overrideWith(
          (ref) => BillsTrackingUnlockedNotifier(initialValue: billsTrackingUnlocked),
        ),
      ],
      child: const AstraApp(),
    ),
  );
}

class AstraApp extends ConsumerWidget {
  const AstraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktopWeb = kIsWeb && constraints.maxWidth > 700;
        return ResponsiveAppWrapper(
          child: MaterialApp.router(
            title: 'Astra',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: isDesktopWeb ? const Size(393, 852) : MediaQuery.of(context).size,
                  padding: isDesktopWeb ? const EdgeInsets.only(top: 47, bottom: 34) : MediaQuery.of(context).padding,
                  viewPadding: isDesktopWeb ? const EdgeInsets.only(top: 47, bottom: 34) : MediaQuery.of(context).viewPadding,
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
          ),
        );
      }
    );
  }
}
