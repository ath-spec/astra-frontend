import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/portfolio_analysis_providers.dart';
import 'mutual_fund_performance_sheet.dart';

class MutualFundPerformanceSection extends ConsumerStatefulWidget {
  const MutualFundPerformanceSection({super.key});

  @override
  ConsumerState<MutualFundPerformanceSection> createState() => _MutualFundPerformanceSectionState();
}

class _MutualFundPerformanceSectionState extends ConsumerState<MutualFundPerformanceSection> {
  @override
  Widget build(BuildContext context) {
    final perfAsync = ref.watch(portfolioPerformanceProvider);
    final perf = perfAsync.value;

    final double yourReturns = perf?.totalReturnPct ?? 0.0;
    final benchmarks = perf?.benchmarks ?? [];

    double niftyReturns = 14.2;
    double goldReturns = 12.8;

    for (final b in benchmarks) {
      if (b.name.toLowerCase().contains('nifty')) niftyReturns = b.benchmarkReturnPct;
      if (b.name.toLowerCase().contains('gold')) goldReturns = b.benchmarkReturnPct;
    }

    final double alpha = yourReturns - niftyReturns;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Performance vs Benchmarks',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => const MutualFundPerformanceSheet(),
                  );
                },
                child: const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
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
            child: Column(
              children: [
                _buildBenchmarkRow(
                  label: 'Your MF Portfolio (3Y CAGR)',
                  returns: '${yourReturns.toStringAsFixed(1)}%',
                  isHighlighted: true,
                  color: const Color(0xFF10B981),
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 24),
                _buildBenchmarkRow(
                  label: 'Nifty 50 Benchmark',
                  returns: '${niftyReturns.toStringAsFixed(1)}%',
                  isHighlighted: false,
                  color: const Color(0xFF64748B),
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 24),
                _buildBenchmarkRow(
                  label: 'Gold Benchmark',
                  returns: '${goldReturns.toStringAsFixed(1)}%',
                  isHighlighted: false,
                  color: const Color(0xFFD97706),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: (alpha >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        alpha >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        color: alpha >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          alpha >= 0
                              ? 'Your portfolio generated +${alpha.toStringAsFixed(1)}% Alpha over the Nifty 50.'
                              : 'Your portfolio underperformed the Nifty 50 by ${alpha.abs().toStringAsFixed(1)}%.',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: alpha >= 0 ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkRow({
    required String label,
    required String returns,
    required bool isHighlighted,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: isHighlighted ? 14 : 13,
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
            color: isHighlighted ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
        Text(
          returns,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: isHighlighted ? 15 : 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
