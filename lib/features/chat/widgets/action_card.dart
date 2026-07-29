import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget chartGraphic;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.chartGraphic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'DMMono',
                fontSize: 10,
                letterSpacing: 0.3,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            // Subtitle
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'DMMono',
                fontSize: 10,
                color: Color(0xFF94A3B8),
                height: 1.4,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 12),
            // Chart area — takes up remaining space
            Expanded(
              child: Visibility(
                visible: false,
                child: ClipRect(child: chartGraphic),
              ),
            ),
            const SizedBox(height: 10),
            // Arrow button bottom-right
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
