import 'package:flutter/material.dart';
import '../../fund_profile/mf_fund_profile_screen.dart';

class MfNewAlternativeAssets extends StatelessWidget {
  const MfNewAlternativeAssets({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Alternative Assets',
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildAssetCard(
                  context,
                  title: 'REITs',
                  subtitle: 'Invest in income\ngenerating\nreal estate.',
                  icon: Icons.apartment_rounded,
                  iconColor: const Color(0xFF3B82F6),
                ),
                _buildAssetCard(
                  context,
                  title: 'Gold Funds',
                  subtitle: 'Diversify with\ngold investments.',
                  icon: Icons.inventory_2_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  backgroundColor: const Color(0xFFFFFBEB), // Faint amber
                ),
                _buildAssetCard(
                  context,
                  title: 'Silver Funds',
                  subtitle: 'Add silver to\nyour portfolio.',
                  icon: Icons.monetization_on_rounded,
                  iconColor: const Color(0xFF94A3B8),
                ),
                _buildAssetCard(
                  context,
                  title: 'INVITs',
                  subtitle: 'Infrastructure\ninvestments\nfor steady\nreturns.',
                  icon: Icons.account_tree_rounded,
                  iconColor: const Color(0xFF10B981),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    Color? backgroundColor,
  }) {
    // Responsive width logic: half width minus half the spacing
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth > 600 ? 200.0 : (screenWidth - 32 - 12) / 2;

    return GestureDetector(
      onTap: () => MfFundProfileScreen.showModal(context, title),
      child: Container(
        width: itemWidth,
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
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
            ],
          ),
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              icon,
              size: 64,
              color: iconColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
