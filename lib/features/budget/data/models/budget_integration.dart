class LatestBudgetsResponse {
  final double totalBudget;
  final List<Budget> budgets;

  LatestBudgetsResponse({required this.totalBudget, required this.budgets});

  factory LatestBudgetsResponse.fromJson(Map<String, dynamic> json) {
    return LatestBudgetsResponse(
      totalBudget: (json['total_budget'] as num?)?.toDouble() ?? 0.0,
      budgets:
          (json['budgets'] as List?)
              ?.map((b) => Budget.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Budget {
  final String id;
  final String name;
  final double amount;
  final String category;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? '',
    );
  }
}
