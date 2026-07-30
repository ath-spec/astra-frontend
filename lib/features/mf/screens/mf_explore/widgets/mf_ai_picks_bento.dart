import 'package:flutter/material.dart';

class MfAiPicksBento extends StatelessWidget {
  const MfAiPicksBento({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'AI Picks',
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
            height: 210,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left tall card (AI Hero)
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF818CF8), // Indigo 400
                          Color(0xFF4F46E5), // Indigo 600
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI thinks\nthis week',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Personalized picks\njust for you.',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.auto_awesome_rounded, color: Colors.white.withOpacity(0.5), size: 36),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Right Grid
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Top Row of 2 cards
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                            child: _buildSmallCard(
                              title: 'Gold Funds',
                              subtitle: 'Hedge &\nStability',
                              icon: Icons.inventory_2_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              backgroundColor: const Color(0xFFFFFBEB),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSmallCard(
                              title: 'REITs',
                              subtitle: 'Real Estate\nIncome',
                              icon: Icons.apartment_rounded,
                              iconColor: const Color(0xFF3B82F6),
                              backgroundColor: const Color(0xFFF8FAFC),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                      // Bottom wide card
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Healthcare',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Long term growth\nopportunity',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF94A3B8),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.vaccines_rounded, color: Color(0xFF10B981), size: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
              height: 1.3,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ],
      ),
    );
  }
}
