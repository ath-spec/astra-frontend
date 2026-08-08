import 'package:flutter/material.dart';
import '../../fund_profile/mf_fund_profile_screen.dart';
import '../../mf_collection/mf_global_invest_collections_screen.dart';

class MfGlobalInvesting extends StatelessWidget {
  const MfGlobalInvesting({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Global Investing',
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
        GestureDetector(
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => const MfGlobalInvestCollectionsScreen(),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Slate 900
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              // Graphic
              Positioned(
                right: -10,
                top: -20,
                bottom: -20,
                child: SizedBox(
                  width: 200,
                  child: Center(
                    child: Image.asset(
                      'lib/core/images/global_invest.webp',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Global Investing',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Own the world\'s greatest\ncompanies.',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8), // Slate 400
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: const [
                        Text(
                          'Explore',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                      ],
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
}
