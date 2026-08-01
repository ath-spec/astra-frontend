import 'dart:ui' show lerpDouble, ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/nav_context_provider.dart';
import 'widgets/mf_explore_grid.dart';
import 'widgets/mf_trending_funds.dart';
import 'widgets/mf_fund_list_card.dart';
import 'widgets/mf_popular_pills.dart';
import 'widgets/mf_alternative_funds.dart';

// NEW SECTIONS
import 'widgets/mf_new_built_for_u.dart';
import 'widgets/mf_explore_assets.dart';
import 'widgets/mf_new_trending_themes.dart';
import 'widgets/mf_new_investment_ideas.dart';
import 'widgets/mf_goal_planning.dart';
import 'widgets/mf_global_investing.dart';
import 'widgets/mf_new_alternative_assets.dart';
import 'widgets/mf_income_safety.dart';
import 'widgets/mf_explore_by_risk.dart';
import 'widgets/mf_ai_picks_bento.dart';
import 'widgets/mf_learn_and_grow.dart';

class MfExploreScreen extends ConsumerWidget {
  const MfExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _MfExploreHeaderDelegate(
              safeAreaTop: MediaQuery.of(context).padding.top,
              screenHeight: MediaQuery.of(context).size.height,
              onBackTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  ref.read(navContextProvider.notifier).state = NavContext.main;
                  context.go('/');
                }
              },
            ),
          ),
          SliverList.list(
            children: [// spacing since we removed MfExploreHeader
                
                // EXPLORE ASSETS
                const SizedBox(height: 32),
                const MfExploreAssets(),

                // Section 1: TRENDING THEMES
                const SizedBox(height: 48),
                const MfNewTrendingThemes(),
                const SizedBox(height: 48),

                // Section 5: INVESTMENT IDEAS
                const MfNewInvestmentIdeas(),
                const SizedBox(height: 48),
                // Section 6: GOAL PLANNING
                const MfGoalPlanning(),
                const SizedBox(height: 48),
                // Section 2: ALTERNATIVE ASSETS
                const MfNewAlternativeAssets(),
                const SizedBox(height: 48),
                const MfAlternativeFunds(),
                const SizedBox(height: 48),
                
                // Section 3: AI PICKS (HERO)
                const MfNewAiPicksHero(),
                const SizedBox(height: 48),

                

                

                // Section 6: GLOBAL INVESTING
                const MfGlobalInvesting(),
                const SizedBox(height: 48),


                // Section 9: EXPLORE BY RISK
                const MfExploreByRisk(),
                const SizedBox(height: 48),

                // Section 10: AI PICKS (DYNAMIC BENTO)
                const MfAiPicksBento(),
                
                const SizedBox(height: 120), // Bottom padding for nav bar
              ],
          ),
        ],
      ),
    );
  }
}

class _MfExploreHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double safeAreaTop;
  final double screenHeight;
  final VoidCallback onBackTap;

  _MfExploreHeaderDelegate({
    required this.safeAreaTop,
    required this.screenHeight,
    required this.onBackTap,
  });

  @override
  double get minExtent => safeAreaTop + 84.0;

  @override
  double get maxExtent => safeAreaTop + (screenHeight * 0.4);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
    final double currentFontSize = lerpDouble(26.0, 14.0, easedRatio)!;
    final double currentBorderRadius = lerpDouble(0.0, 20.0, easedRatio)!;
    final double currentHPad = lerpDouble(0.0, 16.0, easedRatio)!;
    final double currentVPad = lerpDouble(0.0, 6.0, easedRatio)!;
    
    // Fade the background in slower so it looks like text first, then pill
    final double pillBgRatio = (easedRatio * 1.5).clamp(0.0, 1.0);
    final double currentBorderOpacity = lerpDouble(0.0, 1.0, pillBgRatio)!;
    final double currentShadowOpacity = lerpDouble(0.0, 0.05, pillBgRatio)!;

    return Container(
      color: Colors.transparent,
      child: Stack(
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
              child: const Center(
                child: Text(
                  "MUTUAL FUNDS VALUE",
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0xFF9CA3AF),
                    fontSize: 10,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹ 3,43,158',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        color: const Color(0xFF0F172A),
                        fontSize: currentFontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: lerpDouble(-1.5, 0.0, easedRatio)!,
                        height: 1.1,
                      ),
                    ),
                    // Shrinking subtitle text (1D Change)
                    if (shrinkRatio < 1.0)
                      Opacity(
                        opacity: (1.0 - (shrinkRatio * 2)).clamp(0.0, 1.0),
                        child: Padding(
                          padding: EdgeInsets.only(top: lerpDouble(8.0, 0.0, easedRatio)!),
                          child: Container(
                            height: lerpDouble(16.0, 0.0, easedRatio)!,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_upward_rounded,
                                  size: lerpDouble(14.0, 0.0, easedRatio)!,
                                  color: const Color.fromARGB(255, 5, 134, 91), // Emerald 500
                                ),
                                SizedBox(width: lerpDouble(4.0, 0.0, easedRatio)!),
                                Text(
                                  '₹2,491 (0.73%)',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: lerpDouble(10.0, 0.0, easedRatio)!,
                                    fontWeight: FontWeight.w600,
                                    color: const Color.fromARGB(255, 5, 134, 91),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(width: lerpDouble(6.0, 0.0, easedRatio)!),
                                Text(
                                  '1D change',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: lerpDouble(10.0, 0.0, easedRatio)!,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
  bool shouldRebuild(covariant _MfExploreHeaderDelegate oldDelegate) {
    return safeAreaTop != oldDelegate.safeAreaTop;
  }
}
