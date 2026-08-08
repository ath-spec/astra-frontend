import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryBudgetItem extends StatelessWidget {
  final String categoryName;
  final IconData icon;
  final Color color;
  final double budgetedAmount;
  final double spentAmount;
  final double percentage;

  const CategoryBudgetItem({
    super.key,
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.budgetedAmount,
    required this.spentAmount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BudgetColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName.toLowerCase(),
                      style: TextStyle(fontFamily: 'DMSans', 
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${currencyFormat.format(spentAmount)} of ${currencyFormat.format(budgetedAmount)}",
                      style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
                        fontSize: 12,
                        color: BudgetColors.grey7,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${percentage.toStringAsFixed(0)}%",
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: percentage > 100 ? BudgetColors.errorText : BudgetColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0, 1.0),
              backgroundColor: Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 100 ? BudgetColors.errorText : color,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
