import 'package:flutter/material.dart';

class MfLearnAndGrow extends StatelessWidget {
  const MfLearnAndGrow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Learn & Grow',
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildArticleCard(
                title: 'What is\nan ETF?',
                readTime: '2 min read',
                icon: Icons.menu_book_rounded,
              ),
              const SizedBox(width: 12),
              _buildArticleCard(
                title: 'REITs\nExplained',
                readTime: '3 min read',
                icon: Icons.apartment_rounded,
              ),
              const SizedBox(width: 12),
              _buildArticleCard(
                title: 'Bonds\nBasics',
                readTime: '2 min read',
                icon: Icons.security_rounded,
              ),
              const SizedBox(width: 12),
              _buildArticleCard(
                title: 'SIP\nGuide',
                readTime: '3 min read',
                icon: Icons.calendar_month_rounded,
              ),
              const SizedBox(width: 12),
              _buildArticleCard(
                title: 'Risk vs\nReturn',
                readTime: '2 min read',
                icon: Icons.pie_chart_rounded,
              ),
              const SizedBox(width: 16),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0F172A), size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArticleCard({
    required String title,
    required String readTime,
    required IconData icon,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                readTime,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          Icon(icon, color: const Color(0xFFCBD5E1), size: 24),
        ],
      ),
    );
  }
}
