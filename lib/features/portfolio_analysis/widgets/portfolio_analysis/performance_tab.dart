import 'package:flutter/material.dart';

import 'performance_components/performance_gauge_section.dart';
import 'performance_components/mutual_fund_performance_section.dart';
import 'performance_components/expensive_funds_section.dart';

class PerformanceTab extends StatelessWidget {
  const PerformanceTab({super.key});

  @override
  Widget build(BuildContext context) {
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
