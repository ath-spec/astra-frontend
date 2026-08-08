import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/chat/providers/chat_provider.dart';
import '../providers/nav_context_provider.dart';
import '../../features/navigation/widgets/main_nav_row.dart';
import '../../features/navigation/widgets/mf_nav_row.dart';
import '../../features/navigation/widgets/explore_nav_row.dart';
import '../../features/navigation/widgets/learnings_nav_row.dart';
import '../../features/navigation/widgets/nav_shared_components.dart';
import '../../features/navigation/widgets/nav_input_pill.dart';
import '../providers/nav_input_provider.dart';
import '../providers/speech_provider.dart';
import '../navigation/nav_keys.dart';

class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _navVisible = true;
  int _previousIndex = 0;

  static final _branchNavKeys = [
    homeNavKey,
    mfNavKey,
    chatNavKey,
    newsNavKey,
    learningsNavKey,
  ];

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

  void _onPillTap(int index, {bool clearChat = false}) {
    final goingToChat = index == 2;
    final currentIndex = widget.navigationShell.currentIndex;

    if (currentIndex != index) {
      _previousIndex = currentIndex;
    }

    if (goingToChat) {
      setState(() => _navVisible = false);
      if (clearChat) {
        // We only clear the chat if explicitly requested (e.g. starting a fresh session from history)
        // For standard nav pill taps, we want to retain the active session so the user can navigate away and back.
        ref.invalidate(chatNotifierProvider);
      }
    } else {
      if (index == 0 || index == 3) {
        ref.read(navContextProvider.notifier).state = NavContext.main;
      } else if (index == 1) {
        ref.read(navContextProvider.notifier).state = NavContext.mf;
        ref.read(mfTabIndexProvider.notifier).state = 0;
      } else if (index == 4) {
        ref.read(navContextProvider.notifier).state = NavContext.learnings;
        ref.read(learningsTabIndexProvider.notifier).state = 0;
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
    final oldIndex = oldWidget.navigationShell.currentIndex;
    
    // If we just navigated away from the Chat tab (index 2), stop any active generation/audio
    if (oldIndex == 2 && currentIndex != 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatNotifierProvider.notifier).cancelGeneration();
        try {
          ref.read(speechProvider.notifier).stopListening();
        } catch (_) {}
      });
    }
    
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

    // Hide nav pill on deep sub-screens (e.g. chapter reader, video reader, module details)
    // GoRouterState.of(context).uri is reactive — AppShell rebuilds on every route change
    final currentUri = GoRouterState.of(context).uri.toString();
    final isOnSubScreen = currentUri.contains('/learnings/') ||
        currentUri.contains('/chapter-reader') ||
        currentUri.contains('/video-reader') ||
        currentUri.contains('/module-details') ||
        currentUri.contains('/chapter-list');

    final effectiveNavVisible = _navVisible && !isOnSubScreen;

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
      case NavContext.learnings:
        currentPill = const LearningsNavPill(
          key: ValueKey('learnings_pill'),
        );
        break;
    }

    final bool isHome = currentIndex == 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final isInput = ref.read(navInputModeProvider);
        if (isInput) {
          FocusScope.of(context).unfocus();
          ref.read(navInputModeProvider.notifier).state = false;
          ref.read(speechProvider.notifier).stopListening();
          return;
        }

        final currentIndex = widget.navigationShell.currentIndex;

        // Try popping within the current branch first
        final branchKey = _branchNavKeys[currentIndex];
        final nav = branchKey.currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
          return;
        }

        // At branch root — go home if not already there
        if (currentIndex == 0) {
          SystemNavigator.pop();
        } else {
          ref.read(navContextProvider.notifier).state = NavContext.main;
          widget.navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            widget.navigationShell,

            // Global bottom blur behind the floating nav pill
            if (effectiveNavVisible)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 120 + MediaQuery.paddingOf(context).bottom,
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      // Progressive blur (fading out upwards)
                      if (!kIsWeb) ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black, Colors.black, Colors.transparent],
                          stops: [0.0, 0.4, 1.0], // Solid blur at the very bottom edge, fading out
                        ).createShader(bounds),
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                      // Progressive white frosted tint (fading out upwards)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              const Color(0xFFF9FAFB).withValues(alpha: 0.95), // Frosted white at bottom edge
                              const Color(0xFFF9FAFB).withValues(alpha: 0.0),  // Transparent above
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

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
                  LearningsNavPill(),
                ],
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !isInputMode,
                child: GestureDetector(
                  onTap: () {
                    if (isInputMode) {
                      FocusScope.of(context).unfocus();
                      ref.read(navInputModeProvider.notifier).state = false;
                      ref.read(speechProvider.notifier).stopListening();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    color: isInputMode ? Colors.black.withValues(alpha: 0.6) : Colors.transparent,
                  ),
                ),
              ),
            ),
            if (effectiveNavVisible)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                left: 16,
                right: 16,
                bottom: 12 + MediaQuery.paddingOf(context).bottom,
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
                                    child: HomeCircleButton(onTap: () => _onPillTap(0)),
                                  ),
                          ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeOut,
                              transitionBuilder: (child, animation) {
                                final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                );
                                return ScaleTransition(
                                  scale: scaleAnimation,
                                  alignment: navContext == NavContext.main ? Alignment.centerLeft : Alignment.center,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
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
                                    child: GemButton(onTap: () {
                                      if (widget.navigationShell.currentIndex == 0) {
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


