import 'dart:ui' show lerpDouble, ImageFilter;
import 'package:flutter/material.dart';
import '../../../core/widgets/arch_background.dart';

class StocksHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double safeAreaTop;
  final String totalAmount;
  final String todayChange;
  final VoidCallback onBackTap;
  final String lastRefreshedText;
  final VoidCallback onRefreshTap;
  final VoidCallback onAddAccountsTap;
  final bool isLocked;

  StocksHeaderDelegate({
    required this.safeAreaTop,
    required this.totalAmount,
    required this.todayChange,
    required this.onBackTap,
    required this.lastRefreshedText,
    required this.onRefreshTap,
    required this.onAddAccountsTap,
    required this.isLocked,
  });

  @override
  double get minExtent => safeAreaTop + 84.0;

  @override
  double get maxExtent => safeAreaTop + 260.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final scale = MediaQuery.of(context).size.width / 375.0;
    
    final shrinkRatio = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final curve = Curves.easeInOutCubic;
    final double easedRatio = curve.transform(shrinkRatio);

    final double startTop = maxExtent - 124.0;
    final double endTop = safeAreaTop + 18.0; 
    final double currentTop = lerpDouble(startTop, endTop, easedRatio)!;

    final double startSubtitleTop = startTop - 26.0;
    final double endSubtitleTop = endTop - 40.0;
    final double currentSubtitleTop = lerpDouble(startSubtitleTop, endSubtitleTop, easedRatio)!;

    final double currentFontSize = lerpDouble(36.0, 14.0, easedRatio)!;

    return Container(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Arch
          Positioned(
            top: -shrinkOffset * 0.5,
            left: 0 * scale,
            right: 0 * scale,
            child: Opacity(
              opacity: 1.0 - shrinkRatio,
              child: ArchBackground(height: 250 * scale),
            ),
          ),

          // Frosted glass blur overlay
          Positioned.fill(
            child: Stack(
              children: [
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
                      child: SizedBox.expand(),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(lerpDouble(0.0, 0.85, easedRatio)!),
                        Colors.white.withOpacity(lerpDouble(0.0, 0.4, easedRatio)!),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Subtitle "STOCKS & ETF"
          Positioned(
            top: currentSubtitleTop,
            left: 0 * scale,
            right: 0 * scale,
            child: Opacity(
              opacity: (1.0 - (shrinkRatio * 2.5)).clamp(0.0, 1.0), 
              child: Center(
                child: Text(
                  "STOCKS & ETF",
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0xFF64748B),
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Total Amount
          Positioned(
            top: currentTop,
            left: 0 * scale,
            right: 0 * scale,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                totalAmount,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  color: const Color(0xFF0F172A),
                  fontSize: currentFontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: lerpDouble(-1.0, 0.0, easedRatio)!,
                  height: 1.1,
                ),
              ),
            ),
          ),

          // Today's Change
          if (shrinkRatio < 1.0)
            Positioned(
              top: currentTop + 48.0,
              left: 0 * scale,
              right: 0 * scale,
              child: Opacity(
                opacity: (1.0 - (shrinkRatio * 3.0)).clamp(0.0, 1.0),
                child: Center(
                  child: Text(
                    todayChange,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ),
            ),

          // Refresh Pill
          if (shrinkRatio < 1.0)
            Positioned(
              top: currentTop + 72.0,
              left: 0 * scale,
              right: 0 * scale,
              child: Opacity(
                opacity: (1.0 - (shrinkRatio * 4.0)).clamp(0.0, 1.0),
                child: Center(
                  child: GestureDetector(
                    onTap: onRefreshTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16 * scale),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sync_rounded,
                            size: 12 * scale,
                            color: const Color(0xFF0F172A),
                          ),
                          SizedBox(width: 6 * scale),
                          Text(
                            lastRefreshedText,
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 10 * scale,
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
            ),

          // Top Row Buttons (Back, Lock)
          Positioned(
            top: safeAreaTop + 12.0,
            left: 24.0 * scale,
            right: 24.0 * scale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onBackTap,
                  child: Container(
                    width: 44 * scale,
                    height: 44 * scale,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF0F172A),
                      size: 20 * scale,
                    ),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onAddAccountsTap,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle,
                              size: 12 * scale,
                              color: const Color(0xFF475569),
                            ),
                            SizedBox(width: 4 * scale),
                            Text(
                              'ADD ACCOUNTS',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10 * scale,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F172A),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StocksHeaderDelegate oldDelegate) {
    return safeAreaTop != oldDelegate.safeAreaTop || 
           totalAmount != oldDelegate.totalAmount ||
           todayChange != oldDelegate.todayChange;
  }
}
