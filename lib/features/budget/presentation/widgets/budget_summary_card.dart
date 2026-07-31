import 'package:flutter/material.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';

class BudgetSummaryCard extends StatelessWidget {
  final String amountWhole;
  final String amountDecimal;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const BudgetSummaryCard({
    super.key,
    required this.amountWhole,
    required this.amountDecimal,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(16),
        vertical: getProportionateScreenHeight(16),
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFE2EFE9), // Lighter teal/cream
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "₹",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(14),
                    fontWeight: FontWeight.w600,
                    color: textColor ?? const Color(0xFF133026),
                  ),
                ),
                Text(
                  amountWhole,
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(20),
                    fontWeight: FontWeight.w600,
                    color: textColor ?? const Color(0xFF133026),
                  ),
                ),
                if (amountDecimal.isNotEmpty)
                  Text(
                    ".$amountDecimal",
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: getProportionateScreenWidth(14),
                      fontWeight: FontWeight.w600,
                      color: textColor ?? const Color(0xFF133026),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(8)),
          Text(
            label,
            style: TextStyle(fontFamily: 'DMSans', 
              fontSize: getProportionateScreenWidth(12),
              color: textColor ?? const Color(0xFF133026),
            ),
          ),
        ],
      ),
    );
  }
}
