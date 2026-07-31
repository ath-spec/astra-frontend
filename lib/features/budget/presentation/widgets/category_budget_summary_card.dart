import 'package:flutter/material.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/budget_overview_card.dart';

class CategoryBudgetSummaryCard extends StatelessWidget {
  final String categoryName;
  final double budgetedAmount;
  final double spentAmount;
  final double percentageUsed;
  final double projectedSpend;
  final IconData icon;
  final bool isMini;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showCapAndOverspent;

  const CategoryBudgetSummaryCard({
    super.key,
    required this.categoryName,
    required this.budgetedAmount,
    this.spentAmount = 0,
    this.percentageUsed = 0,
    this.projectedSpend = 0,
    this.daysRemaining = 0,
    required this.icon,
    this.isMini = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.showCapAndOverspent = true,
  });
  final int daysRemaining;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return BudgetOverviewCard(
      totalBudget: budgetedAmount,
      spentAmount: spentAmount,
      percentageUsed: percentageUsed,
      projectedSpend: projectedSpend,
      daysRemaining: daysRemaining,
      title: categoryName,
      topIcon: icon,
      backgroundColor: backgroundColor ?? const Color(0xFF8EC8B3),
      textColor: textColor ?? const Color(0xFF133026),
      isMini: isMini,
      showIncomeOutcome: false,
      borderColor: borderColor,
      isCategoryCard: true,
      showCapAndOverspent: showCapAndOverspent,
    );
  }
}
