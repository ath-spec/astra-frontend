import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/navigation/mainnav.dart';
import '../../features/chat/providers/chat_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  // Track visibility separately so we can flip it BEFORE the route changes
  bool _navVisible = true;
  // Track the previous tab so hardware back button works correctly from Chat
  int _previousIndex = 0;

  void _onPillTap(int index) {
    final goingToChat = index == 2;
    final currentIndex = widget.navigationShell.currentIndex;

    if (currentIndex != index) {
      _previousIndex = currentIndex;
    }

    // Hide nav INSTANTLY at tap time — before goBranch fires the route change.
    if (goingToChat) {
      setState(() => _navVisible = false);
    }

    if (index == 2) {
      ref.invalidate(chatNotifierProvider);
    }

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentIndex = widget.navigationShell.currentIndex;
    if (currentIndex != 2 && !_navVisible) {
      _navVisible = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;

    if (currentIndex != 2 && !_navVisible) {
      _navVisible = true;
    }
    if (currentIndex == 2 && _navVisible) {
      _navVisible = false;
    }

    return PopScope(
      canPop: currentIndex != 2,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        if (currentIndex == 2) {
          // Industry standard: if there's a nested route/dialog, pop that first.
          if (context.canPop()) {
            context.pop();
          } else {
            // Otherwise, switch to the previous tab.
            widget.navigationShell.goBranch(_previousIndex);
          }
        }
      },
      child: Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          widget.navigationShell,

          Positioned(
            left: 16,
            right: 16,
            bottom: 12 + MediaQuery.of(context).viewPadding.bottom,
            // _navVisible flips to false at tap time — the nav is ALREADY GONE
            // before go_router starts the page transition. No fade-out on chat.
            // TweenAnimationBuilder only plays when the widget is re-mounted
            // (i.e. when returning FROM chat), giving a nice fade-in.
            child: _navVisible
                ? TweenAnimationBuilder<double>(
                    key: const ValueKey('nav'), // Static key so it doesn't blink between normal tabs
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.94 + 0.06 * value,
                        child: child,
                      ),
                    ),
                    child: _NavRow(
                      currentIndex: currentIndex,
                      onPillTap: _onPillTap,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    ));
  }
}

class _NavRow extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onPillTap;

  const _NavRow({
    required this.currentIndex,
    required this.onPillTap,
  });

  @override
  Widget build(BuildContext context) {
    final pillIndex = currentIndex < 2 ? currentIndex : currentIndex - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: NavigationPill(
            currentIndex: pillIndex,
            onTabTapped: (idx) {
              final globalIndex = idx < 2 ? idx : idx + 1;
              onPillTap(globalIndex);
            },
            isNavVisible: true,
            icons: const [
              Icons.home_rounded,
              Icons.search_rounded,
              Icons.explore_outlined,
              Icons.person_outline_rounded,
            ],
            labels: const ['Home', 'Search', 'Explore', 'Profile'],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => onPillTap(2),
          child: Container(
            height: 52,
            width: 52,
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
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}
