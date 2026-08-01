import 'package:flutter/material.dart';
import '../../../../../core/models/fund_profile_data.dart';
import '../../../../../core/models/fund_asset_allocation_data.dart';

class MfMockFundData {
  static final List<double> _baseChartData = [
    20, 22, 19, 25, 30, 28, 35, 45, 50, 48, 55, 60, 58, 62, 50, 45, 48, 55, 60,
    65, 62, 68, 70, 75, 72, 80, 85, 90, 85, 95, 100
  ];
  
  static final List<double> _conservativeChartData = [
    20, 21, 22, 22, 23, 24, 25, 26, 27, 27, 28, 29, 30, 31, 31, 32, 33, 34, 35,
    36, 37, 38, 38, 39, 40, 41, 42, 43, 44, 45, 46
  ];
  
  static AssetAllocationData get mockAssetAllocation => _mockAssetAllocation;
  static final AssetAllocationData _mockAssetAllocation = AssetAllocationData(
    equity: EquityAllocationData(
      totalPercentage: 98.29,
      largeCapPercentage: 45.16,
      midCapPercentage: 17.40,
      smallCapPercentage: 35.73,
      sectors: [
        DistributionItem(title: 'Financial Services', percentage: 36.65),
        DistributionItem(title: 'Consumer Cyclical', percentage: 15.25),
        DistributionItem(title: 'Basic Materials', percentage: 11.52),
        DistributionItem(title: 'Industrials', percentage: 10.62),
        DistributionItem(title: 'Consumer Defensive', percentage: 7.00),
      ],
      holdings: [
        DistributionItem(title: 'HDFC Bank Ltd', percentage: 4.85),
        DistributionItem(title: 'ICICI Bank Ltd', percentage: 4.11),
        DistributionItem(title: 'The Federal Bank Ltd', percentage: 3.23),
        DistributionItem(title: 'State Bank of India', percentage: 3.18),
        DistributionItem(title: 'Karur Vysya Bank Ltd', percentage: 3.15),
      ],
    ),
    debt: DebtAllocationData(
      totalPercentage: 0.58,
      creditQuality: [
        DistributionItem(title: 'AAA', percentage: 100.00),
      ],
      sectors: [
        DistributionItem(title: 'Corporate', percentage: 3.49),
        DistributionItem(title: 'Government', percentage: 0.99),
      ],
      holdings: [
        DistributionItem(title: 'Tbill', percentage: 0.24, icon: Icons.domain),
        DistributionItem(title: 'Indian Bank', percentage: 0.21, icon: Icons.domain),
        DistributionItem(title: 'Small Industries Development Bank of India', subtitle: '- NCD & Bonds', percentage: 0.21, icon: Icons.domain),
        DistributionItem(title: 'Tbill', percentage: 0.14, icon: Icons.domain),
      ],
    ),
    others: OtherAllocationData(
      totalPercentage: 1.13,
      otherAllocation: [
        DistributionItem(title: 'Cash', percentage: 100.00),
      ],
      holdings: [
        DistributionItem(title: 'Treps', percentage: 2.04, icon: Icons.domain),
        DistributionItem(title: 'Net Current Assets (Including Cash & Bank Balances)', percentage: 0.33, icon: Icons.domain),
      ],
    ),
  );

  static FundProfileData getFundData(String fundId) {
    switch (fundId) {
      // Trending Themes
      case 'AI Revolution':
        return FundProfileData(
          id: fundId,
          name: 'Tech & AI Opportunities Fund',
          tags: 'Equity • Sectoral • Technology',
          logoText: 'ai',
          riskLabel: 'VERY HIGH VOLATILITY',
          riskColor: const Color(0xFFEF4444),
          returnPercentage: '34.20%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 14.2% in Nifty IT >',
          chartDataPoints: _baseChartData.map((e) => e * 1.5).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹6,40,200',
          sipReturnPercentage: '(58.2%)',
          overviewText: 'Invests primarily in companies leading the AI revolution and technology sector globally.',
        );
      case 'India Manufacturing':
        return FundProfileData(
          id: fundId,
          name: 'India Manufacturing Growth Fund',
          tags: 'Equity • Thematic • Manufacturing',
          logoText: 'mfg',
          riskLabel: 'HIGH VOLATILITY',
          riskColor: const Color(0xFFF97316),
          returnPercentage: '28.40%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 12.5% in Nifty 50 >',
          chartDataPoints: _baseChartData.map((e) => e * 1.2).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹5,80,000',
          sipReturnPercentage: '(48.5%)',
          overviewText: 'Focuses on companies benefiting from India\'s push towards manufacturing and infrastructure.',
        );
      case 'Semi-Conductor':
        return FundProfileData(
          id: fundId,
          name: 'Global Semiconductor Fund',
          tags: 'Equity • Thematic • Global',
          logoText: 'semi',
          riskLabel: 'VERY HIGH VOLATILITY',
          riskColor: const Color(0xFFEF4444),
          returnPercentage: '42.10%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 18.2% in Global Tech >',
          chartDataPoints: _baseChartData.map((e) => e * 1.8).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹7,10,500',
          sipReturnPercentage: '(65.1%)',
          overviewText: 'Captures growth in the global semiconductor supply chain and hardware innovators.',
        );

      // Investment Ideas - High Growth
      case 'Quant Value Fund':
      case 'High Growth': // Fallback
        return FundProfileData(
          id: fundId,
          name: 'Quant Value Growth Direct Plan',
          tags: 'Equity • Value • Growth',
          logoText: 'quant',
          riskLabel: 'HIGH VOLATILITY FUND',
          riskColor: const Color(0xFFEF4444), // Red
          returnPercentage: '22.56%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 7.26% in Nifty 50 >',
          chartDataPoints: _baseChartData,
          chartColor: const Color(0xFF10B981), // Emerald 500
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹5,17,681',
          sipReturnPercentage: '(43.8%)',
          overviewText: 'Know about distribution of holdings by market capitalisation, sectors, and individual holdings.',
          assetAllocation: _mockAssetAllocation,
        );
      case 'Axis Value Fund':
        return FundProfileData(
          id: fundId,
          name: 'Axis Value Fund Direct',
          tags: 'Equity • Value',
          logoText: 'axis',
          riskLabel: 'MODERATE VOLATILITY',
          riskColor: const Color(0xFFF59E0B),
          returnPercentage: '18.73%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 7.26% in Nifty 50 >',
          chartDataPoints: _baseChartData.map((e) => e * 0.8).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,80,000',
          sipReturnPercentage: '(38.5%)',
          overviewText: 'Invests in undervalued companies with potential for long term capital appreciation.',
        );
      case 'HSBC Value Fund':
        return FundProfileData(
          id: fundId,
          name: 'HSBC Value Fund Direct Growth',
          tags: 'Equity • Value',
          logoText: 'hsbc',
          riskLabel: 'HIGH VOLATILITY',
          riskColor: const Color(0xFFF97316),
          returnPercentage: '18.40%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 7.26% in Nifty 50 >',
          chartDataPoints: _baseChartData.map((e) => e * 0.75).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,75,000',
          sipReturnPercentage: '(37.2%)',
          overviewText: 'Aims to provide long term capital growth by investing in a diversified portfolio of value stocks.',
        );

      // Investment Ideas - Safe Investing
      case 'HDFC Corporate Bond Fund':
      case 'Safe Investing':
      case 'Corporate Bonds':
        return FundProfileData(
          id: fundId,
          name: 'HDFC Corporate Bond Direct Plan',
          tags: 'Debt • Corporate Bond',
          logoText: 'hdfc',
          riskLabel: 'LOW TO MODERATE RISK',
          riskColor: const Color(0xFF10B981), // Green
          returnPercentage: '7.28%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 6.5% in FD >',
          chartDataPoints: _conservativeChartData,
          chartColor: const Color(0xFF3B82F6), // Blue
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,12,000',
          sipReturnPercentage: '(18.5%)',
          overviewText: 'Invests primarily in highly rated corporate bonds for steady income and low volatility.',
          assetAllocation: _mockAssetAllocation,
        );
      case 'SBI Debt Fund':
      case 'Debt Funds':
        return FundProfileData(
          id: fundId,
          name: 'SBI Short Term Debt Fund',
          tags: 'Debt • Short Term',
          logoText: 'sbi',
          riskLabel: 'LOW RISK',
          riskColor: const Color(0xFF10B981),
          returnPercentage: '7.10%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 6.5% in FD >',
          chartDataPoints: _conservativeChartData.map((e) => e * 0.9).toList(),
          chartColor: const Color(0xFF3B82F6),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,10,000',
          sipReturnPercentage: '(17.8%)',
          overviewText: 'A low risk debt fund ideal for short term parking of funds with better returns than a savings account.',
        );
      case 'ICICI Pru Savings Fund':
      case 'Liquid Funds':
        return FundProfileData(
          id: fundId,
          name: 'ICICI Pru Liquid Fund',
          tags: 'Debt • Liquid',
          logoText: 'icici',
          riskLabel: 'VERY LOW RISK',
          riskColor: const Color(0xFF10B981),
          returnPercentage: '6.75%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 4% in Savings A/C >',
          chartDataPoints: _conservativeChartData.map((e) => e * 0.8).toList(),
          chartColor: const Color(0xFF3B82F6),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,05,000',
          sipReturnPercentage: '(16.2%)',
          overviewText: 'Highly liquid fund providing safety of capital and moderate income.',
        );

      // Alternative Assets & Bento
      case 'REITs':
        return FundProfileData(
          id: fundId,
          name: 'Embassy Office Parks REIT',
          tags: 'Alternative • Real Estate',
          logoText: 'reit',
          riskLabel: 'MODERATE RISK',
          riskColor: const Color(0xFFF59E0B),
          returnPercentage: '8.45%',
          returnDuration: 'Dividend Yield',
          comparisonText: 'Stable real estate income >',
          chartDataPoints: _baseChartData.map((e) => e * 0.4 + 20).toList(),
          chartColor: const Color(0xFF8B5CF6), // Purple
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,25,000',
          sipReturnPercentage: '(22.5%)',
          overviewText: 'Invests in commercial real estate to generate stable rental income distributed as dividends.',
        );
      case 'Gold Funds':
      case 'Gold':
        return FundProfileData(
          id: fundId,
          name: 'Nippon India Gold Savings Fund',
          tags: 'Commodity • Gold',
          logoText: 'gold',
          riskLabel: 'MODERATE VOLATILITY',
          riskColor: const Color(0xFFF59E0B),
          returnPercentage: '14.20%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'Hedge against inflation >',
          chartDataPoints: _baseChartData.map((e) => e * 0.6 + 10).toList(),
          chartColor: const Color(0xFFF59E0B), // Amber
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,50,000',
          sipReturnPercentage: '(32.1%)',
          overviewText: 'Provides returns closely corresponding to physical gold prices without the hassle of storage.',
        );
      case 'Silver Funds':
      case 'Silver':
        return FundProfileData(
          id: fundId,
          name: 'ICICI Silver ETF Fund of Fund',
          tags: 'Commodity • Silver',
          logoText: 'slvr',
          riskLabel: 'HIGH VOLATILITY',
          riskColor: const Color(0xFFEF4444),
          returnPercentage: '16.80%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'Industrial demand driven >',
          chartDataPoints: _baseChartData.map((e) => e * 0.7).toList(),
          chartColor: const Color(0xFF94A3B8), // Slate
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,65,000',
          sipReturnPercentage: '(35.4%)',
          overviewText: 'Invests in physical silver and silver-related instruments to track silver performance.',
        );
      case 'INVITs':
        return FundProfileData(
          id: fundId,
          name: 'PowerGrid Infra INVIT',
          tags: 'Alternative • Infrastructure',
          logoText: 'inv',
          riskLabel: 'MODERATE RISK',
          riskColor: const Color(0xFFF59E0B),
          returnPercentage: '9.50%',
          returnDuration: 'Distribution Yield',
          comparisonText: 'Backed by Govt assets >',
          chartDataPoints: _conservativeChartData.map((e) => e * 1.2).toList(),
          chartColor: const Color(0xFF3B82F6),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,30,000',
          sipReturnPercentage: '(25.2%)',
          overviewText: 'Infrastructure investment trust providing stable yields from operational power transmission assets.',
        );
      case 'Fixed Deposits':
      case 'FDs':
        return FundProfileData(
          id: fundId,
          name: 'Bajaj Finance Fixed Deposit',
          tags: 'Debt • Fixed Income',
          logoText: 'fd',
          riskLabel: 'VERY LOW RISK',
          riskColor: const Color(0xFF10B981),
          returnPercentage: '8.10%',
          returnDuration: 'Annual Interest',
          comparisonText: 'Guaranteed Returns >',
          chartDataPoints: _conservativeChartData,
          chartColor: const Color(0xFF3B82F6),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,18,000',
          sipReturnPercentage: '(20.4%)',
          overviewText: 'Highly secure fixed deposit offering guaranteed returns with AAA rating.',
        );

      // Explore Grid / Generic
      case 'Top rated':
      case 'Parag Parikh Flexi Cap Fund':
        return FundProfileData(
          id: fundId,
          name: 'Parag Parikh Flexi Cap Fund',
          tags: 'Equity • Flexi Cap',
          logoText: 'ppfas',
          riskLabel: 'MODERATE VOLATILITY',
          riskColor: const Color(0xFFF59E0B),
          returnPercentage: '21.40%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'Consistently beats benchmark >',
          chartDataPoints: _baseChartData,
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹5,05,000',
          sipReturnPercentage: '(41.2%)',
          overviewText: 'An unconstrained equity fund investing across market caps and global markets for long term wealth creation.',
        );
      case 'Quant Small Cap Fund':
        return FundProfileData(
          id: fundId,
          name: 'Quant Small Cap Fund',
          tags: 'Equity • Small Cap',
          logoText: 'quant',
          riskLabel: 'VERY HIGH VOLATILITY',
          riskColor: const Color(0xFFEF4444),
          returnPercentage: '21.4%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 15.2% in Nifty Smallcap 250 >',
          chartDataPoints: _baseChartData.map((e) => e * 1.5).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹6,15,000',
          sipReturnPercentage: '(53.2%)',
          overviewText: 'Aggressively invests in small cap companies using quantitative models for rapid growth.',
        );
      case 'Global Exposure':
      case 'Magnificent 7':
      case 'Global Investing':
      case 'Global':
        return FundProfileData(
          id: fundId,
          name: 'Motilal Oswal Nasdaq 100 FOF',
          tags: 'Equity • Global • Tech',
          logoText: 'mo',
          riskLabel: 'HIGH VOLATILITY',
          riskColor: const Color(0xFFEF4444),
          returnPercentage: '26.80%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. Nasdaq 100 >',
          chartDataPoints: _baseChartData.map((e) => e * 1.3).toList(),
          chartColor: const Color(0xFF3B82F6), // Blue
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹5,50,000',
          sipReturnPercentage: '(45.5%)',
          overviewText: 'Invests in top 100 non-financial companies listed on the Nasdaq stock market.',
        );

      case 'Healthcare':
        return FundProfileData(
          id: fundId,
          name: 'SBI Healthcare Opportunities Fund',
          tags: 'Equity • Sectoral • Pharma',
          logoText: 'sbi',
          riskLabel: 'HIGH VOLATILITY',
          riskColor: const Color(0xFFF97316),
          returnPercentage: '19.50%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. Pharma Index >',
          chartDataPoints: _baseChartData.map((e) => e * 0.85).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,95,000',
          sipReturnPercentage: '(39.1%)',
          overviewText: 'Capitalizes on the growth of Indian pharmaceutical and healthcare sectors.',
        );
      case 'Japan':
        return FundProfileData(
          id: fundId,
          name: 'Nippon India Japan Equity Fund',
          tags: 'Equity • Global • Japan',
          logoText: 'nip',
          riskLabel: 'HIGH VOLATILITY',
          riskColor: const Color(0xFFEF4444),
          returnPercentage: '17.20%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. Nikkei 225 >',
          chartDataPoints: _baseChartData.map((e) => e * 0.7).toList(),
          chartColor: const Color(0xFF8B5CF6),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,70,000',
          sipReturnPercentage: '(36.5%)',
          overviewText: 'Provides exposure to Japanese markets which offer unique value and tech opportunities.',
        );
      case 'Europe':
        return FundProfileData(
          id: fundId,
          name: 'Invesco India Europe Fund',
          tags: 'Equity • Global • Europe',
          logoText: 'inv',
          riskLabel: 'HIGH VOLATILITY',
          riskColor: const Color(0xFFF97316),
          returnPercentage: '-4.40%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. Euro Stoxx 50 >',
          chartDataPoints: _baseChartData.reversed.map((e) => e * 0.6).toList(), // Trending down
          chartColor: const Color(0xFFEF4444), // Red
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹3,40,000',
          sipReturnPercentage: '(-19.8%)',
          overviewText: 'Invests in robust European businesses with global revenue streams.',
        );
      // Large Cap Funds
      case 'Mirae Asset Large Cap Fund':
        return FundProfileData(
          id: fundId,
          name: 'Mirae Asset Large Cap Fund',
          tags: 'Equity • Large Cap',
          logoText: 'mi',
          riskLabel: 'MODERATE VOLATILITY',
          riskColor: const Color(0xFFF59E0B),
          returnPercentage: '16.80%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 13.2% in Nifty 100 >',
          chartDataPoints: _baseChartData.map((e) => e * 0.75).toList(),
          chartColor: const Color(0xFF3B82F6),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,80,000',
          sipReturnPercentage: '(38.5%)',
          overviewText: 'One of India\'s most consistent large cap funds, investing in market leaders across sectors.',
          assetAllocation: _mockAssetAllocation,
        );
      case 'HDFC Top 100 Fund':
        return FundProfileData(
          id: fundId,
          name: 'HDFC Top 100 Fund',
          tags: 'Equity • Large Cap',
          logoText: 'hd',
          riskLabel: 'MODERATE VOLATILITY',
          riskColor: const Color(0xFFF59E0B),
          returnPercentage: '15.90%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 13.2% in Nifty 100 >',
          chartDataPoints: _baseChartData.map((e) => e * 0.7).toList(),
          chartColor: const Color(0xFF3B82F6),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,70,000',
          sipReturnPercentage: '(36.5%)',
          overviewText: 'Invests in top 100 companies by market cap listed on BSE for long term wealth creation.',
        );
      case 'ICICI Pru Bluechip Fund':
        return FundProfileData(
          id: fundId,
          name: 'ICICI Pru Bluechip Fund',
          tags: 'Equity • Large Cap',
          logoText: 'ic',
          riskLabel: 'MODERATE VOLATILITY',
          riskColor: const Color(0xFFF59E0B),
          returnPercentage: '15.20%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 13.2% in Nifty 100 >',
          chartDataPoints: _baseChartData.map((e) => e * 0.68).toList(),
          chartColor: const Color(0xFF3B82F6),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,60,000',
          sipReturnPercentage: '(34.2%)',
          overviewText: 'A bluechip fund targeting stable and well-established companies for consistent returns.',
        );
      case 'SBI Bluechip Fund':
        return FundProfileData(
          id: fundId,
          name: 'SBI Bluechip Fund',
          tags: 'Equity • Large Cap',
          logoText: 'sb',
          riskLabel: 'MODERATE VOLATILITY',
          riskColor: const Color(0xFFF59E0B),
          returnPercentage: '14.70%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 13.2% in Nifty 100 >',
          chartDataPoints: _baseChartData.map((e) => e * 0.65).toList(),
          chartColor: const Color(0xFF3B82F6),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,55,000',
          sipReturnPercentage: '(33.5%)',
          overviewText: 'Backed by India\'s largest public bank, invests in top-quality large cap equities.',
        );
      case 'Axis Bluechip Fund':
        return FundProfileData(
          id: fundId,
          name: 'Axis Bluechip Fund',
          tags: 'Equity • Large Cap',
          logoText: 'ax',
          riskLabel: 'MODERATE VOLATILITY',
          riskColor: const Color(0xFFF59E0B),
          returnPercentage: '13.50%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 13.2% in Nifty 100 >',
          chartDataPoints: _baseChartData.map((e) => e * 0.6).toList(),
          chartColor: const Color(0xFF3B82F6),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,45,000',
          sipReturnPercentage: '(31.8%)',
          overviewText: 'Focuses on high quality large cap companies with strong earnings growth and moats.',
        );

      // Mid Cap Funds
      case 'Quant Mid Cap Fund':
        return FundProfileData(
          id: fundId,
          name: 'Quant Mid Cap Fund',
          tags: 'Equity • Mid Cap',
          logoText: 'qm',
          riskLabel: 'HIGH VOLATILITY',
          riskColor: const Color(0xFFF97316),
          returnPercentage: '32.40%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 22.1% in Nifty Midcap 150 >',
          chartDataPoints: _baseChartData.map((e) => e * 1.35).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹6,20,000',
          sipReturnPercentage: '(54.2%)',
          overviewText: 'Uses a quantitative model to pick high-momentum mid cap stocks for superior returns.',
        );
      case 'Nippon India Growth Fund':
        return FundProfileData(
          id: fundId,
          name: 'Nippon India Growth Fund',
          tags: 'Equity • Mid Cap',
          logoText: 'ni',
          riskLabel: 'HIGH VOLATILITY',
          riskColor: const Color(0xFFF97316),
          returnPercentage: '28.60%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 22.1% in Nifty Midcap 150 >',
          chartDataPoints: _baseChartData.map((e) => e * 1.2).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹5,80,000',
          sipReturnPercentage: '(48.5%)',
          overviewText: 'Invests in growing mid-sized Indian companies with strong earnings potential.',
        );
      case 'HDFC Mid-Cap Opportunities':
        return FundProfileData(
          id: fundId,
          name: 'HDFC Mid-Cap Opportunities',
          tags: 'Equity • Mid Cap',
          logoText: 'hm',
          riskLabel: 'HIGH VOLATILITY',
          riskColor: const Color(0xFFF97316),
          returnPercentage: '26.90%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 22.1% in Nifty Midcap 150 >',
          chartDataPoints: _baseChartData.map((e) => e * 1.15).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹5,65,000',
          sipReturnPercentage: '(46.0%)',
          overviewText: 'Long running mid cap fund with a diversified portfolio of emerging Indian businesses.',
        );
      case 'Motilal Oswal Midcap Fund':
        return FundProfileData(
          id: fundId,
          name: 'Motilal Oswal Midcap Fund',
          tags: 'Equity • Mid Cap',
          logoText: 'mo',
          riskLabel: 'HIGH VOLATILITY',
          riskColor: const Color(0xFFF97316),
          returnPercentage: '25.30%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 22.1% in Nifty Midcap 150 >',
          chartDataPoints: _baseChartData.map((e) => e * 1.1).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹5,50,000',
          sipReturnPercentage: '(45.5%)',
          overviewText: 'Concentrated portfolio of conviction mid cap picks with a buy-and-hold philosophy.',
        );
      case 'Edelweiss Mid Cap Fund':
        return FundProfileData(
          id: fundId,
          name: 'Edelweiss Mid Cap Fund',
          tags: 'Equity • Mid Cap',
          logoText: 'ed',
          riskLabel: 'HIGH VOLATILITY',
          riskColor: const Color(0xFFF97316),
          returnPercentage: '23.80%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 22.1% in Nifty Midcap 150 >',
          chartDataPoints: _baseChartData.map((e) => e * 1.05).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹5,30,000',
          sipReturnPercentage: '(42.1%)',
          overviewText: 'Diversified mid cap fund seeking growth through a well-researched bottom-up approach.',
        );

      // Small Cap Funds
      case 'Nippon India Small Cap Fund':
        return FundProfileData(
          id: fundId,
          name: 'Nippon India Small Cap Fund',
          tags: 'Equity • Small Cap',
          logoText: 'ns',
          riskLabel: 'VERY HIGH VOLATILITY',
          riskColor: const Color(0xFFEF4444),
          returnPercentage: '38.60%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 28.4% in Nifty Smallcap 250 >',
          chartDataPoints: _baseChartData.map((e) => e * 1.6).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹6,80,000',
          sipReturnPercentage: '(62.4%)',
          overviewText: 'One of India\'s largest small cap funds by AUM, capturing high-growth emerging companies.',
        );
      case 'SBI Small Cap Fund':
        return FundProfileData(
          id: fundId,
          name: 'SBI Small Cap Fund',
          tags: 'Equity • Small Cap',
          logoText: 'ss',
          riskLabel: 'VERY HIGH VOLATILITY',
          riskColor: const Color(0xFFEF4444),
          returnPercentage: '34.20%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 28.4% in Nifty Smallcap 250 >',
          chartDataPoints: _baseChartData.map((e) => e * 1.45).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹6,40,000',
          sipReturnPercentage: '(58.0%)',
          overviewText: 'Seeks long term capital appreciation by investing in small cap companies with strong fundamentals.',
        );
      case 'Axis Small Cap Fund':
        return FundProfileData(
          id: fundId,
          name: 'Axis Small Cap Fund',
          tags: 'Equity • Small Cap',
          logoText: 'as',
          riskLabel: 'VERY HIGH VOLATILITY',
          riskColor: const Color(0xFFEF4444),
          returnPercentage: '29.80%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 28.4% in Nifty Smallcap 250 >',
          chartDataPoints: _baseChartData.map((e) => e * 1.3).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹5,90,000',
          sipReturnPercentage: '(51.2%)',
          overviewText: 'Quality-focused small cap fund targeting companies with robust business models.',
        );
      case 'DSP Small Cap Fund':
        return FundProfileData(
          id: fundId,
          name: 'DSP Small Cap Fund',
          tags: 'Equity • Small Cap',
          logoText: 'ds',
          riskLabel: 'VERY HIGH VOLATILITY',
          riskColor: const Color(0xFFEF4444),
          returnPercentage: '27.50%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 28.4% in Nifty Smallcap 250 >',
          chartDataPoints: _baseChartData.map((e) => e * 1.2).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹5,65,000',
          sipReturnPercentage: '(45.8%)',
          overviewText: 'Research-driven small cap portfolio targeting emerging companies across sectors.',
        );

      // Bonds
      case 'Adani Airport':
        return FundProfileData(
          id: fundId,
          name: 'Adani Airport Holdings Ltd',
          tags: 'Debt • Corporate Bond',
          logoText: 'adani',
          riskLabel: 'MODERATE RISK',
          riskColor: const Color(0xFFF59E0B),
          returnPercentage: '8.5%',
          returnDuration: 'Annual Interest',
          comparisonText: 'vs. 6.5% in FD >',
          chartDataPoints: _conservativeChartData,
          chartColor: const Color(0xFF3B82F6),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,30,000',
          sipReturnPercentage: '(25.2%)',
          overviewText: 'Invests in Adani Airport Holdings for steady interest income.',
        );
      case 'Akme Fintrade':
      case 'Monedo Oct\' 27':
      case 'DAR Credit':
      case 'Capri Global':
      case 'Navi Finserv Ltd':
        return FundProfileData(
          id: fundId,
          name: '$fundId Bond',
          tags: 'Debt • Corporate Bond',
          logoText: fundId.substring(0, 3).toLowerCase(),
          riskLabel: 'MODERATE TO HIGH RISK',
          riskColor: const Color(0xFFF97316),
          returnPercentage: fundId == 'Akme Fintrade' ? '12.0%' : fundId.contains('Navi') ? '10.85%' : fundId.contains('Capri') ? '9.0%' : '13.5%',
          returnDuration: 'Annual Interest',
          comparisonText: 'High yield corporate bond >',
          chartDataPoints: _conservativeChartData.map((e) => e * 1.1).toList(),
          chartColor: const Color(0xFF3B82F6),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,50,000',
          sipReturnPercentage: '(32.1%)',
          overviewText: 'High yield corporate bond providing superior returns with commensurate credit risk.',
        );

      // Collection Screens Mock Funds
      case 'DSP Value Fund':
      case 'LIC MF Value Fund':
      case 'HDFC Value Fund':
      case 'Aditya Birla Sun Life Value Fund':
        return FundProfileData(
          id: fundId,
          name: fundId,
          tags: 'Equity • Value',
          logoText: fundId.substring(0, 3).toLowerCase(),
          riskLabel: 'HIGH VOLATILITY',
          riskColor: const Color(0xFFF97316),
          returnPercentage: '17.50%',
          returnDuration: '3Y Annualised Return',
          comparisonText: 'vs. 7.26% in Nifty 50 >',
          chartDataPoints: _baseChartData.map((e) => e * 0.8).toList(),
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,70,000',
          sipReturnPercentage: '(36.5%)',
          overviewText: 'Aims to provide long term capital growth by investing in a diversified portfolio of value stocks.',
        );

      case 'Explore By Risk':
      case 'Aggressive':
      case 'Moderate':
      case 'Conservative':
      case 'Very Conservative':
      default:
        return FundProfileData(
          id: fundId,
          name: '$fundId Portfolio',
          tags: 'Portfolio • Diversified',
          logoText: 'port',
          riskLabel: 'DYNAMIC RISK',
          riskColor: const Color(0xFF3B82F6),
          returnPercentage: '15.00%',
          returnDuration: 'Expected CAGR',
          comparisonText: 'Algorithm managed >',
          chartDataPoints: _baseChartData,
          chartColor: const Color(0xFF10B981),
          sipAmount: 10000,
          sipDurationText: '3 years',
          sipFinalAmount: '₹4,50,000',
          sipReturnPercentage: '(32.5%)',
          overviewText: 'A dynamically managed portfolio tailored to your specific risk profile.',
          assetAllocation: _mockAssetAllocation,
        );
    }
  }
}
