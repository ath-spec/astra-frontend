import 'dart:ui' show lerpDouble, ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final VoidCallback onLockTap;

  StocksHeaderDelegate({
    required this.safeAreaTop,
    required this.totalAmount,
    required this.todayChange,
    required this.onBackTap,
    required this.lastRefreshedText,
    required this.onRefreshTap,
    required this.onAddAccountsTap,
    required this.isLocked,
    required this.onLockTap,
  });

  @override
  double get minExtent => safeAreaTop + 84.0;

  @override
  double get maxExtent => safeAreaTop + 260.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
        
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
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 1.0 - shrinkRatio,
              child: ArchBackground(height: 250),
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
                        Colors.white.withValues(alpha: lerpDouble(0.0, 0.85, easedRatio)!),
                        Colors.white.withValues(alpha: lerpDouble(0.0, 0.4, easedRatio)!),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      stops: [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Subtitle "STOCKS & ETF"
          Positioned(
            top: currentSubtitleTop,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: (1.0 - (shrinkRatio * 2.5)).clamp(0.0, 1.0), 
              child: Center(
                child: Text(
                  "STOCKS & ETF",
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0xFF64748B),
                    fontSize: 10,
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
            left: 0,
            right: 0,
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
              left: 0,
              right: 0,
              child: Opacity(
                opacity: (1.0 - (shrinkRatio * 3.0)).clamp(0.0, 1.0),
                child: Center(
                  child: Text(
                    todayChange,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12.sp,
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
              left: 0,
              right: 0,
              child: Opacity(
                opacity: (1.0 - (shrinkRatio * 4.0)).clamp(0.0, 1.0),
                child: Center(
                  child: GestureDetector(
                    onTap: onRefreshTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
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
                            size: 12,
                            color: const Color(0xFF0F172A),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            lastRefreshedText,
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 10,
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
            left: 24.0,
            right: 24.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onBackTap,
                  child: SizedBox(
                    width: 44.w,
                    height: 44,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF0F172A),
                      size: 20,
                    ),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onLockTap,
                      child: Container(
                        width: 36.w,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Icon(
                          isLocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                          color: const Color(0xFF0F172A),
                          size: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: onAddAccountsTap,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle,
                              size: 12,
                              color: const Color(0xFF475569),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'ADD ACCOUNTS',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
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
           todayChange != oldDelegate.todayChange ||
           isLocked != oldDelegate.isLocked;
  }
}
