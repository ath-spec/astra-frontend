// ============================================================
// FILE: lib/core/widgets/responsive_body.dart
// Wraps a scrollable screen body so it centers and caps its width
// on tablet/desktop instead of stretching edge-to-edge, keeping the
// same visual density/feel as phone — while still using the full
// screen width up to that cap. Purely structural; never touches
// typography or fixed component sizing.
// ============================================================

import 'package:flutter/material.dart';
import '../responsive/context_responsive.dart';

class ResponsiveBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveBody({super.key, required this.child, this.maxWidth = 640});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.contentMaxWidth(cap: maxWidth)),
            child: child,
          ),
        );
      },
    );
  }
}
