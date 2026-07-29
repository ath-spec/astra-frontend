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

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: const Color(0xFFE6E6E6),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pillWidth = constraints.maxWidth;
            final tabWidth = pillWidth / widget.icons.length;

            int visualIndex;
            double indicatorLeft;

            if (_isDragging) {
              visualIndex = ((_dragX + (tabWidth / 2)) / tabWidth).floor();
              visualIndex = visualIndex.clamp(0, widget.icons.length - 1);
              indicatorLeft = _dragX.clamp(0.0, pillWidth - tabWidth);
            } else {
              visualIndex = widget.currentIndex;
              indicatorLeft = widget.currentIndex * tabWidth;
            }

            return GestureDetector(
              onHorizontalDragStart: (d) {
                setState(() {
                  _isDragging = true;
                  _dragX = d.localPosition.dx - (tabWidth / 2);
                });
              },
              onHorizontalDragUpdate: (d) {
                setState(() {
                  _dragX = d.localPosition.dx - (tabWidth / 2);
                });
              },
              onHorizontalDragEnd: (d) {
                setState(() {
                  _isDragging = false;
                });
                widget.onTabTapped(visualIndex);
              },
              child: Container(
                color: Colors.transparent,
                height: 36,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    // BACKGROUND PILL MOVED HERE (First in stack draws on bottom)
                    AnimatedPositioned(
                      duration: _isDragging
                          ? Duration.zero
                          : const Duration(milliseconds: 200),
                      curve: Curves.easeOutQuad,
                      top: -4, // Centered inside the 36px tall container
                      left: indicatorLeft + 4, // Horizontal padding
                      width: tabWidth - 8, // Shrunk to fit nicely inside the tab bounds
                      height: 42, // Reduced from 44 to tightly wrap the icon and text
                      child: AnimatedOpacity(
                        opacity: visualIndex == -1 ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
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
                                duration: const Duration(milliseconds: 200),
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
                                        size: 18,
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
              ),
            );
          },
        ),
    );
  }
}
