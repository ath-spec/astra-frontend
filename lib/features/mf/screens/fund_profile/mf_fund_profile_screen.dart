import '../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../data/catalog_providers.dart';
import '../../data/catalog_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/fund_profile_data.dart';
import 'widgets/mf_fund_chart_widget.dart';
import 'widgets/mf_fund_overview_card.dart';
import 'widgets/mf_fund_fees_taxes.dart';
import 'widgets/mf_fund_insights.dart';
import 'widgets/mf_instrument_card.dart';
import 'widgets/mf_fund_return_ratios.dart';
import 'widgets/mf_fund_asset_allocation.dart';
import 'package:intl/intl.dart';
import 'widgets/mf_fund_details_house.dart';
import 'widgets/mf_amount_scroller.dart';
import 'widgets/mf_bookmark_button.dart';
import '../holdings/widgets/holding_item.dart';
import '../holdings/widgets/holding_instrument_card.dart';
import '../../../fund_profile/widgets/holding_fund_insights.dart';


class MfFundProfileScreen extends ConsumerStatefulWidget {
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
  ConsumerState<MfFundProfileScreen> createState() => _MfFundProfileScreenState();
}


FundProfileData _mapLiveProfileToUi(FundProfileDetail live, String selectedPeriod) {
  final f = live.fund;
  final alloc = live.allocation;

  // No fake fallback number when the fund genuinely has no disclosed return
  // for a period (common for newer funds without 3Y/5Y history yet) — null
  // means "not available", which the UI renders as "—" rather than a made-up
  // percentage.
  double? returnVal = f.returns3y;
  if (selectedPeriod == '1M' && f.returns1y != null) returnVal = f.returns1y! / 12.0;
  if (selectedPeriod == '6M' && f.returns1y != null) returnVal = f.returns1y! / 2.0;
  if (selectedPeriod == '1Y') returnVal = f.returns1y;
  if (selectedPeriod == '3Y') returnVal = f.returns3y;
  if (selectedPeriod == '5Y') returnVal = f.returns5y;

  final chartPoints = live.chartPoints.map((cp) => cp.nav).toList();

  final sectorItems = alloc.sectors.map((s) => DistributionItem(
    title: s.title,
    percentage: s.percentage,
  )).toList();

  final holdingItems = alloc.topHoldings.map((h) => DistributionItem(
    title: h.title,
    percentage: h.percentage,
  )).toList();

  final assetAlloc = AssetAllocationData(
    equity: EquityAllocationData(
      totalPercentage: alloc.equityPct,
      largeCapPercentage: alloc.equityPct * 0.6,
      midCapPercentage: alloc.equityPct * 0.3,
      smallCapPercentage: alloc.equityPct * 0.1,
      sectors: sectorItems,
      holdings: holdingItems,
    ),
    debt: DebtAllocationData(
      totalPercentage: alloc.debtPct,
      creditQuality: const [],
      sectors: const [],
      holdings: const [],
    ),
    others: OtherAllocationData(
      totalPercentage: alloc.otherPct,
      otherAllocation: const [],
      holdings: const [],
    ),
  );

  final isHighRisk = f.riskLevel.toLowerCase().contains('high');

  return FundProfileData(
    id: f.schemeCode,
    name: f.schemeName,
    tags: '${f.category} • NAV ₹${f.nav.toStringAsFixed(2)} • Exp ${f.expenseRatio}%',
    logoText: f.amcName.isNotEmpty
        ? f.amcName.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase()
        : 'MF',
    riskLabel: '${f.riskLevel.toUpperCase()} VOLATILITY FUND',
    riskColor: isHighRisk ? const Color(0xFFEF4444) : const Color(0xFF10B981),
    returnPercentage: returnVal != null ? '${returnVal.toStringAsFixed(2)}%' : '—',
    returnDuration: '$selectedPeriod Annualised Return',
    comparisonText: f.benchmarkIndex != null ? 'vs. ${f.benchmarkIndex} >' : '',
    chartDataPoints: chartPoints,
    chartColor: const Color(0xFF10B981),
    sipAmount: f.minSipAmount.toInt() > 0 ? f.minSipAmount.toInt() : 1000,
    sipDurationText: '3 years',
    // Illustrative SIP projection using the fund's own real 3Y return where
    // disclosed; if the fund has no 3Y return yet, the projection can't be
    // computed honestly, so it's omitted rather than assumed.
    sipFinalAmount: f.returns3y != null
        ? '₹${((f.minSipAmount > 0 ? f.minSipAmount : 1000) * 36 * (1 + f.returns3y! / 100)).toInt()}'
        : '—',
    sipReturnPercentage: f.returns3y != null ? '(${f.returns3y!.toStringAsFixed(1)}%)' : '',
    overviewText: '${f.schemeName} is managed by ${f.amcName} in the ${f.category} category. Total scheme AUM is ₹${f.aum.toStringAsFixed(0)} Cr with a direct expense ratio of ${f.expenseRatio}%. Minimum SIP is ₹${f.minSipAmount.toStringAsFixed(0)}.',
    assetAllocation: assetAlloc,
    instrumentData: InstrumentDeepDiveData(
      primaryRole: live.deepDive.primaryRole,
      secondaryRole: live.deepDive.secondaryRole,
      strengths: live.deepDive.strengths,
      tradeOffs: live.deepDive.tradeOffs,
    ),
    insightsData: FundInsightsData(
      isPositiveImpact: live.insights.isPositiveImpact,
      whyGetFund: live.insights.whyGetFund,
      suitableFor: live.insights.suitableFor,
      avoidIf: live.insights.avoidIf,
      impactText: live.insights.impactText,
      whatItDoesRightNow: live.insights.whatItDoesRightNow,
      whatBuyingMoreWillDo: live.insights.whatBuyingMoreWillDo,
      currentValues: live.insights.currentValues,
      projectedValues: live.insights.projectedValues,
    ),
    nav: f.nav,
    expenseRatio: f.expenseRatio,
    aum: f.aum,
    minSipAmount: f.minSipAmount,
    minInvestment: f.minInvestment,
    amcName: f.amcName,
    fundManager: f.fundManager ?? '—',
    exitLoad: f.exitLoadText,
  );
}

class _MfFundProfileScreenState extends ConsumerState<MfFundProfileScreen> {
  String _selectedPeriod = '6M';
  double _selectedAmount = 1000.0;
  bool _isSip = true;
  bool _isScrollerOpen = false;

  @override
  Widget build(BuildContext context) {
    final liveProfileAsync = ref.watch(fundProfileFamilyProvider(widget.fundId));

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
      // Not loading (handled above) and no value — this is a real error
      // (e.g. the fund wasn't found, or a network failure). Never fall back
      // to mock fund data here; show the actual problem instead.
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
                          'Couldn\'t load this fund',
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
                          onPressed: () => ref.invalidate(fundProfileFamilyProvider(widget.fundId)),
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

    final bool hasHoldings = liveProfileAsync.valueOrNull?.hasUserHolding ?? false;
    final FundProfileData processedData = _mapLiveProfileToUi(liveProfileAsync.valueOrNull!, _selectedPeriod);

    // Calculate responsive chart height
    final screenHeight = MediaQuery.sizeOf(context).height;
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
                        
                        const SizedBox(height: 16),
                        
                        // Holdings Card (Optional, shown if user has holdings)
                        _buildHoldingsCard(hasHoldings, liveProfileAsync.valueOrNull?.userHolding),

                        const SizedBox(height: 16),
                        
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
                        
                        const SizedBox(height: 16),
                        hasHoldings
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: HoldingInstrumentCard(
                                  data: HoldingDeepDiveData(
                                    primaryRole: processedData.instrumentData?.primaryRole ?? '',
                                    secondaryRole: processedData.instrumentData?.secondaryRole ?? '',
                                    contribution: liveProfileAsync.valueOrNull?.deepDive.contribution ?? '',
                                  ),
                                ),
                              )
                            : MfInstrumentCard(
                                primaryRole: processedData.instrumentData?.primaryRole ?? '',
                                secondaryRole: processedData.instrumentData?.secondaryRole ?? '',
                                strengths: processedData.instrumentData?.strengths ?? '',
                                tradeOffs: processedData.instrumentData?.tradeOffs ?? '',
                              ),

                        const SizedBox(height: 16),
                        hasHoldings
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: HoldingFundInsights(
                                  isPositiveImpact: processedData.insightsData?.isPositiveImpact ?? true,
                                  whatItDoesRightNow: processedData.insightsData?.whatItDoesRightNow ?? '',
                                  whatBuyingMoreWillDo: processedData.insightsData?.whatBuyingMoreWillDo ?? '',
                                ),
                              )
                            : MfFundInsights(
                                isPositiveImpact: processedData.insightsData?.isPositiveImpact ?? true,
                                whyGetFund: processedData.insightsData?.whyGetFund ?? '',
                                suitableFor: processedData.insightsData?.suitableFor ?? '',
                                avoidIf: processedData.insightsData?.avoidIf ?? '',
                                impactText: processedData.insightsData?.impactText ?? '',
                                currentValues: processedData.insightsData?.currentValues,
                                projectedValues: processedData.insightsData?.projectedValues,
                              ),

                        const SizedBox(height: 16),
                        MfFundFeesTaxes(expenseRatio: processedData.expenseRatio, exitLoad: processedData.exitLoad),
                        const MfFundReturnRatios(),
                        if (processedData.assetAllocation != null)
                          MfFundAssetAllocation(data: processedData.assetAllocation!),
                        MfFundDetailsHouse(amcName: processedData.amcName, aum: processedData.aum, fundManager: processedData.fundManager),
                        
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
              MfBookmarkButton(
                fundId: widget.fundId,
                initialWatched: ref
                        .watch(fundProfileFamilyProvider(widget.fundId))
                        .valueOrNull
                        ?.isWatched ??
                    false,
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
                    color: data.riskColor.withValues(alpha: 0.1),
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
                  color: Colors.black.withValues(alpha: 0.02),
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

  Widget _buildHoldingsCard(bool hasHoldings, UserHoldingData? holding) {
    // Shown only when the backend's fund profile response includes a real
    // user_holding block (i.e. the user genuinely holds this fund).
    if (!hasHoldings) return const SizedBox.shrink();

    final String currentValueText =
        holding != null ? _formatAmount(holding.currentValue) : '₹0';
    final String returnsText = holding != null
        ? '(${holding.returnsPct.toStringAsFixed(2)}%)'
        : '(0.00%)';
    final Color returnsColor = (holding?.returnsPct ?? 0) >= 0
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your holding',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            Row(
              children: [
                Text(
                  currentValueText,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  returnsText,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: returnsColor,
                  ),
                ),
              ],
            ),
          ],
        ),
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
