import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/portfolio_analysis_providers.dart';
import '../discipline_components/generic_info_sheet.dart';

class ExpensiveFundsSection extends ConsumerStatefulWidget {
  const ExpensiveFundsSection({super.key});

  @override
  ConsumerState<ExpensiveFundsSection> createState() => _ExpensiveFundsSectionState();
}

class _ExpensiveFundsSectionState extends ConsumerState<ExpensiveFundsSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
    final perfAsync = ref.watch(portfolioPerformanceProvider);
    final perf = perfAsync.value;

    final expensiveFunds = perf?.expensiveFunds ?? [];

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
                        'Funds with an expense ratio above category median reduce your long-term compounding returns.',
                        'Switching to direct or low-cost index alternatives can save substantial wealth over 5-10+ years.',
                      ],
                    ),
                  );
                },
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: expensiveFunds.isEmpty
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Portfolio is Cost Optimized',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '0 expensive funds found. All schemes have low direct expense ratios.',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      ...expensiveFunds.map((fund) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fund.schemeName,
                                        style: const TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        'Expense ratio: ${fund.expenseRatio}% (Category avg: ${fund.categoryAvgExpenseRatio}%)',
                                        style: const TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 11,
                                          color: Color(0xFFEF4444),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
