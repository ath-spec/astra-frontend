import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';

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
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFECACA), width: 1),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFDC2626),
                  size: 24,
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(20)),

              // Title
              Text(
                "Budget conflict",
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk', 
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: getProportionateScreenHeight(12)),

              // Description
              Text(
                exception.type == 'scalable_floor_exceeded'
                    ? "Your new budget covers your protected bills, but doesn't leave enough room for your other categories. You are short by ${nf.format(exception.amount)}."
                    : "We noticed your new spending limit is lower than what you've already committed to your protected bills. You are short by ${nf.format(exception.amount)}.",
                style: TextStyle(
                  fontFamily: 'DMSans', 
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: const Color(0xFF475569),
                ),
                textAlign: TextAlign.center,
              ),

              if (exception.conflicts.isNotEmpty) ...[
                SizedBox(height: getProportionateScreenHeight(16)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        exception.type == 'scalable_floor_exceeded'
                            ? (exception.conflicts.length > 1
                                ? "Specifically, your flexible limits for:"
                                : "Specifically, your flexible limit for:")
                            : (exception.conflicts.length > 1
                                ? "Specifically, your fixed limits for:"
                                : "Specifically, your fixed limit for:"),
                        style: TextStyle(
                          fontFamily: 'DMSans', 
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        exception.conflicts.map((c) => c.replaceAll('_', ' ')).join(', '),
                        style: TextStyle(
                          fontFamily: 'DMMono', 
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        exception.type == 'scalable_floor_exceeded'
                            ? (exception.conflicts.length > 1 
                                ? "need more funding to stay above their safe minimums. Try increasing your total budget."
                                : "needs more funding to stay above its safe minimum. Try increasing your total budget.")
                            : (exception.conflicts.length > 1
                                ? "add up to more than your new total. You'll need to lower those first to proceed."
                                : "is more than your new total. You'll need to lower it first to proceed."),
                        style: TextStyle(
                          fontFamily: 'DMSans', 
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: getProportionateScreenHeight(28)),

              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: BudgetColors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "I understand",
                  style: TextStyle(
                    fontFamily: 'DMSans', 
                    fontSize: 15,
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
