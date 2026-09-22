// ============================================================
// FILE: lib/core/responsive/context_responsive.dart
// Lightweight, additive structural-responsiveness helpers built on
// MediaQuery. Deliberately does NOT scale typography or fixed
// component sizes — the UI should look and feel identical across
// screen sizes; only layout (max content width, padding, wrapping)
// adapts so nothing overflows or clips. Does not touch
// size_config.dart (that file is a no-op passthrough already relied
// on elsewhere) — this is a separate, opt-in utility.
// ============================================================

import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {
  /// Raw screen width from MediaQuery.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// True for narrow phone widths (< 360dp) — used only to avoid
  /// overflow (e.g. slightly tighter padding), never to shrink text.
  bool get isCompactWidth => screenWidth < 360;

  /// True for tablet/desktop-class widths (>= 600dp).
  bool get isWideWidth => screenWidth >= 600;

  /// Horizontal page padding. Stays visually consistent on phones;
  /// only grows on tablet/desktop so content doesn't stretch
  /// edge-to-edge, keeping the same look and feel everywhere.
  double get pageHorizontalPadding => isWideWidth ? 32 : (isCompactWidth ? 12 : 16);

  /// Caps content width on tablet/desktop so cards/charts render at
  /// the same size they do on a phone instead of stretching wide;
  /// full width on phones.
  double contentMaxWidth({double cap = 640}) => screenWidth < cap ? screenWidth : cap;
}
