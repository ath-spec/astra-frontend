import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/nav_input_provider.dart';
import '../../chat/providers/chat_provider.dart';
import 'border_beam.dart';

class NavInputPill extends ConsumerStatefulWidget {
  final VoidCallback onSend;

  const NavInputPill({
    super.key,
    required this.onSend,
  });

  @override
  ConsumerState<NavInputPill> createState() => _NavInputPillState();
}

class _NavInputPillState extends ConsumerState<NavInputPill> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Send the message directly to the chat state
    ref.read(chatNotifierProvider.notifier).sendMessage(text);
    
    // Close the input mode
    ref.read(navInputModeProvider.notifier).state = false;
    
    // Notify parent to route to chat branch
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    Widget pillContent = Container(
      height: 44,
      padding: const EdgeInsets.only(left: 20, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
        },
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: const TextSelectionThemeData(
                    cursorColor: Color(0xFF1E293B),
                    selectionColor: Color(0x331E293B),
                    selectionHandleColor: Color(0xFF1E293B),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  cursorColor: const Color(0xFF1E293B),
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    hintText: 'Ask ASTRA',
                    hintStyle: TextStyle(
                      fontFamily: 'DMSans',
                      color: Color(0xFFCBD5E1),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (_) => _handleSubmit(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _hasText
                  ? GestureDetector(
                      key: const ValueKey('send'),
                      onTap: _handleSubmit,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1E293B),
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    )
                  : GestureDetector(
                      key: const ValueKey('mic'),
                      onTap: () {
                        // Mic functionality placeholder
                        _focusNode.requestFocus();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF1F5F9),
                        ),
                        child: const Icon(
                          Icons.mic_none_rounded,
                          color: Color(0xFF475569),
                          size: 18,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );

    return BorderBeam(
      duration: 5,
      borderWidth: 2.0,
      colorFrom: const Color(0xFF5BA1F7),
      colorTo: const Color(0xFF8B5CF6),
      staticBorderColor: Colors.transparent,
      borderRadius: BorderRadius.circular(100),
      child: pillContent,
    );
  }
}
