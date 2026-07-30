import 'package:flutter/material.dart';

class MfNewQuickExplore extends StatelessWidget {
  const MfNewQuickExplore({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'Mutual Funds', 'icon': Icons.bar_chart_rounded, 'color': const Color(0xFF818CF8)},
      {'title': 'Stocks', 'icon': Icons.trending_up_rounded, 'color': const Color(0xFF3B82F6)},
      {'title': 'ETFs', 'icon': Icons.pie_chart_rounded, 'color': const Color(0xFF10B981)},
      {'title': 'Gold', 'icon': Icons.inventory_2_rounded, 'color': const Color(0xFFF59E0B)},
      {'title': 'REITs', 'icon': Icons.location_city_rounded, 'color': const Color(0xFF6366F1)},
      {'title': 'INVITs', 'icon': Icons.layers_rounded, 'color': const Color(0xFF8B5CF6)},
      {'title': 'Bonds', 'icon': Icons.description_rounded, 'color': const Color(0xFFEC4899)},
      {'title': 'Global', 'icon': Icons.public_rounded, 'color': const Color(0xFF06B6D4)},
      {'title': 'FDs', 'icon': Icons.lock_outline_rounded, 'color': const Color(0xFFF59E0B)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Quick Explore',
            style: TextStyle(
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
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 24,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8, // Adjust to fit icon + text
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['title'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
