import 'dart:io';

void main() {
  File('lib/features/budget/data/budget_mock_providers.dart').writeAsStringSync('''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/category_item_model.dart';

class BudgetState {
  final bool isLoadingDiagnosis;
  Diagnosis? currentDiagnosis;
  final List<dynamic> suggestedCategories = const [];
  final String currentSessionId = 'mock_session_id';

  BudgetState({
    this.isLoadingDiagnosis = false,
    this.currentDiagnosis,
  });

  Future<void> fetchDiagnosis({required String month, bool forceRefresh = false}) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> finalizeSession({required List<dynamic> allocations, required double totalBudget}) async {
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> fetchLatestDashboard() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  void setSessionBudget(double totalBudget, List<CategoryItem> categoryList) {}
}

class Diagnosis {
  final double averageIncome;
  final double averageSavings;
  final double averageExpenses;
  final List<DiagnosisInsight> diagnosisInsights;
  final double suggestedTotalBudget;
  final List<dynamic> historicalSpending;

  Diagnosis({
    this.averageIncome = 150000.0,
    this.averageSavings = 45000.0,
    this.averageExpenses = 105000.0,
    this.suggestedTotalBudget = 100000.0,
    this.historicalSpending = const [1],
    this.diagnosisInsights = const [],
  });
}

class DiagnosisInsight {
  final String title;
  final String description;
  const DiagnosisInsight({required this.title, required this.description});
}

class CategoryAllocation {
  final String categoryId;
  final double amount;
  CategoryAllocation({required this.categoryId, required this.amount});
}

final budgetStateProvider = Provider<BudgetState>((ref) {
  return BudgetState(
    isLoadingDiagnosis: false,
    currentDiagnosis: Diagnosis(),
  );
});
''');

  File('lib/core/instrumentation/widgets/visibility_tracker.dart').createSync(recursive: true);
  File('lib/core/instrumentation/widgets/visibility_tracker.dart').writeAsStringSync('''
import 'package:flutter/material.dart';

class ZeyroVisibilityTracker extends StatelessWidget {
  final String eventName;
  final Widget child;
  
  const ZeyroVisibilityTracker({super.key, required this.eventName, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
''');

  File('lib/services/finance_repository.dart').writeAsStringSync('''
class FinanceRepository {
  FinanceRepository(dynamic client);
  Future<void> updateBudgetSettings(dynamic data) async {}
  Future<void> updateBudgetSession(String id, dynamic data) async {}
}
''');

  File('lib/features/budget/data/models/budget_api_models.dart').writeAsStringSync('''
class BudgetConflictException implements Exception {
  final dynamic response;
  BudgetConflictException(this.response);
}

class BudgetDiagnosisResponse extends Diagnosis {
  final String month;
  BudgetDiagnosisResponse({
    required this.month,
    required List<dynamic> historicalSpending,
    required double averageIncome,
    required double averageExpenses,
    required double averageSavings,
    required double suggestedTotalBudget,
    required List<DiagnosisInsight> diagnosisInsights,
  }) : super(
          averageIncome: averageIncome,
          averageSavings: averageSavings,
          averageExpenses: averageExpenses,
          suggestedTotalBudget: suggestedTotalBudget,
          historicalSpending: historicalSpending,
          diagnosisInsights: diagnosisInsights,
        );
}
''', mode: FileMode.append);

  File('lib/core/instrumentation/instrumentation.dart').writeAsStringSync('''
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
  final EdgeInsetsGeometry? padding;
  final double? splashRadius;
  final BoxConstraints? constraints;
  
  const ZeyroIconButton({super.key, required this.eventName, this.onPressed, required this.icon, this.padding, this.splashRadius, this.constraints});
  
  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: icon, padding: padding, splashRadius: splashRadius, constraints: constraints);
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
''');
}
