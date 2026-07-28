import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedOrb extends StatefulWidget {
  const AnimatedOrb({super.key});

  @override
  State<AnimatedOrb> createState() => _AnimatedOrbState();
}

class _AnimatedOrbState extends State<AnimatedOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = math.sin(_controller.value * math.pi);
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer soft shadow on the ground
              Positioned(
                bottom: 0,
                child: Container(
                  width: 140,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(70),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB8C5E8).withValues(alpha: 0.5 + pulse * 0.1),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              // Icy outer translucent shell — irregular blob
              Transform.scale(
                scale: 1.0 + pulse * 0.02,
                child: CustomPaint(
                  size: const Size(180, 180),
                  painter: _OrbShellPainter(pulse: pulse),
                ),
              ),

              // Warm amber/orange inner core glow
              Container(
                width: 60 + pulse * 4,
                height: 60 + pulse * 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white,
                      const Color(0xFFFFD580), // amber/gold
                      const Color(0xFFFF8C42), // warm orange
                      const Color(0xFFFF8C42).withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),

              // Blue pixelated dot cluster overlay (the mosaic texture in image)
              CustomPaint(
                size: const Size(90, 90),
                painter: _DotClusterPainter(pulse: pulse),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrbShellPainter extends CustomPainter {
  final double pulse;
  const _OrbShellPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    // Outer diffuse glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFD6E4F7).withValues(alpha: 0.6),
          const Color(0xFFB8CCE8).withValues(alpha: 0.3),
          Colors.transparent,
        ],
        stops: const [0.4, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 1.3));
    canvas.drawCircle(Offset(cx, cy), r * 1.3, glowPaint);

    // Main translucent shell
    final shellPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [
          Colors.white.withValues(alpha: 0.85),
          const Color(0xFFCDDDF5).withValues(alpha: 0.5),
          const Color(0xFFB0C8E8).withValues(alpha: 0.2),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    // Slightly irregular blob path
    final path = Path();
    path.addOval(Rect.fromCenter(
      center: Offset(cx, cy),
      width: r * 2,
      height: r * 1.92,
    ));
    canvas.drawPath(path, shellPaint);

    // Bright specular highlight top-left
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.9),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(cx - r * 0.35, cy - r * 0.38), radius: r * 0.28));
    canvas.drawCircle(
        Offset(cx - r * 0.35, cy - r * 0.38), r * 0.28, highlightPaint);
  }

  @override
  bool shouldRepaint(_OrbShellPainter old) => old.pulse != pulse;
}

class _DotClusterPainter extends CustomPainter {
  final double pulse;
  const _DotClusterPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF6B8FCF).withValues(alpha: 0.5);
    const dotSize = 4.0;
    const cols = 8;
    const rows = 8;
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.4;

    for (int c = 0; c < cols; c++) {
      for (int row = 0; row < rows; row++) {
        final x = c * cellW + cellW / 2;
        final y = row * cellH + cellH / 2;
        final dist = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
        if (dist < r) {
          canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_DotClusterPainter old) => false;
}
