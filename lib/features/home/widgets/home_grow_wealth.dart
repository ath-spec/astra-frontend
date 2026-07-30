import 'package:flutter/material.dart';

class HomeGrowWealth extends StatelessWidget {
  const HomeGrowWealth({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Grow wealth with Mutual Funds',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            // Top Row (Tall Blue Card + 2 small stacked cards)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tall Blue Card
                Expanded(
                  child: Container(
                    height: 160,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB), // Blue 600
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'All Mutual\nFunds',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Explore',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Two stacked cards
                Expanded(
                  child: Column(
                    children: [
                      _buildSmallCard(
                        title: 'Goal Pilot',
                        icon: Icons.rocket_launch_rounded,
                        iconColor: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(height: 12),
                      _buildSmallCard(
                        title: 'Mutual Funds\nStrategies',
                        icon: Icons.layers_rounded,
                        iconColor: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bottom Row (2 small horizontal cards)
            Row(
              children: [
                Expanded(
                  child: _buildSmallCard(
                    title: 'Invest in\nTOP 30 funds',
                    icon: Icons.access_time_filled_rounded,
                    iconColor: const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSmallCard(
                    title: 'Invest in SIF',
                    icon: Icons.stars_rounded,
                    iconColor: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallCard({
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
