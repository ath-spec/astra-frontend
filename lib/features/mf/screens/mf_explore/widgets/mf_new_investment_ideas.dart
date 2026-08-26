import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/catalog_providers.dart';
import '../../../data/catalog_models.dart';
import 'mf_fund_list_card.dart';
import '../../mf_collection/mf_collection_screen.dart';

class MfNewInvestmentIdeas extends ConsumerWidget {
  const MfNewInvestmentIdeas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(allCatalogFundsProvider);
    final catalogFunds = catalogAsync.value ?? [];

    final valueFunds = catalogFunds
        .where((f) => f.category.toLowerCase().contains('equity') || f.category.toLowerCase().contains('value'))
        .take(3)
        .map((f) => MfFundItemData(
              name: f.schemeName,
              category: f.category,
              returns: '${(f.returns3y ?? 21.0).toStringAsFixed(1)}%',
              logoIcon: Icons.trending_up_rounded,
              logoColor: const Color(0xFF10B981),
            ))
        .toList();

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
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 16),
        MfFundListCard(
          sectionTitle: '',
          cardTitle: 'Value Investing',
          cardSubtitle: 'Undervalued companies with solid fundamentals',
          cardGraphic: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.diamond_outlined, color: Color(0xFF10B981), size: 24),
          ),
          funds: valueFunds.isNotEmpty
              ? valueFunds
              : const [
                  MfFundItemData(
                    name: 'Quant Value Fund',
                    category: 'Equity • Value',
                    returns: '22.56%',
                    logoIcon: Icons.trending_up_rounded,
                    logoColor: Color(0xFF10B981),
                  ),
                ],
          onViewCollection: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => const MfCollectionScreen(
                  title: 'Value Investing',
                  subtitle: 'Undervalued stocks with growth potential',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
