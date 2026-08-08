import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class MfAmountScrollerWidget extends StatefulWidget {
  final double initialAmount;
  final double minAmount;
  final double maxAmount;
  final double step;
  final ValueChanged<double> onAmountChanged;

  const MfAmountScrollerWidget({
    super.key,
    required this.initialAmount,
    this.minAmount = 1000,
    this.maxAmount = 500000,
    this.step = 1000,
    required this.onAmountChanged,
  });

  @override
  State<MfAmountScrollerWidget> createState() => _MfAmountScrollerWidgetState();
}

class _MfAmountScrollerWidgetState extends State<MfAmountScrollerWidget> {
  late ScrollController _scrollController;
  final double _tickSpacing = 16.0; // Slightly wider for fewer total ticks
  int _lastHapticValue = -1;
  final int _totalSteps = 35;

  @override
  void initState() {
    super.initState();
    
    // Calculate initial offset based on nonlinear scaling
    final int initialStep = _getStepForAmount(widget.initialAmount).clamp(0, _totalSteps);
    final initialOffset = initialStep * _tickSpacing;
    
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _lastHapticValue = initialStep;
  }

  double _getAmountForStep(int step) {
    if (step <= 9) {
      return 1000.0 + (step * 1000.0);
    } else if (step <= 27) {
      return 10000.0 + ((step - 9) * 5000.0);
    } else {
      return 100000.0 + ((step - 27) * 50000.0);
    }
  }

  int _getStepForAmount(double amount) {
    if (amount <= 10000) {
      return ((amount - 1000) / 1000).round();
    } else if (amount <= 100000) {
      return 9 + ((amount - 10000) / 5000).round();
    } else {
      return 27 + ((amount - 100000) / 50000).round();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime? _lastHapticTime;

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    
    final offset = _scrollController.offset;
    int currentStep = (offset / _tickSpacing).round();
    currentStep = currentStep.clamp(0, _totalSteps);
    
    if (currentStep != _lastHapticValue) {
      _lastHapticValue = currentStep;
      
      // When ScrollUpdateNotification fires, Flutter might be in the middle of a layout pass.
      // Calling platform channels synchronously during layout can cause the engine to drop the message.
      // Wrapping it in a microtask ensures it runs safely after the current synchronous frame operations.
      Future.microtask(() {
        HapticFeedback.selectionClick();
      });
      
      final newAmount = _getAmountForStep(currentStep);
      widget.onAmountChanged(newAmount);
    }
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      _handleScroll();
    } else if (notification is ScrollEndNotification) {
      // Snap to nearest tick smoothly
      final offset = _scrollController.offset;
      int nearestStep = (offset / _tickSpacing).round();
      nearestStep = nearestStep.clamp(0, _totalSteps);
      
      final targetOffset = nearestStep * _tickSpacing;
      if (offset != targetOffset) {
        Future.microtask(() {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              targetOffset,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Perfect padding ensures the first and last items can reach exactly the center
    final horizontalPadding = (screenWidth / 2) - (_tickSpacing / 2);

    return SizedBox(
      height: 60, 
      child: Stack(
        alignment: Alignment.bottomCenter, 
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onNotification,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemCount: _totalSteps + 1,
              itemBuilder: (context, index) {
                // Every 5th tick is major according to standard rulers
                final isMajor = index % 5 == 0;
                
                final double baseHeight = isMajor ? 24 : 12;
                final Color color = isMajor ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

                return AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, child) {
                    double offset = 0;
                    if (_scrollController.hasClients) {
                      offset = _scrollController.offset;
                    }
                    
                    // The center of this tick relative to the scroll offset
                    double itemPosition = index * _tickSpacing;
                    double distance = (itemPosition - offset).abs();
                    
                    // The maximum distance a tick can be visible on screen
                    double maxDistance = screenWidth / 2;
                    
                    // Map distance to an angle from 0 to pi/2 (0 at center, pi/2 at edge)
                    // We use 1.2 instead of 1.0 for the multiplier so it doesn't shrink completely to 0 at the very edge, 
                    // keeping a nice slight curve
                    double angle = (distance / maxDistance) * (1.2);
                    if (angle > 1.57) angle = 1.57; // clamp to pi/2 approx
                    
                    // Cosine gives us that perfect 3D cylinder projection curve
                    double scale = math.cos(angle);
                    // Ensure it doesn't shrink to absolute zero or flip
                    scale = scale.clamp(0.2, 1.0);
                    
                    // Optional: we can also adjust opacity slightly at the edges for more depth
                    double opacity = scale.clamp(0.3, 1.0);

                    return Container(
                      width: _tickSpacing,
                      alignment: Alignment.bottomCenter,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 1.5.w,
                          height: baseHeight, // Scale height dynamically based on distance
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(1.r),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Center Indicator (The active marker)
          Container(
            width: 3.w,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(1.5.r),
            ),
          ),
          
          // Top dot for the indicator (hovering above the 34px marker)
          Positioned(
            bottom: 40,
            child: Container(
              width: 5.w,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Acrylic Fading Edges
          Positioned.fill(
            child: IgnorePointer(
              child: Row(
                children: [
                  Container(
                    width: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
