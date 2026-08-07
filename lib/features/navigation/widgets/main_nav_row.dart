import 'package:flutter/material.dart';
import '../../navigation/mainnav.dart';
import 'nav_shared_components.dart';

class MainNavPill extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onPillTap;

  const MainNavPill({
    super.key,
    required this.currentIndex,
    required this.onPillTap,
  });

  @override
  Widget build(BuildContext context) {
    int pillIndex = currentIndex;
    if (currentIndex == 3) pillIndex = 2; // Map News (3) to pill index (2)

    return NavigationPill(
      currentIndex: pillIndex,
      onTabTapped: (idx) {
        int globalIndex = idx;
        if (idx == 2) globalIndex = 3; 
        onPillTap(globalIndex);
      },
      isNavVisible: true,
      icons: const [
        Icons.home_rounded,
        Icons.pie_chart_rounded, // Mutual Funds
        Icons.newspaper_rounded, // News
      ],
      labels: const ['Home', 'Investments', 'News'],
    );
  }
}
