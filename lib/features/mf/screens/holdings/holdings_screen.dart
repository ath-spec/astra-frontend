import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import '../../../../core/widgets/arch_background.dart';

class HoldingsScreen extends StatelessWidget {
  const HoldingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HoldingsHeaderDelegate(
              safeAreaTop: MediaQuery.of(context).padding.top,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  child: Center(
                    child: _MfHoldingsEmptyStateInline(),
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Inline empty state (no longer needs separate file import) ──────────────

class _MfHoldingsEmptyStateInline extends StatelessWidget {
  const _MfHoldingsEmptyStateInline();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 240,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                    ),
                  ),
                  Container(
                    width: 180,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF8FAFC),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 8)),
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFFFFF), Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.pie_chart_rounded, size: 64, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'New to mutual funds?',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.0,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Browse and invest in mutual funds curated\nfor your goals',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Text(
                'EXPLORE ALL FUNDS',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header Delegate ─────────────────────────────────────────────────────────

class _HoldingsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double safeAreaTop;

  _HoldingsHeaderDelegate({required this.safeAreaTop});

  @override
  double get minExtent => safeAreaTop + 84.0;

  @override
  double get maxExtent => safeAreaTop + 220.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final shrinkRatio = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final curve = Curves.easeInOutCubic;
    final double easedRatio = curve.transform(shrinkRatio);

    // Layout interpolations — same maths as Home
    final double startTop = maxExtent - 84.0;
    final double endTop = safeAreaTop + 18.0;
    final double currentTop = lerpDouble(startTop, endTop, easedRatio)!;

    final double startSubtitleTop = startTop - 26.0;
    final double endSubtitleTop = endTop - 40.0;
    final double currentSubtitleTop = lerpDouble(startSubtitleTop, endSubtitleTop, easedRatio)!;

    final double currentFontSize = lerpDouble(36.0, 14.0, easedRatio)!;
    final double currentBorderRadius = lerpDouble(0.0, 20.0, easedRatio)!;
    final double currentHPad = lerpDouble(0.0, 16.0, easedRatio)!;
    final double currentVPad = lerpDouble(0.0, 6.0, easedRatio)!;

    final double pillBgRatio = (easedRatio * 1.5).clamp(0.0, 1.0);
    final double currentBorderOpacity = lerpDouble(0.0, 1.0, pillBgRatio)!;
    final double currentShadowOpacity = lerpDouble(0.0, 0.05, pillBgRatio)!;

    return Container(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Same ArchBackground as Home — fades out on scroll
          Positioned(
            top: -shrinkOffset * 0.5,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 1.0 - shrinkRatio,
              child: const ArchBackground(height: 250),
            ),
          ),

          // Frosted overlay — pure gradient (no BackdropFilter, zero jank)
          Positioned.fill(
            child: Opacity(
              opacity: easedRatio.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFF9FAFB).withOpacity(0.98),
                      const Color(0xFFF9FAFB).withOpacity(0.92),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Subtitle label — fades out quickly on scroll
          Positioned(
            top: currentSubtitleTop,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: (1.0 - (shrinkRatio * 2.5)).clamp(0.0, 1.0),
              child: const Center(
                child: Text(
                  'MUTUAL FUNDS VALUE',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Transforming value number → pill (same pattern as Home)
          Positioned(
            top: currentTop,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹0',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        color: const Color(0xFF0F172A),
                        fontSize: currentFontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: lerpDouble(-1.0, 0.0, easedRatio)!,
                        height: 1.1,
                      ),
                    ),
                    if (shrinkRatio < 1.0) ...[
                      SizedBox(width: lerpDouble(12.0, 0.0, easedRatio)!),
                      Opacity(
                        opacity: (1.0 - (shrinkRatio * 2)).clamp(0.0, 1.0),
                        child: Container(
                          width: lerpDouble(28.0, 0.0, easedRatio)!,
                          height: lerpDouble(28.0, 0.0, easedRatio)!,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                          ),
                          child: Icon(
                            Icons.refresh_rounded,
                            size: lerpDouble(16.0, 0.0, easedRatio)!,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HoldingsHeaderDelegate oldDelegate) {
    return safeAreaTop != oldDelegate.safeAreaTop;
  }
}
