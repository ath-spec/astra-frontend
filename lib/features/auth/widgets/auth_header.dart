import 'package:flutter/material.dart';

/// Header widget displaying financial growth illustration, title, and pagination indicators.
/// Replaces generic login header with Dezerv-inspired ASTRA onboarding visuals.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Growth Chart Illustration Box
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF13161F),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Stack(
            children: [
              // Subtle background grid / lines
              Positioned.fill(
                child: CustomPaint(
                  painter: _GrowthChartPainter(),
                ),
              ),
              // Floating badge ₹56L
              Positioned(
                left: 28,
                bottom: 38,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B281D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEAB308).withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    '₹56L',
                    style: TextStyle(
                      color: Color(0xFFFDE047),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // Headline
        const Text(
          'Build your path to financial freedom',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Pagination Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    // Draw vertical grid lines
    for (int i = 1; i <= 4; i++) {
      final x = size.width * (i / 5);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    // Draw smooth curve from bottom left to top right
    final curvePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFFEAB308), Color(0xFFFDE047)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final startPoint = Offset(28, size.height - 40);
    final endPoint = Offset(size.width - 28, 24);

    path.moveTo(startPoint.dx, startPoint.dy);
    path.cubicTo(
      size.width * 0.4,
      size.height - 35,
      size.width * 0.7,
      size.height * 0.5,
      endPoint.dx,
      endPoint.dy,
    );

    canvas.drawPath(path, curvePaint);

    // Draw start dot
    final startDotPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startPoint, 4, startDotPaint);

    // Draw glowing end dot
    final endGlowPaint = Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(endPoint, 10, endGlowPaint);

    final endDotPaint = Paint()
      ..color = const Color(0xFFFDE047)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(endPoint, 4, endDotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
