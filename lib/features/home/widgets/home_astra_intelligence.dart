import 'package:flutter/material.dart';

class HomeAstraIntelligence extends StatelessWidget {
  const HomeAstraIntelligence({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Invest with Astra\'s intelligence',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        
        // Main Strategy Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mutual Fund Strategies',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Text(
                          'All-weather',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD97706), // Amber 600
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Color(0xFFD97706),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Simulated sun/cloud icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: Color(0xFFF59E0B),
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Horizontal Goal Cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildGoalCard(
                icon: Icons.home_rounded,
                iconColor: const Color(0xFF10B981),
                iconBgColor: const Color(0xFFECFDF5),
                title: 'Plan your\ndream home',
              ),
              const SizedBox(width: 12),
              _buildGoalCard(
                icon: Icons.school_rounded,
                iconColor: const Color(0xFF3B82F6),
                iconBgColor: const Color(0xFFEFF6FF),
                title: 'Plan your child\'s\neducation',
              ),
              const SizedBox(width: 12),
              _buildGoalCard(
                icon: Icons.add_rounded,
                iconColor: const Color(0xFF64748B),
                iconBgColor: const Color(0xFFF1F5F9),
                title: 'Custom Goal',
                isAdd: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    bool isAdd = false,
  }) {
    return Container(
      width: 145,
      height: 125,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(isAdd ? 8 : 12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: isAdd ? 28 : 24,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isAdd ? const Color(0xFF64748B) : const Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
