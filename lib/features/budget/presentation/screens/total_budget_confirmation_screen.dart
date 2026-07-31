import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/budget/presentation/screens/budget_category_analyzing_screen.dart';

class BudgetConfirmationScreen extends StatelessWidget {
  final double finalBudgetAmount;

  const BudgetConfirmationScreen({super.key, required this.finalBudgetAmount});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
      backgroundColor: const Color(0xFFfaf5ea),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(20),
            vertical: getProportionateScreenHeight(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Success icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: BudgetColors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: BudgetColors.white,
                  size: 24,
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(24)),

              // Title message
              Text(
                "your budget is set at ${currencyFormat.format(finalBudgetAmount)}",
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(30),
                  fontWeight: FontWeight.w600,
                  color: BudgetColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: getProportionateScreenHeight(16)),

              // Sub text
              Text(
                "add category budgets to stay on top of your spending.",
                style: TextStyle(fontFamily: 'DMSans', fontSize: 14, color: BudgetColors.grey7),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Buttons
              ZeyroButton(eventName: 'total_budget_confirmation_screen_confirm_tapped', 
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BudgetCategoryAnalyzingScreen(totalBudget: finalBudgetAmount),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BudgetColors.black,
                  foregroundColor: BudgetColors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  shadowColor: BudgetColors.black.withOpacity(0.3),
                ),
                child: Text(
                  "set category budgets",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(16)),

              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: BudgetColors.black,
                  side: const BorderSide(color: Colors.black12, width: 2),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "not now",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: BudgetColors.foreground,
                  ),
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(20)),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
