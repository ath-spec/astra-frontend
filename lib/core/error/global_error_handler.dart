import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Sets up global error handling across Flutter and Platform dispatcher layers.
/// Follows production-ready patterns in dart-flutter-patterns.
void setupGlobalErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // In production, send details to Crashlytics / Sentry / reporting service
      debugPrint('FATAL FLUTTER ERROR: ${details.exceptionAsString()}');
    } else {
      debugPrint('FLUTTER ERROR: ${details.exceptionAsString()}\n${details.stack}');
    }
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    if (kReleaseMode) {
      // In production, record error in crash reporting tool
      debugPrint('FATAL PLATFORM ERROR: $error');
    } else {
      debugPrint('PLATFORM ERROR: $error\n$stack');
    }
    return true;
  };
}

/// Custom ErrorWidget displayed in production when a widget fails to build.
class ProductionErrorWidget extends StatelessWidget {
  const ProductionErrorWidget(this.details, {super.key});
  
  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong.',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                kDebugMode ? details.exceptionAsString() : 'We encountered an unexpected issue. Please try restarting the app.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
