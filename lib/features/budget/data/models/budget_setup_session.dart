class BudgetSetupSession {
  final String id;
  final String zyid;
  final String month;
  final String status;
  final double totalBudget;
  final bool isFallback;
  final List<SessionCategoryAllocation> categoryAllocations;

  BudgetSetupSession({
    required this.id,
    required this.zyid,
    required this.month,
    required this.status,
    required this.totalBudget,
    this.isFallback = false,
    required this.categoryAllocations,
  });

  factory BudgetSetupSession.fromJson(Map<String, dynamic> json) {
    return BudgetSetupSession(
      id: json['id']?.toString() ?? json['session_id']?.toString() ?? '',
      zyid: json['zyid']?.toString() ?? '',
      month: json['month']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalBudget: (json['total_budget'] is num)
          ? (json['total_budget'] as num).toDouble()
          : (double.tryParse(json['total_budget']?.toString() ?? '') ?? 0.0),
      isFallback: json['is_fallback'] == true,
      categoryAllocations: (json['category_allocations'] as List?)
              ?.map((e) => SessionCategoryAllocation.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}

class SessionCategoryAllocation {
  final String categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final double amount;
  final String? reason;

  SessionCategoryAllocation({
    required this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.amount,
    this.reason,
  });

  factory SessionCategoryAllocation.fromJson(Map<String, dynamic> json) {
    return SessionCategoryAllocation(
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name']?.toString(),
      categoryIcon: json['category_icon']?.toString(),
      categoryColor: json['category_color']?.toString(),
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : (double.tryParse(json['amount']?.toString() ?? '') ?? 0.0),
      reason: json['reason']?.toString(),
    );
  }
}
