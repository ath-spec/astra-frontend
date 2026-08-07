import 'dart:math';
import 'package:flutter/material.dart';

class VoiceAnimationWidget extends StatefulWidget {
  final bool isListening;

  const VoiceAnimationWidget({super.key, required this.isListening});

  @override
  State<VoiceAnimationWidget> createState() => _VoiceAnimationWidgetState();
}

class _VoiceAnimationWidgetState extends State<VoiceAnimationWidget> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  final int _barCount = 5;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _barCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + _random.nextInt(300)),
      ),
    );

    if (widget.isListening) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(VoiceAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _startAnimation();
    } else if (!widget.isListening && oldWidget.isListening) {
      _stopAnimation();
    }
  }

  void _startAnimation() {
    for (var controller in _controllers) {
      controller.repeat(reverse: true);
    }
  }

  void _stopAnimation() {
    for (var controller in _controllers) {
      controller.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOutQuad);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_barCount, (index) {
          return AnimatedBuilder(
            animation: _controllers[index],
            builder: (context, child) {
              final height = 4.0 + (_controllers[index].value * 16.0);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 6,
                height: height,
                decoration: BoxDecoration(
                  color: widget.isListening ? const Color(0xFF5BA1F7) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
