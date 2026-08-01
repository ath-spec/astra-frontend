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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: const [
              PerformanceGaugeSection(),
              MutualFundPerformanceSection(),
              ExpensiveFundsSection(),
            ],
          ),
        ),
      ],
    );
  }
}
