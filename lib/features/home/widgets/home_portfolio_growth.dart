import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'portfolio_interactive_chart.dart';

class HomePortfolioGrowth extends StatefulWidget {
  const HomePortfolioGrowth({super.key});

  @override
  State<HomePortfolioGrowth> createState() => _HomePortfolioGrowthState();
}

class _HomePortfolioGrowthState extends State<HomePortfolioGrowth> {
  String _selectedPeriod = 'ALL';

  List<ChartDataPoint> _generateMockData(String period) {
    final random = Random(period.hashCode);
    final now = DateTime.now();
    int count = 30;
    double startVal = 100000;
    double endVal = 343158;
    Duration step = const Duration(days: 1);

    switch (period) {
      case '1M':
        startVal = 330000;
        count = 30;
        step = const Duration(days: 1);
        break;
      case '6M':
        startVal = 280000;
        count = 26; // approx weeks
        step = const Duration(days: 7);
        break;
      case '1Y':
        startVal = 200000;
        count = 52; // weeks
        step = const Duration(days: 7);
        break;
      case 'ALL':
      default:
        startVal = 120000;
        count = 60; // months
        step = const Duration(days: 30);
        break;
    }

    final data = <ChartDataPoint>[];
    double currentVal = startVal;
    
    for (int i = 0; i < count; i++) {
      // Add some random walk noise leaning upwards
      final progress = i / (count - 1);
      final expectedVal = startVal + (endVal - startVal) * (progress * progress); // curve
      
      currentVal = expectedVal + (random.nextDouble() * 10000 - 5000); // noise
      if (i == count - 1) currentVal = endVal; // force end value

      final date = now.subtract(step * (count - 1 - i));
      final dateStr = _formatDate(date);
      
      final mfValue = currentVal * 0.706;
      final stocksValue = currentVal * 0.294;
      final surplusValue = 0.0;
      
      data.add(ChartDataPoint(
        value: currentVal, 
        mfValue: mfValue,
        stocksValue: stocksValue,
        surplusValue: surplusValue,
        dateStr: dateStr,
      ));
    }

    return data;
  }

  String _formatDate(DateTime date) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${date.day} ${months[date.month - 1]} \'${date.year.toString().substring(2)}';
  }

  String _getStartLabel(String period) {
    switch (period) {
      case '1M': return '1 MONTH AGO';
      case '6M': return '6 MONTHS AGO';
      case '1Y': return '1 YEAR AGO';
      case 'ALL':
      default: return 'APR \'24';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentData = _generateMockData(_selectedPeriod);
    final isPositive = currentData.last.value >= currentData.first.value;
    final chartColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Portfolio Growth',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'PORTFOLIO VALUE',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '₹3,43,158',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
              color: chartColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.bar_chart_rounded, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Portfolio growth does not include your bank balance',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Chart
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: PortfolioInteractiveChart(
              key: ValueKey(_selectedPeriod),
              data: currentData,
              lineColor: chartColor,
              height: 180,
              startDateLabel: _getStartLabel(_selectedPeriod),
              endDateLabel: 'TODAY',
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Timeline toggles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTimeframeToggle('1M'),
                _buildTimeframeToggle('6M'),
                _buildTimeframeToggle('1Y'),
                _buildTimeframeToggle('ALL'),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Bottom divider matching the design
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Divider(color: Color(0xFFE2E8F0), thickness: 1, height: 1),
        ),
      ],
    );
  }

  Widget _buildTimeframeToggle(String label) {
    final isSelected = _selectedPeriod == label;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _selectedPeriod = label;
          });
        }
      },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
          label,
            style: TextStyle(
              fontFamily: 'DMMono',
              fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

