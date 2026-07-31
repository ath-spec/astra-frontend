import 'package:flutter/material.dart';

class ZeyroButton extends StatelessWidget {
  final String eventName;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  
  const ZeyroButton({super.key, required this.eventName, this.onPressed, required this.child, this.style});
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, style: style, child: child);
  }
}

class ZeyroIconButton extends StatelessWidget {
  final String eventName;
  final VoidCallback? onPressed;
  final Widget icon;
  final EdgeInsetsGeometry? padding;
  final double? splashRadius;
  final BoxConstraints? constraints;
  
  const ZeyroIconButton({super.key, required this.eventName, this.onPressed, required this.icon, this.padding, this.splashRadius, this.constraints});
  
  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: icon, padding: padding, splashRadius: splashRadius, constraints: constraints);
  }
}

class ZeyroTapDetector extends StatelessWidget {
  final String eventName;
  final VoidCallback? onTap;
  final Widget child;
  
  const ZeyroTapDetector({super.key, required this.eventName, this.onTap, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: child);
  }
}
