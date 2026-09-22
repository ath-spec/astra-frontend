import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../../data/catalog_providers.dart';
import '../../../data/catalog_models.dart';
import '../../fund_profile/mf_fund_profile_screen.dart';
import '../../mf_collection/mf_alternative_collection_screen.dart';

class MfAlternativeFunds extends ConsumerWidget {
  const MfAlternativeFunds({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(allCatalogFundsProvider);

    List<CatalogFund> altFunds = [];
    if (catalogAsync.hasValue && catalogAsync.value != null) {
      altFunds = catalogAsync.value!.where(
        (f) => f.category.toLowerCase().contains('debt') ||
               f.category.toLowerCase().contains('liquid') ||
               f.category.toLowerCase().contains('arbitrage') ||
               f.category.toLowerCase().contains('hybrid'),
      ).take(5).toList();
    }

    // Hide the whole section once loaded successfully with no matching funds.
    if (!catalogAsync.isLoading && !catalogAsync.hasError && altFunds.isEmpty) {
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alternative to FD',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Better returns than FDs, liquid and tax efficient',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => const MfAlternativeCollectionScreen(
                        title: 'Alternative to FD',
                        subtitle: 'Better returns than FDs, liquid and tax efficient',
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Row(
                    children: [
                      const Text(
                        'View all',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (catalogAsync.isLoading)
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) => const AppThemeShimmerCard(
                width: 220,
                height: 140,
                barWidths: [80, 140, 60, 70],
              ),
            ),
          )
        else if (catalogAsync.hasError)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Couldn't load alternative funds.", style: TextStyle(fontFamily: 'DMSans', color: Color(0xFF64748B))),
          )
        else
          AspectRatio(
            aspectRatio: 390 / 140,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth * (280 / 390);
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: altFunds.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final fund = altFunds[index];
                    final style = _iconForIndex(index);
                    return _buildAlternativeCard(
                      context: context,
                      width: cardWidth,
                      schemeCode: fund.schemeCode,
                      name: fund.schemeName,
                      category: fund.category,
                      expense: '${fund.expenseRatio.toStringAsFixed(2)}%',
                      aum: _formatAum(fund.aum),
                      returns: '${(fund.returns3y ?? 7.8).toStringAsFixed(1)}%',
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

  // `fund.aum` comes straight from the catalog in raw rupees (e.g.
  // 18450000000), not crores — labeling that number "Cr" as-is produced the
  // "crazy amount of 0's" (₹18450000000 Crs). Standardize on Cr, folding
  // over to "K Cr" once it crosses 1,000 Cr so the value stays short.
  String _formatAum(double rupees) {
    final crores = rupees / 10000000;
    if (crores >= 1000) {
      return '₹${(crores / 1000).toStringAsFixed(1)}K Cr';
    }
    return '₹${crores.toStringAsFixed(0)} Cr';
  }

  (IconData, Color) _iconForIndex(int index) {
    const styles = [
      (Icons.water_drop_outlined, Colors.blue),
      (Icons.balance, Color(0xFFDC2626)),
      (Icons.eco, Color(0xFF15803D)),
      (Icons.account_balance, Colors.red),
      (Icons.money, Colors.amber),
    ];
    return styles[index % styles.length];
  }

  Widget _buildAlternativeCard({
    required BuildContext context,
    required double width,
    required String schemeCode,
    required String name,
    required String category,
    required String expense,
    required String aum,
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
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE2E8F0)),
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
            Container(
              height: 1,
              color: const Color(0xFFF1F5F9),
              margin: const EdgeInsets.only(bottom: 12),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildStat('Expense ratio', expense)),
                const SizedBox(width: 8),
                Expanded(child: _buildStat('AUM', aum)),
                const SizedBox(width: 8),
                Expanded(child: _buildStat('3Y Returns', returns, isGreen: true)),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
