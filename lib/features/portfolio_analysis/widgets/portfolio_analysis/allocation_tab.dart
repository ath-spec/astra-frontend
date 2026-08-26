import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/features/portfolio_analysis/data/portfolio_analysis_providers.dart';
import 'package:astra_frontend/features/portfolio_analysis/models/portfolio_analysis_models.dart';

import 'allocation_components/allocation_gauge_section.dart';
import 'allocation_components/allocation_factors_card.dart';
import 'allocation_components/allocation_suggestions_section.dart';
import 'allocation_components/index_fund_exposure_section.dart';
import 'allocation_components/equity_sector_exposure.dart';

class AllocationTab extends ConsumerStatefulWidget {
  const AllocationTab({super.key});

  @override
  ConsumerState<AllocationTab> createState() => _AllocationTabState();
}

class _AllocationTabState extends ConsumerState<AllocationTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final allocAsync = ref.watch(portfolioAllocationProvider);

    final level = allocAsync.value?.level ?? AllocationLevel.veryAggressive;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(portfolioAllocationProvider);
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                AllocationGaugeSection(level: level),
                const SizedBox(height: 56),
                const AllocationFactorsCard(),
                const SizedBox(height: 56),
                const AllocationSuggestionsSection(),
                const SizedBox(height: 56),
                const IndexFundExposureSection(),
                const SizedBox(height: 56),
                const EquitySectorExposureSection(),
                const SizedBox(height: 56),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
