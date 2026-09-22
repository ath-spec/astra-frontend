import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../../data/catalog_providers.dart';
import '../../../data/catalog_models.dart';
import '../../fund_profile/mf_fund_profile_screen.dart';

class MfTrendingFunds extends ConsumerWidget {
  const MfTrendingFunds({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(allCatalogFundsProvider);

    List<CatalogFund> trendingList = [];
    if (catalogAsync.hasValue && catalogAsync.value != null) {
      trendingList = List<CatalogFund>.from(catalogAsync.value!)
        ..sort((a, b) => (b.returns3y ?? 0.0).compareTo(a.returns3y ?? 0.0));
      if (trendingList.length > 5) {
        trendingList = trendingList.take(5).toList();
      }
    }

    // Hide the whole section once loaded successfully with no funds at all.
    if (!catalogAsync.isLoading && !catalogAsync.hasError && trendingList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Trending Funds',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              Row(
                children: const [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (catalogAsync.isLoading)
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) => const AppThemeShimmerCard(
                width: 240,
                height: 160,
                barWidths: [80, 150, 60, 70],
              ),
            ),
          )
        else if (catalogAsync.hasError)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Couldn't load trending funds.",
              style: TextStyle(fontFamily: 'DMSans', color: Color(0xFF64748B)),
            ),
          )
        else
          AspectRatio(
            aspectRatio: 390 / 160,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth * (300 / 390);
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: trendingList.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final fund = trendingList[index];
                    final style = _iconForIndex(index);
                    return _buildTrendingCard(
                      context,
                      width: cardWidth,
                      schemeCode: fund.schemeCode,
                      name: fund.schemeName,
                      category: fund.category,
                      riskLevel: fund.riskLevel,
                      expense: '${fund.expenseRatio.toStringAsFixed(2)}%',
                      returns: '${(fund.returns3y ?? 18.5).toStringAsFixed(1)}%',
                      logoIcon: style.$1,
                      logoColor: style.$2,
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  (IconData, Color) _iconForIndex(int index) {
    const styles = [
      (Icons.pets, Colors.teal),
      (Icons.bar_chart, Colors.deepPurple),
      (Icons.trending_up, Colors.orange),
      (Icons.savings, Colors.blueGrey),
      (Icons.rocket_launch, Colors.indigo),
    ];
    return styles[index % styles.length];
  }

  Widget _buildTrendingCard(
    BuildContext context, {
    required double width,
    required String schemeCode,
    required String name,
    required String category,
    required String riskLevel,
    required String expense,
    required String returns,
    required IconData logoIcon,
    required Color logoColor,
  }) {
    return GestureDetector(
      onTap: () => MfFundProfileScreen.showModal(context, schemeCode),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFF1F5F9), // Slate 100
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Icon(logoIcon, color: logoColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9CA3AF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Dashed divider natively using a linear gradient or just a solid line
            Container(
              height: 1,
              color: const Color(0xFFF1F5F9),
              margin: const EdgeInsets.only(bottom: 12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('Risk', riskLevel),
                _buildStat('Expense ratio', expense),
                _buildStat('3Y Returns', returns, isGreen: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, {bool isGreen = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isGreen ? const Color(0xFF10B981) : const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ],
    );
  }
}
