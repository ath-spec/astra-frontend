import 'dart:ui';
import 'package:flutter/material.dart';

class GemButton extends StatelessWidget {
  final VoidCallback onTap;
  const GemButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double scale = (MediaQuery.sizeOf(context).height / 800).clamp(1.0, 1.15);
    final double size = 48 * scale;
    final double iconSize = 24 * scale;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFF5BA1F7),
              Color(0xFF031E6B),
              Color(0xFF241714),
            ],
            stops: [0.0, 0.25, 0.7, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}

class HomeCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  const HomeCircleButton({super.key, required this.onTap});

  Widget build(BuildContext context) {
    final double scale = (MediaQuery.sizeOf(context).height / 800).clamp(1.0, 1.15);
    final double size = 48 * scale;
    final double iconSize = 24 * scale;
    final double borderRadius = 28 * scale;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: const Color(0xFFE6E6E6).withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  Icons.home_rounded,
                  color: const Color(0xFF1E293B),
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
