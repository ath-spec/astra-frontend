import 'package:flutter/material.dart';
import 'engine/core.dart';
import 'engine/profiles.dart';
import 'engine/lattice.dart';
import 'engine/morph.dart';
import 'engine/orbits.dart';
import 'engine/ribbon.dart';
import 'engine/connecting.dart';

class ThinkingOrb extends StatefulWidget {
  final double size;
  final String mode; // 'rubik'
  final Color? color;

  const ThinkingOrb({
    super.key,
    this.size = 24.0,
    this.mode = 'rubik',
    this.color,
  });

  @override
  State<ThinkingOrb> createState() => _ThinkingOrbState();
}

class _ThinkingOrbState extends State<ThinkingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ModeOpts _baseOpts;
  late ModeOpts _scaledOpts;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1), // Practically infinite
    )..repeat();

    _baseOpts = baseProfiles[widget.mode] ?? baseProfiles['rubik']!;
    _scaledOpts = scaleRadii(scaleCounts(_baseOpts, 1.0), 1.0);
  }

  @override
  void didUpdateWidget(covariant ThinkingOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _baseOpts = baseProfiles[widget.mode] ?? baseProfiles['rubik']!;
      _scaledOpts = scaleRadii(scaleCounts(_baseOpts, 1.0), 1.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Calculate elapsed time in seconds
          final double t = _controller.lastElapsedDuration == null 
              ? 0.0 
              : _controller.lastElapsedDuration!.inMilliseconds / 1000.0;
              
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _OrbPainter(
              t: t,
              isDark: isDark,
              mode: widget.mode,
              opts: _scaledOpts,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t;
  final bool isDark;
  final String mode;
  final ModeOpts opts;
  final Color? color;

  _OrbPainter({
    required this.t,
    required this.isDark,
    required this.mode,
    required this.opts,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (mode) {
      case 'globe':
        drawGlobe(canvas, size.width, t, isDark, opts, color);
        break;
      case 'rubik':
        drawRubik(canvas, size.width, t, isDark, opts, color);
        break;
      case 'wave':
        drawWave(canvas, size.width, t, isDark, opts);
        break;
      case 'orbits':
        drawOrbits(canvas, size.width, t, isDark, opts);
        break;
      case 'ribbon':
        drawRibbon(canvas, size.width, t, isDark, opts, color);
        break;
      case 'morph':
        drawMorph(canvas, size.width, t, isDark, opts);
        break;
      case 'connecting':
        drawConnecting(canvas, size.width, t, isDark, opts, color);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return true; // We repaint every frame for the animation
  }
}
