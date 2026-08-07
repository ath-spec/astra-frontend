import 'package:flutter/material.dart';

class SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Slide exactly one full width for a seamless loop
    final translateX = bounds.width * slidePercent;
    return Matrix4.translationValues(translateX, 0.0, 0.0);
  }
}

class AnimatedGradientShimmer extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  
  const AnimatedGradientShimmer({
    super.key, 
    required this.child, 
    this.colors = const [
      Color(0xFF0F172A), // Deep Slate/Blue (base)
      Color(0xFF5BA1F7), // Bright Azure (shine)
      Color(0xFF0F172A), // Deep Slate/Blue (seamless wrap)
    ],
  });

  @override
  State<AnimatedGradientShimmer> createState() => _AnimatedGradientShimmerState();
}

class _AnimatedGradientShimmerState extends State<AnimatedGradientShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
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
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: widget.colors.length >= 3 
                ? [widget.colors[0], widget.colors[1], widget.colors[0]] 
                : [widget.colors.first, Colors.white, widget.colors.first],
            stops: const [0.35, 0.5, 0.65],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            tileMode: TileMode.repeated,
            transform: SlidingGradientTransform(_controller.value),
          ).createShader(bounds),
          child: widget.child,
        );
      },
    );
  }
}
