import 'dart:ui';
import 'package:flutter/material.dart';

Widget buildGemButton(VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 44,
      width: 44,
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
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: 28,
      ),
    ),
  );
}

Widget buildHomeCircle(VoidCallback onTap) {
  return Container(
    height: 44,
    width: 44,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
    ),
    child: RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFE6E6E6).withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            child: const Icon(
              Icons.home_rounded,
              color: Color(0xFF1E293B),
              size: 26,
            ),
          ),
        ),
      ),
    ),
    ),
  );
}

