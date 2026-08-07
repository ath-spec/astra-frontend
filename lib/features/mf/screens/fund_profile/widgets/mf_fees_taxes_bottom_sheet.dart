import 'package:flutter/material.dart';

class MfFeesTaxesBottomSheet extends StatelessWidget {
  const MfFeesTaxesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              'Fees & taxes on investment',
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
                    'Expense ratio',
                    'A fee payable to a mutual fund house for managing your mutual fund investments. It is the total percentage of a company\'s fund assets used for administrative, management, advertising, and other expenses.',
                  ),
                  _buildDefinitionItem(
                    'Exit load',
                    'A fee payable to a mutual fund house for exiting a fund (fully or partially) before the completion of a specified period from the date of investment.',
                  ),
                  _buildDefinitionItem(
                    'Taxes',
                    'A percentage of your capital gains payable to the government upon exiting your mutual fund investments. Taxation is categorized as long-term capital gains (LTCG) and short-term capital gains (STCG) depending on your holding period and the type of fund.',
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
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Divider(color: Color(0xFFF1F5F9), height: 1), // Subtle divider matching screenshot
          ),
      ],
    );
  }
}
