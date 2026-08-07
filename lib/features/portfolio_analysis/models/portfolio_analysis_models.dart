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

  List<Color> get gradientColors {
    switch (this) {
      case DisciplineLevel.poor:
        return const [Color(0xFFE53E3E), Color(0xFFF56565)];
      case DisciplineLevel.moderate:
        return const [Color(0xFF3B82F6), Color(0xFF60A5FA)];
      case DisciplineLevel.good:
        return const [Color(0xFF38A169), Color(0xFF48BB78)];
      case DisciplineLevel.excellent:
        return const [Color(0xFF22543D), Color(0xFF276749)];
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

  int get activeSegments {
    switch (this) {
      case DisciplineLevel.poor:
        return 1;
      case DisciplineLevel.moderate:
        return 2;
      case DisciplineLevel.good:
        return 4;
      case DisciplineLevel.excellent:
        return 5;
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
        return 'Very Conservative';
      case AllocationLevel.moderateConservative:
        return 'Conservative';
      case AllocationLevel.balanced:
        return 'Moderate';
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
        return const Color(0xFF6B46C1); // Purple base
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case AllocationLevel.conservative:
        return const [Color(0xFF38A169), Color(0xFF68D391)];
      case AllocationLevel.moderateConservative:
        return const [Color(0xFF48BB78), Color(0xFF9AE6B4)];
      case AllocationLevel.balanced:
        return const [Color(0xFF3B82F6), Color(0xFF90CDF4)];
      case AllocationLevel.aggressive:
        return const [Color(0xFFED8936), Color(0xFFFBD38D)];
      case AllocationLevel.veryAggressive:
        return const [Color(0xFF6B46C1), Color(0xFF9F7AEA), Color(0xFFB794F4)];
    }
  }
}

enum PerformanceLevel {
  significantlyBelow,
  belowAverage,
  inLine,
  strong,
  veryStrong;

  String get label {
    switch (this) {
      case PerformanceLevel.significantlyBelow:
        return 'Significantly Below';
      case PerformanceLevel.belowAverage:
        return 'Below Average';
      case PerformanceLevel.inLine:
        return 'In Line';
      case PerformanceLevel.strong:
        return 'Strong';
      case PerformanceLevel.veryStrong:
        return 'Very Strong';
    }
  }

  int get activeSegments => index + 1; // 1 to 5

  Color get activeColor {
    switch (this) {
      case PerformanceLevel.significantlyBelow:
        return const Color(0xFFC6F6D5); // Very Light Green
      case PerformanceLevel.belowAverage:
        return const Color(0xFF9AE6B4); // Light Green
      case PerformanceLevel.inLine:
        return const Color(0xFF68D391); // Medium Green
      case PerformanceLevel.strong:
        return const Color(0xFF48BB78); // Green
      case PerformanceLevel.veryStrong:
        return const Color(0xFF38A169); // Dark Green
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case PerformanceLevel.significantlyBelow:
        return const [Color(0xFFC6F6D5), Color(0xFFF0FFF4)];
      case PerformanceLevel.belowAverage:
        return const [Color(0xFF9AE6B4), Color(0xFFC6F6D5)];
      case PerformanceLevel.inLine:
        return const [Color(0xFF68D391), Color(0xFF9AE6B4)];
      case PerformanceLevel.strong:
        return const [Color(0xFF48BB78), Color(0xFF68D391)];
      case PerformanceLevel.veryStrong:
        return const [Color(0xFF22543D), Color(0xFF38A169), Color(0xFF48BB78)];
    }
  }
}
