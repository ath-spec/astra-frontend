import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';


class ChatAppBar extends ConsumerWidget {
  const ChatAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatNotifierProvider);
    final hasMessages = messages.isNotEmpty;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: Colors.transparent,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 8,
        bottom: 8,
        left: 8,
        right: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Empty space to balance the right icon
          const SizedBox(width: 38),

          // Center: Animated Title
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: const Cubic(0.23, 1.0, 0.32, 1.0), // Strong ease-out
              switchOutCurve: const Cubic(0.23, 1.0, 0.32, 1.0),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, ch) {
                        // Emil Design: use blur during the transition for a fluid morph effect
                        final blurValue = (1 - animation.value) * 4.0;
                        if (blurValue < 0.01) return ch!;
                        return ImageFilterWidget(
                          filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                          child: ch!,
                        );
                      },
                      child: child,
                    ),
                  ),
                );
              },
              child: const SizedBox.shrink(key: ValueKey('empty_title')),
            ),
          ),

          // Right: History Icon
          _HeaderButton(
            icon: Icons.history_rounded,
            onTap: () => context.push('/chat-history'),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

// Custom wrapper to apply blur to children efficiently
class ImageFilterWidget extends StatelessWidget {
  final ImageFilter filter;
  final Widget child;

  const ImageFilterWidget({super.key, required this.filter, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: filter,
        child: child,
      ),
    );
  }
}

class _HeaderButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
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
        scale: _isPressed ? 0.93 : 1.0, // Emil Design: Instant physical feedback
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.transparent, // expanded hit area
          child: Icon(
            widget.icon,
            size: 22,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
