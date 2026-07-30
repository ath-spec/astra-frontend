import 'package:flutter/material.dart';

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
              fontFamily: 'SpaceGrotesk',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Slate 900
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              // Globe simulation background graphic
              Positioned(
                right: -40,
                top: -20,
                bottom: -20,
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF818CF8).withOpacity(0.4), // Indigo 400
                        const Color(0xFF3730A3).withOpacity(0.6), // Indigo 800
                        const Color(0xFF0F172A).withOpacity(0.0),
                      ],
                      stops: const [0.2, 0.6, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.public_rounded,
                      size: 140,
                      color: Colors.white.withOpacity(0.15),
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
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
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
                            fontWeight: FontWeight.w700,
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
        const SizedBox(height: 16),
        // Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildPill('Magnificent 7', isDark: true),
              const SizedBox(width: 8),
              _buildPill('AI'),
              const SizedBox(width: 8),
              _buildPill('Healthcare'),
              const SizedBox(width: 8),
              _buildPill('Japan'),
              const SizedBox(width: 8),
              _buildPill('Europe'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPill(String text, {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF475569),
        ),
      ),
    );
  }
}
