import 'package:flutter/material.dart';
import '../models/learning_module.dart';

class ModuleCard extends StatefulWidget {
  final LearningModule module;
  final VoidCallback onTap;

  const ModuleCard({super.key, required this.module, required this.onTap});

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.02 : 0.04),
                blurRadius: _isPressed ? 4 : 8,
                offset: _isPressed ? const Offset(0, 2) : const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Highlight block behind the number
                    Positioned(
                      left: -20, // stretch to the very edge of the card
                      top: -4,
                      bottom: -4,
                      width: 56, // highlight width
                      child: Container(
                        color: widget.module.themeColor.withOpacity(0.12),
                      ),
                    ),
                    // Solid left bar indicator
                    Positioned(
                      left: -20, // flush with card edge
                      top: -4,
                      bottom: -4,
                      width: 6,
                      child: Container(color: widget.module.themeColor),
                    ),
                    // Title Text
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Text(
                        widget.module.title,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.module.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
