import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../mf/screens/holdings/widgets/holding_item.dart';

import '../../../core/widgets/shimmer_card_skeleton.dart';
import '../data/stocks_models.dart';
import '../data/stocks_providers.dart';
import 'stock_catalog_profile/stock_catalog_profile_screen.dart';
import 'stock_catalog_profile/widgets/stock_history_bottom_sheet.dart';

class YourStockProfileScreen extends ConsumerWidget {
  final HoldingItem holdingItem;

  const YourStockProfileScreen({
    super.key,
    required this.holdingItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stocksAsync = ref.watch(stocksHoldingsProvider);

    return stocksAsync.when(
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
            'Failed to load stock profile: $e',
            style: const TextStyle(fontFamily: 'DMSans', fontSize: 14, color: Color(0xFF64748B)),
          ),
        ),
      ),
      data: (stocksData) {
        final StockHoldingItem? liveStock = stocksData.isNotEmpty
            ? stocksData.where((s) => s.tradingSymbol == holdingItem.name).firstOrNull
            : null;

        final String name = liveStock?.tradingSymbol ?? holdingItem.name;
        final String cat = 'Equity - Stocks';
        final double currVal = liveStock?.currentValue ?? holdingItem.current;
        final double invVal = liveStock?.investedValue ?? holdingItem.invested;
        final double gain = liveStock?.pnl ?? holdingItem.returns;
        final double gainPct = liveStock?.pnlPercentage ?? holdingItem.returnsPercent;
        final int quantity = liveStock?.quantity ?? (holdingItem.current / holdingItem.invested > 0 ? (holdingItem.invested / holdingItem.current).round() : 0);
        final double avgPrice = liveStock?.averagePrice ?? (quantity > 0 ? invVal / quantity : 0.0);

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
                              _buildStockHeader(name, cat),
                              const SizedBox(height: 24),
                              _buildPerformanceCard(currVal, invVal, gain, gainPct),
                              const SizedBox(height: 12),
                              _buildDetailsList(quantity, avgPrice),
                              const SizedBox(height: 32),
                              _buildOverviewCard(context, name),
                              const SizedBox(height: 32),
                              _buildMoreDetailsSection(context, liveStock, name, currVal),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildStickyBottomCTA(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard(BuildContext context, String stockName) {
    return InkWell(
      onTap: () {
        StockCatalogProfileScreen.showModal(context, stockName);
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
                    'Stock Overview & Charts',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'View historical price, financials & company info',
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

  Widget _buildMoreDetailsSection(BuildContext context, StockHoldingItem? liveHolding, String name, double currVal) {
    return Column(
      children: [
        _buildActionRow(
          title: 'Trade History',
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => StockHistoryBottomSheet(
                title: 'Trade History',
                subtitle: 'Record of all past trades in',
                stockName: name,
              ),
            );
          },
        ),
        const Divider(color: Color(0xFFF1F5F9), height: 1),
        _buildActionRow(
          title: 'Stock SIPs & Orders',
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => StockHistoryBottomSheet(
                title: 'Stock SIPs & Orders',
                subtitle: 'Record of all past SIP purchases in',
                stockName: name,
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

  Widget _buildTopBar(BuildContext context, String stockName) {
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
              child: Icon(Icons.show_chart, color: Color(0xFF64748B), size: 18),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStockHeader(String name, String category) {
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

  Widget _buildDetailsList(int quantity, double avgPrice) {
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
              const Text('Quantity', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFF64748B))),
              Text(quantity.toString(), style: const TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            ],
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Avg. Buy Price', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFF64748B))),
              Text('₹ ${avgPrice.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomCTA(BuildContext context) {
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
                // Future placeholder for Trading/Investing more in stocks
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: const Text(
                'BUY MORE',
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
