import 'package:flutter/material.dart';

class LearningsScreen extends StatelessWidget {
  const LearningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learnings',
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.0,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bite-sized financial wisdom, curated for you.',
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 36,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Coming soon',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your personalised learning feed\nis being built.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF94A3B8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom padding for floating nav
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
