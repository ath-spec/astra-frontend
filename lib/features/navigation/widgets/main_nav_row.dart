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
    // Shell: 0=Home, 1=MF (Investments), 2=Chat, 3=News, 4=Learnings, 5=Analytics
    // Pill:  0=Home, 1=Investments, 2=Analytics, 3=News, 4=Learnings
    int pillIndex = currentIndex;
    if (currentIndex == 5) pillIndex = 2; // Analytics
    if (currentIndex == 3) pillIndex = 3; // News
    if (currentIndex == 4) pillIndex = 4; // Learnings

    return NavigationPill(
      currentIndex: pillIndex,
      onTabTapped: (idx) {
        int globalIndex = idx;
        if (idx == 2) globalIndex = 5; // Analytics
        if (idx == 3) globalIndex = 3; // News
        if (idx == 4) globalIndex = 4; // Learnings
        onPillTap(globalIndex);
      },
      isNavVisible: true,
      icons: const [
        Icons.home_rounded,
        Icons.pie_chart_rounded,    // Investments
        Icons.insights_rounded,     // Analytics
        Icons.newspaper_rounded,    // News
        Icons.school_rounded,       // Learnings
      ],
      labels: const ['Home', 'Investments', 'Analytics', 'News', 'Learnings'],
      visibleTabsCount: 4,
    );
  }
}
