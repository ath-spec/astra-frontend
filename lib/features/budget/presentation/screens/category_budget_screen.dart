import 'package:astra_frontend/features/budget/theme/budget_colors.dart';

import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:intl/intl.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/category_budget_summary_card.dart';
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';


class CategoryBudgetScreen extends StatelessWidget {
  final BudgetLatestResponse? dash;
  
  const CategoryBudgetScreen({
    super.key,
    this.dash,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: ZeyroIconButton(eventName: 'category_budget_screen_back_tapped', 
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () { Navigator.of(context).pop(); },
        ),
        title: Text(
          "Category Budgets",
          style: TextStyle(fontFamily: 'DMSans', 
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
            fontSize: getProportionateScreenWidth(20),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(16),
              vertical: getProportionateScreenHeight(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Budget: ₹${NumberFormat('#,##,###').format(dash?.totalBudget ?? 0)}",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(8)),
                Text(
                  "Your active budget categories for the month.",
                  style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(24)),
                SizedBox(height: getProportionateScreenHeight(24)),
                // Categories List
                ..._buildCategoryList(),
                SizedBox(height: getProportionateScreenHeight(40)),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  List<Widget> _buildCategoryList() {
    if (dash == null || dash!.budgets.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(getProportionateScreenWidth(24)),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: getProportionateScreenWidth(48),
                color: const Color(0xFF9CA3AF),
              ),
              SizedBox(height: getProportionateScreenHeight(16)),
              Text(
                "No Category Budgets Set",
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(20),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(8)),
              Text(
                "Create budgets for specific categories to better track your spending.",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(14),
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    Color parseColor(String hexColor, {required Color fallback}) {
      if (hexColor.isEmpty) return fallback;
      try {
        String hex = hexColor.replaceAll('#', '');
        if (hex.length == 6) hex = 'FF$hex';
        return Color(int.parse(hex, radix: 16));
      } catch (_) {
        return fallback;
      }
    }

    // Helper functions for basic colors/icons based on backend strings
    Color getCategoryColor(String? status) {
      switch (status) {
        case 'warning':
          return const Color(0xFFFEF3C7);
        case 'critical':
          return const Color(0xFFFEE2E2);
        default:
          return const Color(0xFFECFDF5);
      }
    }

    Color getCategoryTextColor(String? status) {
      switch (status) {
        case 'warning':
          return const Color(0xFFB45309);
        case 'critical':
          return const Color(0xFF991B1B);
        default:
          return const Color.fromARGB(255, 5, 134, 91);
      }
    }

    IconData getIconForName(String name) {
      final n = name.toLowerCase();
      if (n.contains('grocer') || n.contains('food')) return Icons.shopping_basket_rounded;
      if (n.contains('trans') || n.contains('travel') || n.contains('cab')) return Icons.directions_car_rounded;
      if (n.contains('utilit') || n.contains('bill')) return Icons.bolt_rounded;
      if (n.contains('house') || n.contains('rent')) return Icons.home_rounded;
      if (n.contains('shop')) return Icons.shopping_bag_rounded;
      if (n.contains('health') || n.contains('medic')) return Icons.medical_services_rounded;
      if (n.contains('dine') || n.contains('restaurant')) return Icons.restaurant_rounded;
      return Icons.category_rounded;
    }

    return dash!.budgets.map((b) {
      return Padding(
        padding: EdgeInsets.only(bottom: getProportionateScreenHeight(16)),
        child: CategoryBudgetSummaryCard(
          categoryName: b.categoryName,
          budgetedAmount: b.budgetedAmount,
          spentAmount: b.spentAmount,
          percentageUsed: b.percentageUsed,
          daysRemaining: (dash!.daysRemainingInMonth) > 0 ? dash!.daysRemainingInMonth : (DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day - DateTime.now().day),
          icon: getIconForName(b.categoryName),
          backgroundColor: parseColor(b.categoryColor, fallback: getCategoryColor(b.status)).withValues(alpha: 0.15),
          textColor: parseColor(b.categoryTextColor, fallback: getCategoryTextColor(b.status)),
          borderColor: const Color(0xFFE2E8F0),
        ),
      );
    }).toList();
  }
}
