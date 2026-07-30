import 'package:flutter/material.dart';

class MfExploreAssets extends StatelessWidget {
  const MfExploreAssets({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'Mutual\nFunds', 'icon': Icons.pie_chart_rounded, 'color': const Color(0xFF60A5FA)},
      {'title': 'Stocks', 'icon': Icons.trending_up_rounded, 'color': const Color(0xFF34D399)},
      {'title': 'ETFs', 'icon': Icons.widgets_rounded, 'color': const Color(0xFF3B82F6)},
      {'title': 'Gold', 'icon': Icons.inventory_2_rounded, 'color': const Color(0xFFFBBF24)},
      {'title': 'Bonds', 'icon': Icons.security_rounded, 'color': const Color(0xFF60A5FA)},
      {'title': 'REITs', 'icon': Icons.location_city_rounded, 'color': const Color(0xFFA78BFA)},
      {'title': 'INVITs', 'icon': Icons.account_tree_rounded, 'color': const Color(0xFF34D399)},
      {'title': 'FDs', 'icon': Icons.lock_rounded, 'color': const Color(0xFF3B82F6)},
      {'title': 'Global\nFunds', 'icon': Icons.public_rounded, 'color': const Color(0xFF3B82F6)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'EXPLORE ASSETS',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Color(0xFF475569),
                ),
              ),
              Row(
                children: const [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF0F172A),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
