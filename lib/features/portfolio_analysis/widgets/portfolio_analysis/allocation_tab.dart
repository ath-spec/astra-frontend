import 'package:flutter/material.dart';

import 'allocation_components/allocation_gauge_section.dart';
import 'allocation_components/allocation_factors_card.dart';
import 'allocation_components/allocation_suggestions_section.dart';
import 'allocation_components/index_fund_exposure_section.dart';
import 'allocation_components/equity_sector_exposure.dart';

class AllocationTab extends StatefulWidget {
  const AllocationTab({super.key});

  @override
  State<AllocationTab> createState() => _AllocationTabState();
}

class _AllocationTabState extends State<AllocationTab> with AutomaticKeepAliveClientMixin {
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
              const AllocationGaugeSection(),
              standardGap,
              const AllocationFactorsCard(),
              standardGap,
              const AllocationSuggestionsSection(),
              standardGap,
              const IndexFundExposureSection(),
              standardGap,
              const EquitySectorExposureSection(),
              standardGap,
            ],
          ),
        ),
      ],
    );
  }
}
