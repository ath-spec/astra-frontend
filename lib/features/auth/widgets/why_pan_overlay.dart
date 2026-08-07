import 'package:flutter/material.dart';

/// Modal bottom sheet overlay shown when tapping "WHY PAN?".
/// Uses the app's exact 3-font typography system, colors, and CTA styling.
class WhyPanOverlay extends StatelessWidget {
  const WhyPanOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title and Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Why PAN?',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      color: Color(0xFF111827),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Reason Items with consistent horizontal padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildReasonItem(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: const Color(0xFF031E6B), // Brand Blue
                    bgColor: const Color(0xFFF3E8FF),
                    title: 'Fetch your data in just a few clicks',
                    subtitle:
                        'NO HASSLE OF FORWARDING EMAIL REPORTS.',
                  ),
                  const SizedBox(height: 20),
                  _buildReasonItem(
                    icon: Icons.pie_chart_rounded,
                    iconColor: const Color(0xFF0284C7), // Sky Blue
                    bgColor: const Color(0xFFE0F2FE),
                    title: 'All investments linked to PAN & mobile',
                    subtitle:
                        'INCLUDING ALL YOUR PAST HOLDINGS.',
                  ),
                  const SizedBox(height: 20),
                  _buildReasonItem(
                    icon: Icons.verified_user_rounded,
                    iconColor: const Color(0xFF059669), // Emerald Green
                    bgColor: const Color(0xFFD1FAE5),
                    title: 'Your data is kept secure',
                    subtitle:
                        'YOU CAN DELETE YOUR DATA ANYTIME',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // CTA Button matching exact app CONTINUE button style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFF5BA1F7),
                        Color(0xFF031E6B),
                        Color(0xFF241714),
                      ],
                      stops: [0.0, 0.25, 0.7, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'I UNDERSTAND',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  color: Color(0xFF111827),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  color: Color(0xFF6B7280),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  letterSpacing: 0.8
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
