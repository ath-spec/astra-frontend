import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';
import '../../../core/widgets/dashed_line.dart';

class ChatHistoryScreen extends ConsumerStatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  ConsumerState<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends ConsumerState<ChatHistoryScreen> {
  // Mock data as requested
  final List<Map<String, dynamic>> _todayChats = [
    {
      'title': 'Portfolio optimization strategies',
      'meta': '2 MESSAGES · 1M AGO',
    },
    {
      'title': 'Tax loss harvesting opportunities',
      'meta': '5 MESSAGES · 2H AGO',
    },
    {
      'title': 'Analysis of Q3 earnings reports',
      'meta': '12 MESSAGES · 4H AGO',
    },
    {'title': 'Rebalancing equity exposure', 'meta': '3 MESSAGES · 5H AGO'},
    {'title': 'Funds in investment plan', 'meta': '4 MESSAGES · 8H AGO'},
  ];

  final List<Map<String, dynamic>> _lastMonthChats = [
    {'title': 'Foundation Plan fund options', 'meta': '4 MESSAGES · 13 JUL'},
    {'title': 'ELSS mutual funds tax benefits', 'meta': '8 MESSAGES · 7 JUL'},
    {'title': 'Retirement corpus calculation', 'meta': '15 MESSAGES · 2 JUL'},
    {
      'title': 'Review of technology sector index',
      'meta': '2 MESSAGES · 28 JUN',
    },
    {'title': 'Dividend yield vs growth stocks', 'meta': '6 MESSAGES · 25 JUN'},
  ];

  final List<Map<String, dynamic>> _previousChats = [
    {'title': 'Tax saving investment options', 'meta': '6 MESSAGES · 5 JUN'},
    {'title': 'How to set up your first SIP', 'meta': '12 MESSAGES · 21 MAY'},
    {'title': 'Gold vs real estate investment', 'meta': '4 MESSAGES · 10 MAY'},
    {'title': 'Emergency fund allocation rules', 'meta': '2 MESSAGES · 3 MAY'},
    {'title': 'Understanding expense ratios', 'meta': '7 MESSAGES · 15 APR'},
  ];

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'DMMono',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildChatItem(String title, {bool isLast = false}) {
    return ScaleButton(
      onTap: () {
        ref.read(chatNotifierProvider.notifier).loadDummyThread(title);
        context.pop();
      },
      child: Container(
        color: Colors.transparent, // to expand touch target
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                  height: 1.3,
                ),
              ),
            ),
            if (!isLast)
              DashedLine(
                color: Colors.grey.withValues(alpha: 0.15),
                dashWidth: 4.0,
                dashSpace: 4.0,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SizedBox.expand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Transform.translate(
                          offset: const Offset(-8, 0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'History',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          color: Color(0xFF0F172A),
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // Scrollable History List
                Expanded(
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    children: [
                      _buildSectionHeader('Today'),
                      for (int i = 0; i < _todayChats.length; i++)
                        _buildChatItem(_todayChats[i]['title'], isLast: i == _todayChats.length - 1),

                      _buildSectionHeader('Last Month'),
                      for (int i = 0; i < _lastMonthChats.length; i++)
                        _buildChatItem(_lastMonthChats[i]['title'], isLast: i == _lastMonthChats.length - 1),

                      _buildSectionHeader('Long Time'),
                      for (int i = 0; i < _previousChats.length; i++)
                        _buildChatItem(_previousChats[i]['title'], isLast: i == _previousChats.length - 1),

                      const SizedBox(height: 40),
                      
                      const Center(
                        child: Text(
                          'END OF HISTORY',
                          style: TextStyle(
                            fontFamily: 'DMMono',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40), // Bottom padding
                    ],
                  ),
                ),

                // Bottom Fixed CTA
                Container(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    16,
                    24,
                    bottomPadding > 0 ? bottomPadding + 8 : 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // Invalidate current chat state to start fresh
                      ref.invalidate(chatNotifierProvider);
                      // Pop back to the chat screen
                      context.pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFF5BA1F7),
                            Color(0xFF031E6B),
                            Color(0xFF241714),
                          ],
                          stops: [0.0, 0.25, 0.7, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            'NEW CHAT',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Positioned(
                            right: 20,
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const ScaleButton({super.key, required this.child, required this.onTap});

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
