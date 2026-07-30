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

  @override
  void initState() {
    super.initState();
    // Precache the heavy MF background image while the user is still on the
    // home screen. By the time they tap the MF tab, the image is already
    // decoded and uploaded to the GPU — zero jank on first entry.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        precacheImage(
          const AssetImage('lib/core/images/xplore_pillars.webp'),
          context,
        );
      }
    });
  }

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

    // Freeze the visual index if we're transitioning to Chat (2) so the active pill doesn't slide
    // horizontally while the entire nav bar drops down vertically (which creates a diagonal glitch).
    final displayIndex = currentIndex == 2 ? _previousIndex : currentIndex;

    Widget currentPill;
    switch (navContext) {
      case NavContext.main:
        currentPill = MainNavPill(
          key: const ValueKey('main_pill'),
          currentIndex: displayIndex,
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

            // Pre-warm all nav pill variants offscreen so the first tap into MF
            // or Explore has zero cold-build cost. Offstage keeps them in the
            // element tree (measured + laid out) but never painted.
            Offstage(
              offstage: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  MfNavPill(),
                  ExploreNavPill(),
                ],
              ),
            ),
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
            if (_navVisible)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                left: 16,
                right: 16,
                bottom: 12 + MediaQuery.of(context).padding.bottom,
                child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeOut,
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
                              duration: const Duration(milliseconds: 200),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeOut,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              child: isInputMode
                                  ? NavInputPill(
                                      key: const ValueKey('input_pill'),
                                      onSend: () => _onPillTap(2, clearChat: false),
                                    )
                                  : AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      switchInCurve: Curves.easeOut,
                                      switchOutCurve: Curves.easeOut,
                                      transitionBuilder: (child, animation) {
                                        // Subtle scale (0.95 instead of 0.9) and fade makes the transition lighter
                                        final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(animation);
                                        return FadeTransition(
                                          opacity: animation,
                                          child: ScaleTransition(
                                            scale: scaleAnimation,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: RepaintBoundary(child: currentPill),
                                    ),
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeOut,
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
