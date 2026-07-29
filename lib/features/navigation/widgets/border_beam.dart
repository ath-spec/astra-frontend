import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class BorderBeam extends StatefulWidget {
  final Widget child;
  final double duration;
  final double borderWidth;
  final Color colorFrom;
  final Color colorTo;
  final Color staticBorderColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const BorderBeam({
    Key? key,
    required this.child,
    this.duration = 15,
    this.borderWidth = 1.5,
    this.colorFrom = const Color(0xFFFFAA40),
    this.colorTo = const Color(0xFF9C40FF),
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
            colorFrom: widget.colorFrom,
            colorTo: widget.colorTo,
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
  final Color colorFrom;
  final Color colorTo;
  final Color staticBorderColor;
  final BorderRadius borderRadius;

  BorderBeamPainter({
    required this.progress,
    required this.borderWidth,
    required this.colorFrom,
    required this.colorTo,
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

    // Make the beam cover 25% of the perimeter
    final beamLength = pathLength * 0.25;

    // Calculate tail and head positions along the path
    final tail = (progress * pathLength) % pathLength;
    final head = (tail + beamLength);

    Path extractPath;
    if (head <= pathLength) {
      extractPath = pathMetrics.extractPath(tail, head);
    } else {
      // Wrap around the end of the path
      extractPath = pathMetrics.extractPath(tail, pathLength);
      extractPath.addPath(pathMetrics.extractPath(0, head % pathLength), Offset.zero);
    }

    // Get absolute coordinates for the linear gradient
    final tailPosition = pathMetrics.getTangentForOffset(tail)?.position ?? Offset.zero;
    final headPosition = pathMetrics.getTangentForOffset(head % pathLength)?.position ?? Offset.zero;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        tailPosition,
        headPosition,
        [
          colorTo.withOpacity(0.0), // Faded tail
          colorTo,
          colorFrom,                // Bright glowing head
        ],
        [0.0, 0.4, 1.0],
      );

    // Draw the glowing aura first
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 2.0
      ..strokeCap = StrokeCap.round
      ..shader = paint.shader
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    canvas.drawPath(extractPath, glowPaint);
    
    // Draw the solid core on top
    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant BorderBeamPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
