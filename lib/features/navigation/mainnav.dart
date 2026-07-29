import 'dart:ui';
import 'package:flutter/material.dart';

class NavigationPill extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabTapped;
  final bool isNavVisible;
  final List<IconData> icons;
  final List<String> labels;

  const NavigationPill({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
    required this.isNavVisible,
    required this.icons,
    required this.labels,
  });

  @override
  State<NavigationPill> createState() => _NavigationPillState();
}

class _NavigationPillState extends State<NavigationPill> {
  double _dragX = 0.0;
  bool _isDragging = false;
  final ScrollController _scrollController = ScrollController();
  double _currentTabWidth = 0.0;
  bool _needsScroll = false;

  @override
  void didUpdateWidget(NavigationPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _scrollToIndex(widget.currentIndex);
    }
  }

  void _scrollToIndex(int index) {
    if (!_needsScroll || !_scrollController.hasClients || _currentTabWidth == 0.0) return;
    
    final double tabLeft = index * _currentTabWidth;
    final double tabRight = tabLeft + _currentTabWidth;
    
    final double viewportWidth = _scrollController.position.viewportDimension;
    final double currentScroll = _scrollController.offset;
    // We want to peek at least 60% of the adjacent tab
    final double peekAmount = _currentTabWidth * 0.6;
    
    // The ideal view range we want visible
    final double desiredLeft = tabLeft - peekAmount;
    final double desiredRight = tabRight + peekAmount;
    
    if (desiredLeft < currentScroll) {
      final double targetScroll = desiredLeft.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else if (desiredRight > currentScroll + viewportWidth) {
      final double targetScroll = (desiredRight - viewportWidth).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 0, // Padding moved to inner content to avoid scroll clipping
            ),
            decoration: BoxDecoration(
              // Reduced opacity so the blur is visible
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: const Color(0xFFE6E6E6).withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            child: LayoutBuilder(
          builder: (context, constraints) {
            // Subtract the 16px horizontal padding that we moved inside
            final double pillWidth = constraints.maxWidth - 16.0;
            // Standardize tab width so the 'pill light' is identical across Main, MF, and Explore screens
            double tabWidth = pillWidth / 3;
            bool needsScroll = widget.icons.length > 3;

            final double totalWidth = tabWidth * widget.icons.length;
            
            // Save state for auto-scroll logic
            _needsScroll = needsScroll;
            _currentTabWidth = tabWidth;

            int visualIndex;
            double indicatorLeft;

            if (_isDragging && !needsScroll) {
              visualIndex = ((_dragX + (tabWidth / 2)) / tabWidth).floor();
              visualIndex = visualIndex.clamp(0, widget.icons.length - 1);
              indicatorLeft = _dragX.clamp(0.0, totalWidth - tabWidth);
            } else {
              visualIndex = widget.currentIndex;
              indicatorLeft = widget.currentIndex * tabWidth;
            }

            Widget content = Container(
              color: Colors.transparent,
              height: 38, 
              width: needsScroll ? totalWidth : null,
              child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    // BACKGROUND PILL MOVED HERE (First in stack draws on bottom)
                    AnimatedPositioned(
                      duration: _isDragging
                          ? Duration.zero
                          : const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      top: 0, 
                      left: indicatorLeft, 
                      width: tabWidth, 
                      height: 40,
                      child: AnimatedOpacity(
                        opacity: visualIndex == -1 ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
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
                          ),
                        ),
                      ),
                    ),
                  ),
                    // FOREGROUND ICONS AND LABELS MOVED HERE (Last in stack draws on top)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(widget.icons.length, (index) {
                        final isActive = visualIndex == index;

                        final double iconCenter =
                            (index * tabWidth) + (tabWidth / 2);
                        final double pillCenter =
                            indicatorLeft + (tabWidth / 2);
                        final double distance =
                            (pillCenter - iconCenter).abs();
                        final double maxDistance = tabWidth;

                        double scale = 1.0;
                        if (_isDragging && distance < maxDistance) {
                          final double percent =
                              1.0 - (distance / maxDistance);
                          final double curvedPercent =
                              Curves.easeOut.transform(percent);
                          scale = 1.0 + (curvedPercent * 0.2);
                        }

                        return SizedBox(
                          width: tabWidth,
                          child: GestureDetector(
                            onTap: () => widget.onTabTapped(index),
                            behavior: HitTestBehavior.translucent,
                            child: Transform.scale(
                              scale: scale,
                              child: TweenAnimationBuilder<Color?>(
                                duration: const Duration(milliseconds: 300),
                                tween: ColorTween(
                                  begin: const Color(0xFF1E293B),
                                  end: isActive
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                ),
                                builder: (context, color, child) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        widget.icons[index],
                                        color: color,
                                        size: 16, // Increased from 16
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.labels[index],
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 10, 
                                          fontWeight:FontWeight.w600,
                                          color: color,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
            );

            if (needsScroll) {
              content = SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: content,
              );
            } else {
              content = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: content,
              );
            }

            return GestureDetector(
              onHorizontalDragStart: needsScroll ? null : (d) {
                setState(() {
                  _isDragging = true;
                  _dragX = d.localPosition.dx - 8.0 - (tabWidth / 2);
                });
              },
              onHorizontalDragUpdate: needsScroll ? null : (d) {
                setState(() {
                  _dragX = d.localPosition.dx - 8.0 - (tabWidth / 2);
                });
              },
              onHorizontalDragEnd: needsScroll ? null : (d) {
                setState(() {
                  _isDragging = false;
                });
                widget.onTabTapped(visualIndex);
              },
              child: content,
            );
          },
        ),
          ),
        ),
        ),
      ),
    );
  }
}
