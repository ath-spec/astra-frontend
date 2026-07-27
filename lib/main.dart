import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/error/global_error_handler.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock app to portrait mode only (disables landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Configure native Android navigation bar & status bar for edge-to-edge experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark, // iOS native: light/white status bar text on dark background
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  setupGlobalErrorHandling();
  
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => ProductionErrorWidget(details);
  }

  runApp(
    const ProviderScope(
      child: AstraApp(),
    ),
  );
}

class AstraApp extends ConsumerWidget {
  const AstraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Astra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        // Calculate a responsive scale factor based on screen width
        final width = MediaQuery.sizeOf(context).width;
        // Cap the width at 420 since the UI has a ConstrainedBox
        final effectiveWidth = width > 420 ? 420.0 : width;
        // Base width is 390 (standard iPhone). Allow scaling down to 80% and up to 110%.
        final scale = (effectiveWidth / 390.0).clamp(0.8, 1.1);

        // Apply this scale factor globally to all text in the app
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        );
      },
    );
  }
}
