import 'package:flutter/material.dart';
import 'dart:math' as math;

class RotatingShimmerBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final BorderRadius borderRadius;
  final Color innerColor;

  const RotatingShimmerBorder({
    super.key,
    required this.child,
    this.borderWidth = 1.5,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.innerColor = const Color(0xFFF8FAFC),
  });

  @override
  State<RotatingShimmerBorder> createState() => _RotatingShimmerBorderState();
}

class _RotatingShimmerBorderState extends State<RotatingShimmerBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(widget.borderWidth),
            decoration: BoxDecoration(
              gradient: SweepGradient(
                colors: const [
                  Color(0xFFE2E8F0),
                  Color(0xFFE2E8F0),
                  Color(0xFF94A3B8), // Shimmer color
                  Color(0xFFE2E8F0),
                  Color(0xFFE2E8F0),
                ],
                stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
                transform: GradientRotation(_controller.value * 2 * math.pi),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: widget.innerColor,
                borderRadius: BorderRadius.circular(
                  (widget.borderRadius.topLeft.x - widget.borderWidth).clamp(0.0, double.infinity),
                ),
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
