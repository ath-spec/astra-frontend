import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A widget that applies a progressive blur to the backdrop, fading out seamlessly.
/// Useful for creating a frosted glass effect that doesn't have a harsh bottom edge.
class ProgressiveBlur extends StatelessWidget {
  final double maxBlur;
  final int steps;

  const ProgressiveBlur({
    super.key,
    this.maxBlur = 12.0,
    this.steps = 6,
  });

  @override
  Widget build(BuildContext context) {
    // Emil Design: Hardware accelerated CSS mask-image equivalent in Flutter.
    // Instead of stacking 6 BackdropFilters (which destroys scroll performance),
    // we use a single BackdropFilter and mask its output with a linear gradient.
    // This achieves the exact same fading progressive blur at a fraction of the GPU cost.
    if (kIsWeb) return const SizedBox.shrink();
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0.0, 0.6, 1.0], // Fade out the bottom 40% seamlessly
        ).createShader(bounds);
      },
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: maxBlur, sigmaY: maxBlur),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
