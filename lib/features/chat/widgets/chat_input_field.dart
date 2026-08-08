import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../../../core/providers/speech_provider.dart';
import 'package:go_router/go_router.dart';
class ChatInputField extends ConsumerStatefulWidget {
  const ChatInputField({super.key});

  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _hasTextNotifier = ValueNotifier(false);
  bool _wasVoiceInput = false;

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
      // Force stop listening if active so the mic doesn't block the audio playback hardware
      final speechState = ref.read(speechProvider);
      if (speechState.isListening) {
        ref.read(speechProvider.notifier).stopListening();
      }
      
      ref.read(chatNotifierProvider.notifier).sendMessage(text, isVoice: _wasVoiceInput);
      _wasVoiceInput = false; // Reset for next message
      _controller.clear();
      _onTextChanged(); // Manually trigger state update since programmatic clear() doesn't fire onChanged
      FocusScope.of(context).unfocus(); // Close the keyboard
    }
  }

  void _stopGeneration() {
    ref.read(chatNotifierProvider.notifier).cancelGeneration();
  }

  void _toggleListening() {
    final speechState = ref.read(speechProvider);
    final speechNotifier = ref.read(speechProvider.notifier);

    if (speechState.isListening) {
      speechNotifier.stopListening();
    } else {
      FocusScope.of(context).unfocus(); // Close keyboard so it doesn't interrupt STT
      final existingText = _controller.text;
      
      speechNotifier.startListening(
        onResultCallback: (text) {
          if (text.isNotEmpty) {
            _wasVoiceInput = true;
            // Append the new speech to the existing text
            final separator = existingText.isNotEmpty && !existingText.endsWith(' ') ? ' ' : '';
            _controller.text = '$existingText$separator$text';
            _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
            _onTextChanged();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _hasTextNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = ref.watch(isProcessingProvider);
    final isSpeaking = ref.watch(isSpeakingProvider);
    
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
              constraints: const BoxConstraints(minHeight: 48),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
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
                  contentPadding: const EdgeInsets.only(left: 20.0, right: 8.0, top: 12.0, bottom: 12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide.none,
                  ),
                  // Properly place the send button INSIDE the textbox using suffixIcon
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: _hasTextNotifier,
                          builder: (context, hasText, child) {
                            return _DynamicActionSuffix(
                              hasText: hasText,
                              isListening: ref.watch(speechProvider).isListening,
                              isProcessing: isProcessing,
                              isSpeaking: isSpeaking,
                              isTyping: ref.watch(isTypingProvider),
                              onSend: _submit,
                              onMic: _toggleListening,
                              onStop: _stopGeneration,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
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
  final bool isListening;
  final bool isProcessing;
  final bool isSpeaking;
  final bool isTyping;
  final VoidCallback onSend;
  final VoidCallback onMic;
  final VoidCallback onStop;

  const _DynamicActionSuffix({
    required this.hasText,
    required this.isListening,
    required this.isProcessing,
    required this.isSpeaking,
    required this.isTyping,
    required this.onSend,
    required this.onMic,
    required this.onStop,
  });

  @override
  State<_DynamicActionSuffix> createState() => _DynamicActionSuffixState();
}

class _DynamicActionSuffixState extends State<_DynamicActionSuffix> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isAiActive = widget.isProcessing || widget.isSpeaking || widget.isTyping;
    
    // Determine colors based on Emil's design principles
    Color bgColor;
    Color iconColor;
    
    if (widget.isListening) {
      // User is speaking into the mic! Show red stop button.
      bgColor = Colors.red.shade50;
      iconColor = Colors.red;
    } else if (isAiActive) {
      // AI is working (processing, speaking, or typing). Show black stop button.
      bgColor = const Color(0xFF1E293B); // Dark charcoal (black)
      iconColor = Colors.white;
    } else if (widget.hasText) {
      bgColor = const Color(0xFF1E293B);
      iconColor = Colors.white;
    } else {
      bgColor = const Color(0xFFF1F5F9);
      iconColor = const Color(0xFF64748B);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (isAiActive) {
          widget.onStop();
        } else if (widget.isListening) {
          widget.onMic(); // Stops the mic
        } else if (widget.hasText) {
          widget.onSend();
        } else {
          widget.onMic(); // Starts the mic
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: isAiActive 
                ? Icon(
                    Icons.stop_rounded,
                    key: ValueKey('stop_ai_${widget.isProcessing}'),
                    color: iconColor,
                    size: 20,
                  )
                : widget.isListening
                ? Icon(
                    Icons.stop_rounded,
                    key: const ValueKey('stop_mic'),
                    color: iconColor,
                    size: 20,
                  )
                : widget.hasText
                ? Icon(
                    Icons.arrow_upward_rounded,
                    key: const ValueKey('send'),
                    color: iconColor,
                    size: 20,
                  )
                : Icon(
                    Icons.mic_none_rounded,
                    key: const ValueKey('mic'),
                    color: iconColor,
                    size: 20,
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
          width: 48,
          height: 48,
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
            size: 22,
          ),
        ),
      ),
    );
  }
}
