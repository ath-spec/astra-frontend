import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class BorderBeam extends StatefulWidget {
  final Widget child;
  final double duration;
  final double borderWidth;
  final List<Color> colors;
  final Color staticBorderColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const BorderBeam({
    Key? key,
    required this.child,
    this.duration = 15,
    this.borderWidth = 1.5,
    this.colors = const [
      Color(0xFF5BA1F7),
      Color(0xFF8B5CF6),
      Color(0xFFFFAA40),
    ],
    this.staticBorderColor = const Color(0xFFCCCCCC),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  _BorderBeamState createState() => _BorderBeamState();
}

class _BorderBeamState extends State<BorderBeam>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (widget.duration * 1000).toInt()),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: BorderBeamPainter(
            progress: _animation.value,
            borderWidth: widget.borderWidth,
            colors: widget.colors,
            staticBorderColor: widget.staticBorderColor,
            borderRadius: widget.borderRadius,
          ),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class BorderBeamPainter extends CustomPainter {
  final double progress;
  final double borderWidth;
  final List<Color> colors;
  final Color staticBorderColor;
  final BorderRadius borderRadius;

  BorderBeamPainter({
    required this.progress,
    required this.borderWidth,
    required this.colors,
    required this.staticBorderColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = borderRadius.toRRect(rect);

    // Draw static border if visible
    if (staticBorderColor != Colors.transparent) {
      final staticPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = staticBorderColor;
      canvas.drawRRect(rrect, staticPaint);
    }

    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics().first;
    final pathLength = pathMetrics.length;

    // 8 Pulses exactly as requested: 4 corners + 4 flat sides
    for (int i = 0; i < 8; i++) {
      // 1. Phase Offset (Staggered starts)
      // Space them out in time so it looks organic
      final double phaseOffset = (i * 0.37) % 1.0; 
      
      // Calculate local progress for this specific pulse (0.0 to 1.0)
      final double localProgress = (progress + phaseOffset) % 1.0;
      
      // Origin on the perimeter (evenly spaced 0/8, 1/8 ...)
      final double originNormalized = i / 8.0;
      final double originDistance = originNormalized * pathLength;
      
      // Travel distance
      // Each pulse travels up to ~15% of the perimeter
      final double maxTravel = pathLength * (0.10 + ((i % 3) * 0.03)); 
      final double currentTravel = maxTravel * localProgress;
      
      // Opacity / Fade
      // Spawns instantly (0 to 0.05), holds briefly, then fades out slowly
      double opacity = 1.0;
      if (localProgress < 0.05) {
        opacity = localProgress / 0.05;
      } else {
        opacity = 1.0 - ((localProgress - 0.05) / 0.95);
      }
      
      // Color: Prism effect. 
      // Base hue rotates globally with `progress`. Offset it by `i` so they differ.
      final double hue = ((progress * 360 * 2) + (i * 45)) % 360;
      final Color pulseColor = HSVColor.fromAHSV(opacity, hue, 1.0, 1.0).toColor();
      
      // Beam head fixed length
      final double beamLength = 16.0;
      
      // Head 1 (Clockwise)
      double h1Center = originDistance + currentTravel;
      _drawComet(canvas, pathMetrics, pathLength, h1Center, beamLength, pulseColor);
      
      // Head 2 (Counter-Clockwise)
      double h2Center = originDistance - currentTravel;
      _drawComet(canvas, pathMetrics, pathLength, h2Center, beamLength, pulseColor);
    }
  }

  void _drawComet(Canvas canvas, ui.PathMetric pathMetrics, double pathLength, double center, double length, Color color) {
    double start = (center - length / 2) % pathLength;
    if (start < 0) start += pathLength;
    
    double end = (center + length / 2) % pathLength;
    if (end < 0) end += pathLength;
    
    Path segment = Path();
    if (start < end) {
      segment.addPath(pathMetrics.extractPath(start, end), Offset.zero);
    } else {
      // Wrapped around 0
      segment.addPath(pathMetrics.extractPath(start, pathLength), Offset.zero);
      segment.addPath(pathMetrics.extractPath(0, end), Offset.zero);
    }
    
    // Outer Glow
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 3.0
      ..strokeCap = StrokeCap.round
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      
    // Inner Solid Core
    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(color.opacity); 
      
    canvas.drawPath(segment, glowPaint);
    canvas.drawPath(segment, corePaint);
  }

  @override
  bool shouldRepaint(covariant BorderBeamPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
