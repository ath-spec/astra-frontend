import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/fund_profile_data.dart';
import '../../providers/watchlist_provider.dart';
import '../mf_explore/data/mf_mock_fund_data.dart';
import 'widgets/mf_fund_chart_widget.dart';
import 'widgets/mf_fund_overview_card.dart';
import 'widgets/mf_fund_fees_taxes.dart';
import 'widgets/mf_fund_return_ratios.dart';
import 'widgets/mf_fund_asset_allocation.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'widgets/mf_fund_details_house.dart';
import 'widgets/mf_amount_scroller.dart';


class MfFundProfileScreen extends StatefulWidget {
  final String fundId;

  const MfFundProfileScreen({super.key, required this.fundId});

  static void showModal(BuildContext context, String fundId) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => MfFundProfileScreen(fundId: fundId),
      ),
    );
  }

  @override
  State<MfFundProfileScreen> createState() => _MfFundProfileScreenState();
}

class _MfFundProfileScreenState extends State<MfFundProfileScreen> {
  String _selectedPeriod = '6M';
  double _selectedAmount = 1000.0;
  bool _isSip = true;
  bool _isScrollerOpen = false;

  @override
  Widget build(BuildContext context) {
    final FundProfileData baseData = MfMockFundData.getFundData(widget.fundId);
    
    // Process data based on selected period
    final processedData = _processDataForPeriod(baseData, _selectedPeriod);
    
    // Calculate responsive chart height
    final screenHeight = MediaQuery.of(context).size.height;
    final chartHeight = (screenHeight * 0.18).clamp(120.0, 200.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Header (Down arrow, Cart, Bookmark)
                _buildHeader(context),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Section
                        _buildTitleSection(processedData),
                        
                        const SizedBox(height: 12),
                        
                        // Top Collapsible: Returns + Chart
                        AnimatedSize(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: _isScrollerOpen
                              ? const SizedBox(width: double.infinity, height: 0)
                              : Column(
                                  children: [
                                    _buildReturnsSection(processedData),
                                    const SizedBox(height: 8),
                                    MfFundChartWidget(
                                      key: ValueKey(_selectedPeriod),
                                      dataPoints: processedData.chartDataPoints,
                                      lineColor: processedData.chartColor,
                                      height: chartHeight,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                        ),
                        
                        // Interactive Calculator Anchor & Scroller
                        _buildInteractiveCalculatorArea(processedData),
                        
                        const SizedBox(height: 16),
                        
                        // Fund Overview
                        MfFundOverviewCard(data: processedData),
                        
                        const MfFundFeesTaxes(),
                        const MfFundReturnRatios(),
                        MfFundAssetAllocation(data: processedData.assetAllocation ?? MfMockFundData.mockAssetAllocation),
                        const MfFundDetailsHouse(),
                        
                        // Padding to ensure we can scroll past the bottom bar
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Action Bar pinned to the absolute bottom, no safe area
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

  FundProfileData _processDataForPeriod(FundProfileData baseData, String period) {
    List<double> newChartData = List.from(baseData.chartDataPoints);
    double baseReturn = double.tryParse(baseData.returnPercentage.replaceAll('%', '').trim()) ?? 0.0;
    
    String newReturnStr;
    String newReturnDuration;
    String newOverviewPrefix;
    
    int startIdx = 0;
    switch (period) {
      case '1M':
        startIdx = (newChartData.length * 0.75).toInt();
        newReturnStr = '${(baseReturn / 12).toStringAsFixed(2)}%';
        newReturnDuration = '1M Return';
        break;
      case '6M':
        startIdx = (newChartData.length * 0.50).toInt();
        newReturnStr = '${(baseReturn / 2).toStringAsFixed(2)}%';
        newReturnDuration = '6M Return';
        break;
      case '1Y':
        startIdx = (newChartData.length * 0.25).toInt();
        newReturnStr = '${(baseReturn * 0.8).toStringAsFixed(2)}%';
        newReturnDuration = '1Y Annualised Return';
        break;
      case '3Y':
      default:
        startIdx = 0;
        newReturnStr = baseData.returnPercentage;
        newReturnDuration = baseData.returnDuration;
        break;
    }
    
    newChartData = newChartData.sublist(startIdx);
    
    // Determine trend from the actual graph data shown
    double firstPoint = newChartData.first;
    double lastPoint = newChartData.last;
    bool isPositiveGraph = lastPoint >= firstPoint;
    
    // Make sure the return string matches the graph's visual trend!
    // If graph goes down, ensure the return is negative. If graph goes up, ensure it's positive.
    double parsedNewReturn = double.tryParse(newReturnStr.replaceAll('%', '').trim()) ?? 0.0;
    if (isPositiveGraph && parsedNewReturn < 0) {
      newReturnStr = '${parsedNewReturn.abs().toStringAsFixed(2)}%';
    } else if (!isPositiveGraph && parsedNewReturn > 0) {
      newReturnStr = '-${parsedNewReturn.toStringAsFixed(2)}%';
    }

    if (period == '3Y') {
      newOverviewPrefix = 'Looking at a 3-year horizon, the fund has demonstrated consistent ${isPositiveGraph ? "compounding" : "consolidation"}. ';
    } else if (period == '1Y') {
      newOverviewPrefix = 'Over the last 1 year, the fund has ${isPositiveGraph ? "trended upwards" : "seen a correction"}, adapting to economic cycles. ';
    } else if (period == '6M') {
      newOverviewPrefix = 'In the past 6 months, the fund has ${isPositiveGraph ? "successfully captured market rallies" : "faced broad market headwinds"}. ';
    } else { // 1M
      newOverviewPrefix = 'Over the last 1 month, the fund has shown short-term ${isPositiveGraph ? "momentum" : "volatility"}. ';
    }
    
    return FundProfileData(
      id: baseData.id,
      name: baseData.name,
      tags: baseData.tags,
      logoText: baseData.logoText,
      riskLabel: baseData.riskLabel,
      riskColor: baseData.riskColor,
      returnPercentage: newReturnStr,
      returnDuration: newReturnDuration,
      comparisonText: baseData.comparisonText,
      chartDataPoints: newChartData,
      chartColor: baseData.chartColor,
      sipAmount: baseData.sipAmount,
      sipDurationText: baseData.sipDurationText,
      sipFinalAmount: baseData.sipFinalAmount,
      sipReturnPercentage: baseData.sipReturnPercentage,
      overviewText: newOverviewPrefix + baseData.overviewText,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Down Arrow Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.chevron_left, size: 28, color: Color(0xFF0F172A)),
            ),
          ),
          // Actions
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
              const SizedBox(width: 12),
              Consumer(
                builder: (context, ref, child) {
                  final watchlist = ref.watch(watchlistProvider);
                  final isBookmarked = watchlist.contains(widget.fundId);
                  
                  return GestureDetector(
                    onTap: () {
                      ref.read(watchlistProvider.notifier).toggleFund(widget.fundId);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        color: isBookmarked ? const Color(0xFFE2E8F0) : Colors.white,
                      ),
                      child: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, 
                        size: 20, 
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(FundProfileData data) {
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
                  data.name,
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
                  data.tags,
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
                    color: data.riskColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14, color: data.riskColor),
                      const SizedBox(width: 4),
                      Text(
                        data.riskLabel,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: data.riskColor,
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
          // Logo Circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                data.logoText.toUpperCase(),
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

  Widget _buildReturnsSection(FundProfileData data) {
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
                data.returnPercentage,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: data.chartColor,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data.returnDuration,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                data.comparisonText,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return format.format(amount);
  }

  (String, String) _calculateFutureValue(double amount, bool isSip, String period) {
    int months = 36;
    switch (period) {
      case '1M': months = 1; break;
      case '6M': months = 6; break;
      case '1Y': months = 12; break;
      case '3Y': months = 36; break;
    }
    
    double absoluteReturnPct = 0.0;
    if (period == '6M') {
      absoluteReturnPct = isSip ? 1.71 : 5.82;
    } else if (period == '1Y') {
      absoluteReturnPct = isSip ? 8.5 : 12.4;
    } else if (period == '3Y') {
      absoluteReturnPct = isSip ? 24.5 : 38.2;
    } else {
      absoluteReturnPct = isSip ? 0.2 : 0.5;
    }
    
    double investedAmount = isSip ? amount * months : amount;
    double futureValue = investedAmount * (1 + (absoluteReturnPct / 100.0));
    
    String returnPctStr = absoluteReturnPct >= 0 
        ? '(${absoluteReturnPct.toStringAsFixed(2)}%)'
        : '(${absoluteReturnPct.toStringAsFixed(2)}%)';
        
    return (_formatAmount(futureValue), returnPctStr);
  }

  Widget _buildInteractiveCalculatorArea(FundProfileData data) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0);
    final (finalAmount, returnPct) = _calculateFutureValue(_selectedAmount, _isSip, _selectedPeriod);
    final monthsText = _selectedPeriod == '1M' ? '1 month' : (_selectedPeriod == '6M' ? '6 months' : (_selectedPeriod == '1Y' ? '1 year' : '3 years'));
    final typeText = _isSip ? 'SIP' : 'LUMPSUM';
    final amountText = format.format(_selectedAmount).replaceAll('.00', '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Anchor: "SIP would have become" text and Edit/Down Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$typeText $amountText for $monthsText would have become',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          finalAmount,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          returnPct,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: data.chartColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isScrollerOpen = !_isScrollerOpen;
                  });
                },
                behavior: HitTestBehavior.opaque, // Ensures the entire padding area is clickable
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Huge invisible touch target
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Icon(
                      _isScrollerOpen ? Icons.keyboard_arrow_down_rounded : Icons.edit_outlined, 
                      size: 16, 
                      color: const Color(0xFF475569)
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Expandable: MONTHLY SIP / ONE-TIME toggles (Slides in when open)
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_isScrollerOpen
                ? const SizedBox(width: double.infinity, height: 0)
                : Padding(
                    padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isSip = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: _isSip ? const Color(0xFF0F172A) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              'MONTHLY SIP',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _isSip ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _isSip = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: !_isSip ? const Color(0xFF0F172A) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              'ONE-TIME',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: !_isSip ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          
          if (!_isScrollerOpen) const SizedBox(height: 16),
          
          // Faint divider acting as a subtle line below toggles / preview
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9), // Subtle dashed-like separation
          ),
          
          // Expandable: The Scroller
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_isScrollerOpen
                ? const SizedBox(width: double.infinity, height: 0)
                : Column(
                    children: [
                      const SizedBox(height: 24),
                      // Large Amount Text
                      Text(
                        amountText,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        _isSip ? 'SIP' : 'LUMPSUM',
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // The Scroller
                      MfAmountScrollerWidget(
                        initialAmount: _selectedAmount,
                        onAmountChanged: (val) {
                          setState(() {
                            _selectedAmount = val;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
          ),
          
          const SizedBox(height: 24),
          
          // Timeframe toggles
          Wrap(
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
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
            color: Colors.black.withOpacity(0.05),
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
                border: Border.all(color: const Color(0xFF0F172A)),
              ),
              child: const Center(
                child: Text(
                  'One-time',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
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
                  'Start SIP',
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
