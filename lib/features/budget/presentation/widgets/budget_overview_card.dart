import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/core/instrumentation/widgets/visibility_tracker.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/budget_summary_card.dart';
import 'package:intl/intl.dart';

class BudgetOverviewCard extends StatelessWidget {
  final double totalBudget;
  final double spentAmount;
  final double percentageUsed;
  final int daysRemaining;
  final double projectedSpend;
  final double incomeAmount;
  final String? budgetPeriodStart;
  final String? budgetPeriodEnd;
  final String title;
  final String? periodLabel;
  final Color backgroundColor;
  final Color textColor;
  final IconData topIcon;
  final bool isMini;
  final VoidCallback? onTopIconTap;
  final bool showIncomeOutcome;

  final Color? borderColor;
  final bool isCategoryCard;
  final bool showCapAndOverspent;
  final bool showBreakdownRow;
  final bool showRemainingAmount;
  final bool showTotalWithCurrentAmount;

  const BudgetOverviewCard({
    super.key,
    this.totalBudget = 5000,
    this.spentAmount = 0,
    this.percentageUsed = 0,
    this.daysRemaining = 0,
    this.projectedSpend = 0,
    this.incomeAmount = 0,
    this.budgetPeriodStart,
    this.budgetPeriodEnd,
    this.title = "Budget",
    this.periodLabel,
    this.backgroundColor = const Color(0xFF8EC8B3),
    this.textColor = const Color(0xFF133026),
    this.topIcon = Icons.settings_outlined,
    this.isMini = false,
    this.onTopIconTap,
    this.showIncomeOutcome = true,
    this.borderColor,
    this.isCategoryCard = false,
    this.showCapAndOverspent = true,
    this.showBreakdownRow = true,
    this.showRemainingAmount = true,
    this.showTotalWithCurrentAmount = false,
  });

  @override
  Widget build(BuildContext context) {
    final remainingAmount = totalBudget - spentAmount;
    final daysPassed = DateTime.now().day;
    final perDay = spentAmount / (daysPassed > 0 ? daysPassed : 1);
    final incomingAmount = incomeAmount;

    final nfWhole = NumberFormat('#,##,###');
    final nf = NumberFormat('#,##,###.00');

    String formatCompact(double value) {
      if (value >= 10000000) {
        final val = (value / 10000000).toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
        return '${val}Cr';
      } else if (value >= 100000) {
        final val = (value / 100000).toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
        return '${val}L';
      } else if (value >= 10000) {
        final val = (value / 1000).toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
        return '${val}k';
      } else {
        return nfWhole.format(value);
      }
    }

    String getPeriodText() {
      if (periodLabel != null && periodLabel!.isNotEmpty) {
        return periodLabel!;
      }
      DateTime? dt;
      if (budgetPeriodStart != null && budgetPeriodStart!.isNotEmpty) {
        dt = DateTime.tryParse(budgetPeriodStart!);
      }
      dt ??= DateTime.now();
      final monthName = DateFormat('MMMM').format(dt);
      return "This month ($monthName)";
    }

    return ZeyroVisibilityTracker(
      eventName: 'budget_overview_card_viewed',
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(isMini ? 16 : 20),
        vertical: getProportionateScreenHeight(
          isMini ? (showCapAndOverspent ? 18 : 16) : 20,
        ),
      ),
      decoration: BoxDecoration(
        color: backgroundColor, // Background color
        borderRadius: BorderRadius.circular(4),
        border: (isCategoryCard || borderColor != null) ? Border.all(color: borderColor ?? const Color(0xFFE2E8F0), width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "This month (Month)" (or Category Title) & Settings / Category Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isCategoryCard
                      ? title
                      : (title.isNotEmpty && title.toLowerCase() != 'budget' ? title : getPeriodText()),
                  style: TextStyle(
                    fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(isMini ? 12 : 14),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isMini)
                onTopIconTap != null
                    ? ZeyroIconButton(
                        eventName: 'budget_overview_card_forward_tapped',
                        onPressed: onTopIconTap ?? () {},
                        icon: Icon(topIcon, color: textColor),
                      )
                    : Icon(topIcon, color: textColor)
              else if (isCategoryCard)
                Icon(topIcon, color: textColor, size: getProportionateScreenWidth(16)),
            ],
          ),
          if (!isCategoryCard) ...[
            SizedBox(height: getProportionateScreenHeight(isMini ? 2 : 10)),
            Text(
              "Spent",
              style: TextStyle(
                fontFamily: 'DMSans', 
                fontSize: getProportionateScreenWidth(isMini ? 11 : 12),
                fontWeight: FontWeight.w500,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(isMini ? 2 : 4)),
          ] else
            SizedBox(height: getProportionateScreenHeight(isMini ? 4 : 16)),
          // Main amount and conditional Left/Cap
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
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
                          style: TextStyle(
                            fontFamily: 'DMSans', 
                            fontSize: getProportionateScreenWidth(isMini ? 12 : 14),
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        Text(
                          formatCompact(spentAmount),
                          style: TextStyle(
                            fontFamily: 'DMSans', 
                            fontSize: getProportionateScreenWidth(isMini ? 14 : 22),
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        if (showTotalWithCurrentAmount) ...[
                          Text(
                            " / ",
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: getProportionateScreenWidth(isMini ? 11 : 13),
                              fontWeight: FontWeight.w500,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                          ),
                          Text(
                            "₹${formatCompact(totalBudget)}",
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: getProportionateScreenWidth(isMini ? 11 : 13),
                              fontWeight: FontWeight.w500,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isCategoryCard && isMini) ...[
                    SizedBox(height: getProportionateScreenHeight(2)),
                    Text(
                      "Cap: ₹${formatCompact(totalBudget)}",
                      style: TextStyle(
                        fontFamily: 'DMSans', 
                        fontSize: getProportionateScreenWidth(10),
                        fontWeight: FontWeight.w500,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
              if (isCategoryCard && isMini && showCapAndOverspent)
                Text.rich(
                  TextSpan(
                    children: [
                      if (remainingAmount < 0) ...[
                        TextSpan(
                          text: "Overspent\n",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'DMSans', 
                            fontSize: getProportionateScreenWidth(9),
                            color: textColor.withValues(alpha: 0.9),
                          ),
                        ),
                        TextSpan(
                          text: "₹${formatCompact(remainingAmount.abs())}",
                          style: TextStyle(
                            fontFamily: 'DMSans', 
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ] else ...[
                        TextSpan(
                          text: "Left\n",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'DMSans', 
                            fontSize: 12,
                            color: textColor.withValues(alpha: 0.9),
                          ),
                        ),
                        TextSpan(
                          text: "₹${formatCompact(remainingAmount)}",
                          style: TextStyle(
                            fontFamily: 'DMSans', 
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          if (showRemainingAmount && showCapAndOverspent && !(isCategoryCard && isMini)) ...[
            SizedBox(height: getProportionateScreenHeight(isMini ? 2 : 4)),
            Text.rich(
              TextSpan(
                children: [
                  if (remainingAmount < 0) ...[
                    TextSpan(
                      text: "Overspent by ",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'DMSans', 
                        fontSize: getProportionateScreenWidth(isMini ? 12 : 14),
                        color: textColor.withValues(alpha: 0.9),
                      ),
                    ),
                    TextSpan(
                      text: "₹${formatCompact(remainingAmount.abs())}",
                      style: TextStyle(
                        fontFamily: 'DMSans', 
                        fontSize: getProportionateScreenWidth(isMini ? 10 : 12),
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ] else ...[
                    TextSpan(
                      text: "₹${formatCompact(remainingAmount)} ",
                      style: TextStyle(
                        fontFamily: 'DMSans', 
                        fontSize: getProportionateScreenWidth(isMini ? 12 : 14),
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    TextSpan(
                      text: "Left",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'DMSans', 
                        fontSize: getProportionateScreenWidth(isMini ? 12 : 14),
                        color: textColor.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (showCapAndOverspent)
            SizedBox(
              height: getProportionateScreenHeight(
                isMini ? 4 : (showRemainingAmount ? 24 : 16),
              ),
            ),
          // Days to go and per day amount
          if (!isMini || (isMini && !isCategoryCard))
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "$daysRemaining ",
                      style: TextStyle(fontFamily: 'DMSans', 
                        fontSize: getProportionateScreenWidth(isMini ? 12 : 14),
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    TextSpan(text: "Days to go",
                      style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
                        fontSize: getProportionateScreenWidth(isMini ? 12 : 14),
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMini)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "₹${perDay.isFinite ? nf.format(perDay) : '0'} ",
                        style: TextStyle(fontFamily: 'DMSans', 
                          fontSize: getProportionateScreenWidth(isMini ? 12 : 14),
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      TextSpan(
                        text: "Spent / day",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DMSans', 
                          fontSize: getProportionateScreenWidth(isMini ? 8 : 10),
                          color: textColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (isMini && !showCapAndOverspent) SizedBox(height: getProportionateScreenHeight(14)),
          if (isMini && showCapAndOverspent) SizedBox(height: getProportionateScreenHeight(2)),
          if (!isMini && showCapAndOverspent) SizedBox(height: getProportionateScreenHeight(4)),

          if (showCapAndOverspent)
            SizedBox(height: getProportionateScreenHeight(isMini ? 2 : 12)),
          // Custom Progress Bar
          if (showCapAndOverspent)
            Container(
              height: getProportionateScreenHeight(isMini ? 10 : 20),
              width: double.infinity,
              padding: EdgeInsets.all(isMini ? 1.5 : 2.5),
              decoration: BoxDecoration(
              color: BudgetColors.white,
              borderRadius: BorderRadius.circular(isMini ? 6 : 12),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Safely handle NaN or Infinity
                double safePercentage = percentageUsed;
                if (safePercentage.isNaN || safePercentage.isInfinite) {
                  safePercentage = 0.0;
                }
                
                final usedFlex = (safePercentage * 100).toInt().clamp(0, 100);
                final remainingFlex = 100 - usedFlex;

                return Row(
                  children: [
                    if (usedFlex > 0)
                      Expanded(
                        flex: usedFlex,
                        child: Container(
                          decoration: BoxDecoration(
                            color: textColor, // Exactly match text color
                            borderRadius: BorderRadius.circular(isMini ? 5 : 10),
                          ),
                        ),
                      ),
                    if (remainingFlex > 0)
                      Expanded(
                        flex: remainingFlex,
                        child: Container(),
                      ),
                  ],
                );
              },
            ),
          ),
          if (showCapAndOverspent)
            SizedBox(
              height: getProportionateScreenHeight(
                isMini ? 8 : (showBreakdownRow ? 24 : 16),
              ),
            ),
          // Spent and Due breakdown
          if (showBreakdownRow && showCapAndOverspent && (!isMini || (isMini && !isCategoryCard)))
            _buildBreakdownRow(
              isSelected: true,
              label: isCategoryCard ? "Cap" : "Budget",
              amount: "₹${formatCompact(totalBudget)}",
              isMini: isMini,
            ),

          if (!isMini && showIncomeOutcome) ...[
            if (showBreakdownRow)
              SizedBox(height: getProportionateScreenHeight(24)),
          ],
        ],
      ),
    )
    );
  }

  Widget _buildBreakdownRow({
    required bool isSelected,
    required String label,
    required String amount,
    required bool isMini,
  }) {
    return Row(
      children: [
        // Radio icon
        Container(
          width: getProportionateScreenWidth(isMini ? 12 : 16),
          height: getProportionateScreenWidth(isMini ? 12 : 16),
          padding: EdgeInsets.all(isMini ? 2 : 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BudgetColors.white,
            border: isSelected
                ? null
                : Border.all(color: textColor.withValues(alpha: 0.3), width: 1.5),
          ),
          child: isSelected
              ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: textColor,
                  ),
                )
              : null,
        ),
        SizedBox(width: getProportionateScreenWidth(isMini ? 8 : 12)),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
            fontSize: getProportionateScreenWidth(isMini ? 12 : 14),
            color: textColor,
          ),
        ),
        SizedBox(width: getProportionateScreenWidth(isMini ? 4 : 8)),
        // Dotted spacer
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final boxWidth = constraints.constrainWidth();
              const dashWidth = 3.0;
              final dashCount = (boxWidth / (2 * dashWidth)).floor();
              return Flex(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                direction: Axis.horizontal,
                children: List.generate(dashCount, (_) {
                  return SizedBox(
                    width: dashWidth,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.2),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        SizedBox(width: getProportionateScreenWidth(isMini ? 4 : 8)),
        Text(
          amount,
          style: TextStyle(fontFamily: 'DMSans', 
            fontSize: getProportionateScreenWidth(isMini ? 12 : 14),
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
