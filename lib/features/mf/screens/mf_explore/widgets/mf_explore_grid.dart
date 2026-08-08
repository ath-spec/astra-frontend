import 'package:flutter/material.dart';
import '../../fund_profile/mf_fund_profile_screen.dart';

class MfExploreGrid extends StatelessWidget {
  const MfExploreGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Funds',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildGridCard(
                  context,
                  title: 'Top rated',
                  colors: const [Color(0xFFA7F3D0), Color(0xFF6EE7B7)], // Emerald 200 -> 300
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFF34D399), // Emerald 400
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridCard(
                  context,
                  title: 'Global Exposure',
                  colors: const [Color(0xFFDBEAFE), Color(0xFF93C5FD)], // Blue 100 -> 300
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFF60A5FA), // Blue 400
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGridCard(
                  context,
                  title: 'Silver Funds',
                  colors: const [Color(0xFFF8FAFC), Color(0xFFE2E8F0)], // Slate 50 -> 200
                  icon: Icons.monetization_on_rounded, // Simulating coins
                  iconColor: const Color(0xFFCBD5E1), // Slate 300
                  textColor: const Color(0xFF334155),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridCard(
                  context,
                  title: 'Gold Funds',
                  colors: const [Color(0xFFFEF3C7), Color(0xFFFCD34D)], // Amber 100 -> 300
                  icon: Icons.view_agenda_rounded, // Simulating gold bars
                  iconColor: const Color(0xFFFBBF24), // Amber 400
                  textColor: const Color(0xFF78350F), // Amber 900
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context, {
    required String title,
    required List<Color> colors,
    required IconData icon,
    required Color iconColor,
    Color textColor = const Color(0xFF064E3B), // Default dark green for Top Rated
  }) {
    // If it's global exposure, make text dark blue
    if (title == 'Global Exposure') {
      textColor = const Color(0xFF1E3A8A); // Blue 900
    }

    return GestureDetector(
      onTap: () => MfFundProfileScreen.showModal(context, title),
      child: Container(
        height: 76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -16,
            child: Icon(
              icon,
              size: 72,
              color: iconColor.withValues(alpha: 0.5), // Simulated 3D graphic fade
            ),
          ),
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
