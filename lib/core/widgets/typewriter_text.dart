import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration? duration;
  final Curve curve;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.duration,
    this.curve = Curves.linear,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textAnimation;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    final defaultDuration = Duration(milliseconds: (widget.text.length * 20).clamp(500, 3000));
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? defaultDuration,
    );

    _textAnimation = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      final defaultDuration = Duration(milliseconds: (widget.text.length * 20).clamp(500, 3000));
      _controller.duration = widget.duration ?? defaultDuration;
      _textAnimation = StepTween(
        begin: 0,
        end: widget.text.length,
      ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
      
      if (_hasStarted) {
        _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('typewriter_${widget.text.hashCode}'),
      onVisibilityChanged: (info) {
        if (!_hasStarted && info.visibleFraction >= 0.1) {
          _hasStarted = true;
          _controller.forward();
        }
      },
      child: Stack(
        children: [
          // Invisible base layer to reserve exact height and line breaks
          Text(
            widget.text,
            style: widget.style?.copyWith(color: Colors.transparent) ?? 
                   const TextStyle(color: Colors.transparent),
          ),
          // Visible typing layer
          AnimatedBuilder(
            animation: _textAnimation,
            builder: (context, child) {
              final visibleText = widget.text.substring(0, _textAnimation.value);
              return Text(
                visibleText,
                style: widget.style,
              );
            },
          ),
        ],
      ),
    );
  }
}
