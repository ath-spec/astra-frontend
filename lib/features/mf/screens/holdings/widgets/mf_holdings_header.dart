import 'dart:ui' show lerpDouble, ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HoldingsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double safeAreaTop;
  final double screenHeight;
  final bool hasImportedPortfolio;
  final bool isLocked;
  final VoidCallback onLockTap;
  final VoidCallback onCartTap;
  final VoidCallback onRefreshTap;

  HoldingsHeaderDelegate({
    required this.safeAreaTop,
    required this.screenHeight,
    this.hasImportedPortfolio = false,
    required this.isLocked,
    required this.onLockTap,
    required this.onCartTap,
    required this.onRefreshTap,
  });

  @override
  double get minExtent => safeAreaTop + 84.0;

  @override
  double get maxExtent => safeAreaTop + (screenHeight * 0.4);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = 1.0; // Handled globally via Transform.scale

    // 0.0 when fully expanded, 1.0 when fully collapsed
    final shrinkRatio = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    // Use an ease-in-out curve for the transition to make it feel organic (Emil style)
    final curve = Curves.easeInOutCubic;
    final double easedRatio = curve.transform(shrinkRatio);

    // Layout Interpolations
    final double startTop = maxExtent * 0.3;
    final double endTop = safeAreaTop + 18.0; // Vertically centered with 44px buttons
    final double currentTop = lerpDouble(startTop, endTop, easedRatio)!;

    final double startSubtitleTop = startTop - 26.0;
    final double endSubtitleTop = endTop - 40.0;
    final double currentSubtitleTop = lerpDouble(startSubtitleTop, endSubtitleTop, easedRatio)!;

    // Style Interpolations
    final double currentFontSize = lerpDouble(26.0 * scale, 14.0 * scale, easedRatio)!;
    final double currentBorderRadius = lerpDouble(0.0, 20.0 * scale, easedRatio)!;
    final double currentHPad = lerpDouble(0.0, 16.0 * scale, easedRatio)!;
    final double currentVPad = lerpDouble(0.0, 6.0 * scale, easedRatio)!;
    
    // Fade the background in slower so it looks like text first, then pill
    final double pillBgRatio = (easedRatio * 1.5).clamp(0.0, 1.0);
    final double currentBorderOpacity = lerpDouble(0.0, 1.0, pillBgRatio)!;
    final double currentShadowOpacity = lerpDouble(0.0, 0.05, pillBgRatio)!;

    return Container(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned(
            top: (-shrinkOffset * 0.1),
            left: 0,
            right: 0,
            bottom: screenHeight * 0.035, // Responsive bottom spacing
            child: Opacity(
              opacity: 1.0 - shrinkRatio,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  image: DecorationImage(
                    image: AssetImage('lib/core/images/net_value_bg.webp'),
                    fit: BoxFit.fitWidth,
                    alignment: Alignment(0.0, 0.3),
                  ),
                ),
              ),
            ),
          ),

          // Frosted glass blur overlay
          Positioned.fill(
            child: Stack(
              children: [
                // Progressive blur
                ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.black, Colors.transparent],
                    stops: [0.0, 0.7, 1.0],
                  ).createShader(bounds),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: lerpDouble(0.0, 16.0, easedRatio)!,
                        sigmaY: lerpDouble(0.0, 16.0, easedRatio)!,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                // Progressive tint
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFF9FAFB).withOpacity(lerpDouble(0.0, 0.85, easedRatio)!),
                        const Color(0xFFF9FAFB).withOpacity(lerpDouble(0.0, 0.4, easedRatio)!),
                        const Color(0xFFF9FAFB).withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Subtitle
          Positioned(
            top: currentSubtitleTop,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: (1.0 - (shrinkRatio * 2.5)).clamp(0.0, 1.0), // Fades out quickly
              child: Center(
                child: Text(
                  "MUTUAL FUNDS VALUE",
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: const Color(0xFF9CA3AF),
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),

          
          // The Transforming Wealth Number -> Pill
          Positioned(
            top: currentTop,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: currentHPad, vertical: currentVPad),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(pillBgRatio),
                      borderRadius: BorderRadius.circular(currentBorderRadius),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0).withOpacity(currentBorderOpacity),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(currentShadowOpacity),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _OdometerText(
                      targetValue: hasImportedPortfolio ? 343158 : 0,
                      isLocked: isLocked,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        color: const Color(0xFF0F172A),
                        fontSize: currentFontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: lerpDouble(-1.5, 0.0, easedRatio)!,
                        height: 1.1,
                      ),
                    ),
                  ),
                  // Shrinking subtitle text (1D Change)
                  if (shrinkRatio < 1.0)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation, 
                          axisAlignment: -1.0, 
                          child: Align(
                            alignment: Alignment.topCenter, 
                            child: child,
                          ),
                        ),
                      ),
                      child: !hasImportedPortfolio
                        ? const SizedBox.shrink(key: ValueKey('empty'))
                        : Opacity(
                            key: const ValueKey('content'),
                            opacity: (1.0 - (shrinkRatio * 2)).clamp(0.0, 1.0),
                            child: Padding(
                              padding: EdgeInsets.only(top: lerpDouble(8.0, 0.0, easedRatio)!),
                              child: Container(
                                height: lerpDouble(16.0, 0.0, easedRatio)!,
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: lerpDouble(1.0, 0.0, easedRatio)!,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_upward_rounded,
                                          size: lerpDouble(14.0 * scale, 0.0, easedRatio)!,
                                          color: const Color.fromARGB(255, 5, 134, 91), // Emerald 500
                                        ),
                                        SizedBox(width: lerpDouble(4.0 * scale, 0.0, easedRatio)!),
                                        Text(
                                          isLocked ? '₹ * * * *' : '₹2,491 (0.73%)',
                                          style: TextStyle(
                                            fontFamily: 'DMSans',
                                            fontSize: lerpDouble(8.0 * scale, 0.0, easedRatio)!,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(255, 5, 134, 91),
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        SizedBox(width: lerpDouble(6.0 * scale, 0.0, easedRatio)!),
                                        Text(
                                          '1D change',
                                          style: TextStyle(
                                            fontFamily: 'DMSans',
                                            fontSize: lerpDouble(8.0 * scale, 0.0, easedRatio)!,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  if (shrinkRatio < 1.0)
                    Opacity(
                      opacity: (1.0 - (shrinkRatio * 3.0)).clamp(0.0, 1.0),
                      child: Padding(
                        padding: EdgeInsets.only(top: lerpDouble(8.0, 0.0, easedRatio)!),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: onRefreshTap,
                              child: Container(
                                height: lerpDouble(22.0, 0.0, easedRatio)!,
                                padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.center,
                                    heightFactor: lerpDouble(1.0, 0.0, easedRatio)!,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.sync_rounded,
                                          size: lerpDouble(10.0 * scale, 0.0, easedRatio)!,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        SizedBox(width: lerpDouble(4.0 * scale, 0.0, easedRatio)!),
                                        Text(
                                          'Just now',
                                          style: TextStyle(
                                            fontFamily: 'SpaceGrotesk',
                                            fontSize: lerpDouble(10.0 * scale, 0.0, easedRatio)!,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF0F172A),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Top Row Buttons (Lock, Cart)
          Positioned(
            top: safeAreaTop + 12.0,
            right: 24.0 * scale,
            child: Row(
              children: [
                GestureDetector(
                  onTap: onLockTap,
                  child: Container(
                    width: 36 * scale,
                    height: 36 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                      color: Color(0xFF0F172A),
                      size: 18 * scale,
                    ),
                  ),
                ),
                SizedBox(width: 12 * scale),
                GestureDetector(
                  onTap: onCartTap,
                  child: Container(
                    width: 36 * scale,
                    height: 36 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: Color(0xFF0F172A),
                      size: 18 * scale,
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HoldingsHeaderDelegate oldDelegate) {
    return safeAreaTop != oldDelegate.safeAreaTop || 
           screenHeight != oldDelegate.screenHeight ||
           hasImportedPortfolio != oldDelegate.hasImportedPortfolio ||
           isLocked != oldDelegate.isLocked;
  }
}

// ─── Haptic Odometer Text ───────────────────────────────────────────────────

class _OdometerText extends StatefulWidget {
  final int targetValue;
  final TextStyle style;
  final bool isLocked;

  const _OdometerText({required this.targetValue, required this.style, this.isLocked = false});

  @override
  State<_OdometerText> createState() => _OdometerTextState();
}

class _OdometerTextState extends State<_OdometerText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _lastHapticValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _animation = Tween<double>(begin: 0, end: widget.targetValue.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )..addListener(_onTick);
    
    if (widget.targetValue > 0) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _OdometerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetValue != oldWidget.targetValue) {
      _animation = Tween<double>(begin: _animation.value, end: widget.targetValue.toDouble()).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  void _onTick() {
    int current = _animation.value.round();
    
    // Determine dynamic interval based on the target value
    int interval;
    if (widget.targetValue < 1000) {
      interval = 100;
    } else if (widget.targetValue < 10000) {
      interval = 1000;
    } else if (widget.targetValue < 100000) {
      interval = 10000;
    } else {
      interval = 15000; // Using 15,000 for >1L to get a satisfying ~20-30 clicks
    }

    if ((current - _lastHapticValue).abs() > interval || (current == widget.targetValue && _lastHapticValue != widget.targetValue)) {
      HapticFeedback.selectionClick();
      _lastHapticValue = current;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        String formatted;
        int intVal = _animation.value.round();
        if (widget.isLocked) {
          return Text('₹ * * * *', style: widget.style);
        }
        if (intVal == 0) {
          formatted = '0';
        } else {
          String numStr = intVal.toString();
          if (numStr.length <= 3) {
            formatted = numStr;
          } else {
            String lastThree = numStr.substring(numStr.length - 3);
            String otherNumbers = numStr.substring(0, numStr.length - 3);
            formatted = otherNumbers.replaceAllMapped(RegExp(r".{1,2}(?=(.{2})+(?!.))"), (Match m) => "${m[0]},") + ',' + lastThree;
          }
        }
        return Text('₹ $formatted', style: widget.style);
      }
    );
  }
}

