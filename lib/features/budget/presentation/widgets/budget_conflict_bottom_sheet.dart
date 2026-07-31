import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';
import 'package:astra_frontend/services/finance_repository.dart';
import 'package:intl/intl.dart';

class BudgetConflictBottomSheet extends StatelessWidget {
  final BudgetConflictException exception;

  const BudgetConflictBottomSheet({
    super.key,
    required this.exception,
  });

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: BudgetColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(24),
            vertical: getProportionateScreenHeight(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Warning Icon Header
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: BudgetColors.errorBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFB71C1C),
                  size: 32,
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(24)),

              // Title
              Text(
                "budget conflict",
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: const Color(0xFF133026),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: getProportionateScreenHeight(16)),

              // Description
              Text(
                exception.type == 'scalable_floor_exceeded'
                    ? "your new budget covers your protected bills, but doesn't leave enough room for your other categories. you are short by ${nf.format(exception.amount)}."
                    : "we noticed your new spending limit is lower than what you've already committed to your protected bills. you are short by ${nf.format(exception.amount)}.",
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: 14,
                  height: 1.5,
                  color: const Color(0xFF133026).withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              if (exception.conflicts.isNotEmpty) ...[
                SizedBox(height: getProportionateScreenHeight(16)),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5EA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF133026).withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        exception.type == 'scalable_floor_exceeded'
                            ? (exception.conflicts.length > 1 ? "specifically, your flexible limits for" : "specifically, your flexible limit for")
                            : (exception.conflicts.length > 1 ? "specifically, your fixed limits for" : "specifically, your fixed limit for"),
                        style: TextStyle(fontFamily: 'DMSans', 
                          fontSize: 13,
                          color: const Color(0xFF133026).withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        exception.conflicts.map((c) => c.replaceAll('_', ' ')).join(', '),
                        style: TextStyle(fontFamily: 'DMSans', 
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF133026),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        exception.type == 'scalable_floor_exceeded'
                            ? (exception.conflicts.length > 1 
                                ? "need more funding to stay above their safe minimums. try increasing your total budget."
                                : "needs more funding to stay above its safe minimum. try increasing your total budget.")
                            : (exception.conflicts.length > 1
                                ? "add up to more than your new total. you'll need to lower those first to proceed."
                                : "is more than your new total. you'll need to lower it first to proceed."),
                        style: TextStyle(fontFamily: 'DMSans', 
                          fontSize: 13,
                          color: const Color(0xFF133026).withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: getProportionateScreenHeight(32)),

              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF133026),
                  foregroundColor: BudgetColors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "i understand",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
