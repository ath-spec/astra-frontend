import 'dart:io';

void main() {
  final files = {
    'd:/astra-frontend/lib/services/service_providers.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/features/budget/data/budget_mock_providers.dart';
export 'package:astra_frontend/features/budget/data/budget_mock_providers.dart';
final budgetStateProvider = Provider<BudgetState>((ref) => BudgetState());
''',
    'd:/astra-frontend/lib/core/responsive/size_config.dart': '''
import 'package:flutter/material.dart';
class SizeConfig {
  void init(BuildContext context) {}
}
double getProportionateScreenWidth(double inputWidth) => inputWidth;
double getProportionateScreenHeight(double inputHeight) => inputHeight;
''',
    'd:/astra-frontend/lib/core/routes/app_routes.dart': '''
class AppRoutes {
  static const String main = '/';
  static const String mFOnboardingStart = '/mf-onboarding';
  static const String recurringSetup = '/recurring-setup';
}
''',
    'd:/astra-frontend/lib/services/analytics_service.dart': '''
class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService();
  void logScreenView(String screenName) {}
  void logEvent(String eventName, {Map<String, dynamic>? properties}) {}
}
''',
    'd:/astra-frontend/lib/core/instrumentation/funnel_tracker.dart': '''
class FunnelTracker {
  static final FunnelTracker instance = FunnelTracker();
  void startFunnel(String name) {}
  void advanceFunnel(String name, String step) {}
  void cancelFunnel(String name) {}
  void completeFunnel(String name) {}
}
''',
    'd:/astra-frontend/lib/core/instrumentation/instrumentation.dart': '''
import 'package:flutter/material.dart';

class ZeyroButton extends StatelessWidget {
  final String eventName;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  
  const ZeyroButton({super.key, required this.eventName, this.onPressed, required this.child, this.style});
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, style: style, child: child);
  }
}

class ZeyroIconButton extends StatelessWidget {
  final String eventName;
  final VoidCallback? onPressed;
  final Widget icon;
  
  const ZeyroIconButton({super.key, required this.eventName, this.onPressed, required this.icon});
  
  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: icon);
  }
}

class ZeyroTapDetector extends StatelessWidget {
  final String eventName;
  final VoidCallback? onTap;
  final Widget child;
  
  const ZeyroTapDetector({super.key, required this.eventName, this.onTap, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: child);
  }
}
'''
  };

  for (final entry in files.entries) {
    final file = File(entry.key);
    file.writeAsStringSync(entry.value);
    print('Created \${entry.key}');
  }
}

void addMore() {
  File('d:/astra-frontend/lib/core/network/api.dart').writeAsStringSync('class DioApiClient {}');
  File('d:/astra-frontend/lib/services/finance_repository.dart').writeAsStringSync('class FinanceRepository { FinanceRepository(dynamic client); }');
}

