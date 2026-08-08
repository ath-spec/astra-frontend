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
import '../../chat/services/demo_ai_service.dart';
import '../../../core/widgets/typewriter_markdown.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../auth/providers/auth_provider.dart';

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
  final _aiService = DemoAIService();

  NavInputState _currentState = NavInputState.initial;
  String _userMessage = "";
  
  String _aiResponse = "";
  String _streamedResponse = "";
  Timer? _streamTimer;
  bool _wasVoiceInput = false;

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
    _aiService.stopSpeaking();
    try {
      ref.read(speechProvider.notifier).stopListening();
    } catch (_) {}
    super.dispose();
  }

  void _handleFirstSubmit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _userMessage = text;
      _currentState = NavInputState.generating;
    });

    try {
      final chatHistory = ref.read(chatNotifierProvider);
      final historyMessages = chatHistory.map((msg) => {
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      }).toList();
      
      final messages = [...historyMessages, {'role': 'user', 'content': text}];

      final authState = ref.read(authProvider);
      String phone = '+919876543210';
      String name = 'Judge';
      
      if (authState is AuthAuthenticated) {
        phone = authState.user.email.replaceAll('@astra.dev', '');
        name = authState.user.name;
      }

      final response = await _aiService.getChatResponse(
        messages,
        phone: phone,
        name: name,
        isNavPill: true,
      );

      if (mounted) {
        _aiResponse = response.trim();
        
        // Trigger voice synthesis (TTS) only if user used voice and hasn't pressed stop
        if (_wasVoiceInput && _currentState == NavInputState.generating) {
          String spokenText = _aiResponse.replaceAll(RegExp(r'```json[\s\S]*?```'), '');
          spokenText = spokenText.replaceAll(RegExp(r'\|.*\|'), '');
          spokenText = spokenText.replaceAll(RegExp(r'[-*#_~`]'), '');
          spokenText = spokenText.replaceAll(RegExp(r'\n+'), ' ').trim();
          
          if (spokenText.isNotEmpty) {
            // Await so text typing synchronizes with audio start
            await _aiService.speak(spokenText);
          }
        }
        
        // Only start streaming text if the user hasn't pressed stop (double check after await)
        if (mounted && _currentState == NavInputState.generating) {
          setState(() => _currentState = NavInputState.streaming);
        }
      }
    } catch (e) {
      if (mounted) {
        _aiResponse = "I apologize, but I encountered an error. Let's head to the main chat to sort this out.";
        setState(() => _currentState = NavInputState.streaming);
        if (_wasVoiceInput) _aiService.speak("I apologize, but I encountered an error.");
      }
    }
  }

  void _stopAiGeneration() {
    _aiService.stopSpeaking();
    if (mounted) {
      setState(() {
        if (!_aiResponse.endsWith('\u200B')) {
          _aiResponse += '\u200B';
        }
        _currentState = NavInputState.replied;
        _secondFocusNode.requestFocus();
      });
    }
  }

  // _startStreaming removed since TypewriterMarkdown handles it.
  void _handleSecondSubmit() {
    final text = _secondController.text.trim();
    if (text.isEmpty) return;

    final uuid = const Uuid();
    final messages = [
      ChatMessage(
        id: uuid.v4(),
        text: _userMessage,
        isUser: true,
        // Use a timestamp old enough that TypewriterMarkdown won't re-animate it
        timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
      ),
      ChatMessage(
        id: uuid.v4(),
        // Append the \u200B sentinel so chat's TypewriterMarkdown treats this
        // as an already-shown message and skips the typewriter effect
        text: '${_aiResponse}\u200B',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
      ),
    ];

    // 1. Add the inline conversation history from the nav pill
    ref.read(chatNotifierProvider.notifier).addMessages(messages);

    // 2. Send the new follow-up message immediately (no delay — delay causes race condition)
    ref.read(chatNotifierProvider.notifier).sendMessage(text, isVoice: _wasVoiceInput);

    // 3. Close input mode and navigate AFTER messages are set up
    ref.read(navInputModeProvider.notifier).state = false;
    widget.onSend();
  }

  void _toggleListening() {
    final speechState = ref.read(speechProvider);
    final speechNotifier = ref.read(speechProvider.notifier);

    if (speechState.isListening) {
      speechNotifier.stopListening();
    } else {
      FocusScope.of(context).unfocus(); // Close keyboard so it doesn't interrupt STT
      final isFirstPhase = _currentState == NavInputState.initial || _currentState == NavInputState.typing;
      final existingText = isFirstPhase ? _controller.text : _secondController.text;

      speechNotifier.startListening(
        onResultCallback: (text) {
          if (!mounted) return;
          if (text.isNotEmpty) {
            _wasVoiceInput = true;
            final separator = existingText.isNotEmpty && !existingText.endsWith(' ') ? ' ' : '';
            final combinedText = '$existingText$separator$text';
            
            if (isFirstPhase) {
              _controller.text = combinedText;
              _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
              _onTextChanged();
            } else if (_currentState == NavInputState.replied) {
              _secondController.text = combinedText;
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
                          onTap: () {
                            if (_currentState == NavInputState.streaming || _currentState == NavInputState.generating) {
                              _stopAiGeneration();
                            } else {
                              _toggleListening();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              (_currentState == NavInputState.streaming || _currentState == NavInputState.generating || ref.watch(speechProvider).isListening)
                                  ? Icons.stop_rounded 
                                  : Icons.mic_none_rounded, 
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
                    : TypewriterMarkdown(
                        text: _aiResponse,
                        animate: _currentState == NavInputState.streaming && !_aiResponse.contains('```json'),
                        onTypingStarted: () {},
                        onTypingFinished: () {
                          if (mounted) {
                            setState(() {
                              _currentState = NavInputState.replied;
                              _secondFocusNode.requestFocus();
                            });
                          }
                        },
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
                          onTap: () {
                            if (_currentState == NavInputState.streaming || _currentState == NavInputState.generating) {
                              _stopAiGeneration();
                            } else {
                              _toggleListening();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD3E3FD), // Deeper blue for active mic
                            ),
                            child: Icon(
                              (_currentState == NavInputState.streaming || _currentState == NavInputState.generating || ref.watch(speechProvider).isListening)
                                  ? Icons.stop_rounded 
                                  : Icons.mic_none_rounded, 
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
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
        ),
        const SizedBox(height: 12),
        const _GeneratingStepsWidget(),
      ],
    );
  }
}

class _GeneratingStepsWidget extends StatefulWidget {
  const _GeneratingStepsWidget();

  @override
  State<_GeneratingStepsWidget> createState() => _GeneratingStepsWidgetState();
}

class _GeneratingStepsWidgetState extends State<_GeneratingStepsWidget> {
  int _stepIndex = 0;
  Timer? _timer;
  final List<String> _steps = [
    'Thinking...',
    'Analyzing portfolio...',
    'Preparing voice...',
    'Almost ready...',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          if (_stepIndex < _steps.length - 1) {
            _stepIndex++;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(_stepIndex),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: const Cubic(0.23, 1, 0.32, 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 4 * (1 - value)),
            child: Text(
              _steps[_stepIndex],
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                color: Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      },
    );
  }
}
