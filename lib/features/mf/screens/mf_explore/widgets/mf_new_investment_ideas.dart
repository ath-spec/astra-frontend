import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../../data/catalog_providers.dart';
import '../../../data/catalog_models.dart';
import 'mf_fund_list_card.dart';
import '../../mf_collection/mf_collection_screen.dart';

class MfNewInvestmentIdeas extends ConsumerWidget {
  const MfNewInvestmentIdeas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(allCatalogFundsProvider);

    if (catalogAsync.isLoading) {
      return _buildLoadingState();
    }

    if (catalogAsync.hasError) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          "Couldn't load investment ideas.",
          style: TextStyle(fontFamily: 'DMSans', color: Color(0xFF64748B)),
        ),
      );
    }

    final catalogFunds = catalogAsync.valueOrNull ?? <CatalogFund>[];

    List<CatalogFund> sorted(List<CatalogFund> src) {
      final list = List<CatalogFund>.from(src);
      list.sort((a, b) => (b.returns1y ?? 0).compareTo(a.returns1y ?? 0));
      return list;
    }

    final highGrowthSource = sorted(
      catalogFunds.where((f) {
        final category = f.category.toLowerCase();
        return category.contains('thematic') || f.riskLevel.toLowerCase() == 'high';
      }).toList(),
    ).take(3).toList();

    final safeInvestingSource = catalogFunds.where((f) {
      final category = f.category.toLowerCase();
      return category.contains('debt') ||
          category.contains('liquid') ||
          category.contains('corporate bond') ||
          category.contains('conservative');
    }).take(3).toList();

    final highGrowthFunds = highGrowthSource
        .map((f) => MfFundItemData(
              name: f.schemeName,
              category: f.category,
              returns: '${(f.returns1y ?? 0).toStringAsFixed(2)}%',
              logoIcon: Icons.trending_up_rounded,
              logoColor: Colors.deepPurple,
              schemeCode: f.schemeCode,
            ))
        .toList();

    final safeInvestingFunds = safeInvestingSource
        .map((f) => MfFundItemData(
              name: f.schemeName,
              category: f.category,
              returns: '${(f.returns1y ?? 0).toStringAsFixed(2)}%',
              logoIcon: Icons.water_drop,
              logoColor: Colors.blue,
              schemeCode: f.schemeCode,
            ))
        .toList();

    final cards = <Widget>[];

    if (highGrowthFunds.isNotEmpty) {
      cards.add(
        SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.8,
          child: MfFundListCard(
            margin: const EdgeInsets.only(left: 16.0, right: 8.0),
            borderColor: HSLColor.fromColor(Colors.white).withLightness((1.0 - 0.12).clamp(0.0, 1.0)).toColor(),
            sectionTitle: '', // We use our own header above
            cardTitle: 'High Growth',
            cardSubtitle: 'Top ideas with high potential returns.',
            cardGraphic: SizedBox(
              width: 90,
              height: 90,
              child: Image.asset(
                'lib/core/images/growth_collections.webp',
                fit: BoxFit.contain,
              ),
            ),
            onViewCollection: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const MfCollectionScreen(
                    title: 'High Growth',
                    subtitle: 'Top ideas with high potential returns.',
                    imagePath: 'lib/core/images/growth_collections.webp',
                  ),
                ),
              );
            },
            funds: highGrowthFunds,
          ),
        ),
      );
    }

    if (safeInvestingFunds.isNotEmpty) {
      cards.add(
        SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.8,
          child: MfFundListCard(
            margin: EdgeInsets.only(left: cards.isEmpty ? 16.0 : 8.0, right: 16.0),
            borderColor: HSLColor.fromColor(Colors.white).withLightness((1.0 - 0.12).clamp(0.0, 1.0)).toColor(),
            sectionTitle: '',
            cardTitle: 'Safe Investing',
            cardSubtitle: 'Protect your capital with safer options.',
            cardGraphic: SizedBox(
              width: 90,
              height: 90,
              child: Image.asset(
                'lib/core/images/safe_investments.webp',
                fit: BoxFit.contain,
              ),
            ),
            onViewCollection: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const MfCollectionScreen(
                    title: 'Safe Investing',
                    subtitle: 'Protect your capital with safer options.',
                    imagePath: 'lib/core/images/safe_investments.webp',
                  ),
                ),
              );
            },
            funds: safeInvestingFunds,
          ),
        ),
      );
    }

    // Hide the whole section if neither category has any real data.
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Investment Ideas',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cards,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Investment Ideas',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 8.0),
                child: AppThemeShimmerCard(
                  width: 280,
                  height: 320,
                  barWidths: [90, 160, 90, 90],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8.0, right: 16.0),
                child: AppThemeShimmerCard(
                  width: 280,
                  height: 320,
                  barWidths: [90, 160, 90, 90],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
