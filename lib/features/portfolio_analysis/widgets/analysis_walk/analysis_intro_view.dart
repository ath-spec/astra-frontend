import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnalysisIntroView extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onNext;

  const AnalysisIntroView({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onNext,
  });

  @override
  State<AnalysisIntroView> createState() => _AnalysisIntroViewState();
}

class _AnalysisIntroViewState extends State<AnalysisIntroView> with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple Rings
                AnimatedBuilder(
                  animation: _rippleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _RipplePainter(
                        progress: _rippleController.value,
                        color: Colors.black.withOpacity(0.05),
                      ),
                      size: const Size(280, 280),
                    );
                  },
                ),
                // Center Icon Container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    size: 32,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Text Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 48),
        
        // Gradient CTA Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onNext();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFF5BA1F7),
                    Color(0xFF031E6B),
                    Color(0xFF241714),
                  ],
                  stops: [0.0, 0.25, 0.7, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Show My ${widget.title} \u2192',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _RipplePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    
    // Draw 3 concentric rings offset by phase
    _drawRing(canvas, center, maxRadius, (progress) % 1.0);
    _drawRing(canvas, center, maxRadius, (progress + 0.33) % 1.0);
    _drawRing(canvas, center, maxRadius, (progress + 0.66) % 1.0);
  }

  void _drawRing(Canvas canvas, Offset center, double maxRadius, double phase) {
    final radius = maxRadius * phase;
    // Fade out as it expands
    final opacity = 1.0 - phase;
    
    final paint = Paint()
      ..color = color.withOpacity(color.opacity * opacity)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
