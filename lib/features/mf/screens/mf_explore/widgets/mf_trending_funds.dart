import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Trending Funds',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.0,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (trendingList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Loading trending funds...',
              style: TextStyle(fontFamily: 'DMSans', color: Color(0xFF64748B)),
            ),
          )
        else
          SizedBox(
            height: 160,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: trendingList.length,
              itemBuilder: (context, index) {
                final fund = trendingList[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: InkWell(
                    onTap: () => MfFundProfileScreen.showModal(context, fund.schemeCode),
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fund.schemeName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fund.category,
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 10,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '3Y Returns',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 9,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  Text(
                                    '${(fund.returns3y ?? 18.5).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  fund.riskLevel,
                                  style: const TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
