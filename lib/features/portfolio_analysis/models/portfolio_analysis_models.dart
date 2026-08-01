import 'package:flutter/material.dart';

enum DisciplineLevel {
  poor,
  moderate,
  good,
  excellent;

  String get label {
    switch (this) {
      case DisciplineLevel.poor:
        return 'Poor';
      case DisciplineLevel.moderate:
        return 'Moderate';
      case DisciplineLevel.good:
        return 'Good';
      case DisciplineLevel.excellent:
        return 'Excellent';
    }
  }

  Color get color {
    switch (this) {
      case DisciplineLevel.poor:
        return const Color(0xFFE53E3E); // Red
      case DisciplineLevel.moderate:
        return const Color(0xFF3B82F6); // Blue
      case DisciplineLevel.good:
        return const Color(0xFF38A169); // Green
      case DisciplineLevel.excellent:
        return const Color(0xFF22543D); // Dark Green
    }
  }

  double get score {
    switch (this) {
      case DisciplineLevel.poor:
        return 0.3;
      case DisciplineLevel.moderate:
        return 0.7; // From our hardcoded 0.7
      case DisciplineLevel.good:
        return 0.85;
      case DisciplineLevel.excellent:
        return 1.0;
    }
  }
}

enum AllocationLevel {
  conservative,
  moderateConservative,
  balanced,
  aggressive,
  veryAggressive;

  String get label {
    switch (this) {
      case AllocationLevel.conservative:
        return 'Conservative';
      case AllocationLevel.moderateConservative:
        return 'Moderate Cons.';
      case AllocationLevel.balanced:
        return 'Balanced';
      case AllocationLevel.aggressive:
        return 'Aggressive';
      case AllocationLevel.veryAggressive:
        return 'Very Aggressive';
    }
  }

  int get activeSegments => index + 1; // 1 to 5

  Color get activeColor {
    switch (this) {
      case AllocationLevel.conservative:
        return const Color(0xFF38A169);
      case AllocationLevel.moderateConservative:
        return const Color(0xFF48BB78);
      case AllocationLevel.balanced:
        return const Color(0xFF3B82F6);
      case AllocationLevel.aggressive:
        return const Color(0xFFED8936);
      case AllocationLevel.veryAggressive:
        return const Color(0xFF6B46C1);
    }
  }
}

enum PerformanceLevel {
  veryWeak,
  weak,
  average,
  strong,
  veryStrong;

  String get label {
    switch (this) {
      case PerformanceLevel.veryWeak:
        return 'Very Weak';
      case PerformanceLevel.weak:
        return 'Weak';
      case PerformanceLevel.average:
        return 'Average';
      case PerformanceLevel.strong:
        return 'Strong';
      case PerformanceLevel.veryStrong:
        return 'Very Strong';
    }
  }

  int get activeSegments => index + 1; // 1 to 5

  Color get activeColor {
    switch (this) {
      case PerformanceLevel.veryWeak:
        return const Color(0xFFE53E3E); // Red
      case PerformanceLevel.weak:
        return const Color(0xFFED8936); // Orange
      case PerformanceLevel.average:
        return const Color(0xFFECC94B); // Yellow
      case PerformanceLevel.strong:
        return const Color(0xFF4ADE80); // Light Green
      case PerformanceLevel.veryStrong:
        return const Color(0xFF16A34A); // Dark Green
    }
  }
}
