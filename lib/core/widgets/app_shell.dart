import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';
import 'navigation_pill.dart';
import '../../features/chat/providers/chat_provider.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.chat_bubble_rounded, // Chat Tab
    Icons.explore_outlined,
    Icons.person_outline_rounded,
  ];

  static const List<String> _labels = ['Home', 'Search', 'Chat', 'Explore', 'Profile'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isChatActive = navigationShell.currentIndex == 2;

    void onPillTap(int index) {
      // Clear chat history when visiting the Chat tab
      if (index == 2) {
        ref.invalidate(chatNotifierProvider);
      }
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          navigationShell,
          if (!isChatActive)
            NativeGlassNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: onPillTap,
              tabs: const [
                NativeGlassNavBarItem(label: 'Home', symbol: 'house.fill'),
                NativeGlassNavBarItem(label: 'Search', symbol: 'magnifyingglass'),
                NativeGlassNavBarItem(label: 'Chat', symbol: 'bubble.left.and.bubble.right.fill'),
                NativeGlassNavBarItem(label: 'Explore', symbol: 'safari'),
                NativeGlassNavBarItem(label: 'Profile', symbol: 'person'),
              ],
              fallback: NavigationPill(
                currentIndex: navigationShell.currentIndex,
                onTabTapped: onPillTap,
                isNavVisible: !isChatActive,
                icons: _icons,
                labels: _labels,
              ),
            ),
        ],
      ),
    );
  }
}
