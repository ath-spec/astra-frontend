import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

// ─────────────────────────────────────────────────────────────────────────────
// BorderBeam — Pulse Outside Effect
//
// Visual model (Sleek Continuous Aura):
//   • 3 Layers: Outer Bloom (very blurred), Core Glow (moderately blurred), 
//     and a crisp Stroke.
//   • A SweepGradient that transitions through a colorful palette.
//   • The SweepGradient hues rotate continuously (14s cycle).
//   • The opacity of all layers pulses (breathes) simultaneously over a ~3.7s cycle.
//   • The auras are drawn *behind* the widget to bloom outward, requiring 
//     the child to be opaque to hide the inner bleed.
// ─────────────────────────────────────────────────────────────────────────────

class BorderBeam extends StatefulWidget {
  final Widget child;
  final double duration;
  final double borderWidth;
  final Color staticBorderColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const BorderBeam({
    Key? key,
    required this.child,
    this.duration = 3.7, // ~3.7s is the dark-theme pulse cycle in Magic UI
    this.borderWidth = 1.5,
    this.staticBorderColor = Colors.transparent, 
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  _BorderBeamState createState() => _BorderBeamState();
}

class _BorderBeamState extends State<BorderBeam> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _hueController;

  @override
  void initState() {
    super.initState();
    // Opacity pulse (breathing effect)
    _pulseController = AnimationController(
      duration: Duration(milliseconds: (widget.duration * 1000).toInt()),
      vsync: this,
    )..repeat(reverse: true);

    // Continuous 360-degree hue rotation (slow lively wash)
    _hueController = AnimationController(
      duration: const Duration(seconds: 14),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _hueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _hueController]),
      builder: (_, child) {
        return CustomPaint(
          // Drawn *behind* the child so the inner glow is hidden by the opaque child
          painter: _BorderBeamPainter(
            pulseProgress: _pulseController.value,
            hueProgress: _hueController.value,
            borderWidth: widget.borderWidth,
            staticBorderColor: widget.staticBorderColor,
            borderRadius: widget.borderRadius,
          ),
          child: RepaintBoundary(
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        );
      },
    );
  }
}

class _BorderBeamPainter extends CustomPainter {
  final double pulseProgress; // 0.0 to 1.0 (sine wave)
  final double hueProgress;   // 0.0 to 1.0 (linear rotation)
  final double borderWidth;
  final Color staticBorderColor;
  final BorderRadius borderRadius;

  _BorderBeamPainter({
    required this.pulseProgress,
    required this.hueProgress,
    required this.borderWidth,
    required this.staticBorderColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = borderRadius.toRRect(rect);

    if (staticBorderColor != Colors.transparent) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = staticBorderColor,
      );
    }

    // The colorful palette (Pink -> Purple -> Blue -> Green -> Orange -> Pink)
    const baseColors = [
      Color(0xFFFF3264), // Pink
      Color(0xFFB428F0), // Purple
      Color(0xFF288CFF), // Blue
      Color(0xFF32C850), // Green
      Color(0xFFFF7828), // Orange
      Color(0xFFFF3264), // Pink (wrap for seamless gradient)
    ];

    // Shift hues continuously
    final hueShift = hueProgress * 360.0;
    
    // Smooth ease-in-out breathing. 
    // The controller is using `repeat(reverse: true)`, so pulseProgress linearly ping-pongs 0 to 1.
    // We apply a sine curve to make the turnaround smooth.
    final t = (math.sin((pulseProgress - 0.5) * math.pi) + 1) / 2.0;
    
    // Opacity pulses between roughly 40% and 100% intensity.
    final double masterOpacity = 0.4 + (0.6 * t);

    // Apply hue rotation
    final colors = baseColors.map((c) {
      final hsv = HSVColor.fromColor(c);
      return hsv.withHue((hsv.hue + hueShift) % 360).toColor();
    }).toList();
    
    const stops = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
    final transform = GradientRotation(hueProgress * 2 * math.pi);

    // 1. Bloom Layer (Highly blurred, spills far outside)
    final bloomColors = colors.map((c) => c.withOpacity(0.35 * masterOpacity)).toList();
    final bloomPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 4.0 // Thicker to create a wide halo
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22.5)
      ..shader = SweepGradient(
        colors: bloomColors,
        stops: stops,
        transform: transform,
      ).createShader(rect);

    canvas.drawRRect(rrect, bloomPaint);

    // 2. Core Glow Layer (Moderately blurred)
    final coreColors = colors.map((c) => c.withOpacity(0.7 * masterOpacity)).toList();
    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0)
      ..shader = SweepGradient(
        colors: coreColors,
        stops: stops,
        transform: transform,
      ).createShader(rect);
    
    canvas.drawRRect(rrect, corePaint);

    // 3. Crisp Stroke Layer
    final strokeColors = colors.map((c) => c.withOpacity(1.0 * masterOpacity)).toList();
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = SweepGradient(
        colors: strokeColors,
        stops: stops,
        transform: transform,
      ).createShader(rect);

    canvas.drawRRect(rrect, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _BorderBeamPainter old) {
    return old.pulseProgress != pulseProgress || old.hueProgress != hueProgress;
  }
}

