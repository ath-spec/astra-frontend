import 'package:flutter/material.dart';

import 'allocation_components/allocation_gauge_section.dart';
import 'allocation_components/allocation_factors_card.dart';
import 'allocation_components/allocation_suggestions_section.dart';
import 'allocation_components/index_fund_exposure_section.dart';
import 'allocation_components/equity_sector_exposure.dart';

class AllocationTab extends StatelessWidget {
  const AllocationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: const [
              AllocationGaugeSection(),
              AllocationFactorsCard(),
              SizedBox(height: 48),
              AllocationSuggestionsSection(),
              IndexFundExposureSection(),
              EquitySectorExposureSection(),
            ],
          ),
        ),
      ],
    );
  }
}
