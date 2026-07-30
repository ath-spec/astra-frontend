import 'package:flutter/material.dart';

class HomePortfolioInsights extends StatelessWidget {
  const HomePortfolioInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Unlock portfolio insights',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect funds, stocks\n& bank accounts in one place.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          
          // Simulated Interactive Box
          Container(
            height: 125,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF1F2), // Rose 50
                  Color(0xFFFFFFFF),
                ],
              ),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Stack(
              children: [
                // Faint grid background
                Positioned.fill(
                  child: GridPaper(
                    color: const Color(0xFFE11D48).withOpacity(0.05), // Rose 600
                    divisions: 1,
                    subdivisions: 1,
                    interval: 20,
                  ),
                ),
                // Card in the middle
                Center(
                  child: Container(
                    width: 240,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE11D48).withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add some debt to\nyour portfolio',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'FIX NOW',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Mini simulated graph
                        Container(
                          width: 40,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 40,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE11D48), // Rose 600
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Connect account button
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Connect account',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
