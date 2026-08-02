import 'package:flutter/material.dart';

class DisciplineInfoSheet extends StatefulWidget {
  final int currentLevelIndex; // 0 to 4 (e.g., Fair is 2)

  const DisciplineInfoSheet({super.key, this.currentLevelIndex = 2});

  @override
  State<DisciplineInfoSheet> createState() => _DisciplineInfoSheetState();
}

class _DisciplineInfoSheetState extends State<DisciplineInfoSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Snappier duration
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
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
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.adjust, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Text(
                'Discipline',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTargetIcon(),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      'What does Discipline mean?',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Discipline measures how consistently you invest and how rarely you interrupt that habit. It does not judge your returns or fund choices. It focuses only on your investing behaviour.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      height: 1.6,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Bar Chart Area
                  _buildAnimatedChart(),

                  const SizedBox(height: 48),
                  const Text(
                    'How your discipline is calculated',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    'Monthly Consistency',
                    'How steady your investing habit is from month to month.',
                    'This looks at whether you show up regularly and maintain a base level of investing. Adding extra money is good and does not hurt your score. Missing months or large gaps do.',
                  ),
                  const Divider(height: 32, color: Color(0xFFF1F5F9)),
                  _buildSection(
                    'SIP Health',
                    'How reliably your SIPs run and how much of your investing is automated.',
                    'SIPs remove forgetfulness and emotion. Missing them repeatedly weakens discipline, even if you invest later.',
                  ),
                  const Divider(height: 32, color: Color(0xFFF1F5F9)),
                  _buildSection(
                    'Withdrawal Pattern',
                    'How often and how much you took money out of your investments.',
                    'Frequent cash-outs interrupt compounding and usually hurt long-term outcomes. Rebalancing within your portfolio does not count as money out.',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetIcon() {
    return Center(
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.black.withOpacity(0.04),
              Colors.black.withOpacity(0.01),
              Colors.transparent,
            ],
            stops: const [0.2, 0.6, 1.0],
          ),
        ),
        child: Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 4,
                  spreadRadius: 2,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.track_changes_outlined,
                size: 32,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            height: 1.5,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedChart() {
    final labels = ['VERY LOW', 'LOW', 'FAIR', 'GOOD', 'EXCELLENT'];
    final colors = [
      const Color(0xFFBCE3FF), // Very Low
      const Color(0xFF65B4FF), // Low
      const Color(0xFF2796FF), // Fair
      const Color(0xFF1E56D0), // Good
      const Color(0xFF0F172A), // Excellent
    ];
    final emptyColor = const Color(0xFFE2E8F0);
    
    // Custom easing curve from Emil's framework (ease-out)
    final easeOut = const Cubic(0.23, 1, 0.32, 1);
    final curvedAnimation = CurvedAnimation(parent: _controller, curve: easeOut);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;
                    final targetFraction = (widget.currentLevelIndex + 1) / 5.0;
                    final currentFraction = curvedAnimation.value * targetFraction;
                    final currentWidth = totalWidth * currentFraction;

                    return Container(
                      height: 8,
                      width: totalWidth,
                      decoration: BoxDecoration(
                        color: emptyColor,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: currentWidth,
                            child: ClipRRect(
                              child: OverflowBox(
                                alignment: Alignment.centerLeft,
                                minWidth: totalWidth,
                                maxWidth: totalWidth,
                                child: Row(
                                  children: List.generate(5, (index) {
                                    return Expanded(
                                      child: Container(
                                        color: colors[index],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (index) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          labels[index],
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),

            // Dotted Separators
            Positioned.fill(
              child: Row(
                children:
                    List.generate(4, (index) {
                      return Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 1,
                            height: 30, // extends down
                            color: Colors.transparent,
                            child: CustomPaint(
                              painter: _VerticalDottedLinePainter(),
                            ),
                          ),
                        ),
                      );
                    })..add(
                      const Expanded(child: SizedBox()),
                    ), // Empty for the last item
              ),
            ),

            // "CURRENT" Label
            if (widget.currentLevelIndex >= 0)
              Positioned(
                left: 0,
                right: 0,
                top: -30,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final segmentWidth = constraints.maxWidth / 5;
                    final leftOffset =
                        (widget.currentLevelIndex * segmentWidth);

                    // Trigger label beautifully near the end of the fill
                    final labelStart = 0.6;
                    final labelAnimProgress = ((curvedAnimation.value - labelStart) / (1.0 - labelStart)).clamp(0.0, 1.0);
                    
                    // Spring-like bounce for the label
                    final labelAnim = Curves.easeOutBack.transform(labelAnimProgress);
                    final labelOpacity = ((curvedAnimation.value - labelStart) / 0.2).clamp(0.0, 1.0);

                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.translate(
                        offset: Offset(
                          leftOffset + (segmentWidth / 2) - 36,
                          10 * (1 - labelAnim),
                        ),
                        child: Opacity(
                          opacity: labelOpacity,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFF14B8A6),
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'CURRENT',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: Color(0xFF14B8A6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _VerticalDottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final dashHeight = 3.0;
    final dashSpace = 3.0;
    double startY = -15.0; // Start slightly above

    while (startY < 45.0) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
