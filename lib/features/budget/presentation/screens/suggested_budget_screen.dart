import 'package:astra_frontend/features/budget/theme/budget_colors.dart';

import 'package:astra_frontend/features/budget/data/models/budget_models.dart'
    hide BudgetDiagnosisResponse;
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/budget/presentation/screens/finalize_total_budget_screen.dart';

import 'package:astra_frontend/core/instrumentation/funnel_tracker.dart';

import 'package:astra_frontend/services/service_providers.dart';
import 'package:astra_frontend/services/analytics_service.dart';

class SuggestedBudgetScreen extends ConsumerStatefulWidget {
  final double totalBudget;
  const SuggestedBudgetScreen({super.key, required this.totalBudget});

  @override
  ConsumerState<SuggestedBudgetScreen> createState() =>
      _SuggestedBudgetScreenState();
}

class _SuggestedBudgetScreenState extends ConsumerState<SuggestedBudgetScreen> {
  int _reasonIndex = 0;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('suggested_budget_screen');
    FunnelTracker.instance.logStep(
      'budget_creation',
      stepNumber: 3,
      stepName: 'suggested',
    );
    _loadReasonIndex();
  }

  Future<void> _loadReasonIndex() async {
    if (mounted) {
      setState(() {
        _reasonIndex = 0;
      });
    }
  }

  // ── Local fallback reasoning (mirrors Go logic; used only when backend field is empty) ──
  List<String> _buildLocalReasoning(Diagnosis? diag, double budget) {
    final idx = _reasonIndex % 5;

    if (diag == null || diag.averageExpenses <= 0) {
      final fallbackVariations = [
        [
          'This is a sensible starting point for first-time budgeters.',
          'As you track more spending, we\'ll refine this based on your real patterns.',
        ],
        [
          'Here is a safe baseline to get you started.',
          'Once you record more expenses, we\'ll tailor this to your actual habits.',
        ],
        [
          'A practical initial budget for your journey.',
          'We\'ll automatically adjust this as we learn your true spending style.',
        ],
        [
          'Starting simple makes budgeting easier.',
          'Keep tracking your spends, and we\'ll personalize this over time.',
        ],
        [
          'A gentle introduction to managing your money.',
          'This target will evolve as we gather more data on your habits.',
        ],
      ];
      return fallbackVariations[idx];
    }

    final reasons = <String>[];
    final avgExpenses = diag.averageExpenses;
    final avgIncome = diag.averageIncome;
    final avgSavings = diag.averageSavings;
    final fmt = NumberFormat('#,##,###');

    // Reason 1 — why this number
    if (avgIncome > 0) {
      final savingsRate = avgSavings / avgIncome;
      final rateStr = (savingsRate * 100).round();
      final pct = (budget / avgExpenses * 100).round();

      if (savingsRate <= 0.20) {
        final vars = [
          'Your savings rate is $rateStr% of income. We nudged the budget to $pct% of your average spend to build a stronger cushion.',
          'Currently saving $rateStr% of what you earn. This budget is set at $pct% of your usual spend to help you save more.',
          'With a $rateStr% savings rate, setting your budget to $pct% of typical expenses gives your savings a healthy boost.',
          'You save about $rateStr% of your income. We trimmed your target to $pct% of your average spend to accelerate your wealth.',
          'To improve your $rateStr% savings rate, this budget targets $pct% of your historical spend for a better safety net.',
        ];
        reasons.add(vars[idx]);
      } else {
        final vars = [
          'You\'re already saving $rateStr% of your income — great discipline. We matched this budget to your average spend so you don\'t over-restrict yourself.',
          'A fantastic $rateStr% savings rate! This budget aligns closely with your usual spend to keep things comfortable.',
          'Saving $rateStr% of your earnings is excellent. We kept the budget near your average so you can maintain your lifestyle.',
          'Your $rateStr% savings rate shows great control. This target matches your average spend, giving you room to breathe.',
          'Impressive discipline with a $rateStr% savings rate. We aligned this budget to your typical expenses for a balanced life.',
        ];
        reasons.add(vars[idx]);
      }
    } else {
      final expStr = fmt.format(avgExpenses);
      final vars = [
        'Based on your average monthly spend of ₹$expStr, this budget gives you a realistic but slightly tighter target.',
        'Looking at your typical ₹$expStr monthly spend, we crafted a practical and slightly leaner budget.',
        'Your historical spend is around ₹$expStr. This target is designed to be achievable while encouraging slight savings.',
        'With an average spend of ₹$expStr, this budget offers a smart, realistic goal to keep your finances tight.',
        'We analyzed your ₹$expStr average spend to set a budget that is both realistic and gently restrictive.',
      ];
      reasons.add(vars[idx]);
    }

    // Reason 2 — savings implication
    if (avgIncome > 0) {
      final monthly = avgIncome - budget;
      if (monthly > 0) {
        final yearly = (monthly * 12).round();
        final mStr = fmt.format(monthly.round());
        final yStr = fmt.format(yearly);
        final vars = [
          'Sticking to this budget means saving roughly ₹$mStr/month — ₹$yStr over the year.',
          'Hitting this target leaves you with ₹$mStr each month, adding up to ₹$yStr in annual savings.',
          'If you follow this plan, you\'ll retain about ₹$mStr monthly, which means ₹$yStr saved by year-end.',
          'This budget sets you up to save ₹$mStr every month, projected at ₹$yStr over a full year.',
          'Stay on track and you could pocket ₹$mStr per month, building a ₹$yStr reserve annually.',
        ];
        reasons.add(vars[idx]);
      } else {
        final vars = [
          'This budget is close to your income — keep an eye on discretionary categories to avoid dipping into savings.',
          'Your target is near your total earnings. Watch your non-essential spends carefully to protect your savings.',
          'This budget runs tight against your income. Try limiting lifestyle expenses to stay in the green.',
          'With this budget near your income cap, tracking your wants vs needs will be crucial.',
          'Earnings and this budget are closely matched. Be mindful of luxury spends to avoid a negative balance.',
        ];
        reasons.add(vars[idx]);
      }
    }

    // Reason 3 — vs avg spend
    final diff = avgExpenses - budget;
    if (diff > 50) {
      final diffStr = fmt.format(diff.round());
      final vars = [
        'It\'s ₹$diffStr less than what you typically spend — achievable with small cuts in non-essential categories.',
        'This is ₹$diffStr below your average spend. Trimming a few lifestyle expenses will get you there.',
        'We reduced your typical spend by ₹$diffStr. A few mindful adjustments to daily luxuries make this very doable.',
        'Targeting ₹$diffStr less than your norm. Focusing on needs over wants makes this completely realistic.',
        'By cutting ₹$diffStr from your usual expenses, this budget encourages smarter daily choices without heavy sacrifices.',
      ];
      reasons.add(vars[idx]);
    } else {
      final vars = [
        'This aligns closely with your typical spend — no dramatic lifestyle changes needed to stay on track.',
        'Almost identical to your usual expenses. You can meet this goal without changing your daily habits.',
        'This budget mirrors your historical spending perfectly. Just keep doing what you\'re doing.',
        'Very close to your average spend. Staying on track requires zero drastic lifestyle shifts.',
        'This target matches your normal routine. You won\'t need to make any big sacrifices to succeed.',
      ];
      reasons.add(vars[idx]);
    }

    return reasons;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final diag = ref.watch(budgetStateProvider).currentDiagnosis;

    // Use our local rotating reasoning logic to ensure the user gets fresh variations every time,
    // bypassing the static text provided by the backend.
    final List<String> reasons = _buildLocalReasoning(diag, widget.totalBudget);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: getProportionateScreenHeight(180),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back Button
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                          child: ZeyroIconButton(
                            eventName: 'suggested_budget_screen_back_tapped',
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: BudgetColors.black,
                              size: 20,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(0)),

                      // Title
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(24),
                          ),
                          child: Text(
                            "Your suggested monthly budget",
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: getProportionateScreenWidth(18),
                              fontWeight: FontWeight.w600,
                              color: BudgetColors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(32)),

                      // Budget Amount Pill
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(24),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(32),
                            vertical: getProportionateScreenHeight(16),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xfffbd1d3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "₹${NumberFormat('#,##,###').format(widget.totalBudget)}",
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: BudgetColors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(20)),

                      // Bar Chart
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(24),
                        ),
                        child: _SuggestedBarChart(
                          totalBudget: widget.totalBudget,
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(28)),

                      // Dynamic "Why this budget?" card
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(24),
                        ),
                        child: Container(
                          width: double.infinity,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: const Color(0xfffbd1d3),
                            borderRadius: BorderRadius.circular(
                              getProportionateScreenWidth(4),
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Background Image
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                width: getProportionateScreenWidth(150),
                                child: Image.asset(
                                  "lib/core/images/whybudget.webp",
                                  fit: BoxFit.contain,
                                ),
                              ),
                              // Gradient Overlay
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        const Color(0xfffbd1d3),
                                        const Color(0xfffbd1d3),
                                        const Color(
                                          0xfffbd1d3,
                                        ).withOpacity(0.0),
                                      ],
                                      stops: const [0.0, 0.3, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                              // Dynamic reasoning bullets
                              Padding(
                                padding: EdgeInsets.all(
                                  getProportionateScreenWidth(16),
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: 0.6,
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Why ₹${NumberFormat('#,##,###').format(widget.totalBudget)}?",
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: BudgetColors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      for (final reason in reasons) ...[
                                        _buildBulletPoint(
                                          reason,
                                          isDark: false,
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Floating Continue Button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: getProportionateScreenWidth(32),
                    right: getProportionateScreenWidth(32),
                    bottom: getProportionateScreenHeight(16),
                  ),
                  child: ZeyroButton(
                    eventName: 'suggested_budget_screen_continue_tapped',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FinalizeBudgetScreen(
                            totalBudget: widget.totalBudget,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BudgetColors.black,
                      foregroundColor: BudgetColors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 4,
                      shadowColor: BudgetColors.black.withOpacity(0.3),
                    ),
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, {bool isDark = false}) {
    final color = isDark ? Colors.white70 : BudgetColors.grey7;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '• ',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'DMSans',
                fontSize: 10,
                color: color,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedBarChart extends ConsumerStatefulWidget {
  final double totalBudget;
  const _SuggestedBarChart({required this.totalBudget});

  @override
  ConsumerState<_SuggestedBarChart> createState() => _SuggestedBarChartState();
}

class _SuggestedBarChartState extends ConsumerState<_SuggestedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // strong ease-out curve recommended by emil-design-eng
  final Curve _easeOut = const Cubic(0.23, 1, 0.32, 1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diag = ref.watch(budgetStateProvider).currentDiagnosis;
    final history = (diag?.historicalSpending ?? [])
        .map((e) => HistoricalSpending.fromJson(e as Map<String, dynamic>))
        .toList();

    double maxSpend = widget.totalBudget > 0 ? widget.totalBudget : 1.0;
    for (var h in history) {
      if (h.expenses > maxSpend) maxSpend = h.expenses;
    }

    double budgetHeightFactor = maxSpend > 0
        ? (widget.totalBudget / maxSpend)
        : 0.0;

    final double maxBarHeight = getProportionateScreenHeight(90);
    final double barBottom = getProportionateScreenHeight(120);
    final double containerHeight = getProportionateScreenHeight(140);
    final double lineTop = barBottom - (maxBarHeight * budgetHeightFactor);

    final lineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.65, 1.0, curve: _easeOut),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // 1. Dotted average line (drawn behind bars)
        Positioned(
          top: lineTop,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: lineAnim,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: lineAnim.value,
                  child: Opacity(
                    opacity: lineAnim.value.clamp(0.0, 1.0),
                    child: child,
                  ),
                ),
              );
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: List.generate(
                    (constraints.constrainWidth() /
                            getProportionateScreenWidth(10))
                        .floor(),
                    (index) => SizedBox(
                      width: getProportionateScreenWidth(5),
                      height: getProportionateScreenHeight(1),
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.black38),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // 2. Bars (padded on the right so they never overlap the text)
        SizedBox(
          height: containerHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _generateBars(history, maxSpend, maxBarHeight),
            ),
          ),
        ),

        // 3. Total Budget Text (fixed at top to avoid overlap)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: lineAnim,
            builder: (context, child) {
              return Opacity(
                opacity: lineAnim.value.clamp(0.0, 1.0),
                child: child,
              );
            },
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(4),
                  vertical: getProportionateScreenHeight(1),
                ),
                color: Colors.transparent, // No longer needs to mask bars
                child: Text(
                  "₹${NumberFormat('#,##,###').format(widget.totalBudget)}",
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: getProportionateScreenWidth(12),
                    fontWeight: FontWeight.w600,
                    color: BudgetColors.foreground,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _generateBars(
    List<HistoricalSpending> history,
    double maxSpend,
    double maxBarHeight,
  ) {
    final now = DateTime.now();
    final List<Widget> bars = [];

    final historyMap = {for (var h in history) '${h.year}-${h.month}': h};

    int barIndex = 0;
    for (int i = 6; i >= 1; i--) {
      int m = now.month - i;
      int y = now.year;
      while (m <= 0) {
        m += 12;
        y -= 1;
      }
      final date = DateTime(y, m, 1);
      final monthStr = DateFormat('MMM').format(date);

      final h = historyMap['$y-$m'];
      double heightFactor = 0.0;
      if (h != null && maxSpend > 0) {
        heightFactor = h.expenses / maxSpend;
      }

      double start = barIndex * 0.05;
      double end = start + 0.40;
      if (end > 0.65) end = 0.65;

      bars.add(_buildBar(monthStr, heightFactor, maxBarHeight, start, end));
      barIndex++;
    }
    return bars;
  }

  Widget _buildBar(
    String month,
    double heightFactor,
    double maxBarHeight,
    double start,
    double end,
  ) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: _easeOut),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: (animation.value * 2).clamp(0.0, 1.0),
              child: Container(
                width: getProportionateScreenWidth(14),
                height: maxBarHeight * heightFactor * animation.value,
                decoration: BoxDecoration(color: BudgetColors.foreground),
              ),
            );
          },
        ),
        SizedBox(height: getProportionateScreenHeight(8)),
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: (animation.value * 2).clamp(0.0, 1.0),
              child: child,
            );
          },
          child: Text(
            month,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'DMSans',
              fontSize: getProportionateScreenWidth(10),
              color: BudgetColors.grey7,
            ),
          ),
        ),
      ],
    );
  }
}
