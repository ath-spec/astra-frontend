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
    Widget pillContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
          minLines: 1,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          cursorColor: const Color(0xFF1E293B),
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 14,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: 'Ask ASTRA',
            hintStyle: const TextStyle(
              fontFamily: 'DMSans',
              color: Color(0xFFCBD5E1),
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
            contentPadding: const EdgeInsets.only(left: 20.0, right: 8.0, top: 12.0, bottom: 12.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
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
          ),
        ),
      ),
    );

    return BorderBeam(
      duration: 5,
      borderWidth: 2.0,
      colors: const [
        Color(0xFF5BA1F7),
        Color(0xFF8B5CF6),
        Color(0xFFFFAA40),
      ],
      staticBorderColor: Colors.transparent,
      borderRadius: BorderRadius.circular(32),
      child: pillContent,
    );
  }
}
