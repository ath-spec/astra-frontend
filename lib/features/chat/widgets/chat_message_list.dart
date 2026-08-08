import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import 'chat_initial_view.dart'; // Contains ChatHeader
import '../../../core/widgets/typewriter_markdown.dart';

class ChatMessageList extends ConsumerStatefulWidget {
  const ChatMessageList({super.key});

  @override
  ConsumerState<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends ConsumerState<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initial scroll when opening an existing chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatNotifierProvider);
    final isProcessing = ref.watch(isProcessingProvider);
    
    // Auto-scroll to bottom when messages are added
    ref.listen(chatNotifierProvider, (previous, next) {
      if (next.isNotEmpty && (previous == null || next.length != previous.length)) {
        // Wait slightly longer to allow keyboard animation and layout to finish
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToBottom();
        });
      }
    });

    return CustomScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: [
        if (messages.isEmpty) ...[
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment(0.0, -0.4), // Moved up from center
              child: ChatHeader(),
            ),
          ),
        ] else ...[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.paddingOf(context).top + 80,
              20,
              100,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // If this is the last item slot and we're processing, show thinking widget
                  if (index == messages.length) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 16),
                      child: _ThinkingStepsWidget(),
                    );
                  }
                  final message = messages[index];
                  return _ChatBubble(
                    message: message,
                    isLast: index == messages.length - 1 && !isProcessing,
                  );
                },
                childCount: messages.length + (isProcessing ? 1 : 0),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChatBubble extends ConsumerWidget {
  final ChatMessage message;
  final bool isLast;

  const _ChatBubble({
    required this.message,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: message.isUser ? 16 : 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                constraints: BoxConstraints(
                  maxWidth: message.isUser 
                      ? constraints.maxWidth * 0.80 // 80% of available width for user messages
                      : constraints.maxWidth,       // 100% of available width for system messages
                ),
                decoration: BoxDecoration(
                  color: message.isUser ? const Color.fromARGB(255, 46, 137, 222) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20).copyWith(
                    bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
                    bottomLeft: !message.isUser ? const Radius.circular(4) : const Radius.circular(20),
                  ),
                  border: message.isUser 
                      ? Border.all(color: const Color.fromARGB(30, 90, 102, 114), width: 1.0) 
                      : null,
                ),
                child: message.isUser 
                  ? Text(
                      message.text,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14, // Slightly larger for better readability
                        height: 1.4,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    )
                  : TypewriterMarkdown(
                      text: message.text,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF0F172A),
                      ),
                      duration: const Duration(milliseconds: 15),
                      // Only animate if it's new, hasn't been interrupted (\u200B), and DOES NOT contain a markdown table (|) or json widget
                      // Tables and Widgets should render instantly so they don't glitch during the typewriter effect.
                      animate: !message.text.contains('|') && !message.text.contains('```json') && !message.text.endsWith('\u200B') && DateTime.now().difference(message.timestamp).inSeconds < 5,
                      onTypingStarted: () {
                        if (!message.isUser && isLast) {
                          ref.read(isTypingProvider.notifier).setTyping(true);
                        }
                      },
                      onTypingFinished: () {
                        if (!message.isUser && isLast) {
                          ref.read(isTypingProvider.notifier).setTyping(false);
                        }
                      },
                    ),
              ),
              if (!message.isUser)
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 24),
                  child: _MessageActionRow(messageText: message.text),
                ),
            ],
          ),
        );
      }
    );
  }
}

class _MessageActionRow extends StatefulWidget {
  final String messageText;

  const _MessageActionRow({required this.messageText});

  @override
  State<_MessageActionRow> createState() => _MessageActionRowState();
}

class _MessageActionRowState extends State<_MessageActionRow> {
  bool _isCopied = false;
  int _feedbackStatus = 0; // 0 = none, 1 = up, -1 = down
  Timer? _copyTimer;

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  void _handleCopy() async {
    _copyTimer?.cancel(); // Cancel any existing timer to prevent race condition
    setState(() => _isCopied = true);
    
    // Perform clipboard set
    final data = ClipboardData(text: widget.messageText);
    try {
      await Clipboard.setData(data);
    } catch (_) {}
    
    if (!mounted) return;
    _copyTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isSpeaking = ref.watch(isSpeakingProvider);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSpeaking) ...[
              const Icon(Icons.volume_up_rounded, size: 16, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
            ],
            _ActionButton(
              icon: _isCopied ? Icons.check_rounded : Icons.content_copy_rounded,
              onTap: _handleCopy,
              isActive: _isCopied,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.thumb_up_outlined,
              activeIcon: Icons.thumb_up_rounded,
              onTap: () => setState(() => _feedbackStatus = _feedbackStatus == 1 ? 0 : 1),
              isActive: _feedbackStatus == 1,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.thumb_down_outlined,
              activeIcon: Icons.thumb_down_rounded,
              onTap: () => setState(() => _feedbackStatus = _feedbackStatus == -1 ? 0 : -1),
              isActive: _feedbackStatus == -1,
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    this.activeIcon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive ? const Color(0xFF6366F1) : const Color(0xFF64748B);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: Icon(
              widget.isActive && widget.activeIcon != null ? widget.activeIcon : widget.icon,
              key: ValueKey(widget.isActive && widget.activeIcon != null ? widget.activeIcon : widget.icon),
              size: 16,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Thinking Steps Widget — shimmer glow + cycling label
// ─────────────────────────────────────────────
class _ThinkingStepsWidget extends StatefulWidget {
  const _ThinkingStepsWidget();

  @override
  State<_ThinkingStepsWidget> createState() => _ThinkingStepsWidgetState();
}

class _ThinkingStepsWidgetState extends State<_ThinkingStepsWidget>
    with TickerProviderStateMixin {
  int _stepIndex = 0;
  Timer? _stepTimer;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  final List<String> _steps = [
    'Thinking...',
    'Analyzing portfolio...',
    'Preparing response...',
    'Almost ready...',
  ];

  @override
  void initState() {
    super.initState();

    // Shimmer pulse — breathes in & out continuously
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _shimmerAnim = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Step cycling
    _stepTimer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (mounted) {
        setState(() {
          if (_stepIndex < _steps.length - 1) _stepIndex++;
        });
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Opacity(
              opacity: _shimmerAnim.value,
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: const Cubic(0.23, 1, 0.32, 1),
                    )),
                    child: child,
                  ),
                );
              },
              child: Text(
                _steps[_stepIndex],
                key: ValueKey(_stepIndex),
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
