import 'package:flutter/material.dart';
import '../../fund_profile/mf_fund_profile_screen.dart';

class MfFundListCard extends StatelessWidget {
  final String sectionTitle;
  final String cardTitle;
  final String cardSubtitle;
  final Widget cardGraphic; // E.g., an icon or custom drawn widget
  final List<MfFundItemData> funds;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final VoidCallback? onViewCollection;

  const MfFundListCard({
    super.key,
    required this.sectionTitle,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.cardGraphic,
    required this.funds,
    this.margin,
    this.borderColor,
    this.onViewCollection,
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
                fontWeight: FontWeight.w600,
                letterSpacing: -1.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Container(
          margin: margin ?? const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: borderColor ?? const Color(0xFFF1F5F9),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
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
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cardSubtitle,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9CA3AF),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    cardGraphic,
                  ],
                ),
              ),
              // List of funds
              ...funds.map((fund) => _buildFundRow(context, fund)),
              // Footer
              InkWell(
                onTap: onViewCollection,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  child: Row(
                    children: const [
                      Text(
                        'View collection',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
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
      onTap: () => MfFundProfileScreen.showModal(
          context, fund.schemeCode.isNotEmpty ? fund.schemeCode : fund.name),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFF1F5F9),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Icon(fund.logoIcon, color: fund.logoColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fund.name,
                    maxLines: 3,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fund.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '3Y Returns',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  fund.returns,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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
  final String schemeCode;

  const MfFundItemData({
    required this.name,
    required this.category,
    required this.returns,
    required this.logoIcon,
    required this.logoColor,
    this.schemeCode = '',
  });
}
