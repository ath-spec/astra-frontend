import 'package:flutter/material.dart';
import '../../navigation/mainnav.dart';

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
    // Map global shell indices to pill indices
    // Shell: 0=Home, 1=MF, 2=Chat, 3=News, 4=Learnings, 5=Analytics
    // Pill:  0=Home, 1=Investments, 2=News, 3=Learnings, 4=Analytics
    int pillIndex = currentIndex;
    if (currentIndex == 3) pillIndex = 2; // News
    if (currentIndex == 4) pillIndex = 3; // Learnings
    if (currentIndex == 5) pillIndex = 4; // Analytics

    return NavigationPill(
      currentIndex: pillIndex,
      onTabTapped: (idx) {
        int globalIndex = idx;
        if (idx == 2) globalIndex = 3; // News
        if (idx == 3) globalIndex = 4; // Learnings
        if (idx == 4) globalIndex = 5; // Analytics
        onPillTap(globalIndex);
      },
      isNavVisible: true,
      icons: const [
        Icons.home_rounded,
        Icons.pie_chart_rounded,    // Mutual Funds
        Icons.newspaper_rounded,    // News
        Icons.school_rounded,       // Learnings
        Icons.insights_rounded,     // Analytics
      ],
      labels: const ['Home', 'Investments', 'News', 'Learnings', 'Analytics'],
      visibleTabsCount: 4,
    );
  }
}
