import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../mf/data/mf_holdings_providers.dart';
import '../../mf/data/mf_holdings_models.dart';
import '../../mf/data/catalog_providers.dart';
import '../widgets/orders_bottom_sheet.dart';
import '../widgets/folios_bottom_sheet.dart';
import '../../mf/screens/fund_profile/mf_fund_profile_screen.dart';
import '../../mf/screens/holdings/widgets/holding_item.dart';
import '../../mf/screens/holdings/widgets/holding_instrument_card.dart';
import '../widgets/holding_fund_insights.dart';

class YourFundProfileScreen extends ConsumerWidget {
  final String? fundId;
  final String? fundName;
  final String? category;
  final double? currentValue;
  final double? investedValue;
  final double? returns;
  final double? returnsPct;
  final double? units;
  final double? avgNav;

  const YourFundProfileScreen({
    super.key,
    this.fundId,
    this.fundName,
    this.category,
    this.currentValue,
    this.investedValue,
    this.returns,
    this.returnsPct,
    this.units,
    this.avgNav,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foliosAsync = ref.watch(mfFoliosProvider);
    final targetKey = fundId ?? fundName ?? '';
    final profileAsync = targetKey.isNotEmpty ? ref.watch(fundProfileFamilyProvider(targetKey)) : null;

    // Show skeleton card loading while fetching live data from backend
    if (foliosAsync.isLoading || (profileAsync != null && profileAsync.isLoading)) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, '...'),
              const Expanded(child: FundProfileSkeletonLoading()),
            ],
          ),
        ),
      );
    }

    MfFolio? liveHolding;
    if (foliosAsync.hasValue && foliosAsync.value != null && foliosAsync.value!.isNotEmpty) {
      for (final folio in foliosAsync.value!) {
        if ((fundId != null && (folio.schemeCode == fundId || folio.folioNumber == fundId)) ||
            (fundName != null && folio.schemeName.toLowerCase() == fundName!.toLowerCase())) {
          liveHolding = folio;
          break;
        }
      }
      liveHolding ??= foliosAsync.value!.first;
    }

    final String name = liveHolding?.schemeName ?? fundName ?? profileAsync?.value?.fund.schemeName ?? '';
    final String cat = liveHolding?.category ?? category ?? profileAsync?.value?.fund.category ?? '';
    final double currVal = liveHolding?.currentValue ?? currentValue ?? 0.0;
    final double invVal = liveHolding?.investedValue ?? investedValue ?? 0.0;
    final double gain = liveHolding?.returnsAmount ?? returns ?? (currVal - invVal);
    final double gainPct = liveHolding?.returnsPct ?? returnsPct ?? (invVal > 0 ? (gain / invVal * 100) : 0.0);
    final double unitsHeld = liveHolding?.unitsHeld ?? units ?? 0.0;
    final double navAvg = liveHolding?.nav ?? avgNav ?? (unitsHeld > 0 ? (invVal / unitsHeld) : 0.0);

    final String logoInitials = name.isNotEmpty
        ? name.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase()
        : '';

    final backendDeepDive = profileAsync?.value?.deepDive;
    final backendInsights = profileAsync?.value?.insights;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(context, logoInitials),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildFundHeader(name, cat),
                          const SizedBox(height: 24),
                          _buildPerformanceCard(currVal, invVal, gain, gainPct),
                          _buildDetailsList(unitsHeld, navAvg),
                          
                          if (backendDeepDive != null) ...[
                            const SizedBox(height: 32),
                            _buildSectionTitle('HOLDING PROFILE'),
                            const SizedBox(height: 16),
                            HoldingInstrumentCard(
                              data: HoldingDeepDiveData(
                                primaryRole: backendDeepDive.primaryRole,
                                secondaryRole: backendDeepDive.secondaryRole,
                                contribution: backendDeepDive.contribution,
                              ),
                            ),
                          ],

                          if (backendInsights != null) ...[
                            const SizedBox(height: 24),
                            HoldingFundInsights(
                              isPositiveImpact: backendInsights.isPositiveImpact,
                              whatItDoesRightNow: backendInsights.whatItDoesRightNow,
                              whatBuyingMoreWillDo: backendInsights.whatBuyingMoreWillDo,
                              currentValues: backendInsights.currentValues.isNotEmpty ? backendInsights.currentValues : null,
                              projectedValues: backendInsights.projectedValues.isNotEmpty ? backendInsights.projectedValues : null,
                            ),
                          ],

                          const SizedBox(height: 32),
                          _buildSectionTitle('EXPLORE FUND'),
                          const SizedBox(height: 16),
                          _buildExploreFundCard(context, liveHolding?.schemeCode ?? fundId ?? profileAsync?.value?.fund.schemeCode ?? ''),
                          const SizedBox(height: 32),
                          _buildSectionTitle('MORE DETAILS'),
                          const SizedBox(height: 16),
                          _buildMoreDetailsSection(context, liveHolding, name, currVal),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildStickyBottomCTA(context, liveHolding?.schemeCode ?? fundId ?? profileAsync?.value?.fund.schemeCode ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String logoInitials) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          if (logoInitials.isNotEmpty)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  logoInitials,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFundHeader(String name, String cat) {
    if (name.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        if (cat.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              cat,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  Widget _buildExploreFundCard(BuildContext context, String schemeCode) {
    return InkWell(
      onTap: () {
        if (schemeCode.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MfFundProfileScreen(fundId: schemeCode),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_graph_rounded, color: Color(0xFF6366F1), size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fund Overview & NAV Chart',
                    style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'View historical returns, fund manager details & asset mix',
                    style: TextStyle(fontFamily: 'DMSans', fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(double currVal, double invVal, double gain, double gainPct) {
    final currencyFormatter = NumberFormat('#,##,##0.00', 'en_IN');
    final formattedCurr = '₹ ${currencyFormatter.format(currVal)}';
    final formattedInv = '₹ ${currencyFormatter.format(invVal)}';
    final formattedGain = '${gain >= 0 ? '+' : ''}₹ ${currencyFormatter.format(gain)} (${gainPct.toStringAsFixed(2)}%)';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Current Value',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formattedCurr,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    'Invested Value',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedInv,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                children: [
                  const Text(
                    'Total Returns',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        gain >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: gain >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        size: 16,
                      ),
                      Text(
                        formattedGain,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: gain >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList(double unitsHeld, double navAvg) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Units Held', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFF64748B))),
              Text(unitsHeld.toStringAsFixed(3), style: const TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            ],
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Average NAV', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFF64748B))),
              Text('₹ ${navAvg.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoreDetailsSection(BuildContext context, MfFolio? liveHolding, String name, double currVal) {
    return Column(
      children: [
        _buildActionRow(
          title: 'Folios Details',
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => FoliosBottomSheet(
                folio: liveHolding,
                schemeName: name,
                currentValue: currVal,
              ),
            );
          },
        ),
        const Divider(color: Color(0xFFF1F5F9), height: 1),
        _buildActionRow(
          title: 'Orders & SIP History',
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => OrdersBottomSheet(
                folio: liveHolding,
                schemeName: name,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionRow({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyBottomCTA(BuildContext context, String schemeCode) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (schemeCode.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MfFundProfileScreen(fundId: schemeCode),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Invest More',
                  style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
