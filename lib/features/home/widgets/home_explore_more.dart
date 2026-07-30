import 'package:flutter/material.dart';

class HomeExploreMore extends StatelessWidget {
  const HomeExploreMore({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'SIF', 'icon': Icons.trending_up_rounded, 'color': 0xFF10B981},
      {'title': 'FD', 'icon': Icons.savings_rounded, 'color': 0xFF10B981},
      {'title': 'Bonds', 'icon': Icons.assignment_rounded, 'color': 0xFF10B981, 'tag': 'Up to 13.5%'},
      {'title': 'Guaranteed\nIncome', 'icon': Icons.verified_user_rounded, 'color': 0xFF10B981},
      {'title': 'Term\nInsurance', 'icon': Icons.shield_rounded, 'color': 0xFF10B981},
      {'title': 'NPS', 'icon': Icons.account_balance_wallet_rounded, 'color': 0xFF10B981},
      {'title': 'Loans', 'icon': Icons.monetization_on_rounded, 'color': 0xFF10B981},
      {'title': 'ITR FY 25-26', 'icon': Icons.request_quote_rounded, 'color': 0xFF10B981, 'tag': 'Upto 65% off', 'isNew': true},
      {'title': 'More', 'icon': Icons.grid_view_rounded, 'color': 0xFF64748B},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore more on Astra',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 110,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildTile(
              title: item['title'] as String,
              icon: item['icon'] as IconData,
              color: Color(item['color'] as int),
              tag: item['tag'] as String?,
              isNew: item['isNew'] as bool? ?? false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTile({
    required String title,
    required IconData icon,
    required Color color,
    String? tag,
    bool isNew = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          if (tag != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF1E5142), // Dark forest green
                borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Text(
                tag,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          else
            const SizedBox(height: 16),
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
                if (isNew) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: const Text(
                      '• NEW',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
