// ============================================================
// FILE: lib/features/transactions/widgets/type_switcher_pill.dart
// Transactions / Categories / Merchants 3-way pill switcher used
// at the top of TransactionsScreen.
// ============================================================

import 'package:flutter/material.dart';

class TypeSwitcherPill extends StatelessWidget {
  static const labels = ['Transactions', 'Categories', 'Merchants'];

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const TypeSwitcherPill({super.key, required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 8.5),
                  decoration: BoxDecoration(
                    color: selectedIndex == i ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: selectedIndex == i
                        ? Border.all(color: const Color(0xFFE2E8F0), width: 0.8)
                        : Border.all(color: Colors.transparent, width: 0.8),
                    boxShadow: selectedIndex == i
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1.5),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12.5,
                      fontWeight: selectedIndex == i ? FontWeight.w700 : FontWeight.w500,
                      color: selectedIndex == i ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
