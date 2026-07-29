import 'package:flutter/material.dart';

class CornerFadeRevealTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const CornerFadeRevealTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (Rect bounds) {
            final double value = animation.value;
            // Sweep goes from 0.0 to 2.0 to ensure the gradient fully crosses the screen
            final double sweep = value * 2.0;

            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.black,
                Colors.black,
                Colors.transparent,
                Colors.transparent,
              ],
              stops: [
                0.0,
                (sweep - 0.5).clamp(0.0, 1.0),
                sweep.clamp(0.0, 1.0),
                1.0,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.08, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      ),
    );
  }
}
