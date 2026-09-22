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

  // Blue ramp, light to dark across the four tiers — matches the blue family
  // _MiniDisciplinePainter already uses for the home card's gauge. Previously
  // this ran red (poor) -> blue (moderate) -> green (good) -> dark green
  // (excellent), an unrelated traffic-light scheme.
  Color get color {
    switch (this) {
      case DisciplineLevel.poor:
        return const Color(0xFFBCE3FF);
      case DisciplineLevel.moderate:
        return const Color(0xFF65B4FF);
      case DisciplineLevel.good:
        return const Color(0xFF2796FF);
      case DisciplineLevel.excellent:
        return const Color(0xFF015294);
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case DisciplineLevel.poor:
        return const [Color(0xFFBCE3FF), Color(0xFFE0F2FE)];
      case DisciplineLevel.moderate:
        return const [Color(0xFF65B4FF), Color(0xFFBCE3FF)];
      case DisciplineLevel.good:
        return const [Color(0xFF2796FF), Color(0xFF65B4FF)];
      case DisciplineLevel.excellent:
        return const [Color(0xFF015294), Color(0xFF2796FF)];
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

  // Purple ramp (Chakra's purple.200 -> purple.600), light to dark across the
  // five levels — previously conservative/moderate/balanced/aggressive used
  // an unrelated green/blue/orange traffic-light scheme and only
  // veryAggressive was purple. Allocation's whole identity is purple now.
  Color get activeColor {
    switch (this) {
      case AllocationLevel.conservative:
        return const Color(0xFFD6BCFA); // purple.200
      case AllocationLevel.moderateConservative:
        return const Color(0xFFB794F4); // purple.300
      case AllocationLevel.balanced:
        return const Color(0xFF9F7AEA); // purple.400
      case AllocationLevel.aggressive:
        return const Color(0xFF805AD5); // purple.500
      case AllocationLevel.veryAggressive:
        return const Color(0xFF6B46C1); // purple.600
    }
  }

  // Darker than activeColor's pastel ramp — this feeds text/icon gradients
  // (ShaderMask over the level label, the insight sentence), where the
  // light 200/300 purples read as washed-out and low-contrast against a
  // white card. activeColor keeps the lighter ramp for the gauge fill.
  List<Color> get gradientColors {
    switch (this) {
      case AllocationLevel.conservative:
        return const [Color(0xFF9F7AEA), Color(0xFFB794F4)];
      case AllocationLevel.moderateConservative:
        return const [Color(0xFF805AD5), Color(0xFF9F7AEA)];
      case AllocationLevel.balanced:
        return const [Color(0xFF6B46C1), Color(0xFF805AD5)];
      case AllocationLevel.aggressive:
        return const [Color(0xFF553C9A), Color(0xFF6B46C1)];
      case AllocationLevel.veryAggressive:
        return const [Color(0xFF44337A), Color(0xFF553C9A), Color(0xFF6B46C1)];
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

  // Darker than activeColor's pastel ramp — matches the same fix applied to
  // AllocationLevel.gradientColors, so text/icon gradients across the three
  // gauge tabs (Discipline/Allocation/Performance) are consistently legible
  // rather than some washed-out and some not. activeColor keeps the lighter
  // ramp for the gauge fill.
  List<Color> get gradientColors {
    switch (this) {
      case PerformanceLevel.significantlyBelow:
        return const [Color(0xFF68D391), Color(0xFF9AE6B4)];
      case PerformanceLevel.belowAverage:
        return const [Color(0xFF48BB78), Color(0xFF68D391)];
      case PerformanceLevel.inLine:
        return const [Color(0xFF38A169), Color(0xFF48BB78)];
      case PerformanceLevel.strong:
        return const [Color(0xFF2F855A), Color(0xFF38A169)];
      case PerformanceLevel.veryStrong:
        return const [Color(0xFF22543D), Color(0xFF2F855A), Color(0xFF38A169)];
    }
  }
}
