import 'dart:ui' show lerpDouble, ImageFilter;
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/arch_background.dart';
import '../../asset_connection/providers/asset_connection_provider.dart';
import '../../../core/providers/nav_context_provider.dart';
import '../../../core/providers/privacy_provider.dart';
import '../../../core/utils/privacy_formatter.dart';

import '../widgets/home_portfolio_insights.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/home_astra_intelligence.dart';
import '../widgets/home_grow_wealth.dart';
import '../widgets/home_explore_more.dart';
import '../widgets/home_order_cards.dart';
import '../widgets/home_portfolio_analysis.dart';
import 'package:astra_frontend/features/home/widgets/home_portfolio_growth.dart';
import 'package:astra_frontend/features/home/widgets/budget_section.dart';
import 'package:astra_frontend/features/home/widgets/recurring_section.dart';

/// Screen 4: New Home Screen / Dashboard (Image 4) in clean light mode.
/// Displays user wealth header, portfolio chart card, asset status list (with FETCHING status),
/// and floating pill bottom navigation bar.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isSecondCardStacked = ValueNotifier(false);
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _isSecondCardStacked.addListener(() {
      if (_isSecondCardStacked.value && !_showFab) {
        setState(() => _showFab = true);
      } else if (!_isSecondCardStacked.value && _showFab) {
        setState(() => _showFab = false);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.stop();
    _pulseController.dispose();
    _scrollController.dispose();
    _isSecondCardStacked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetState = ref.watch(assetConnectionProvider);
    final isLocked = ref.watch(privacyProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final double totalWealthValue = (assetState.mfConnected ? 352962.0 : 0.0) + (assetState.stocksConnected ? 147908.0 : 0.0);
    final formattedTotal = PrivacyFormatter.obscure(
      totalWealthValue == 0 ? '₹0' : '₹${NumberFormat('#,##,###').format(totalWealthValue)}',
      isLocked
    ); 

    final bool showReturnsPill = assetState.mfConnected || assetState.stocksConnected;
    String pillOneDayText = '';
    String pillTotalText = '';

    if (assetState.mfConnected && assetState.stocksConnected) {
      pillOneDayText = '↑ ₹3,402 (0.65%) 1D change';
      pillTotalText = '↑ ₹67,960 (13.50%) Total Returns';
    } else if (assetState.mfConnected) {
      pillOneDayText = '↑ ₹2,202 (0.62%) 1D change';
      pillTotalText = '↑ ₹52,960 (17.65%) Total Returns';
    } else if (assetState.stocksConnected) {
      pillOneDayText = '↑ ₹1,200 (0.81%) 1D change';
      pillTotalText = '↑ ₹15,000 (10.14%) Total Returns';
    }

    if (assetState.step == AssetConnectionStep.banksLinkingProgress) {
      if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
    } else {
      if (_pulseController.isAnimating) _pulseController.stop();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Sit above the navigation bar
        child: AnimatedScale(
          scale: _showFab ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          curve: const Cubic(0.23, 1, 0.32, 1),
          child: AnimatedOpacity(
            opacity: _showFab ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            curve: const Cubic(0.23, 1, 0.32, 1),
            child: SizedBox(
              width: 40,
              height: 40,
              child: FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: const Cubic(0.23, 1, 0.32, 1),
                  );
                },
                backgroundColor: const Color(0xFF0F172A),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, minHeight: double.infinity), // Max width for tablet/web, full height
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HomeHeaderDelegate(
              safeAreaTop: MediaQuery.of(context).padding.top,
              totalWealth: formattedTotal,
              showReturnsPill: showReturnsPill,
              pillOneDayText: pillOneDayText,
              pillTotalText: pillTotalText,
              isLocked: isLocked,
              onProfileTap: () => context.push('/user-profile'),
              onLockTap: () => ref.read(privacyProvider.notifier).state = !isLocked,
            ),
          ),
          // 1. Main content with consistent horizontal padding
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                
                // Asset List
                
                if (assetState.mfConnected)
                  _buildConnectedAssetRow(
                    icon: Icons.signal_cellular_alt_rounded,
                    title: 'Mutual Funds',
                    percentage: '67.9%',
                    amount: PrivacyFormatter.obscure('₹3,52,962', isLocked),
                    subtitle: PrivacyFormatter.obscure('↑ ₹52.96K (17.65%) Returns', isLocked),
                    subtitleColor: const Color(0xFF22C55E),
                    onTap: () {
                      ref.read(navContextProvider.notifier).state = NavContext.mf;
                      context.go('/mf');
                    },
                  )
                else
                  _buildAssetRow(
                    icon: Icons.bar_chart_rounded,
                    title: 'Mutual Funds',
                    buttonText: 'Import',
                    onPressed: () => context.push('/mf-fetch-confirm'),
                  ),
                _buildDottedDivider(),
                
                if (assetState.stocksConnected)
                  _buildConnectedAssetRow(
                    icon: Icons.candlestick_chart_rounded,
                    title: 'Stocks',
                    percentage: '32.1%',
                    amount: PrivacyFormatter.obscure('₹1,47,908', isLocked),
                    subtitle: PrivacyFormatter.obscure('↑ ₹16.7K (12.7%) Returns', isLocked),
                    subtitleColor: const Color(0xFF22C55E),
                    onTap: () {
                      context.push('/stocks');
                    },
                  )
                else
                  _buildAssetRow(
                    icon: Icons.candlestick_chart_rounded,
                    title: 'Stocks',
                    buttonText: 'Import',
                    onPressed: () => context.push('/aa-stocks-otp'),
                  ),
                _buildDottedDivider(),
                
                if (assetState.banksConnected)
                  _buildConnectedAssetRow(
                    icon: Icons.account_balance_rounded,
                    title: 'Bank Accounts',
                    percentage: '3.7%',
                    amount: '₹19,544',
                    onTap: () {
                      context.push('/linked-bank-accounts');
                    },
                  )
                else
                  _buildBankAccountsRow(
                    isLinked: false,
                    isLinking: assetState.step == AssetConnectionStep.banksLinkingProgress,
                  ),
                
                const SizedBox(height: 40),
                const HomePortfolioInsights(),
                
                const SizedBox(height: 48),
                const HomePortfolioAnalysis(),
                
                const SizedBox(height: 48),
                const HomeQuickActions(),
                
              ]),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
          // 4. Edge-to-edge Portfolio Growth Graph
          if (assetState.mfConnected || assetState.stocksConnected)
            SliverToBoxAdapter(
              child: HomePortfolioGrowth(
                mfConnected: assetState.mfConnected,
                stocksConnected: assetState.stocksConnected,
              ),
            ),


          const SliverToBoxAdapter(
            child: BudgetSection(),
          ),

          const SliverToBoxAdapter(
            child: RecurringSection(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 140 + bottomPadding), // Extra padding for AppShell nav bar
          ),
        ],
      ),
    ),
      ),
    );
  }

  Widget _buildConnectedAssetRow({
    required IconData icon,
    required String title,
    required String percentage,
    required String amount,
    String? subtitle,
    Color subtitleColor = const Color(0xFF64748B),
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF0F172A), size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: subtitle != null ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    percentage,
                    style: const TextStyle(
                      fontFamily: 'DMMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: subtitle != null ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      amount,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: subtitleColor,
                      letterSpacing: 0,
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetRow({
    required IconData icon,
    required String title,
    required String buttonText,
    required VoidCallback onPressed,
    bool isLinked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'DMSans',
                color: Color(0xFF0F172A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isLinked ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
              foregroundColor: isLinked ? const Color(0xFF0F172A) : Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: isLinked
                    ? const BorderSide(color: Color(0xFFCBD5E1))
                    : BorderSide.none,
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurplusRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF64748B), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Surplus',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                    children: [
                      TextSpan(text: 'Earn '),
                      TextSpan(
                        text: '2.5x',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(text: ' on your idle money'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Surplus idle money management coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Explore',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountsRow({required bool isLinked, required bool isLinking}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: GestureDetector(
        onTap: () {
          if (isLinked) {
            context.push('/linked-bank-accounts');
          } else {
            context.push('/banks-linking');
          }
        },
        child: Row(
          children: [
            const Icon(Icons.account_balance_rounded, color: Color(0xFF64748B), size: 24),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Bank Accounts',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
              if (isLinked)
                const SizedBox() // Handled by _buildConnectedAssetRow now
              else if (isLinking)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: const Text(
                      '• • •',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'FETCHING',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Import',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDottedDivider() {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DottedLinePainter(),
    );
  }
}

/// Dotted horizontal line separator
class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    double startX = 0;
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double safeAreaTop;
  final String totalWealth;
  final bool showReturnsPill;
  final String pillOneDayText;
  final String pillTotalText;
  final VoidCallback onProfileTap;
  final VoidCallback onLockTap;
  final bool isLocked;

  _HomeHeaderDelegate({
    required this.safeAreaTop,
    required this.totalWealth,
    required this.showReturnsPill,
    required this.pillOneDayText,
    required this.pillTotalText,
    required this.onProfileTap,
    required this.onLockTap,
    required this.isLocked,
  });

  @override
  double get minExtent => safeAreaTop + 84.0;

  @override
  double get maxExtent => safeAreaTop + 260.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 0.0 when fully expanded, 1.0 when fully collapsed
    final shrinkRatio = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    // Use an ease-in-out curve for the transition to make it feel organic (Emil style)
    final curve = Curves.easeInOutCubic;
    final double easedRatio = curve.transform(shrinkRatio);

    // Layout Interpolations
    final double startTop = maxExtent - 124.0; // Keep the text at the same visual height (260 - 124 = 136)
    final double endTop = safeAreaTop + 18.0; // Vertically centered with 44px buttons
    final double currentTop = lerpDouble(startTop, endTop, easedRatio)!;

    final double startSubtitleTop = startTop - 26.0;
    final double endSubtitleTop = endTop - 40.0;
    final double currentSubtitleTop = lerpDouble(startSubtitleTop, endSubtitleTop, easedRatio)!;

    // Style Interpolations
    final double currentFontSize = lerpDouble(36.0, 14.0, easedRatio)!;
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
        fit: StackFit.expand,
        children: [
          // Background Arch - fades out
          Positioned(
            top: -shrinkOffset * 0.5,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 1.0 - shrinkRatio,
              child: const ArchBackground(height: 250),
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

          // Subtitle "ABHIMANYU'S WEALTH"
          Positioned(
            top: currentSubtitleTop,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: (1.0 - (shrinkRatio * 2.5)).clamp(0.0, 1.0), // Fades out quickly
              child: const Center(
                child: Text(
                  "ABHIMANYU'S WEALTH",
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      totalWealth,
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        color: const Color(0xFF0F172A),
                        fontSize: currentFontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: lerpDouble(-1.0, 0.0, easedRatio)!,
                        height: 1.1,
                      ),
                    ),
                    // Shrinking Refresh Icon
                    if (shrinkRatio < 1.0) ...[
                      SizedBox(width: lerpDouble(12.0, 0.0, easedRatio)!),
                      Opacity(
                        opacity: (1.0 - (shrinkRatio * 2)).clamp(0.0, 1.0),
                        child: Container(
                          width: lerpDouble(28.0, 0.0, easedRatio)!,
                          height: lerpDouble(28.0, 0.0, easedRatio)!,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 1.2,
                            ),
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

          // Returns Pill below the wealth number
          if (shrinkRatio < 1.0 && showReturnsPill)
            Positioned(
              top: currentTop + 64.0, // Move it further down so it never covers the text
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: _ReturnsPill(
                  opacity: (1.0 - (shrinkRatio * 3.0)).clamp(0.0, 1.0),
                  oneDayText: pillOneDayText,
                  totalText: pillTotalText,
                ),
              ),
            ),

          // Top Row (Profile, Lock)
          Positioned(
            top: safeAreaTop + 12.0,
            left: 24.0,
            right: 24.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF0F172A),
                      size: 22,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onLockTap,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                      color: const Color(0xFF0F172A),
                      size: 20,
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
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) {
    return safeAreaTop != oldDelegate.safeAreaTop || 
           totalWealth != oldDelegate.totalWealth ||
           showReturnsPill != oldDelegate.showReturnsPill ||
           pillOneDayText != oldDelegate.pillOneDayText ||
           pillTotalText != oldDelegate.pillTotalText;
  }
}

class _ReturnsPill extends StatefulWidget {
  final double opacity;
  final String oneDayText;
  final String totalText;
  
  const _ReturnsPill({
    required this.opacity,
    required this.oneDayText,
    required this.totalText,
  });

  @override
  State<_ReturnsPill> createState() => _ReturnsPillState();
}

class _ReturnsPillState extends State<_ReturnsPill> {
  bool _showOneDay = true;

  @override
  Widget build(BuildContext context) {
    if (widget.opacity <= 0.01) return const SizedBox.shrink();
    
    return Opacity(
      opacity: widget.opacity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _showOneDay = !_showOneDay;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, childWidget) {
                      final isCurrent = childWidget?.key == ValueKey(_showOneDay);
                      final angle = isCurrent 
                          ? (1.0 - animation.value) * -pi / 2 
                          : (1.0 - animation.value) * pi / 2;
                      
                      return FadeTransition(
                        opacity: animation,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.002)
                            ..rotateX(angle),
                          alignment: Alignment.center,
                          child: childWidget,
                        ),
                      );
                    },
                    child: child,
                  );
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _showOneDay ? widget.oneDayText : widget.totalText,
                    key: ValueKey<bool>(_showOneDay),
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.unfold_more_rounded,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

