import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/core/widgets/shimmer_card_skeleton.dart';
import 'package:astra_frontend/features/stocks/data/stocks_providers.dart';
import 'package:astra_frontend/features/stocks/data/stocks_models.dart';

import 'package:astra_frontend/features/mf/screens/fund_profile/widgets/mf_fund_chart_widget.dart';
import 'package:astra_frontend/features/mf/screens/fund_profile/widgets/mf_instrument_card.dart';
import 'package:astra_frontend/features/mf/screens/fund_profile/widgets/mf_fund_insights.dart';
import 'package:astra_frontend/features/stocks/screens/stock_catalog_profile/widgets/stock_overview_card.dart';
import 'package:astra_frontend/features/stocks/screens/stock_catalog_profile/widgets/stock_shareholding.dart';

/// Mirrors MfFundProfileScreen's layout one-to-one — same header, same
/// title-section shape, same collapsible returns+chart, same instrument
/// deep-dive and portfolio-insights cards (reused directly from the MF
/// screen, since both are already asset-agnostic) — only the content is
/// stock-specific instead of fund-specific.
class StockCatalogProfileScreen extends ConsumerStatefulWidget {
  final String tradingSymbol;

  const StockCatalogProfileScreen({super.key, required this.tradingSymbol});

  static void showModal(BuildContext context, String tradingSymbol) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => StockCatalogProfileScreen(tradingSymbol: tradingSymbol),
      ),
    );
  }

  @override
  ConsumerState<StockCatalogProfileScreen> createState() => _StockCatalogProfileScreenState();
}

class _StockCatalogProfileScreenState extends ConsumerState<StockCatalogProfileScreen> {
  String _selectedPeriod = '6M';

  // The mock backend returns one fixed 180-day series — slicing it client
  // side per toggle (like the MF screen's period-driven return figure) gives
  // the same interactive feel without needing a period-aware backend yet.
  List<double> _pointsForPeriod(List<StockChartPoint> points, String period) {
    final prices = points.map((p) => p.price).toList();
    if (prices.isEmpty) return prices;
    int days;
    switch (period) {
      case '1M':
        days = 30;
        break;
      case '6M':
        days = 180;
        break;
      case '1Y':
        days = 365;
        break;
      case '3Y':
        days = 1095;
        break;
      default:
        days = 180;
    }
    if (days >= prices.length) return prices;
    return prices.sublist(prices.length - days);
  }

  @override
  Widget build(BuildContext context) {
    final liveProfileAsync = ref.watch(stockProfileFamilyProvider(widget.tradingSymbol));

    if (liveProfileAsync.isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const Expanded(child: FundProfileSkeletonLoading()),
            ],
          ),
        ),
      );
    }
    if (liveProfileAsync.valueOrNull == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 40, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        const Text(
                          'Couldn\'t load this stock',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          liveProfileAsync.error?.toString() ?? 'Please try again in a moment.',
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => ref.invalidate(stockProfileFamilyProvider(widget.tradingSymbol)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final StockProfileDetail data = liveProfileAsync.valueOrNull!;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final chartHeight = (screenHeight * 0.18).clamp(120.0, 200.0);
    final chartPoints = _pointsForPeriod(data.chartPoints, _selectedPeriod);

    final double periodStart = chartPoints.isNotEmpty ? chartPoints.first : data.quote.lastPrice;
    final double periodChangePct =
        periodStart > 0 ? ((data.quote.lastPrice - periodStart) / periodStart) * 100 : 0.0;
    final Color trendColor = periodChangePct >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    final instrument = data.instrumentDeepDive;
    final insights = data.portfolioInsights;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleSection(data),
                        const SizedBox(height: 16),

                        // Same shape as the fund screen's returns section
                        // (that one collapses to make room for its SIP
                        // calculator — stocks have no equivalent calculator
                        // here, so this stays permanently expanded).
                        _buildReturnsSection(periodChangePct, trendColor),
                        const SizedBox(height: 8),
                        MfFundChartWidget(
                          key: ValueKey(_selectedPeriod),
                          dataPoints: chartPoints,
                          lineColor: trendColor,
                          height: chartHeight,
                        ),
                        const SizedBox(height: 12),
                        _buildTimeframeToggles(),
                        const SizedBox(height: 12),

                        const SizedBox(height: 16),
                        StockOverviewCard(data: data),

                        const SizedBox(height: 16),
                        MfInstrumentCard(
                          instrumentType: 'Stock',
                          primaryRole: instrument.primaryRole,
                          secondaryRole: instrument.secondaryRole,
                          strengths: instrument.strengths.join('; '),
                          tradeOffs: instrument.tradeOffs.join('; '),
                        ),

                        const SizedBox(height: 16),
                        MfFundInsights(
                          isPositiveImpact: insights.isPositiveImpact,
                          whyGetFund: insights.whyGetFund.join('; '),
                          suitableFor: insights.suitableFor.join('; '),
                          avoidIf: insights.avoidIf.join('; '),
                          impactText: insights.impactText,
                        ),

                        const SizedBox(height: 16),
                        StockShareholdingWidget(data: data.shareholdingPattern),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomActionBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.chevron_left, size: 28, color: Color(0xFF0F172A)),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  color: Colors.white,
                ),
                child: const Icon(Icons.shopping_cart_outlined, size: 20, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Same shape as MfFundProfileScreen._buildTitleSection: name/tags/badge on
  // the left, logo circle on the right.
  Widget _buildTitleSection(StockProfileDetail data) {
    final bool isUp = data.quote.lastPrice >= data.quote.close;
    final double change = data.quote.lastPrice - data.quote.close;
    final double changePct = data.quote.close > 0 ? (change / data.quote.close) * 100 : 0.0;
    final Color changeColor = isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.companyName,
                  style: const TextStyle(
                    fontFamily: 'DMsans',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.sector} • ₹${data.quote.lastPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 14,
                        color: changeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isUp ? '+' : ''}${change.toStringAsFixed(2)} (${changePct.toStringAsFixed(2)}%) TODAY',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: changeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.tradingSymbol.length >= 2 ? widget.tradingSymbol.substring(0, 2).toUpperCase() : widget.tradingSymbol,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Same shape as MfFundProfileScreen._buildReturnsSection.
  Widget _buildReturnsSection(double periodChangePct, Color trendColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${periodChangePct >= 0 ? '+' : ''}${periodChangePct.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: trendColor,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$_selectedPeriod Price Change',
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeToggles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildTimeframeToggle('1M'),
          _buildTimeframeToggle('6M'),
          _buildTimeframeToggle('1Y'),
          _buildTimeframeToggle('3Y'),
        ],
      ),
    );
  }

  Widget _buildTimeframeToggle(String label) {
    final bool isSelected = _selectedPeriod == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? const Color(0xFFE2E8F0) : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottomPadding > 0 ? bottomPadding : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
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
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFEF4444)),
              ),
              child: const Center(
                child: Text(
                  'SELL',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'BUY',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
