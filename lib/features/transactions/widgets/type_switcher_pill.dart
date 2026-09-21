// ============================================================
// FILE: lib/features/transactions/widgets/type_switcher_pill.dart
// Transactions / Categories / Merchants 3-way pill switcher.
// Uses a single physically-sliding white pill indicator (via
// AnimatedPositioned) so the transition is a smooth spatial move
// instead of independent per-tab fade-ins that cause a "flash".
// ============================================================

import 'package:flutter/material.dart';

class TypeSwitcherPill extends StatefulWidget {
  static const labels = ['Transactions', 'Categories', 'Merchants'];

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const TypeSwitcherPill({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<TypeSwitcherPill> createState() => _TypeSwitcherPillState();
}

class _TypeSwitcherPillState extends State<TypeSwitcherPill> {
  // Strong ease-out curve (Emil Kowalski: cubic-bezier(0.23,1,0.32,1))
  static const _curve = Cubic(0.23, 1.0, 0.32, 1.0);
  static const _duration = Duration(milliseconds: 220);
  static const _padding = 3.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final count = TypeSwitcherPill.labels.length;
        // Width of each tab segment (excluding the outer padding on each side)
        final pillWidth = (totalWidth - _padding * 2) / count;
        final pillLeft = _padding + widget.selectedIndex * pillWidth;

        return Container(
          height: 40,
          padding: const EdgeInsets.all(_padding),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // ── Sliding white indicator pill ──────────────────────────
              AnimatedPositioned(
                duration: _duration,
                curve: _curve,
                left: pillLeft - _padding,   // relative to Stack (padding already subtracted)
                top: 0,
                bottom: 0,
                width: pillWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 4,
                        offset: Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Label row (sits above the sliding pill) ───────────────
              Row(
                children: [
                  for (var i = 0; i < count; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onChanged(i),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox.expand(
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: _duration,
                              curve: _curve,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 12.5,
                                fontWeight: widget.selectedIndex == i
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: widget.selectedIndex == i
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF64748B),
                              ),
                              child: Text(TypeSwitcherPill.labels[i]),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
