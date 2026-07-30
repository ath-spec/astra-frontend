import 'package:flutter/material.dart';
import '../../../../core/models/fund_profile_data.dart';
import '../mf_explore/data/mf_mock_fund_data.dart';
import 'widgets/mf_fund_chart_widget.dart';

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
  String _selectedPeriod = '3Y';

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
                        
                        // Returns Section
                        _buildReturnsSection(processedData),
                        
                        const SizedBox(height: 8),
                        
                        // Chart Section
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: MfFundChartWidget(
                            key: ValueKey(_selectedPeriod),
                            dataPoints: processedData.chartDataPoints,
                            lineColor: processedData.chartColor,
                            height: chartHeight, // Responsive height
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // SIP Calculator Preview
                        _buildSipPreview(processedData),
                        
                        const SizedBox(height: 16),
                        
                        // Fund Overview
                        _buildFundOverview(processedData),
                        
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF1F5F9)),
                color: Colors.white,
              ),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  color: Colors.white,
                ),
                child: const Icon(Icons.bookmark_border_rounded, size: 20, color: Color(0xFF0F172A)),
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
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 18,
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
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: data.riskColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
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
                  fontFamily: 'SpaceGrotesk',
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
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 24,
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
                  fontSize: 11,
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
                  fontSize: 11,
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

  Widget _buildSipPreview(FundProfileData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIP ₹10K / ${data.sipDurationText} would have become',
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        data.sipFinalAmount,
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        data.sipReturnPercentage,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: data.chartColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF475569)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Timeframe toggles
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: Color(0xFFF1F5F9), style: BorderStyle.solid), // Actually flutter only supports uniform dashes easily, we'll use solid light line for now
              ),
            ),
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
          borderRadius: BorderRadius.circular(20),
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

  Widget _buildFundOverview(FundProfileData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fund overview',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 14, color: data.riskColor),
                    const SizedBox(width: 8),
                    Text(
                      data.riskLabel,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Color(0xFFE2E8F0), height: 1),
                ),
                Text(
                  data.overviewText,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                borderRadius: BorderRadius.circular(8),
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
                borderRadius: BorderRadius.circular(8),
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
