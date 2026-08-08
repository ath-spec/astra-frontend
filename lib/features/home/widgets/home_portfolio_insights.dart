import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePortfolioInsights extends StatelessWidget {
  final bool isLocked;
  const HomePortfolioInsights({super.key, this.isLocked = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Insights for your portfolio',
                style: TextStyle(
                  fontFamily: 'DMSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -1.0,
                  color: Color(0xFF0F172A),

                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Key signals from your portfolio',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
        SizedBox(
          height: 180,
          child: ListView(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 24.0, right: 24.0),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildInsightCard(
                context: context,
                index: 0,
                title: 'Tax harvesting:\nlock in ₹1.25L tax-\nfree',
                buttonText: 'KNOW MORE',
                painter: TaxHarvestingPainter(isLocked: isLocked),
                cardWidth: 280,
              ),
              const SizedBox(width: 16),
              _buildInsightCard(
                context: context,
                index: 1,
                title: 'Steady your\ngrowth with index\nfunds',
                buttonText: 'KNOW MORE',
                painter: IndexFundsPainter(isLocked: isLocked),
                cardWidth: 280,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required BuildContext context,
    required int index,
    required String title,
    required String buttonText,
    required CustomPainter painter,
    required double cardWidth,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/insights?initial=$index');
      },
      child: Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background graphic
          Positioned(
            right: 16,
            bottom: 16,
            top: 16,
            width: 120,
            child: CustomPaint(
              painter: painter,
              size: const Size(120, 150),
            ),
          ),
          
          // Foreground Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 140, // Limit width so text doesn't overlap graphic too much
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF27272A), Color(0xFF09090B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}

class TaxHarvestingPainter extends CustomPainter {
  final bool isLocked;
  TaxHarvestingPainter({this.isLocked = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Faint grid background in bottom area
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    for (double i = 0; i < w; i += 10) {
      canvas.drawLine(Offset(i, h * 0.7), Offset(i, h), gridPaint);
    }
    for (double j = h * 0.7; j < h; j += 10) {
      canvas.drawLine(Offset(0, j), Offset(w, j), gridPaint);
    }

    // Isometric Block Points
    // Left front face (Dark Teal)
    final leftFace = Path()
      ..moveTo(20, h - 30)
      ..lineTo(40, h - 20)
      ..lineTo(40, h - 60)
      ..lineTo(20, h - 70)
      ..close();

    // Right front face (Light Blue gradient)
    final rightFace = Path()
      ..moveTo(40, h - 20)
      ..lineTo(110, h - 45)
      ..lineTo(110, h - 85)
      ..lineTo(40, h - 60)
      ..close();

    // Top face (Very Light Blue)
    final topFace = Path()
      ..moveTo(20, h - 70)
      ..lineTo(40, h - 60)
      ..lineTo(110, h - 85)
      ..lineTo(90, h - 95)
      ..close();

    canvas.drawPath(leftFace, Paint()..color = const Color(0xFF38B2AC)); // Teal 400
    
    final gradientPaint = Paint();
    if (isLocked) {
      gradientPaint.color = const Color(0xFF81E6D9);
    } else {
      gradientPaint.shader = const LinearGradient(
        colors: [Color(0xFF81E6D9), Color(0xFFE6FFFA)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTRB(40, h-85, 110, h-20));
    }
    canvas.drawPath(rightFace, gradientPaint);
    
    canvas.drawPath(topFace, Paint()..color = const Color(0xFFE6FFFA)); // Teal 50

    // Stroke outlines
    final strokePaint = Paint()
      ..color = const Color(0xFF319795)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawPath(leftFace, strokePaint);
    canvas.drawPath(rightFace, strokePaint);
    canvas.drawPath(topFace, strokePaint);

    // Label Speech Bubble "HARVESTABLE"
    final labelBg = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final labelStroke = Paint()
      ..color = const Color(0xFF319795)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw connecting line
    canvas.drawLine(Offset(50, h - 55), Offset(50, 45), labelStroke);

    // Bubble Path
    final bubble = Path()
      ..moveTo(30, 45)
      ..lineTo(95, 25)
      ..lineTo(95, 45)
      ..lineTo(30, 65)
      ..close();
    
    canvas.drawPath(bubble, labelBg);
    canvas.drawPath(bubble, labelStroke);

    // Text in bubble
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'HARVESTABLE',
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: Color(0xFF319795),
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Rotate canvas to draw isometric text
    canvas.save();
    canvas.translate(35, 52);
    canvas.rotate(-0.3); // slight upward tilt
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IndexFundsPainter extends CustomPainter {
  final bool isLocked;
  IndexFundsPainter({this.isLocked = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Faint grid background in bottom area
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    for (double i = 0; i < w; i += 10) {
      canvas.drawLine(Offset(i, h * 0.7), Offset(i, h), gridPaint);
    }
    for (double j = h * 0.7; j < h; j += 10) {
      canvas.drawLine(Offset(0, j), Offset(w, j), gridPaint);
    }

    // Isometric Block Points (Tall Purple)
    final leftFace = Path()
      ..moveTo(60, h - 20)
      ..lineTo(90, h - 10)
      ..lineTo(90, h - 70)
      ..lineTo(60, h - 80)
      ..close();

    final rightFace = Path()
      ..moveTo(90, h - 10)
      ..lineTo(110, h - 20)
      ..lineTo(110, h - 80)
      ..lineTo(90, h - 70)
      ..close();

    final topFace = Path()
      ..moveTo(60, h - 80)
      ..lineTo(90, h - 70)
      ..lineTo(110, h - 80)
      ..lineTo(80, h - 90)
      ..close();

    // Base glowing rim
    final baseRim = Path()
      ..moveTo(60, h - 15)
      ..lineTo(90, h - 5)
      ..lineTo(110, h - 15)
      ..lineTo(110, h - 20)
      ..lineTo(90, h - 10)
      ..lineTo(60, h - 20)
      ..close();

    canvas.drawPath(leftFace, Paint()..color = const Color(0xFFE9D8FD)); // Purple 200
    canvas.drawPath(rightFace, Paint()..color = const Color(0xFFFAF5FF)); // Purple 50
    canvas.drawPath(topFace, Paint()..color = Colors.white);
    canvas.drawPath(baseRim, Paint()..color = const Color(0xFF805AD5)); // Purple 500

    final strokePaint = Paint()
      ..color = const Color(0xFFB794F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    canvas.drawPath(leftFace, strokePaint);
    canvas.drawPath(rightFace, strokePaint);
    canvas.drawPath(topFace, strokePaint);

    // "YOUR TARGET" Projection Dotted box
    final dotPaint = Paint()
      ..color = const Color(0xFF9F7AEA) // Purple 400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw dotted lines for projection
    _drawDottedLine(canvas, Offset(50, 40), Offset(80, 50), dotPaint);
    _drawDottedLine(canvas, Offset(80, 50), Offset(80, h - 70), dotPaint);
    _drawDottedLine(canvas, Offset(50, 40), Offset(50, h - 80), dotPaint);
    _drawDottedLine(canvas, Offset(50, h - 80), Offset(80, h - 70), dotPaint);

    // "CURRENT" label pointing to base
    final labelBg = Paint()..color = Colors.white;
    final labelStroke = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final currentBubble = Path()
      ..moveTo(10, h - 35)
      ..lineTo(60, h - 20)
      ..lineTo(60, h - 30)
      ..lineTo(10, h - 45)
      ..close();
    
    canvas.drawPath(currentBubble, labelBg);
    canvas.drawPath(currentBubble, labelStroke);
    canvas.drawLine(Offset(60, h - 25), Offset(75, h - 15), labelStroke); // pointer line

    // Text in CURRENT bubble
    final textPainterCurrent = TextPainter(
      text: const TextSpan(
        text: 'CURRENT',
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 7,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterCurrent.layout();
    canvas.save();
    canvas.translate(18, h - 38);
    canvas.rotate(0.28);
    textPainterCurrent.paint(canvas, Offset.zero);
    canvas.restore();

    // Text for "YOUR TARGET 20.0%-30.0%"
    final textPainterTarget = TextPainter(
      text: const TextSpan(
        text: 'YOUR\nTARGET\n',
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
          height: 1.1,
        ),
        children: [
          TextSpan(
            text: '20.0%-30.0%',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Color(0xFF805AD5),
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainterTarget.layout();
    canvas.save();
    canvas.translate(35, 45);
    canvas.rotate(0.3);
    textPainterTarget.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path()..moveTo(start.dx, start.dy)..lineTo(end.dx, end.dy);
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double extractPathLength = 0.0;
      while (extractPathLength < metric.length) {
        final currentPath = metric.extractPath(extractPathLength, extractPathLength + 3);
        canvas.drawPath(currentPath, paint);
        extractPathLength += 6; // Dash + gap
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
