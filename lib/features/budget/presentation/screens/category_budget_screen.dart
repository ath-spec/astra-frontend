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
      backgroundColor: BudgetColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: ZeyroIconButton(eventName: 'category_budget_screen_back_tapped', 
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF133026),
            size: 20,
          ),
          onPressed: () { Navigator.of(context).pop(); },
        ),
        title: Text(
          "Category Budgets",
          style: TextStyle(fontFamily: 'DMSans', 
            color: const Color(0xFF133026),
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
                    fontSize: getProportionateScreenWidth(24),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF133026),
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(8)),
                Text(
                  "Your active budget categories for the month.",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(14),
                    color: const Color(0xFF133026).withOpacity(0.8),
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
            color: BudgetColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF133026).withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: getProportionateScreenWidth(48),
                color: const Color(0xFF133026).withOpacity(0.3),
              ),
              SizedBox(height: getProportionateScreenHeight(16)),
              Text(
                "No Category Budgets Set",
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(20),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF133026),
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(8)),
              Text(
                "Create budgets for specific categories to better track your spending.",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(14),
                  color: const Color(0xFF133026).withOpacity(0.7),
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
          return const Color(0xFFFFF3E0);
        case 'critical':
          return BudgetColors.errorBg;
        default:
          return BudgetColors.successBg;
      }
    }

    Color getCategoryTextColor(String? status) {
      switch (status) {
        case 'warning':
          return const Color(0xFFE65100);
        case 'critical':
          return const Color(0xFFC62828);
        default:
          return BudgetColors.darkGreen;
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
          backgroundColor: parseColor(b.categoryColor, fallback: getCategoryColor(b.status)),
          textColor: parseColor(b.categoryTextColor, fallback: getCategoryTextColor(b.status)),
        ),
      );
    }).toList();
  }
}
