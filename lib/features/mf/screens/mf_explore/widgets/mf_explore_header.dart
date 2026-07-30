import 'package:flutter/material.dart';

class MfExploreHeader extends StatelessWidget {
  const MfExploreHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 64, bottom: 80),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        image: DecorationImage(
          image: AssetImage('lib/core/images/xplore_pillars.webp'),
          fit: BoxFit.fill,
          alignment: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'MUTUAL FUNDS VALUE',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '₹3,43,158',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.5,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.arrow_upward_rounded,
                size: 14,
                color: Color(0xFF10B981), // Emerald 500
              ),
              const SizedBox(width: 4),
              const Text(
                '₹2,491 (0.73%)',
                style: TextStyle(
                  fontFamily: 'DMMono',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '1D change',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
