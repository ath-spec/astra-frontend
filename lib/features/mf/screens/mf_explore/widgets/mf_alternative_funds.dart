import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      ).take(4).toList();
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
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Higher returns than traditional FDs with high liquidity',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => const MfAlternativeCollectionScreen(
                        title: 'Alternative to FD',
                        subtitle: 'Curated liquid and debt funds',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (altFunds.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Loading alternative funds...', style: TextStyle(fontFamily: 'DMSans', color: Color(0xFF64748B))),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: altFunds.length,
              itemBuilder: (context, index) {
                final fund = altFunds[index];
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
                                style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('3Y Returns', style: TextStyle(fontFamily: 'DMSans', fontSize: 9, color: Color(0xFF94A3B8))),
                                  Text(
                                    '${(fund.returns3y ?? 7.8).toStringAsFixed(1)}%',
                                    style: const TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
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
