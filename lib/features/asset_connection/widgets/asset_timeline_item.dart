import 'package:flutter/material.dart';

/// Timeline step item for asset connection screen.
/// Displays animated loading ring when linking, checkmark when completed, and connecting vertical line.
class AssetTimelineItem extends StatelessWidget {
  const AssetTimelineItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isLinking = false,
    this.isCompleted = false,
    this.isLast = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isLinking;
  final bool isCompleted;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF0D9488); // Teal
    final Color circleBg = isCompleted || isLinking
        ? activeColor.withValues(alpha: 0.15)
        : const Color(0xFF161922);
    final Color iconColor = isCompleted || isLinking ? activeColor : Colors.white38;
    final Color subtitleColor = isLinking ? Colors.white70 : Colors.white38;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circle Icon with optional loading ring & vertical connecting line
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: circleBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? activeColor
                            : Colors.white.withValues(alpha: 0.08),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle_rounded : icon,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  if (isLinking)
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                        strokeWidth: 2.5,
                      ),
                    ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.0,
                    color: isCompleted
                        ? activeColor
                        : Colors.white.withValues(alpha: 0.12),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 18),
          // Title & Subtitle text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isCompleted || isLinking ? Colors.white : Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 14,
                      fontWeight: isLinking ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
