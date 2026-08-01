import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

bool hasSeenAnalysisWalkthrough = false;

class HomePortfolioAnalysis extends StatelessWidget {
  const HomePortfolioAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
          'Your Portfolio Analysis',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: Color(0xFF0F172A),
          ),
        ),
              const SizedBox(height: 4),
              const Text(
                'See your portfolio through a new lens',
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
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildAnalysisCard(
                      title: 'Discipline',
                      icon: Icons.track_changes,
                      color: const Color(0xFF4299E1), // Blue
                      brailleDots: '⠓⠕⠗⠍',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildAnalysisCard(
                      title: 'Allocation',
                      icon: Icons.layers_outlined,
                      color: const Color(0xFF9F7AEA), // Purple
                      brailleDots: '⠓⠕⠗⠍',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildAnalysisCard(
                      title: 'Performance',
                      icon: Icons.change_history,
                      color: const Color(0xFF48BB78), // Green
                      brailleDots: '⠓⠕⠗⠍',
                    ),
                  ),
                ],
              ),
            ),
            
            // "REVEAL ANALYSIS" glowing pill
            Positioned(
              bottom: 10,
              child: GestureDetector(
                onTap: () {
                  if (!hasSeenAnalysisWalkthrough) {
                    context.push('/analysis-walkthrough');
                  } else {
                    context.push('/portfolio-analysis');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF27272A), Color(0xFF09090B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF48BB78).withOpacity(0.3), // Glow effect
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                ),
                child: const Text(
                  'REVEAL ANALYSIS',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisCard({
    required String title,
    required IconData icon,
    required Color color,
    required String brailleDots,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 32, bottom: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Semi-circle gauge
          SizedBox(
            width: 70,
            height: 40,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CustomPaint(
                  size: const Size(70, 40),
                  painter: SemiCircleGaugePainter(color: color),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(icon, size: 16, color: const Color(0xFF475569)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            brailleDots,
            style: TextStyle(
              fontSize: 20,
              color: color,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

class SemiCircleGaugePainter extends CustomPainter {
  final Color color;

  SemiCircleGaugePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    
    // Background track (light grey)
    final trackPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // Draw background arc
    canvas.drawArc(
      rect,
      math.pi, // start from 180 degrees (left)
      math.pi, // sweep 180 degrees (to right)
      false,
      trackPaint,
    );

    // Foreground track (colored)
    final gradient = SweepGradient(
      colors: [color.withOpacity(0.3), color],
      stops: const [0.0, 1.0],
      startAngle: math.pi,
      endAngle: math.pi * 2,
    );

    final foregroundPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      math.pi,
      math.pi * 0.7, 
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
