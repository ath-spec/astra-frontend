import 'package:flutter/material.dart';
import '../../fund_profile/mf_fund_profile_screen.dart';

class MfFundListCard extends StatelessWidget {
  final String sectionTitle;
  final String cardTitle;
  final String cardSubtitle;
  final Widget cardGraphic; // E.g., an icon or custom drawn widget
  final List<MfFundItemData> funds;

  const MfFundListCard({
    super.key,
    required this.sectionTitle,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.cardGraphic,
    required this.funds,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionTitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              sectionTitle,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFF1F5F9), // Slate 100
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cardTitle,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cardSubtitle,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9CA3AF),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Simulated 3D Graphic
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: cardGraphic,
                    ),
                  ],
                ),
              ),
              // List of funds
              ...funds.map((fund) => _buildFundRow(context, fund)).toList(),
              // Footer
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Text(
                      'View collection',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFundRow(BuildContext context, MfFundItemData fund) {
    return GestureDetector(
      onTap: () => MfFundProfileScreen.showModal(context, fund.name),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFF1F5F9),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Icon(fund.logoIcon, color: fund.logoColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fund.name,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fund.category,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '3Y Returns',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fund.returns,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MfFundItemData {
  final String name;
  final String category;
  final String returns;
  final IconData logoIcon;
  final Color logoColor;

  const MfFundItemData({
    required this.name,
    required this.category,
    required this.returns,
    required this.logoIcon,
    required this.logoColor,
  });
}
