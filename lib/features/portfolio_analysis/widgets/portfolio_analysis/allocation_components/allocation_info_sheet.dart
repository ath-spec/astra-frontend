import 'package:flutter/material.dart';
import '../../../models/portfolio_analysis_models.dart';
import 'dart:math' as math;

class AllocationInfoSheet extends StatefulWidget {
  final AllocationLevel level;

  const AllocationInfoSheet({super.key, required this.level});

  @override
  State<AllocationInfoSheet> createState() => _AllocationInfoSheetState();
}

class _AllocationInfoSheetState extends State<AllocationInfoSheet> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    
    Future.delayed(const Duration(milliseconds: 200), () {
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
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.view_in_ar_outlined, size: 12, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Text(
                'Allocation',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                        // Core Icon with shadow
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.view_in_ar_outlined,
                              size: 24,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  const Text(
                    'What is Allocation?',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'Allocation is how your money is spread across investments that move differently. More in steadier holdings pulls you left, more in higher-volatility holdings pulls you right.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        height: 1.6,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 58),
                  
                  // Spectrum Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildSpectrumBar(context),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // What's shaping your allocation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What\'s shaping your allocation',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Your asset split',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'We group your holdings by how much they\'ve typically moved in the past, and then show how much of your money sits in each bucket. It\'s a simple way to see where stability and growth are coming from in your portfolio.',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            height: 1.6,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Factors List
                        _buildInfoItem(
                          icon: Icons.change_history,
                          iconColor: const Color(0xFF38A169),
                          title: 'Stable assets',
                          description: 'Includes Bank Accounts, FDs, and liquid or overnight funds. These are usually the steadiest part of a portfolio, meant to keep things grounded and accessible.',
                        ),
                        _buildInfoItem(
                          icon: Icons.call_split,
                          iconColor: const Color(0xFF38A169),
                          title: 'Low volatility assets',
                          description: 'Holdings that usually move a little, but not a lot. This bucket often supports stability while still earning better returns than pure cash-like options.',
                        ),
                        _buildInfoItem(
                          icon: Icons.star_border,
                          iconColor: const Color(0xFFDD6B20),
                          title: 'Medium volatility assets',
                          description: 'Holdings that can swing with markets, but are not the most extreme. A common "middle" bucket for balanced portfolios, with meaningful growth potential.',
                        ),
                        _buildInfoItem(
                          icon: Icons.ac_unit, // Using ac_unit for the asterisk-like icon
                          iconColor: const Color(0xFFE53E3E),
                          title: 'High volatility assets',
                          description: 'Holdings that can swing the most in the short term, but also tend to offer the highest long-term return potential. Best suited if you can stay invested through ups and downs.',
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
                    fontSize: 12,
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
    final levels = AllocationLevel.values;
    final activeIndex = widget.level.index;
    final activeColor = widget.level.activeColor;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final segmentWidth = totalWidth / levels.length;
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // The segment labels and dividers
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(levels.length, (index) {
                final isLast = index == levels.length - 1;
                return SizedBox(
                  width: segmentWidth,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // Label
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, left: 2.0, right: 2.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            levels[index].label.toUpperCase().replaceAll(' ', '\n'),
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
                      // Divider line (skip on first)
                      if (index != 0)
                        Positioned(
                          left: 0,
                          top: -32,
                          bottom: -32,
                          child: CustomPaint(
                            size: const Size(1, 48),
                            painter: _DashedLinePainter(),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            
            // The gray bar background
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            
            // The animated active segment
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                // Calculate the left offset for the active segment
                final leftOffset = activeIndex * segmentWidth;
                // Animate width from 0 to segmentWidth
                final currentWidth = segmentWidth * _animation.value;
                
                return Positioned(
                  left: leftOffset,
                  top: 0,
                  child: Container(
                    height: 6,
                    width: currentWidth,
                    decoration: BoxDecoration(
                      color: activeColor,
                    ),
                  ),
                );
              },
            ),
            
            // The CURRENT pill
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                // Keep pill centered above the active segment
                // Fade in as it animates
                final leftOffset = activeIndex * segmentWidth;
                
                return Positioned(
                  left: leftOffset,
                  top: -32,
                  width: segmentWidth,
                  child: Opacity(
                    opacity: _animation.value,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF14B8A6)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          'CURRENT',
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Color(0xFF14B8A6),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      }
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
      
    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 0;
    
    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

