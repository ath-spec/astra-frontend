import 'package:flutter/material.dart';

/// A LazyIndexedStack that only builds its children when they become active.
/// Once a child has been built, it remains in the tree (like a normal IndexedStack)
/// so that state is preserved. This drastically improves the first-load performance
/// when switching to a tab containing multiple heavy screens.
class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final AlignmentGeometry alignment;
  final StackFit sizing;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
    this.sizing = StackFit.loose,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late List<bool> _activated;

  @override
  void initState() {
    super.initState();
    _activated = List<bool>.generate(
      widget.children.length,
      (i) => i == widget.index,
    );
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      if (widget.index >= 0 && widget.index < _activated.length) {
        _activated[widget.index] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: widget.alignment,
      fit: widget.sizing,
      children: List.generate(widget.children.length, (i) {
        if (!_activated[i]) {
          return const SizedBox.shrink();
        }
        final bool isActive = i == widget.index;
        return IgnorePointer(
          ignoring: !isActive,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            opacity: isActive ? 1.0 : 0.0,
            child: widget.children[i],
          ),
        );
      }),
    );
  }
}
