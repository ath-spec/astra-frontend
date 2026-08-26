import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../widgets/orders_bottom_sheet.dart';
import '../widgets/folios_bottom_sheet.dart';
import '../../mf/screens/fund_profile/mf_fund_profile_screen.dart';
import '../../mf/screens/holdings/widgets/holding_item.dart';
import '../../mf/data/mf_holdings_providers.dart';
import '../../mf/data/mf_holdings_models.dart';
import '../../../core/utils/fund_name_formatter.dart';
import '../../../core/widgets/shimmer_card_skeleton.dart';

class YourFundProfileScreen extends ConsumerWidget {
  final String? schemeCode;
  final HoldingItem? holdingItem;

  const YourFundProfileScreen({
    super.key,
    this.schemeCode,
    this.holdingItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsAsync = ref.watch(mfHoldingsProvider);

    return holdingsAsync.when(
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: Column(
            children: [
              _buildLoadingTopBar(context),
              const Expanded(child: FundProfileSkeletonLoading()),
            ],
          ),
        ),
      ),
      error: (e, st) => Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Text(
            'Failed to load fund profile: $e',
            style: const TextStyle(fontFamily: 'DMSans', fontSize: 14, color: Color(0xFF64748B)),
          ),
        ),
      ),
      data: (holdingsData) {
        final MfFolio? liveHolding = holdingsData.folios.isNotEmpty
            ? (schemeCode != null && schemeCode!.isNotEmpty
                ? holdingsData.folios.firstWhere(
                    (f) => f.schemeCode == schemeCode,
                    orElse: () => holdingsData.folios.first,
                  )
                : holdingsData.folios.first)
            : null;

        if (liveHolding == null && holdingItem == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFFAFAFA),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: const Center(
              child: Text(
                'No holding details found for this fund.',
                style: TextStyle(fontFamily: 'DMSans', fontSize: 14, color: Color(0xFF64748B)),
              ),
            ),
          );
        }

        final String name = cleanFundName(liveHolding?.schemeName ?? holdingItem?.name ?? '');
        final String cat = liveHolding?.category ?? holdingItem?.category ?? '';
        final double currVal = liveHolding?.currentValue ?? holdingItem?.current ?? 0.0;
        final double invVal = liveHolding?.investedValue ?? holdingItem?.invested ?? 0.0;
        final double returnsAmt = liveHolding?.returnsAmount ?? holdingItem?.returns ?? (currVal - invVal);
        final double returnsPct = liveHolding?.returnsPct ?? holdingItem?.returnsPercent ?? (invVal > 0 ? (returnsAmt / invVal) * 100 : 0.0);
        final double units = liveHolding?.unitsHeld ?? 0.0;
        final double navAvg = units > 0 ? (invVal / units) : 0.0;
        final String targetSchemeCode = liveHolding?.schemeCode ?? schemeCode ?? '';

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildTopBar(context, name),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              _buildFundHeader(name, cat),
                              const SizedBox(height: 24),
                              _buildPerformanceCard(currVal, invVal, returnsAmt, returnsPct),
                              const SizedBox(height: 12),
                              _buildDetailsList(units, navAvg),
                              const SizedBox(height: 32),
                              _buildSectionTitle('EXPLORE FUND'),
                              const SizedBox(height: 16),
                              _buildExploreFundCard(context, targetSchemeCode),
                              const SizedBox(height: 32),
                              _buildSectionTitle('MORE DETAILS'),
                              const SizedBox(height: 16),
                              _buildMoreDetailsSection(context, liveHolding, name, currVal),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildStickyBottomCTA(context, targetSchemeCode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const ShimmerBar(width: 36, height: 36, borderRadius: 18),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String fundName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.business, color: Color(0xFF64748B), size: 18),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFundHeader(String name, String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          category,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
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
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invested',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
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
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'View historical returns, fund manager details & asset mix',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
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
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyBottomCTA(BuildContext context, String schemeCode) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (schemeCode.isNotEmpty) {
                  MfFundProfileScreen.showModal(context, schemeCode);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: const Text(
                'INVEST MORE',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
