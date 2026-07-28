import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'action_card.dart';
import 'animated_orb.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class ChatHeader extends ConsumerWidget {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    String userName = 'Guest';
    if (authState is AuthAuthenticated) {
      userName = authState.user.name;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top safe area + heading
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 0), // Increased top padding to avoid app bar
            child: Text(
              'Hi, $userName.',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 28,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Cards — two equal cards filling width side by side
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildCard(
                    title: 'REVIEW CASH POSITION',
                    subtitle: 'SEE INFLOWS, OUTFLOWS AND\nRUNWAY',
                    chart: const _LineChart(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCard(
                    title: 'MANAGE OUTGOING PAYMENTS',
                    subtitle: 'VENDORS, CONTRACTORS,\nSUBSCRIPTIONS',
                    chart: const _BarChart(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required Widget chart,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
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
              fontSize: 9,
              letterSpacing: 0.4,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 5),
          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'DMMono',
              fontSize: 9,
              color: Color(0xFF94A3B8),
              height: 1.4,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          // Chart area
          SizedBox(
            height: 90,
            child: chart,
          ),
          const SizedBox(height: 10),
          // Arrow bottom-right
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 13,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Line chart matching reference: multi-peak wavy line, single dot at highest peak
class _LineChart extends StatelessWidget {
  const _LineChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 90),
      painter: _LineChartPainter(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Multiple overlapping wave lines like the reference
    _drawWave(canvas, w, h, [
      Offset(0, h * 0.75),
      Offset(w * 0.15, h * 0.55),
      Offset(w * 0.28, h * 0.68),
      Offset(w * 0.45, h * 0.42),
      Offset(w * 0.62, h * 0.58),
      Offset(w * 0.75, h * 0.28),
      Offset(w * 0.88, h * 0.48),
      Offset(w, h * 0.40),
    ], const Color(0xFF93C5FD), 1.5);

    _drawWave(canvas, w, h, [
      Offset(0, h * 0.85),
      Offset(w * 0.18, h * 0.70),
      Offset(w * 0.35, h * 0.78),
      Offset(w * 0.52, h * 0.55),
      Offset(w * 0.68, h * 0.70),
      Offset(w * 0.82, h * 0.45),
      Offset(w, h * 0.55),
    ], const Color(0xFFBFDBFE), 1.0);

    _drawWave(canvas, w, h, [
      Offset(0, h * 0.90),
      Offset(w * 0.20, h * 0.82),
      Offset(w * 0.38, h * 0.88),
      Offset(w * 0.55, h * 0.68),
      Offset(w * 0.72, h * 0.82),
      Offset(w * 0.88, h * 0.60),
      Offset(w, h * 0.70),
    ], const Color(0xFFDBEAFE), 1.0);

    // Peak dot on the highest point
    final dotPaint = Paint()
      ..color = const Color(0xFF60A5FA)
      ..style = PaintingStyle.fill;
    final dotOutline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const peakX = 0.75;
    const peakY = 0.28;
    canvas.drawCircle(Offset(w * peakX, h * peakY), 4, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * peakX, h * peakY), 3, dotPaint);
  }

  void _drawWave(Canvas canvas, double w, double h, List<Offset> pts, Color color, double strokeWidth) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(pts[0].dx, pts[0].dy);

    for (int i = 0; i < pts.length - 1; i++) {
      final cp1x = (pts[i].dx + pts[i + 1].dx) / 2;
      final cp1y = pts[i].dy;
      final cp2x = (pts[i].dx + pts[i + 1].dx) / 2;
      final cp2y = pts[i + 1].dy;
      path.cubicTo(cp1x, cp1y, cp2x, cp2y, pts[i + 1].dx, pts[i + 1].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Bar chart matching reference: hatched/striped tall bars with varied heights
class _BarChart extends StatelessWidget {
  const _BarChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 90),
      painter: _BarChartPainter(),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bar heights as fraction of available height (from reference: tall, medium, very tall, medium)
    final fractions = [0.7, 0.45, 0.9, 0.55, 0.35];
    final barCount = fractions.length;
    const barSpacing = 8.0;
    final totalSpacing = barSpacing * (barCount - 1);
    final barWidth = (w - totalSpacing) / barCount;

    for (int i = 0; i < barCount; i++) {
      final barH = h * fractions[i];
      final x = i * (barWidth + barSpacing);
      final y = h - barH;

      final rect = Rect.fromLTWH(x, y, barWidth, barH);

      // Background fill
      final bgPaint = Paint()..color = const Color(0xFFF0F4FF);
      canvas.drawRRect(
        RRect.fromRectAndCorners(rect,
            topLeft: const Radius.circular(4), topRight: const Radius.circular(4)),
        bgPaint,
      );

      // Hatch lines (diagonal stripes)
      canvas.save();
      canvas.clipRRect(RRect.fromRectAndCorners(rect,
          topLeft: const Radius.circular(4), topRight: const Radius.circular(4)));
      final hatchPaint = Paint()
        ..color = const Color(0xFFBFCFEE)
        ..strokeWidth = 1.0;
      const spacing = 5.0;
      for (double s = -barH; s < barWidth + barH; s += spacing) {
        canvas.drawLine(
          Offset(x + s, y),
          Offset(x + s + barH, y + barH),
          hatchPaint,
        );
      }
      canvas.restore();

      // Border
      final borderPaint = Paint()
        ..color = const Color(0xFFBFCFEE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawRRect(
        RRect.fromRectAndCorners(rect,
            topLeft: const Radius.circular(4), topRight: const Radius.circular(4)),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
