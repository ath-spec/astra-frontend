import 'package:flutter/material.dart';

class MfNewTrendingThemes extends StatelessWidget {
  const MfNewTrendingThemes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Trending Themes',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildThemeCard(
                title: 'AI Revolution',
                subtitle: 'Invest in companies\nbuilding AI.',
                icon: Icons.memory_rounded,
                iconColor: const Color(0xFF8B5CF6),
              ),
              const SizedBox(width: 12),
              _buildThemeCard(
                title: 'India\nManufacturing',
                subtitle: 'Back India\'s next\ngrowth engine.',
                icon: Icons.factory_rounded,
                iconColor: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 12),
              _buildThemeCard(
                title: 'Semi-\nConductor',
                subtitle: 'Powering the\ndigital future.',
                icon: Icons.developer_board_rounded,
                iconColor: const Color(0xFF10B981),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: 160,
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
              height: 1.3,
            ),
          ),
          const Spacer(),
          Center(
            child: Icon(icon, size: 64, color: iconColor.withOpacity(0.5)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Explore',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
