import 'package:flutter/material.dart';

class MfAlternativeFunds extends StatelessWidget {
  const MfAlternativeFunds({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alternative to FD',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Better returns than FDs, liquid and tax efficient',
                      style: TextStyle(
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
              Row(
                children: [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140, // Slightly shorter than Trending because only 3 stats
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildAlternativeCard(
                name: 'Union Liquid Fund',
                category: 'Debt • Liquid',
                expense: '0.06%',
                aum: '₹6649 Crs',
                returns: '7.0%',
                logoIcon: Icons.water_drop_outlined,
                logoColor: Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildAlternativeCard(
                name: 'HDFC Liquid Fund',
                category: 'Debt • Liquid',
                expense: '0.08%',
                aum: '₹8000 Crs',
                returns: '7.1%',
                logoIcon: Icons.account_balance,
                logoColor: Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlternativeCard({
    required String name,
    required String category,
    required String expense,
    required String aum,
    required String returns,
    required IconData logoIcon,
    required Color logoColor,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(logoIcon, color: logoColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category,
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
            ],
          ),
          const Spacer(),
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
            margin: const EdgeInsets.only(bottom: 12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Expense ratio', expense),
              _buildStat('AUM', aum),
              _buildStat('3Y Returns', returns, isGreen: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {bool isGreen = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isGreen ? const Color(0xFF10B981) : const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ],
    );
  }
}
