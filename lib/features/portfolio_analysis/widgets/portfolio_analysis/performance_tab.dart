import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/features/portfolio_analysis/data/portfolio_analysis_providers.dart';
import 'package:astra_frontend/features/portfolio_analysis/models/portfolio_analysis_models.dart';

import 'performance_components/performance_gauge_section.dart';
import 'performance_components/mutual_fund_performance_section.dart';
import 'performance_components/expensive_funds_section.dart';

class PerformanceTab extends ConsumerStatefulWidget {
  const PerformanceTab({super.key});

  @override
  ConsumerState<PerformanceTab> createState() => _PerformanceTabState();
}

class _PerformanceTabState extends ConsumerState<PerformanceTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final perfAsync = ref.watch(portfolioPerformanceProvider);

    final level = perfAsync.value?.level ?? PerformanceLevel.veryStrong;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(portfolioPerformanceProvider);
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                PerformanceGaugeSection(level: level),
                const SizedBox(height: 56),
                const MutualFundPerformanceSection(),
                const SizedBox(height: 56),
                const ExpensiveFundsSection(),
                const SizedBox(height: 56),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
