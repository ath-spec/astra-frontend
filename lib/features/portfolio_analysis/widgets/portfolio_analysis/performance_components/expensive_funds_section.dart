import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/animated_gradient_text.dart';
import '../../../../../core/widgets/typewriter_text.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../data/portfolio_analysis_providers.dart';
import '../../../data/portfolio_analysis_models.dart';
import '../discipline_components/generic_info_sheet.dart';
import 'expensive_funds_sheet.dart';

String _formatInr(double value) {
  final rounded = value.round();
  final digits = rounded.abs().toString();
  String formatted;
  if (digits.length <= 3) {
    formatted = digits;
  } else {
    final head = digits.substring(0, digits.length - 3);
    final tail = digits.substring(digits.length - 3);
    final headFormatted = head.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
      (m) => '${m[1]},',
    );
    formatted = '$headFormatted,$tail';
  }
  return '₹ $formatted';
}

class ExpensiveFundsSection extends ConsumerStatefulWidget {
  const ExpensiveFundsSection({super.key});

  @override
  ConsumerState<ExpensiveFundsSection> createState() => _ExpensiveFundsSectionState();
}

class _ExpensiveFundsSectionState extends ConsumerState<ExpensiveFundsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final perfAsync = ref.watch(portfolioPerformanceProvider);
    final perf = perfAsync.value;
    final funds = perf?.fundsPerformance ?? const <FundPerformanceData>[];

    double expensiveAmt = 0;
    for (final f in funds) {
      if (f.expenseRatio > 1.2) {
        expensiveAmt += f.currentValue;
      }
    }

    final totalValue = funds.fold<double>(0.0, (sum, f) => sum + f.currentValue);
    final expensiveRatio = totalValue > 0 ? (expensiveAmt / totalValue).clamp(0.0, 1.0) : 0.0;
    final fillRatio = expensiveRatio > 0 ? expensiveRatio : 0.05;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Expensive Funds',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => const GenericInfoSheet(
                      title: 'What are Expensive Funds?',
                      paragraphs: [
                        'Funds with a high expense ratio relative to their category are considered expensive.',
                        'Expense ratio is the annual fee charged by a fund. Over time, higher costs can meaningfully reduce net returns.',
                      ],
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${_formatInr(expensiveAmt)} ',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: -1.0,
                  ),
                ),
                const TextSpan(
                  text: 'invested in funds with higher expense ratios',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Progress Bar
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    height: 12,
                    width: MediaQuery.of(context).size.width *
                        fillRatio *
                        _animation.value,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53E3E),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) =>
                    const ExpensiveFundsSheet(initialIndex: 1),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'View funds',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Icon(Icons.chevron_right, size: 14, color: Color(0xFF0F172A)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          VisibilityDetector(
            key: const Key('ExpensiveFundsSection_InsightsLine'),
            onVisibilityChanged: (info) {
              if (!_hasAnimated && info.visibleFraction >= 0.15) {
                _hasAnimated = true;
                _controller.forward();
              }
            },
            child: Row(
              children: [
                AnimatedGradientShimmer(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'INSIGHTS BY ANALYTICS AGENT',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Divider(
                    color: Color(0xFFE2E8F0),
                    thickness: 1,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const AnimatedGradientShimmer(
              child: TypewriterText(
                text: 'Fees aren\'t eating into your gains every rupee is compounding efficiently for you.',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 64),

          // Disclaimer
          const Text(
            'This information is provided for informational purposes only and does not constitute investment advice, a recommendation, or an offer to buy or sell any securities. It is based on standardized methods and may not reflect your individual financial circumstances or risk profile. Consider consulting a financial advisor before making any investment decisions.',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              height: 1.5,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
