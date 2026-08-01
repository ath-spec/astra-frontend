import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class InsightsScreen extends StatefulWidget {
  final int initialInsight;
  const InsightsScreen({super.key, this.initialInsight = 0});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

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
    final screenWidth = math.min(MediaQuery.of(context).size.width, 420.0);
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
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  children: [
                    InsightTaxHarvestingView(scale: scale, isActive: _currentIndex == 0),
                    InsightIndexFundsView(scale: scale, isActive: _currentIndex == 1),
                  ],
                ),
              ),
            ),
          ),

          // Floating Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
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
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Icon(Icons.arrow_back, size: 24 * scale),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _prevPage,
                              child: Container(
                                padding: EdgeInsets.all(4 * scale),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFF1F5F9)),
                                  color: Colors.white.withOpacity(0.8), // subtle background for readability
                                ),
                                child: Icon(Icons.chevron_left, size: 16 * scale, color: _currentIndex > 0 ? Colors.black : Colors.black26),
                              ),
                            ),
                            SizedBox(width: 16 * scale),
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
                            SizedBox(width: 16 * scale),
                            GestureDetector(
                              onTap: _nextPage,
                              child: Container(
                                padding: EdgeInsets.all(4 * scale),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFF1F5F9)),
                                  color: Colors.white.withOpacity(0.8), // subtle background
                                ),
                                child: Icon(Icons.chevron_right, size: 16 * scale, color: _currentIndex < 1 ? Colors.black : Colors.black26),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 24 * scale), // Balance the back button
                    ],
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
  const InsightTaxHarvestingView({super.key, required this.scale, required this.isActive});

  @override
  State<InsightTaxHarvestingView> createState() => _InsightTaxHarvestingViewState();
}

class _InsightTaxHarvestingViewState extends State<InsightTaxHarvestingView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _barFillAnim;
  late Animation<double> _calloutScaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    
    // Staggered animations per Emil Kowalski principles
    // Bar fills up smoothly
    _barFillAnim = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.2, 0.8, curve: Cubic(0.23, 1, 0.32, 1))),
    );
    
    // Callout pops in after bar starts filling
    _calloutScaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.6, 1.0, curve: Cubic(0.23, 1, 0.32, 1))),
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
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0 * s),
        child: Column(
          children: [
            SizedBox(height: 64 * s),
          // 3D Illustration Placeholder / Drawing
          SizedBox(
            height: 120 * s,
            width: 160 * s,
            child: CustomPaint(painter: _TaxBriefcasePainter(scale: s)),
          ),
          SizedBox(height: 32 * s),
          
          // Gradient Title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Save tax on your gains\n(Tax Harvesting)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 22 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white, // Masked
                height: 1.2,
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
              fontWeight: FontWeight.w700,
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
              '₹11,984',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 28 * s,
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
          Expanded(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final barHeight = 44 * s;
                final fullWidth = MediaQuery.of(context).size.width - (48 * s); // padding
                final fillWidth = (fullWidth - (3 * s)) * 0.25 * _barFillAnim.value; // ~25% fill
                final calloutWidth = 90 * s;

                return Stack(
                  alignment: Alignment.topLeft,
                  clipBehavior: Clip.none,
                  children: [
                    // True 3D Solid Bar
                    SizedBox(
                      width: fullWidth,
                      height: barHeight + (4 * s), // account for 3D bottom extrusion
                      child: CustomPaint(
                        painter: _Horizontal3DBarPainter(
                          fillPercentage: 0.25 * _barFillAnim.value,
                          scale: s,
                        ),
                      ),
                    ),

                    // Connecting line from bar to callout
                    Positioned(
                      left: fillWidth,
                      top: barHeight + 3 * s, // Connect exactly to bottom edge of 3D shadow
                      child: Opacity(
                        opacity: (_calloutScaleAnim.value < 0.95 ? 0.0 : (_calloutScaleAnim.value - 0.95) * 20).clamp(0.0, 1.0),
                        child: Container(
                          width: 1.5 * s,
                          height: 8 * s,
                          color: const Color(0xFF0891B2),
                        ),
                      ),
                    ),

                    // Callout Bubble
                    Positioned(
                      left: fillWidth - (calloutWidth / 2) + (1.5 * s / 2), // Align exact center of bubble with wire
                      top: barHeight + (4 * s) + (8 * s), // Bar + dy + wire
                      child: Opacity(
                        opacity: (_calloutScaleAnim.value < 0.95 ? 0.0 : (_calloutScaleAnim.value - 0.95) * 20).clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: _calloutScaleAnim.value,
                          alignment: Alignment.topCenter,
                          child: CustomPaint(
                            painter: _CalloutBubblePainter(
                              scale: s,
                              borderColor: const Color(0xFF06B6D4),
                              backgroundColor: Colors.white,
                            ),
                            child: SizedBox(
                              width: calloutWidth,
                              height: 48 * s, // Enough height for the bubble and notch
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 6 * s), // Offset for notch
                                  Text(
                                    'HARVESTABLE',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 8 * s,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: const Color(0xFF64748B), // Sleek gray
                                    ),
                                  ),
                                  SizedBox(height: 2 * s),
                                  Text(
                                    '9%',
                                    style: TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontSize: 12 * s,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0891B2), // Sleek cyan
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
          
          SizedBox(height: 24 * s),
          Text(
            'Optimize your tax liability',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14 * s,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0D9488),
            ),
          ),
          SizedBox(height: 16 * s),
          
          SizedBox(
            width: double.infinity,
            height: 56 * s,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4 * s)),
                elevation: 0,
              ),
              child: Text(
                'Harvest gains now',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 16 * s),
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
    final paintBase = Paint()..color = const Color(0xFFCCFBF1)..style = PaintingStyle.fill;
    final strokeBase = Paint()..color = const Color(0xFF14B8A6)..style = PaintingStyle.stroke..strokeWidth = 2 * scale;
    
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
    path.arcToPoint(Offset(size.width, notchHeight + radius), radius: Radius.circular(radius));
    // Right edge
    path.lineTo(size.width, size.height - radius);
    // Bottom right corner
    path.arcToPoint(Offset(size.width - radius, size.height), radius: Radius.circular(radius));
    // Bottom edge
    path.lineTo(radius, size.height);
    // Bottom left corner
    path.arcToPoint(Offset(0, size.height - radius), radius: Radius.circular(radius));
    // Left edge
    path.lineTo(0, notchHeight + radius);
    // Top left corner
    path.arcToPoint(Offset(radius, notchHeight), radius: Radius.circular(radius));
    
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
  const InsightIndexFundsView({super.key, required this.scale, required this.isActive});

  @override
  State<InsightIndexFundsView> createState() => _InsightIndexFundsViewState();
}

class _InsightIndexFundsViewState extends State<InsightIndexFundsView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _barFillAnim;
  late Animation<double> _calloutScaleAnim;
  late Animation<double> _targetFadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    
    _targetFadeAnim = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );
    
    _barFillAnim = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.3, 0.9, curve: Cubic(0.23, 1, 0.32, 1))),
    );
    
    _calloutScaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.7, 1.0, curve: Cubic(0.23, 1, 0.32, 1))),
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
        // Faint purple background gradient stripes placeholder
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFAF5FF), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.4],
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
                SizedBox(height: 64 * s),
              // 3D Illustration Placeholder / Drawing
              SizedBox(
                height: 120 * s,
                width: 160 * s,
                child: CustomPaint(painter: _IndexFundsPainter(scale: s)),
              ),
              SizedBox(height: 32 * s),
              
              // Gradient Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 22 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.2,
                  ),
                  children: [
                    const TextSpan(text: 'Add '),
                    WidgetSpan(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF6B46C1), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'passive funds',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 22 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ' for\nefficient, '),
                    WidgetSpan(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF6B46C1), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'low-cost growth',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 22 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16 * s),
              
              Text(
                'Your portfolio has low exposure to index funds',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14 * s,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 32 * s),
              
              // Sleek 3D Animated Vertical Bar Graph
              Expanded(
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    final barWidth = 60 * s;
                    final fullHeight = 240 * s;
                    final fillHeight = fullHeight * 0.15 * _barFillAnim.value; // ~15% fill
                    final calloutWidth = 90 * s;
                    final currentHeight = fillHeight; // How high the purple bar goes from the bottom

                    return Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: fullHeight,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          clipBehavior: Clip.none,
                          children: [
                            // Target Area (Dashed lines and background on the right)
                            Positioned(
                              left: (MediaQuery.of(context).size.width / 2) + (barWidth / 2) + 4 * s,
                              bottom: fullHeight * 0.45, // Target region start
                              child: Opacity(
                                opacity: _targetFadeAnim.value,
                                child: SizedBox(
                                  height: fullHeight * 0.35, // Target region height
                                  width: 120 * s,
                                  child: Stack(
                                    children: [
                                      // Soft glow/background
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFFF3E8FF).withOpacity(0.8),
                                              Colors.white.withOpacity(0.0)
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                        ),
                                      ),
                                      // Top dashed line
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        child: CustomPaint(
                                          painter: _DashedLinePainter(color: const Color(0xFF60A5FA)),
                                          size: Size(double.infinity, 1 * s),
                                        ),
                                      ),
                                      // Bottom dashed line
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: CustomPaint(
                                          painter: _DashedLinePainter(color: const Color(0xFF60A5FA)),
                                          size: Size(double.infinity, 1 * s),
                                        ),
                                      ),
                                      // Target text
                                      Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'YOUR TARGET',
                                              style: TextStyle(
                                                fontFamily: 'DMSans',
                                                fontSize: 8 * s,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                                color: const Color(0xFF94A3B8),
                                              ),
                                            ),
                                            SizedBox(height: 4 * s),
                                            Text(
                                              '20%-30%',
                                              style: TextStyle(
                                                fontFamily: 'SpaceGrotesk',
                                                fontSize: 14 * s,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFFE11D48),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Main Empty Bar (Crisp 3D isometric flat design)
                            Positioned(
                              bottom: 0,
                              child: Container(
                                width: barWidth,
                                height: fullHeight,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  border: Border.all(color: const Color(0xFF94A3B8), width: 1.0 * s),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFCBD5E1),
                                      offset: Offset(4 * s, 0),
                                      blurRadius: 0, // Sharp 3D edge right side
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
                                    colors: [Color(0xFFC084FC), Color(0xFF9333EA)], // Sleek purple gradient
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  border: Border.all(color: const Color(0xFF7E22CE), width: 1.0 * s),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7E22CE),
                                      offset: Offset(4 * s, 0),
                                      blurRadius: 0, // Sharp 3D edge right side for filled part
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Current Callout Bubble & Line
                            Positioned(
                              right: (MediaQuery.of(context).size.width / 2) + (barWidth / 2) - (1.0 * s), // Align exactly with left edge of bar
                              bottom: currentHeight - (18 * s), // Center vertically with the top of the fill
                              child: Opacity(
                                opacity: (_calloutScaleAnim.value < 0.95 ? 0.0 : (_calloutScaleAnim.value - 0.95) * 20).clamp(0.0, 1.0),
                                child: Transform.scale(
                                  scale: _calloutScaleAnim.value,
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomPaint(
                                        painter: _HorizontalCalloutBubblePainter(
                                          scale: s,
                                          borderColor: const Color(0xFF7E22CE),
                                          backgroundColor: Colors.white,
                                        ),
                                        child: SizedBox(
                                          width: calloutWidth,
                                          height: 44 * s, // Enough height for the bubble
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'CURRENT',
                                                style: TextStyle(
                                                  fontFamily: 'DMSans',
                                                  fontSize: 8 * s,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                  color: const Color(0xFF64748B), // Sleek gray
                                                ),
                                              ),
                                              SizedBox(height: 2 * s),
                                              Text(
                                                '9.0%', // Changed from 0.0 to match the 9% animation
                                                style: TextStyle(
                                                  fontFamily: 'SpaceGrotesk',
                                                  fontSize: 12 * s,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF7E22CE), // Sleek purple
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Connecting line to the bar
                                      Container(
                                        width: 32 * s, // slightly shorter wire
                                        height: 1.5 * s,
                                        color: const Color(0xFF7E22CE),
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
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              SizedBox(height: 4 * s),
              Text(
                '₹0',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 28 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 24 * s),
              
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12 * s,
                    color: const Color(0xFF64748B),
                  ),
                  children: [
                    const TextSpan(text: 'Invest '),
                    TextSpan(
                      text: '₹86,281',
                      style: TextStyle(
                        color: const Color(0xFF059669),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' in index funds to move towards the 20%-30%\nrange'),
                  ],
                ),
              ),
              SizedBox(height: 16 * s),
              
              SizedBox(
                width: double.infinity,
                height: 56 * s,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4 * s)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Invest in the Index',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16 * s),
            ],
          ),
         ),
        ),
      ],
    );
  }
}

class _IndexFundsPainter extends CustomPainter {
  final double scale;
  _IndexFundsPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    // Highly simplified drawing of charts/coins to match visual style
    final paintBase = Paint()..color = const Color(0xFFF3E8FF)..style = PaintingStyle.fill;
    final strokeBase = Paint()..color = const Color(0xFF8B5CF6)..style = PaintingStyle.stroke..strokeWidth = 2 * scale;
    
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
    path.arcToPoint(Offset(size.width - notchWidth, radius), radius: Radius.circular(radius));
    
    // Right edge and notch (notch pointing RIGHT)
    path.lineTo(size.width - notchWidth, size.height / 2 - notchHeight / 2);
    path.lineTo(size.width, size.height / 2); // notch tip pointing RIGHT
    path.lineTo(size.width - notchWidth, size.height / 2 + notchHeight / 2);
    
    path.lineTo(size.width - notchWidth, size.height - radius);
    
    // Bottom right corner
    path.arcToPoint(Offset(size.width - notchWidth - radius, size.height), radius: Radius.circular(radius));
    // Bottom edge
    path.lineTo(radius, size.height);
    // Bottom left corner
    path.arcToPoint(Offset(0, size.height - radius), radius: Radius.circular(radius));
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
    final emptyFaceFill = Paint()..color = const Color(0xFFF1F5F9); // Lighter gray for 3D faces
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
        
      final fillFacePaint = Paint()..color = const Color(0xFF0891B2); // Darker cyan for faces
      final fillStroke = Paint()
        ..color = const Color(0xFF0E7490) // Even darker stroke
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
    return oldDelegate.fillPercentage != fillPercentage || oldDelegate.scale != scale;
  }
}
