import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/nav_input_provider.dart';
import '../../chat/providers/chat_provider.dart';
import '../../../core/providers/speech_provider.dart';
import '../../../core/widgets/animated_gradient_text.dart';
import 'border_beam.dart';
import 'voice_animation.dart';
import 'package:uuid/uuid.dart';
import '../../chat/models/chat_message.dart';

enum NavInputState { initial, typing, generating, streaming, replied }

// Emil's custom easing curve for snappy UI
const Curve _snappyEaseOut = Cubic(0.23, 1.0, 0.32, 1.0);

class NavInputPill extends ConsumerStatefulWidget {
  final VoidCallback onSend;

  const NavInputPill({
    super.key,
    required this.onSend,
  });

  @override
  ConsumerState<NavInputPill> createState() => _NavInputPillState();
}

class _NavInputPillState extends ConsumerState<NavInputPill> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  final TextEditingController _secondController = TextEditingController();
  final FocusNode _secondFocusNode = FocusNode();

  NavInputState _currentState = NavInputState.initial;
  String _userMessage = "";
  
  final String _aiResponse = "I can certainly help you with that! Let's analyze your portfolio first.";
  String _streamedResponse = "";
  Timer? _streamTimer;

  // Shimmer animation for generating state
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    
    _shimmerAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }
  
  void _onTextChanged() {
    if (_currentState == NavInputState.initial || _currentState == NavInputState.typing) {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText && _currentState == NavInputState.initial) {
        setState(() => _currentState = NavInputState.typing);
      } else if (!hasText && _currentState == NavInputState.typing) {
        setState(() => _currentState = NavInputState.initial);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _secondController.dispose();
    _secondFocusNode.dispose();
    _streamTimer?.cancel();
    _shimmerController.dispose();
    try {
      ref.read(speechProvider.notifier).stopListening();
    } catch (_) {}
    super.dispose();
  }

  void _handleFirstSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _userMessage = text;
      _currentState = NavInputState.generating;
    });

    // Simulate network delay then start streaming
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _currentState = NavInputState.streaming);
        _startStreaming();
      }
    });
  }

  void _startStreaming() {
    _streamedResponse = "";
    int currentIndex = 0;
    _streamTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (currentIndex < _aiResponse.length) {
        setState(() {
          _streamedResponse += _aiResponse[currentIndex];
        });
        currentIndex++;
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _currentState = NavInputState.replied;
              _secondFocusNode.requestFocus();
            });
          }
        });
      }
    });
  }

  void _handleSecondSubmit() {
    final text = _secondController.text.trim();
    if (text.isEmpty) return;

    final uuid = const Uuid();
    final messages = [
      ChatMessage(
        id: uuid.v4(),
        text: _userMessage,
        isUser: true,
        timestamp: DateTime.now().subtract(const Duration(seconds: 2)),
      ),
      ChatMessage(
        id: uuid.v4(),
        text: _aiResponse,
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(seconds: 1)),
      ),
    ];

    // Add the inline conversation history first
    ref.read(chatNotifierProvider.notifier).addMessages(messages);
    
    // Slight delay to allow history to process before sending the new message
    Future.delayed(const Duration(milliseconds: 100), () {
      ref.read(chatNotifierProvider.notifier).sendMessage(text);
    });

    // Close input mode
    ref.read(navInputModeProvider.notifier).state = false;
    
    // Notify parent to route to chat branch
    widget.onSend();
  }

  void _toggleListening() {
    final speechState = ref.read(speechProvider);
    final speechNotifier = ref.read(speechProvider.notifier);

    if (speechState.isListening) {
      speechNotifier.stopListening();
    } else {
      speechNotifier.startListening(
        onResultCallback: (text) {
          if (!mounted) return;
          if (_currentState == NavInputState.initial || _currentState == NavInputState.typing) {
            if (text.isNotEmpty) {
              _controller.text = text;
              _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
              _onTextChanged();
            }
          } else if (_currentState == NavInputState.replied) {
            if (text.isNotEmpty) {
              _secondController.text = text;
              _secondController.selection = TextSelection.fromPosition(TextPosition(offset: _secondController.text.length));
            }
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    
    if (_currentState == NavInputState.initial || _currentState == NavInputState.typing) {
      content = _buildInputState();
    } else {
      content = _buildChatState();
    }

    final mainContent = AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: _snappyEaseOut,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.35,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: _snappyEaseOut,
          switchOutCurve: _snappyEaseOut.flipped,
          child: content,
        ),
      ),
    );

    final speechState = ref.watch(speechProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: _snappyEaseOut,
          child: speechState.isListening
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Center(child: VoiceAnimationWidget(isListening: true)),
                )
              : const SizedBox.shrink(),
        ),
        BorderBeam(
          duration: 5,
          borderWidth: 2.0,
          staticBorderColor: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: mainContent,
        ),
      ],
    );
  }

  Widget _buildInputState() {
    final isTyping = _currentState == NavInputState.typing;
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        key: const ValueKey('input_state'),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedGradientShimmer(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'ASTRA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 24,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          
          // Main Input
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            minLines: 1,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            cursorColor: const Color(0xFF1E293B),
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 16,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              hintText: "Type or talk, we've got you",
              hintStyle: TextStyle(
                fontFamily: 'DMSans',
                color: Color(0xFFCBD5E1),
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              isDense: true,
              filled: false,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
            ),
          ),
          const Spacer(),
          
          // Bottom Row
          SizedBox(
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Centered Interaction Pill
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: _snappyEaseOut,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE), // Google blue-ish pill background
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isTyping && !ref.watch(speechProvider).isListening) ...[
                          GestureDetector(
                            onTap: () {
                              if (_focusNode.hasFocus) {
                                _focusNode.unfocus();
                              } else {
                                _focusNode.requestFocus();
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.keyboard_alt_outlined, size: 20, color: Color(0xFF041E49)),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        GestureDetector(
                          onTap: _toggleListening,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              ref.watch(speechProvider).isListening ? Icons.stop_rounded : Icons.mic_none_rounded, 
                              size: 20, 
                              color: const Color(0xFF041E49)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Send Button on the right
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    opacity: isTyping ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: isTyping ? _handleFirstSubmit : null,
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.send_outlined,
                          color: Color(0xFF1E293B),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPillIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    Color activeColor = const Color(0xFFE2E8F0),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? activeColor : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 18,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildChatState() {
    return Padding(
      key: const ValueKey('chat_state'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row: Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedGradientShimmer(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'ASTRA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 18,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
          
          // User Bubble
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _userMessage,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // AI Response Area
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: Icon(Icons.auto_awesome, size: 16, color: Color(0xFF5BA1F7)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _currentState == NavInputState.generating
                    ? _buildGeneratingShimmer()
                    : Text(
                        _currentState == NavInputState.streaming ? _streamedResponse : _aiResponse,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                          height: 1.4,
                        ),
                      ),
              ),
              if (_currentState == NavInputState.replied)
                const Icon(Icons.volume_up_outlined, size: 18, color: Color(0xFF444746)),
            ],
          ),
        ],
      ),
    ),
  ),
  
  if (_currentState == NavInputState.replied) ...[
    const SizedBox(height: 16),
            // Second Input Field seamlessly integrated
            TextField(
              controller: _secondController,
              focusNode: _secondFocusNode,
              minLines: 1,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText: 'Ask a follow up...',
                hintStyle: TextStyle(
                  fontFamily: 'DMSans',
                  color: Color(0xFFCBD5E1),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
              ),
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                color: Color(0xFF0F172A),
              ),
              onSubmitted: (_) => _handleSecondSubmit(),
            ),
          ],
          const SizedBox(height: 16),
          
          // Bottom Row (Exactly like initial state)
          SizedBox(
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Centered Interaction Pill
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: _snappyEaseOut,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE), // Google blue-ish pill background
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _toggleListening,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD3E3FD), // Deeper blue for active mic
                            ),
                            child: Icon(
                              ref.watch(speechProvider).isListening ? Icons.stop_rounded : Icons.mic_none_rounded, 
                              size: 20, 
                              color: const Color(0xFF041E49)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Send Button on the right
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    opacity: _currentState == NavInputState.replied ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: _currentState == NavInputState.replied ? _handleSecondSubmit : null,
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.send_outlined,
                          color: Color(0xFF1E293B),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingShimmer() {
    return FadeTransition(
      opacity: _shimmerAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}
