import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import 'package:go_router/go_router.dart';
class ChatInputField extends ConsumerStatefulWidget {
  const ChatInputField({super.key});

  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _hasTextNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (_hasTextNotifier.value != hasText) {
      _hasTextNotifier.value = hasText;
    }
  }

  void _submit() {
    final text = _controller.text;
    if (text.trim().isNotEmpty) {
      ref.read(chatNotifierProvider.notifier).sendMessage(text);
      _controller.clear();
      _onTextChanged(); // Manually trigger state update since programmatic clear() doesn't fire onChanged
      FocusScope.of(context).unfocus(); // Close the keyboard
    }
  }

  void _startVoice() {
    // Placeholder for voice recording logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Voice recording coming soon"), duration: Duration(seconds: 1)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _hasTextNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.95 + (0.05 * value), // Slight scale up from 0.95 to 1.0 matching Emil's morph design
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Home icon button (Outside the pill)
            _HomeButton(),
            const SizedBox(width: 8),
            
            // Text field with Send button properly nested inside as a suffixIcon
            Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                onChanged: (_) => _onTextChanged(),
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask ASTRA',
                  hintStyle: const TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0xFFCBD5E1), // Lighter color
                    fontSize: 14,
                    fontWeight: FontWeight.w300, // Lighter weight
                  ),
                  filled: true,
                  fillColor: Colors.white, // Always solid white like the reference image
                  contentPadding: const EdgeInsets.only(left: 20.0, right: 8.0, top: 16.0, bottom: 16.0), // Reduced vertical padding from 18 to 16 to offset the larger text size
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26), // Half of 52
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide.none,
                  ),
                  // Properly place the send button INSIDE the textbox using suffixIcon
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 10.0), // 10px bottom to center the 32px button in a 52px container
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: _hasTextNotifier,
                          builder: (context, hasText, child) {
                            return _DynamicActionSuffix(
                              hasText: hasText,
                              onSend: _submit,
                              onMic: _startVoice,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // The style property here is duplicated; removed the old lower-font-size one below
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _DynamicActionSuffix extends StatefulWidget {
  final bool hasText;
  final VoidCallback onSend;
  final VoidCallback onMic;

  const _DynamicActionSuffix({
    required this.hasText,
    required this.onSend,
    required this.onMic,
  });

  @override
  State<_DynamicActionSuffix> createState() => _DynamicActionSuffixState();
}

class _DynamicActionSuffixState extends State<_DynamicActionSuffix> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.hasText) {
          widget.onSend();
        } else {
          widget.onMic();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            // Mic is a lighter color, Send is dark charcoal
            color: widget.hasText ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: Icon(
              widget.hasText ? Icons.arrow_upward_rounded : Icons.mic_none_rounded,
              key: ValueKey(widget.hasText),
              size: 18,
              color: widget.hasText ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeButton extends StatefulWidget {
  @override
  State<_HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<_HomeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        context.go('/');
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white, // Solid white background like the pill
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.home_rounded,
            color: Color(0xFF334155),
            size: 24,
          ),
        ),
      ),
    );
  }
}
