import 'package:flutter/material.dart';

import 'performance_components/performance_gauge_section.dart';
import 'performance_components/mutual_fund_performance_section.dart';
import 'performance_components/expensive_funds_section.dart';

class PerformanceTab extends StatefulWidget {
  const PerformanceTab({super.key});

  @override
  State<PerformanceTab> createState() => _PerformanceTabState();
}

class _PerformanceTabState extends State<PerformanceTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final standardGap = SizedBox(height: MediaQuery.sizeOf(context).height * 0.04);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const PerformanceGaugeSection(),
              standardGap,
              const MutualFundPerformanceSection(),
              standardGap,
              const ExpensiveFundsSection(),
              standardGap,
            ],
          ),
        ),
      ],
    );
  }
}
