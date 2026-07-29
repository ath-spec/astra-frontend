import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/chat/providers/chat_provider.dart';
import '../providers/nav_context_provider.dart';
import '../../features/navigation/widgets/main_nav_row.dart';
import '../../features/navigation/widgets/mf_nav_row.dart';
import '../../features/navigation/widgets/explore_nav_row.dart';
import '../../features/navigation/widgets/nav_shared_components.dart';
import '../../features/navigation/widgets/nav_input_pill.dart';
import '../providers/nav_input_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _navVisible = true;
  int _previousIndex = 0;

  void _onPillTap(int index, {bool clearChat = true}) {
    final goingToChat = index == 2;
    final currentIndex = widget.navigationShell.currentIndex;

    if (currentIndex != index) {
      _previousIndex = currentIndex;
    }

    if (goingToChat) {
      setState(() => _navVisible = false);
      if (clearChat) {
        ref.invalidate(chatNotifierProvider);
      }
    } else {
      if (index == 0) {
        ref.read(navContextProvider.notifier).state = NavContext.main;
      } else if (index == 1) {
        ref.read(navContextProvider.notifier).state = NavContext.mf;
      } else if (index == 3) {
        ref.read(navContextProvider.notifier).state = NavContext.explore;
      }
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
    final navContext = ref.watch(navContextProvider);
    final isInputMode = ref.watch(navInputModeProvider);

    if (currentIndex != 2 && !_navVisible) {
      _navVisible = true;
    }
    if (currentIndex == 2 && _navVisible) {
      _navVisible = false;
    }

    Widget currentPill;
    switch (navContext) {
      case NavContext.main:
        currentPill = MainNavPill(
          key: const ValueKey('main_pill'),
          currentIndex: currentIndex,
          onPillTap: _onPillTap,
        );
        break;
      case NavContext.mf:
        currentPill = const MfNavPill(
          key: ValueKey('mf_pill'),
        );
        break;
      case NavContext.explore:
        currentPill = const ExploreNavPill(
          key: ValueKey('explore_pill'),
        );
        break;
    }

    return PopScope(
      canPop: currentIndex == 0 && !isInputMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        if (isInputMode) {
          FocusScope.of(context).unfocus();
          ref.read(navInputModeProvider.notifier).state = false;
        } else if (currentIndex == 2) {
          widget.navigationShell.goBranch(_previousIndex);
        } else {
          _onPillTap(0); // Return to Home
        }
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            widget.navigationShell,
            if (isInputMode)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    ref.read(navInputModeProvider.notifier).state = false;
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              left: 16,
              right: 16,
              // Slide off screen when not visible. Use padding instead of viewPadding so it sits flush with the keyboard when open.
              bottom: _navVisible ? (12 + MediaQuery.of(context).padding.bottom) : -100,
              child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                               return SizeTransition(
                                 sizeFactor: animation,
                                 axis: Axis.horizontal,
                                 child: FadeTransition(opacity: animation, child: child),
                               );
                            },
                            child: navContext == NavContext.main || isInputMode
                                ? const SizedBox.shrink(key: ValueKey('no_home'))
                                : Padding(
                                    key: const ValueKey('has_home'),
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: buildHomeCircle(() => _onPillTap(0)),
                                  ),
                          ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              child: isInputMode
                                  ? NavInputPill(
                                      key: const ValueKey('input_pill'),
                                      onSend: () => _onPillTap(2, clearChat: false),
                                    )
                                  : AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 400),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      transitionBuilder: (child, animation) {
                                        // Use a subtle scale and fade instead of slide to prevent overlapping siblings
                                        final scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(animation);
                                        return FadeTransition(
                                          opacity: animation,
                                          child: ScaleTransition(
                                            scale: scaleAnimation,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: currentPill,
                                    ),
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                               return SizeTransition(
                                 sizeFactor: animation,
                                 axis: Axis.horizontal,
                                 child: FadeTransition(opacity: animation, child: child),
                               );
                            },
                            child: isInputMode
                                ? const SizedBox.shrink(key: ValueKey('no_gem'))
                                : Padding(
                                    key: const ValueKey('has_gem'),
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: buildGemButton(() {
                                      if (navContext == NavContext.main) {
                                        _onPillTap(2, clearChat: true);
                                      } else {
                                        ref.read(navInputModeProvider.notifier).state = true;
                                      }
                                    }),
                                  ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

// End of AppShell
