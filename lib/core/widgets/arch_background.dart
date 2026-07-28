import 'package:flutter/material.dart';

/// Reusable subtle 3D white architectural arch graphic displayed at the top
/// of clean light mode screens (e.g. Banks linking, Fetching, and Home dashboard).
class ArchBackground extends StatelessWidget {
  final double height;

  const ArchBackground({
    super.key,
    this.height = 420.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -20,
      left: 0,
      right: 0,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: IgnorePointer(
              child: Container(
                height: height,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(220)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF1F5F9).withValues(alpha: 0.8),
                const Color(0xFFFFFFFF).withValues(alpha: 0.0),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 40,
                spreadRadius: 10,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.9),
                blurRadius: 2,
                spreadRadius: -2,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(180)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFFFFF),
                    const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                  width: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
      ),
      ),
      ),
    );
  }
}
