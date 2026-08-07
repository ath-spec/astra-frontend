import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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


  List<Map<String, dynamic>> _getPromptsForPath() {
    final router = GoRouter.of(context);
    final String path = router.routerDelegate.currentConfiguration.uri.path;
    
    if (path.startsWith('/stocks') || path.startsWith('/owned-stocks') || path.startsWith('/mf-portfolio')) {
      return [
        {'icon': Icons.trending_up, 'text': 'Why is Mazagon Dock up?'},
        {'icon': Icons.analytics_outlined, 'text': 'Analyze my sector allocation'},
        {'icon': Icons.compare_arrows_rounded, 'text': 'Should I hold or sell?'},
      ];
    }
    if (path.startsWith('/news')) {
      return [
        {'icon': Icons.newspaper_rounded, 'text': 'Summarize today\'s news'},
        {'icon': Icons.show_chart, 'text': 'How does this affect my portfolio?'},
      ];
    }
    if (path.startsWith('/budget') || path.startsWith('/recurring')) {
      return [
        {'icon': Icons.money_off_rounded, 'text': 'How can I reduce expenses?'},
        {'icon': Icons.credit_card_rounded, 'text': 'Find my largest subscriptions'},
      ];
    }
    if (path.startsWith('/bank') || path.startsWith('/linked-banks')) {
      return [
        {'icon': Icons.account_balance_rounded, 'text': 'Analyze my bank balances'},
        {'icon': Icons.history_rounded, 'text': 'Show recent large transactions'},
      ];
    }
    return [
      {'icon': Icons.query_stats_rounded, 'text': 'Analyze my portfolio'},
      {'icon': Icons.account_balance_wallet_outlined, 'text': 'What\'s my net worth?'},
      {'icon': Icons.shield_outlined, 'text': 'Suggest tax saving strategies'},
    ];
  }

  void _handlePromptTap(String text) {
    _controller.text = text;
    _handleSubmit();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Clear the chat state to ensure we always start a brand new chat
    ref.invalidate(chatNotifierProvider);

    // Send the message to the freshly created chat state
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
        borderRadius: BorderRadius.circular(4),
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
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
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

    final mainContent = BorderBeam(
      duration: 5,
      borderWidth: 2.0,
      staticBorderColor: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: pillContent,
    );

    final prompts = _getPromptsForPath();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (int i = 0; i < prompts.length; i++) ...[
                _ContextualChip(
                  icon: prompts[i]['icon'] as IconData,
                  text: prompts[i]['text'] as String,
                  index: i,
                  onTap: () => _handlePromptTap(prompts[i]['text'] as String),
                ),
                if (i < prompts.length - 1) const SizedBox(width: 8),
              ]
            ],
          ),
        ),
        const SizedBox(height: 12),
        mainContent,
      ],
    );

  }
}


class _ContextualChip extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final int index;

  const _ContextualChip({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.index,
  });

  @override
  State<_ContextualChip> createState() => _ContextualChipState();
}

class _ContextualChipState extends State<_ContextualChip> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Cubic(0.23, 1.0, 0.32, 1.0))
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut)
    );

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: const Cubic(0.23, 1.0, 0.32, 1.0),
          transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: const Color(0xFF475569)),
              const SizedBox(width: 6),
              Text(
                widget.text,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
