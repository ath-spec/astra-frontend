import 'package:flutter/material.dart';
import '../../../models/portfolio_analysis_models.dart';

class PerformanceInfoSheet extends StatefulWidget {
  final PerformanceLevel level;

  const PerformanceInfoSheet({super.key, required this.level});

  @override
  State<PerformanceInfoSheet> createState() => _PerformanceInfoSheetState();
}

class _PerformanceInfoSheetState extends State<PerformanceInfoSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final activeCount = widget.level.activeSegments;
    // 300ms per active segment
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: activeCount * 300),
    );

    // Add a slight delay before starting to allow sheet to open smoothly
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(
                          Icons.change_history,
                          size: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Performance',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Circular Graphic
                  SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Faint outer circle
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                              color: const Color(0xFFF1F5F9),
                              width: 2,
                            ),
                          ),
                        ),
                        // Inner circle
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                              color: const Color(0xFFF1F5F9),
                              width: 2,
                            ),
                          ),
                        ),
                        // Core Icon with gradient and shadow
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.change_history,
                              size: 24,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // What is Performance
                  const Text(
                    'What is Performance?',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: const Text(
                      'Performance measures how your portfolio has grown over time compared to your benchmark.\n\nYour benchmark is aligned to your allocation, so returns are evaluated against a comparable level of risk.\n\nOutperformance means your portfolio has generated returns above what a similar allocation would typically deliver.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        height: 1.6,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Spectrum Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildSpectrumBar(context),
                  ),

                  const SizedBox(height: 48),

                  // Factors that contribute
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Factors that contribute to performance',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInfoItem(
                          icon: Icons.pie_chart_outline,
                          iconColor: const Color(0xFF38A169),
                          title: 'Asset Allocation',
                          description:
                              'The primary driver of returns is the mix of assets (equity, debt, gold) you hold.',
                        ),
                        _buildInfoItem(
                          icon: Icons.stars,
                          iconColor: const Color(0xFF38A169),
                          title: 'Fund Selection',
                          description:
                              'How well the specific mutual funds in your portfolio have performed against their categories.',
                          isLast: true,
                        ),
                      ],
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

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(icon, size: 12, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    height: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpectrumBar(BuildContext context) {
    final levels = PerformanceLevel.values;
    final activeCount = widget.level.activeSegments; // 1 to 5

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final segmentWidth = totalWidth / levels.length;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(levels.length, (index) {
                final isActive = index < activeCount;
                final isCurrent = index == (activeCount - 1);

                // Calculate interval for this segment
                final startTime = isActive ? (index / activeCount) : 0.0;
                final endTime = isActive ? ((index + 1) / activeCount) : 0.0;

                final fillAnimation = isActive
                    ? Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Interval(
                            startTime,
                            endTime,
                            curve: Curves.easeOut,
                          ),
                        ),
                      )
                    : const AlwaysStoppedAnimation<double>(0.0);

                final pillOpacityAnimation = isCurrent
                    ? Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Interval(0.8, 1.0, curve: Curves.easeIn),
                        ),
                      )
                    : const AlwaysStoppedAnimation<double>(0.0);

                return SizedBox(
                  width: segmentWidth,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // Label
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 16.0,
                          left: 2.0,
                          right: 2.0,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            levels[index].label.toUpperCase().replaceAll(
                              ' ',
                              '\n',
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              letterSpacing: 0.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),

                      // Segment Bar Base (Gray)
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: index == 0
                              ? const BorderRadius.horizontal(
                                  left: Radius.circular(4),
                                )
                              : (index == levels.length - 1
                                    ? const BorderRadius.horizontal(
                                        right: Radius.circular(4),
                                      )
                                    : BorderRadius.zero),
                        ),
                      ),

                      // Segment Bar Fill (Animated)
                      if (isActive)
                        AnimatedBuilder(
                          animation: fillAnimation,
                          builder: (context, child) {
                            return Positioned(
                              left: 0,
                              top: 0,
                              height: 8,
                              child: Container(
                                width: segmentWidth * fillAnimation.value,
                                decoration: BoxDecoration(
                                  color: levels[index].activeColor,
                                  borderRadius: index == 0
                                      ? const BorderRadius.horizontal(
                                          left: Radius.circular(4),
                                        )
                                      : (index == levels.length - 1
                                            ? const BorderRadius.horizontal(
                                                right: Radius.circular(4),
                                              )
                                            : BorderRadius.zero),
                                ),
                              ),
                            );
                          },
                        ),

                      // Divider line (skip on first)
                      if (index != 0)
                        Positioned(
                          left: 0,
                          top: -6,
                          bottom: -32,
                          child: CustomPaint(
                            size: const Size(1, 48),
                            painter: _DashedLinePainter(),
                          ),
                        ),

                      // CURRENT Pill
                      if (isCurrent)
                        AnimatedBuilder(
                          animation: pillOpacityAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: -28,
                              child: Opacity(
                                opacity: pillOpacityAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFF38A169),
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'CURRENT',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                      color: Color(0xFF38A169),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square;

    double dashHeight = 3;
    double dashSpace = 3;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
