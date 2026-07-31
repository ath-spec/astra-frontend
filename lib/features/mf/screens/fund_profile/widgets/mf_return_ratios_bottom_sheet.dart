import 'package:flutter/material.dart';

class MfReturnRatiosBottomSheet extends StatelessWidget {
  const MfReturnRatiosBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      // make it responsive and handle safe area for android nav bar
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Wrap content tightly
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 24),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Return ratios',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDefinitionItem(
                    'Alpha',
                    'Alpha in mutual funds measures excess return relative to a benchmark, indicating a manager\'s skill at generating returns beyond market performance.',
                  ),
                  _buildDefinitionItem(
                    'Beta',
                    'Beta in mutual funds indicates a fund\'s sensitivity to market changes. A beta over 1 means it\'s more volatile than the market, while below 1 implies less volatility.',
                  ),
                  _buildDefinitionItem(
                    'Sharpe',
                    'Sharpe Ratio evaluates a fund\'s return relative to its risk. Higher values signify better risk-adjusted performance.',
                  ),
                  _buildDefinitionItem(
                    'Standard Deviation',
                    'Standard Deviation is a statistical measure of a fund\'s volatility or risk. It shows how much the fund\'s returns have historically fluctuated around its average return. A higher Std Dev. signifies higher risk due to greater potential for large swings in returns.',
                    isLast: true,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefinitionItem(String title, String description, {bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            child: Divider(color: Color(0xFFF1F5F9), height: 1), // Subtle divider matching screenshot
          ),
      ],
    );
  }
}
