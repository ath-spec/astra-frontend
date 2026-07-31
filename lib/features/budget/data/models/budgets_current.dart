// lib/models/budgets_current.dart
import 'budget.dart' as bm;
import 'spend.dart' as sm;

class BudgetsCurrent {
  final List<bm.Budget> budgets;
  final List<sm.Spend> spending;

  BudgetsCurrent({required this.budgets, required this.spending});

  factory BudgetsCurrent.fromJson(Map<String, dynamic> json) {
    final budgetsList = (json['budgets'] as List<dynamic>? ?? [])
        .map((e) => bm.Budget.fromJson(e as Map<String, dynamic>))
        .toList();

    final spendingList = (json['spending'] as List<dynamic>? ?? [])
        .map((e) => sm.Spend.fromJson(e as Map<String, dynamic>))
        .toList();

    return BudgetsCurrent(budgets: budgetsList, spending: spendingList);
  }

  Map<String, dynamic> toJson() => {
        'budgets': budgets.map((e) => e.toJson()).toList(),
        'spending': spending.map((e) => e.toJson()).toList(),
      };
}
