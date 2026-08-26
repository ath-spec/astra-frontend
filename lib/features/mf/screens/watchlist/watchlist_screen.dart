import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/watchlist_provider.dart';
import '../../data/catalog_providers.dart';
import '../../data/catalog_models.dart';
import '../mf_explore/data/mf_mock_fund_data.dart';
import '../fund_profile/mf_fund_profile_screen.dart';
import 'widgets/mf_watchlist_empty_state.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);
    final catalogAsync = ref.watch(allCatalogFundsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 24),
              child: Text(
                'Watchlist',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  letterSpacing: -1.0,
                ),
              ),
            ),
            Expanded(
              child: watchlist.isEmpty
                  ? const MfWatchlistEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: watchlist.length,
                      itemBuilder: (context, index) {
                        final fundId = watchlist[index];

                        // Check if item exists in live catalog
                        CatalogFund? liveFund;
                        if (catalogAsync.hasValue && catalogAsync.value != null) {
                          try {
                            liveFund = catalogAsync.value!.firstWhere(
                              (f) => f.schemeCode == fundId || f.isin == fundId,
                            );
                          } catch (_) {}
                        }

                        final name = liveFund?.schemeName ??
                            MfMockFundData.getFundData(fundId).name;
                        final tags = liveFund?.category ??
                            MfMockFundData.getFundData(fundId).tags;
                        final returnVal = liveFund != null
                            ? '${(liveFund.returns3y ?? liveFund.returns1y ?? 15.0).toStringAsFixed(1)}%'
                            : MfMockFundData.getFundData(fundId).returnPercentage;
                        final logoText = (liveFund?.amcName.isNotEmpty ?? false)
                            ? liveFund!.amcName.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join()
                            : MfMockFundData.getFundData(fundId).logoText;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: () => MfFundProfileScreen.showModal(
                                context, liveFund?.schemeCode ?? fundId),
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: Row(
                                children: [
                                  // Logo Circle
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(color: const Color(0xFFF1F5F9)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        logoText.toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontFamily: 'DMSans',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          tags,
                                          style: const TextStyle(
                                            fontFamily: 'DMSans',
                                            fontSize: 10,
                                            color: Color(0xFF64748B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        returnVal,
                                        style: const TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        '3Y Returns',
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 10,
                                          color: Color(0xFF64748B),
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
        ),
      ),
    );
  }
}
