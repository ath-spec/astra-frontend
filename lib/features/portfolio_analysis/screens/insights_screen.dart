import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:math' as math;
import '../../../core/widgets/typewriter_text.dart';
import '../../fund_profile/screens/your_fund_profile_screen.dart';

class InsightsScreen extends StatefulWidget {
  final int initialInsight;
  const InsightsScreen({super.key, this.initialInsight = 0});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialInsight;
    _pageController = PageController(initialPage: widget.initialInsight);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic scaling capped at 420
    final screenWidth = math.min(MediaQuery.sizeOf(context).width, 420.0);
    final scale = screenWidth / 390.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Full-screen PageView
          Positioned.fill(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification &&
                        notification.metrics.axis == Axis.vertical) {
                      final isScrolled = notification.metrics.pixels > 20;
                      if (isScrolled != _isScrolled) {
                        setState(() => _isScrolled = isScrolled);
                      }
                    }
                    return false;
                  },
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                        _isScrolled =
                            false; // Reset scroll state on page change
                      });
                    },
                    children: [
                      InsightTaxHarvestingView(
                        scale: scale,
                        isActive: _currentIndex == 0,
                      ),
                      InsightIndexFundsView(
                        scale: scale,
                        isActive: _currentIndex == 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: _isScrolled
                    ? Colors.white
                    : (_currentIndex == 0
                          ? const Color(0x00F0FDF4)
                          : const Color(0x00FAF5FF)),
                boxShadow: [
                  BoxShadow(
                    color: _isScrolled
                        ? Colors.black.withOpacity(0.04)
                        : Colors.transparent,
                    blurRadius: 10 * scale,
                    offset: Offset(0, 4 * scale),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 16.0 * scale,
                        left: 16.0 * scale,
                        right: 16.0 * scale,
                        bottom: 12.0 * scale,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Icon(
                              Icons.keyboard_backspace,
                              size: 28 * scale,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 24 * scale),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: _prevPage,
                                child: Container(
                                  width: 40 * scale,
                                  height: 40 * scale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFF1F5F9),
                                    ),
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  child: Icon(
                                    Icons.chevron_left,
                                    size: 20 * scale,
                                    color: _currentIndex > 0
                                        ? Colors.black
                                        : Colors.black26,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    'INSIGHT ${_currentIndex + 1} of 2',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 10 * scale,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  SizedBox(height: 4 * scale),
                                  Text(
                                    'ALLOCATION',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 12 * scale,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: _nextPage,
                                child: Container(
                                  width: 40 * scale,
                                  height: 40 * scale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFF1F5F9),
                                    ),
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  child: Icon(
                                    Icons.chevron_right,
                                    size: 20 * scale,
                                    color: _currentIndex < 1
                                        ? Colors.black
                                        : Colors.black26,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Tax Harvesting View (Insight 1)
// -----------------------------------------------------------------------------
class InsightTaxHarvestingView extends StatefulWidget {
  final double scale;
  final bool isActive;
  const InsightTaxHarvestingView({
    super.key,
    required this.scale,
    required this.isActive,
  });

  @override
  State<InsightTaxHarvestingView> createState() =>
      _InsightTaxHarvestingViewState();
}

class _InsightTaxHarvestingViewState extends State<InsightTaxHarvestingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _barFillAnim;
  late Animation<double> _calloutScaleAnim;
  bool _isCTAVisible = false;

  final GlobalKey _inlineButtonKey = GlobalKey();
  final GlobalKey _stickyButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Staggered animations per Emil Kowalski principles
    // Bar fills up smoothly
    _barFillAnim = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.8, curve: Cubic(0.23, 1, 0.32, 1)),
      ),
    );

    // Callout pops in after bar starts filling
    _calloutScaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.6, 1.0, curve: Cubic(0.23, 1, 0.32, 1)),
      ),
    );

    if (widget.isActive) {
      _animController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant InsightTaxHarvestingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return Stack(
      children: [
        Positioned.fill(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              final inlineBox =
                  _inlineButtonKey.currentContext?.findRenderObject()
                      as RenderBox?;
              final stickyBox =
                  _stickyButtonKey.currentContext?.findRenderObject()
                      as RenderBox?;
              if (inlineBox != null && stickyBox != null) {
                final inlinePos = inlineBox.localToGlobal(Offset.zero);
                final stickyPos = stickyBox.localToGlobal(Offset.zero);
                final shouldHideSticky = inlinePos.dy <= stickyPos.dy;
                if (_isCTAVisible != shouldHideSticky) {
                  setState(() => _isCTAVisible = shouldHideSticky);
                }
              }
              return false;
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 46 * s),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: MediaQuery.sizeOf(context).height * 0.4,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF0FDF4), Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0 * s),
                      child: Column(
                        children: [
                          SizedBox(height: 140 * s),
                          // 3D Illustration Placeholder / Drawing
                          SizedBox(
                            height: 120 * s,
                            width: 160 * s,
                            child: Image.asset(
                              'lib/core/images/insight1.webp',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 32 * s),

                          // Gradient Title
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF0F766E), Color.fromARGB(255, 16, 220, 203)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              'Save tax on your gains\n(Tax Harvesting)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white, // Masked
                              ),
                            ),
                          ),
                          SizedBox(height: 16 * s),

                          Text(
                            'Some of your long-term gains are within\nthe tax-free limit. You can book them now\nand reinvest right away.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14 * s,
                              color: const Color(0xFF64748B),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 32 * s),

                          Text(
                            'AVAILABLE GAINS STOCK',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10 * s,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          SizedBox(height: 8 * s),

                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(bounds),
                            child: Text(
                              '₹ 11,984',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 4 * s),
                          Text(
                            'Within your annual ₹1.25L LTCG limit',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 12 * s,
                              color: const Color(0xFF64748B),
                            ),
                          ),

                          SizedBox(height: 32 * s),

                          // Sleek 3D Animated Bar Graph
                          SizedBox(
                            height: 120 * s,
                            child: AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                final barHeight = 44 * s;
                                final fullWidth =
                                    MediaQuery.sizeOf(context).width -
                                    (48 * s); // padding
                                final fillWidth =
                                    (fullWidth - (3 * s)) *
                                    0.25 *
                                    _barFillAnim.value; // ~25% fill
                                final calloutWidth = 90 * s;

                                return Stack(
                                  alignment: Alignment.topLeft,
                                  clipBehavior: Clip.none,
                                  children: [
                                    // True 3D Solid Bar
                                    SizedBox(
                                      width: fullWidth,
                                      height:
                                          barHeight +
                                          (4 *
                                              s), // account for 3D bottom extrusion
                                      child: CustomPaint(
                                        painter: _Horizontal3DBarPainter(
                                          fillPercentage:
                                              0.25 * _barFillAnim.value,
                                          scale: s,
                                        ),
                                      ),
                                    ),

                                    // Connecting line from bar to callout
                                    Positioned(
                                      left: fillWidth,
                                      top:
                                          barHeight +
                                          3 * s, // Connect exactly to bottom edge of 3D shadow
                                      child: Opacity(
                                        opacity:
                                            (_calloutScaleAnim.value < 0.95
                                                    ? 0.0
                                                    : (_calloutScaleAnim.value -
                                                              0.95) *
                                                          20)
                                                .clamp(0.0, 1.0),
                                        child: Container(
                                          width: 1.5 * s,
                                          height: 8 * s,
                                          color: const Color(0xFF0891B2),
                                        ),
                                      ),
                                    ),

                                    // Callout Bubble
                                    Positioned(
                                      left:
                                          fillWidth -
                                          (calloutWidth / 2) +
                                          (1.5 *
                                              s /
                                              2), // Align exact center of bubble with wire
                                      top:
                                          barHeight +
                                          (4 * s) +
                                          (8 * s), // Bar + dy + wire
                                      child: Opacity(
                                        opacity:
                                            (_calloutScaleAnim.value < 0.95
                                                    ? 0.0
                                                    : (_calloutScaleAnim.value -
                                                              0.95) *
                                                          20)
                                                .clamp(0.0, 1.0),
                                        child: Transform.scale(
                                          scale: _calloutScaleAnim.value,
                                          alignment: Alignment.topCenter,
                                          child: CustomPaint(
                                            painter: _CalloutBubblePainter(
                                              scale: s,
                                              borderColor: const Color(
                                                0xFF06B6D4,
                                              ),
                                              backgroundColor: Colors.white,
                                            ),
                                            child: SizedBox(
                                              width: calloutWidth,
                                              height:
                                                  48 *
                                                  s, // Enough height for the bubble and notch
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 6 * s,
                                                  ), // Offset for notch
                                                  Text(
                                                    'HARVESTABLE',
                                                    style: TextStyle(
                                                      fontFamily: 'DMSans',
                                                      fontSize: 10 * s,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                      color: const Color(
                                                        0xFF64748B,
                                                      ), // Sleek gray
                                                    ),
                                                  ),
                                                  SizedBox(height: 2 * s),
                                                  Text(
                                                    '9%',
                                                    style: TextStyle(
                                                      fontFamily: 'DMSans',
                                                      fontSize: 12 * s,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                        0xFF0891B2,
                                                      ), // Sleek cyan
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 48 * s),

                          // NEW SECTIONS
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 16 * s,
                                  color: const Color(0xFF0891B2),
                                ),
                                SizedBox(width: 8 * s),
                                Text(
                                  'Why should you harvest now?',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 14 * s,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0891B2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16 * s),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildBenefitCard(
                                    s,
                                    Icons.check_circle_outline,
                                    'Use this year\'s LTCG limit',
                                    'If you do not book ₹1.25L gains, you lose the limit for this year.',
                                  ),
                                  SizedBox(width: 16 * s),
                                  _buildBenefitCard(
                                    s,
                                    Icons.show_chart,
                                    'Stay invested',
                                    'You buy back the same funds instantly. Your wealth continues to compound.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 32 * s),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Here are the eligible holdings',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 14 * s,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: 16 * s),
                          _buildHoldingItem(s),
                          SizedBox(height: 32 * s),

                          // DID YOU KNOW
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 14 * s,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  SizedBox(width: 6 * s),
                                  Text(
                                    'DID YOU KNOW?',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8 * s),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16 * s,
                                  vertical: 10 * s,
                                ),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    231,
                                    251,
                                    250,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      255,
                                      138,
                                      231,
                                      254,
                                    ),
                                  ),
                                ),
                                child: TypewriterText(
                                  text:
                                      'The ₹1.25L tax-free LTCG limit resets every financial year. Unused limits cannot be carried forward.',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 12 * s,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 48 * s),

                          // Inline CTA (above disclaimer)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'NEXT STEP',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 10 * s,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: const Color(0xFF14B8A6),
                                ),
                              ),
                              SizedBox(height: 8 * s),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFF0F766E), Color.fromARGB(255, 16, 220, 203)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: const Text(
                                  'Use your LTCG limit before\nthe year ends',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12 * s),
                              Text(
                                'Choose eligible holdings, harvest gains within\nyour tax bracket, and reinvest with a higher\ntax basis.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 12 * s,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 24 * s),
                              SizedBox(
                                width: double.infinity,
                                height: 56 * s,
                                child: ElevatedButton(
                                  key: _inlineButtonKey,
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        4 * s,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Harvest gains now',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 14 * s,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 42 * s),

                          // Disclaimer
                          Text(
                            'This information is provided for informational purposes only and does not constitute investment advice, a recommendation, or an offer to buy or sell any securities. It is based on standardized methods and may not reflect your individual financial circumstances or risk profile. Consider consulting a financial advisor before making any investment decisions.',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
                              height: 1.5,
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
        ),

        // Sticky CTA Bottom (Fades out when scrolled to bottom)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 0),
            curve: Curves.easeOutCubic,
            opacity: _isCTAVisible ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: _isCTAVisible,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white,
                      Colors.white,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(24 * s, 32 * s, 24 * s, 24 * s),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Optimize your tax liability',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0D9488),
                        ),
                      ),
                      SizedBox(height: 12 * s),
                      SizedBox(
                        width: double.infinity,
                        height: 56 * s,
                        child: ElevatedButton(
                          key: _stickyButtonKey,
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4 * s),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Harvest gains now',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitCard(double s, IconData icon, String title, String desc) {
    return Container(
      width: 200 * s,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFCFFAFE), Colors.white],
        ),
        border: Border.all(color: const Color(0xFFCFFAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8 * s),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF67E8F9)),
            ),
            child: Icon(icon, color: const Color(0xFF0891B2), size: 16 * s),
          ),
          SizedBox(height: 12 * s),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14 * s,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            desc,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12 * s,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingItem(double s) {
    final logoSize = 30.0 * s;
    final badgeSize = 16.0 * s;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const YourFundProfileScreen(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 8 * s),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1.5 * s,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CANARA',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 5.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF06B6D4),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'ROBECO',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 5.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: -2 * s,
                  bottom: -2 * s,
                  child: Container(
                    width: badgeSize,
                    height: badgeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 1.5 * s,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '✱',
                        style: TextStyle(
                          fontSize: 9 * s,
                          color: const Color(0xFFEF4444),
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16 * s),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          'Canara Robeco Large Cap Fund',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      Text(
                        '₹ 14,435',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6 * s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Amount to book ₹ 1,98,784',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      Text(
                        'Tax-Free Gain (LTCG)',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
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

class _TaxBriefcasePainter extends CustomPainter {
  final double scale;
  _TaxBriefcasePainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    // Highly simplified drawing of the briefcase to match visual style
    final paintBase = Paint()
      ..color = const Color(0xFFCCFBF1)
      ..style = PaintingStyle.fill;
    final strokeBase = Paint()
      ..color = const Color(0xFF14B8A6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;

    // Draw base isometric square
    final pathBase = Path()
      ..moveTo(size.width * 0.5, size.height * 0.6)
      ..lineTo(size.width * 0.9, size.height * 0.75)
      ..lineTo(size.width * 0.5, size.height * 0.9)
      ..lineTo(size.width * 0.1, size.height * 0.75)
      ..close();

    canvas.drawPath(pathBase, paintBase);
    canvas.drawPath(pathBase, strokeBase);

    // Draw simple bars inside
    final barFill = Paint()..color = const Color(0xFF5EEAD4);

    final pathBar1 = Path()
      ..moveTo(size.width * 0.4, size.height * 0.65)
      ..lineTo(size.width * 0.5, size.height * 0.69)
      ..lineTo(size.width * 0.5, size.height * 0.3)
      ..lineTo(size.width * 0.4, size.height * 0.26)
      ..close();
    canvas.drawPath(pathBar1, barFill);
    canvas.drawPath(pathBar1, strokeBase);

    final pathBar2 = Path()
      ..moveTo(size.width * 0.55, size.height * 0.7)
      ..lineTo(size.width * 0.65, size.height * 0.74)
      ..lineTo(size.width * 0.65, size.height * 0.45)
      ..lineTo(size.width * 0.55, size.height * 0.41)
      ..close();
    canvas.drawPath(pathBar2, barFill);
    canvas.drawPath(pathBar2, strokeBase);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CalloutBubblePainter extends CustomPainter {
  final double scale;
  final Color borderColor;
  final Color backgroundColor;

  _CalloutBubblePainter({
    required this.scale,
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale;

    final notchWidth = 12.0 * scale;
    final notchHeight = 6.0 * scale;
    final radius = 4.0 * scale;

    final path = Path();
    // Start at top left, after radius
    path.moveTo(radius, notchHeight);

    // Top edge and notch (notch in the exact top center)
    path.lineTo(size.width / 2 - notchWidth / 2, notchHeight);
    path.lineTo(size.width / 2, 0); // notch tip pointing UP
    path.lineTo(size.width / 2 + notchWidth / 2, notchHeight);

    path.lineTo(size.width - radius, notchHeight);
    // Top right corner
    path.arcToPoint(
      Offset(size.width, notchHeight + radius),
      radius: Radius.circular(radius),
    );
    // Right edge
    path.lineTo(size.width, size.height - radius);
    // Bottom right corner
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: Radius.circular(radius),
    );
    // Bottom edge
    path.lineTo(radius, size.height);
    // Bottom left corner
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: Radius.circular(radius),
    );
    // Left edge
    path.lineTo(0, notchHeight + radius);
    // Top left corner
    path.arcToPoint(
      Offset(radius, notchHeight),
      radius: Radius.circular(radius),
    );

    path.close();

    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// Index Funds View (Insight 2)
// -----------------------------------------------------------------------------
class InsightIndexFundsView extends StatefulWidget {
  final double scale;
  final bool isActive;
  const InsightIndexFundsView({
    super.key,
    required this.scale,
    required this.isActive,
  });

  @override
  State<InsightIndexFundsView> createState() => _InsightIndexFundsViewState();
}

class _InsightIndexFundsViewState extends State<InsightIndexFundsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _barFillAnim;
  late Animation<double> _calloutScaleAnim;
  late Animation<double> _targetFadeAnim;
  bool _isCTAVisible = false;

  final GlobalKey _inlineButtonKey = GlobalKey();
  final GlobalKey _stickyButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _targetFadeAnim = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
      ),
    );

    _barFillAnim = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 0.9, curve: Cubic(0.23, 1, 0.32, 1)),
      ),
    );

    _calloutScaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.7, 1.0, curve: Cubic(0.23, 1, 0.32, 1)),
      ),
    );

    if (widget.isActive) {
      _animController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant InsightIndexFundsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return Stack(
      children: [
        Positioned.fill(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              final inlineBox =
                  _inlineButtonKey.currentContext?.findRenderObject()
                      as RenderBox?;
              final stickyBox =
                  _stickyButtonKey.currentContext?.findRenderObject()
                      as RenderBox?;
              if (inlineBox != null && stickyBox != null) {
                final inlinePos = inlineBox.localToGlobal(Offset.zero);
                final stickyPos = stickyBox.localToGlobal(Offset.zero);
                final shouldHideSticky = inlinePos.dy <= stickyPos.dy;
                if (_isCTAVisible != shouldHideSticky) {
                  setState(() => _isCTAVisible = shouldHideSticky);
                }
              }
              return false;
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 46 * s),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: MediaQuery.sizeOf(context).height * 0.4,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFAF5FF), Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0 * s),
                      child: Column(
                        children: [
                          SizedBox(height: 140 * s),
                          // 3D Illustration Placeholder / Drawing
                          SizedBox(
                            height: 120 * s,
                            width: 160 * s,
                            child: Image.asset(
                              'lib/core/images/insight2.webp',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 32 * s),

                          // Main Title
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color.fromARGB(255, 69, 51, 234), Color.fromARGB(255, 132, 152, 252)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              'Add passive funds for\nefficient, low-cost growth',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 24 * s,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 16 * s),
                          Text(
                            'Your portfolio has low exposure to index\nfunds',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 32 * s),
                          SizedBox(height: 32 * s),

                          // Sleek 3D Animated Vertical Bar Graph
                          SizedBox(
                            height: 240 * s,
                            child: AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                final barWidth = 60 * s;
                                final fullHeight = 240 * s;
                                final stackWidth =
                                    MediaQuery.sizeOf(context).width - 48.0 * s;
                                final fillHeight =
                                    fullHeight *
                                    0.15 *
                                    _barFillAnim.value; // ~15% fill
                                final calloutWidth = 90 * s;
                                final currentHeight =
                                    fillHeight; // How high the purple bar goes from the bottom

                                return Center(
                                  child: SizedBox(
                                    width: MediaQuery.sizeOf(context).width,
                                    height: fullHeight,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      clipBehavior: Clip.none,
                                      children: [
                                        // Main Empty Bar (Crisp 3D isometric flat design)
                                        Positioned(
                                          bottom: 0,
                                          child: Container(
                                            width: barWidth,
                                            height: fullHeight,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              border: Border.all(
                                                color: const Color(0xFF94A3B8),
                                                width: 1.0 * s,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFFCBD5E1,
                                                  ),
                                                  offset: Offset(8 * s, 0),
                                                  blurRadius:
                                                      0, // Sharp 3D edge right side
                                                  spreadRadius: 0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Filled Purple Bar
                                        Positioned(
                                          bottom: 0,
                                          child: Container(
                                            width: barWidth,
                                            height: fillHeight,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFC084FC),
                                                  Color(0xFF9333EA),
                                                ], // Sleek purple gradient
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              border: Border.all(
                                                color: const Color(0xFF7E22CE),
                                                width: 1.0 * s,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF7E22CE,
                                                  ),
                                                  offset: Offset(8 * s, 0),
                                                  blurRadius:
                                                      0, // Sharp 3D edge right side for filled part
                                                  spreadRadius: 0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Target Area (Dashed lines and background on the right)
                                        Positioned(
                                          left:
                                              (stackWidth / 2) - (barWidth / 2),
                                          bottom:
                                              fullHeight *
                                              0.65, // Target region start
                                          child: Opacity(
                                            opacity: _targetFadeAnim.value,
                                            child: SizedBox(
                                              height:
                                                  fullHeight *
                                                  0.35, // Target region height
                                              width:
                                                  barWidth + 12 * s + 120 * s,
                                              child: Stack(
                                                children: [
                                                  // Soft glow/background
                                                  Positioned(
                                                    left: barWidth + 8 * s,
                                                    right: 0,
                                                    top: 0,
                                                    bottom: 0,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            const Color(
                                                              0xFFF3E8FF,
                                                            ).withOpacity(0.8),
                                                            Colors.white
                                                                .withOpacity(
                                                                  0.0,
                                                                ),
                                                          ],
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Top dashed line
                                                  Positioned(
                                                    top: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: CustomPaint(
                                                      painter:
                                                          _DashedLinePainter(
                                                            color: const Color(
                                                              0xFF60A5FA,
                                                            ),
                                                          ),
                                                      size: Size(
                                                        double.infinity,
                                                        1 * s,
                                                      ),
                                                    ),
                                                  ),
                                                  // Bottom dashed line
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: CustomPaint(
                                                      painter:
                                                          _DashedLinePainter(
                                                            color: const Color(
                                                              0xFF60A5FA,
                                                            ),
                                                          ),
                                                      size: Size(
                                                        double.infinity,
                                                        1 * s,
                                                      ),
                                                    ),
                                                  ),
                                                  // Target text
                                                  Positioned(
                                                    left: barWidth + 12 * s,
                                                    right: 0,
                                                    top: 0,
                                                    bottom: 0,
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'YOUR TARGET',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'DMSans',
                                                              fontSize: 10 * s,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              letterSpacing:
                                                                  0.5,
                                                              color:
                                                                  const Color(
                                                                    0xFF94A3B8,
                                                                  ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 4 * s,
                                                          ),
                                                          Text(
                                                            '20%-30%',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'DMSans',
                                                              fontSize: 14 * s,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  const Color(
                                                                    0xFFE11D48,
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
                                        ),

                                        // Current Callout Bubble & Line
                                        Positioned(
                                          right:
                                              (stackWidth / 2) +
                                              (barWidth / 2) -
                                              (1.0 *
                                                  s), // Align exactly with left edge of bar
                                          bottom:
                                              currentHeight -
                                              (22 *
                                                  s), // Center vertically with the top of the fill
                                          child: Opacity(
                                            opacity:
                                                (_calloutScaleAnim.value < 0.95
                                                        ? 0.0
                                                        : (_calloutScaleAnim
                                                                      .value -
                                                                  0.95) *
                                                              20)
                                                    .clamp(0.0, 1.0),
                                            child: Transform.scale(
                                              scale: _calloutScaleAnim.value,
                                              alignment: Alignment.centerRight,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CustomPaint(
                                                    painter:
                                                        _HorizontalCalloutBubblePainter(
                                                          scale: s,
                                                          borderColor:
                                                              const Color(
                                                                0xFF7E22CE,
                                                              ),
                                                          backgroundColor:
                                                              Colors.white,
                                                        ),
                                                    child: SizedBox(
                                                      width: calloutWidth,
                                                      height:
                                                          44 *
                                                          s, // Enough height for the bubble
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'CURRENT',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'DMSans',
                                                              fontSize: 10 * s,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              letterSpacing:
                                                                  0.5,
                                                              color: const Color(
                                                                0xFF64748B,
                                                              ), // Sleek gray
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 2 * s,
                                                          ),
                                                          Text(
                                                            '9.0%', // Changed from 0.0 to match the 9% animation
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'DMSans',
                                                              fontSize: 12 * s,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: const Color(
                                                                0xFF7E22CE,
                                                              ), // Sleek purple
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  // Connecting line to the bar
                                                  Container(
                                                    width:
                                                        32 *
                                                        s, // slightly shorter wire
                                                    height: 1.5 * s,
                                                    color: const Color(
                                                      0xFF7E22CE,
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
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 16 * s),

                          Text(
                            'INDEX FUND PORTFOLIO',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10 * s,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          SizedBox(height: 4 * s),
                          Text(
                            '₹0',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 48 * s),

                          // NEW SECTIONS
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 16 * s,
                                  color: const Color(0xFF6B46C1),
                                ),
                                SizedBox(width: 8 * s),
                                Text(
                                  'Why invest in index funds',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 14 * s,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6B46C1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16 * s),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildBenefitCard(
                                    s,
                                    Icons.trending_up,
                                    'Consistent returns',
                                    'Index funds track the market reliably without performance surprises.',
                                  ),
                                  SizedBox(width: 16 * s),
                                  _buildBenefitCard(
                                    s,
                                    Icons.account_balance_wallet,
                                    'Low cost',
                                    'Passive funds have minimal fees, helping you maximize your returns.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 32 * s),

                          // DID YOU KNOW
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 14 * s,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  SizedBox(width: 6 * s),
                                  Text(
                                    'DID YOU KNOW?',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8 * s),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16 * s,
                                  vertical: 10 * s,
                                ),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 245, 232),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Color.fromARGB(255, 255, 250, 232)),
                                ),
                                child: TypewriterText(
                                  text:
                                      'Only ~26% largecap and ~12% mid / smallcap funds beat their index over 10 years',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 12,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 48 * s),

                          Text(
                            'WHAT SHOULD YOU DO?',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10 * s,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: const Color(0xFF6B46C1),
                            ),
                          ),
                          SizedBox(height: 16 * s),
                          Text(
                            'Investing ₹1.23L in index will\nget you to a healthy index\nallocation of 20%',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 22 * s,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 16 * s),

                          // Inline CTA at end of scroll
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 14 * s,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                    height: 1.5,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Add '),
                                    TextSpan(
                                      text: '₹1,23,832',
                                      style: TextStyle(
                                        color: const Color(
                                          0xFF10B981,
                                        ), // Crisp green
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' to increase your index exposure\nto 20%',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12 * s),
                              SizedBox(
                                width: double.infinity,
                                height: 56 * s,
                                child: ElevatedButton(
                                  key: _inlineButtonKey,
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        4 * s,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Invest in the Index',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 12 * s,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32 * s),

                          // Disclaimer (Footer)
                          Text(
                            'This information is provided for informational purposes only and does not constitute investment advice, a recommendation, or an offer to buy or sell any securities. It is based on standardized methods and may not reflect your individual financial circumstances or risk profile. Consider consulting a financial advisor before making any investment decisions.',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10 * s,
                              color: const Color(0xFF94A3B8),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 24 * s),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Sticky CTA Bottom (Fades out when scrolled to bottom)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 0),
            curve: Curves.easeOutCubic,
            opacity: _isCTAVisible ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: _isCTAVisible,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white,
                      Colors.white,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(24 * s, 32 * s, 24 * s, 24 * s),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 169, 169, 169),
                            height: 1.3,
                          ),
                          children: [
                            const TextSpan(text: 'Add '),
                            TextSpan(
                              text: '₹1,23,832',
                              style: TextStyle(
                                color: const Color(0xFF10B981), // Crisp green
                              ),
                            ),
                            const TextSpan(
                              text: ' to increase your index exposure to 20%',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12 * s),
                      SizedBox(
                        width: double.infinity,
                        height: 56 * s,
                        child: ElevatedButton(
                          key: _stickyButtonKey,
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4 * s),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Invest in the Index',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 12 * s,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitCard(double s, IconData icon, String title, String desc) {
    return Container(
      width: 200 * s,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8 * s),
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFF3E8FF), Colors.white],
        ),
        border: Border.all(color: const Color(0xFFFAF5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8 * s),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE9D5FF)),
            ),
            child: Icon(icon, color: const Color(0xFF6B46C1), size: 16 * s),
          ),
          SizedBox(height: 12 * s),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14 * s,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            desc,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12 * s,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _IndexFundsPainter extends CustomPainter {
  final double scale;
  _IndexFundsPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    // Highly simplified drawing of charts/coins to match visual style
    final paintBase = Paint()
      ..color = const Color(0xFFF3E8FF)
      ..style = PaintingStyle.fill;
    final strokeBase = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;

    // Draw base isometric square
    final pathBase = Path()
      ..moveTo(size.width * 0.5, size.height * 0.7)
      ..lineTo(size.width * 0.9, size.height * 0.85)
      ..lineTo(size.width * 0.5, size.height * 1.0)
      ..lineTo(size.width * 0.1, size.height * 0.85)
      ..close();

    canvas.drawPath(pathBase, paintBase);
    canvas.drawPath(pathBase, strokeBase);

    // Draw simple bars inside
    final barFill = Paint()..color = const Color(0xFFC4B5FD);

    final pathBar1 = Path()
      ..moveTo(size.width * 0.65, size.height * 0.75)
      ..lineTo(size.width * 0.75, size.height * 0.79)
      ..lineTo(size.width * 0.75, size.height * 0.3)
      ..lineTo(size.width * 0.65, size.height * 0.26)
      ..close();
    canvas.drawPath(pathBar1, barFill);
    canvas.drawPath(pathBar1, strokeBase);

    // Draw an upward arrow (simplified)
    final arrowFill = Paint()..color = const Color(0xFFF5F3FF);
    final pathArrow = Path()
      ..moveTo(size.width * 0.2, size.height * 0.6)
      ..lineTo(size.width * 0.4, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.6, size.height * 0.2)
      ..lineTo(size.width * 0.45, size.height * 0.2)
      ..lineTo(size.width * 0.5, size.height * 0.4)
      ..lineTo(size.width * 0.4, size.height * 0.3)
      ..close();

    canvas.drawPath(pathArrow, arrowFill);
    canvas.drawPath(pathArrow, strokeBase);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..style = PaintingStyle.stroke;

    var max = size.width;
    var dashWidth = 4.0;
    var dashSpace = 4.0;
    double startX = 0;
    while (startX < max) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _HorizontalCalloutBubblePainter extends CustomPainter {
  final double scale;
  final Color borderColor;
  final Color backgroundColor;

  _HorizontalCalloutBubblePainter({
    required this.scale,
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale;

    final notchWidth = 6.0 * scale;
    final notchHeight = 12.0 * scale;
    final radius = 4.0 * scale;

    final path = Path();
    // Start at top left, after radius
    path.moveTo(radius, 0);

    // Top edge
    path.lineTo(size.width - notchWidth - radius, 0);

    // Top right corner
    path.arcToPoint(
      Offset(size.width - notchWidth, radius),
      radius: Radius.circular(radius),
    );

    // Right edge and notch (notch pointing RIGHT)
    path.lineTo(size.width - notchWidth, size.height / 2 - notchHeight / 2);
    path.lineTo(size.width, size.height / 2); // notch tip pointing RIGHT
    path.lineTo(size.width - notchWidth, size.height / 2 + notchHeight / 2);

    path.lineTo(size.width - notchWidth, size.height - radius);

    // Bottom right corner
    path.arcToPoint(
      Offset(size.width - notchWidth - radius, size.height),
      radius: Radius.circular(radius),
    );
    // Bottom edge
    path.lineTo(radius, size.height);
    // Bottom left corner
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: Radius.circular(radius),
    );
    // Left edge
    path.lineTo(0, radius);
    // Top left corner
    path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));

    path.close();

    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Horizontal3DBarPainter extends CustomPainter {
  final double fillPercentage;
  final double scale;

  _Horizontal3DBarPainter({required this.fillPercentage, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final dx = 3.0 * scale;
    final dy = 4.0 * scale;

    // Front face is smaller to leave room for the 3D extrusion on bottom and right
    final frontRect = Rect.fromLTWH(0, 0, size.width - dx, size.height - dy);

    // Draw Empty Box
    // Right Face
    final emptyRightFace = Path()
      ..moveTo(frontRect.right, frontRect.top)
      ..lineTo(frontRect.right + dx, frontRect.top + dy)
      ..lineTo(frontRect.right + dx, frontRect.bottom + dy)
      ..lineTo(frontRect.right, frontRect.bottom)
      ..close();

    // Bottom Face
    final emptyBottomFace = Path()
      ..moveTo(frontRect.left, frontRect.bottom)
      ..lineTo(frontRect.right, frontRect.bottom)
      ..lineTo(frontRect.right + dx, frontRect.bottom + dy)
      ..lineTo(frontRect.left + dx, frontRect.bottom + dy)
      ..close();

    final emptyFill = Paint()..color = Colors.white;
    final emptyFaceFill = Paint()
      ..color = const Color(0xFFF1F5F9); // Lighter gray for 3D faces
    final stroke = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * scale
      ..strokeJoin = StrokeJoin.round;

    // Draw empty faces
    canvas.drawPath(emptyRightFace, emptyFaceFill);
    canvas.drawPath(emptyRightFace, stroke);

    canvas.drawPath(emptyBottomFace, emptyFaceFill);
    canvas.drawPath(emptyBottomFace, stroke);

    // Draw empty front
    canvas.drawRect(frontRect, emptyFill);
    canvas.drawRect(frontRect, stroke);

    // Draw Filled Box (Cyan)
    if (fillPercentage > 0) {
      final fillWidth = frontRect.width * fillPercentage;
      final fillRect = Rect.fromLTWH(0, 0, fillWidth, frontRect.height);

      final fillRightFace = Path()
        ..moveTo(fillRect.right, fillRect.top)
        ..lineTo(fillRect.right + dx, fillRect.top + dy)
        ..lineTo(fillRect.right + dx, fillRect.bottom + dy)
        ..lineTo(fillRect.right, fillRect.bottom)
        ..close();

      final fillBottomFace = Path()
        ..moveTo(fillRect.left, fillRect.bottom)
        ..lineTo(fillRect.right, fillRect.bottom)
        ..lineTo(fillRect.right + dx, fillRect.bottom + dy)
        ..lineTo(fillRect.left + dx, fillRect.bottom + dy)
        ..close();

      final fillFacePaint = Paint()
        ..color = const Color(0xFF0891B2); // Darker cyan for faces
      final fillStroke = Paint()
        ..color =
            const Color(0xFF0E7490) // Even darker stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 * scale
        ..strokeJoin = StrokeJoin.round;

      // Gradient for front face
      final fillGradient = const LinearGradient(
        colors: [Color(0xFF67E8F9), Color(0xFF06B6D4)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(fillRect);

      final fillFrontPaint = Paint()..shader = fillGradient;

      canvas.drawPath(fillRightFace, fillFacePaint);
      canvas.drawPath(fillRightFace, fillStroke);

      canvas.drawPath(fillBottomFace, fillFacePaint);
      canvas.drawPath(fillBottomFace, fillStroke);

      canvas.drawRect(fillRect, fillFrontPaint);
      canvas.drawRect(fillRect, fillStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _Horizontal3DBarPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.scale != scale;
  }
}
