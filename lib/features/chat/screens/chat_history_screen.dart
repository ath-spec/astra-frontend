import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';
import '../../../core/widgets/dashed_line.dart';

class ChatHistoryScreen extends ConsumerWidget {
  const ChatHistoryScreen({super.key});

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

  // "2 MESSAGES · 1H AGO" / "5 MESSAGES · 13 JUL" — same style the screen
  // always used, now computed from the real message_count/updated_at the
  // backend returns instead of being hand-typed mock text.
  String _metaFor(int messageCount, DateTime updatedAt) {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);
    String when;
    if (diff.inMinutes < 1) {
      when = 'JUST NOW';
    } else if (diff.inHours < 1) {
      when = '${diff.inMinutes}M AGO';
    } else if (diff.inHours < 24 && updatedAt.day == now.day) {
      when = '${diff.inHours}H AGO';
    } else {
      const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
      when = '${updatedAt.day} ${months[updatedAt.month - 1]}';
    }
    final msgWord = messageCount == 1 ? 'MESSAGE' : 'MESSAGES';
    return '$messageCount $msgWord · $when';
  }

  Widget _buildChatItem(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String meta,
    required String sessionId,
    bool isLast = false,
  }) {
    return ScaleButton(
      onTap: () {
        ref.read(chatNotifierProvider.notifier).loadSession(sessionId);
        context.pop();
      },
      child: Container(
        color: Colors.transparent, // to expand touch target
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    style: const TextStyle(
                      fontFamily: 'DMMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
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
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final topPadding = MediaQuery.paddingOf(context).top;
    final sessionsAsync = ref.watch(chatSessionsProvider);

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
                  child: sessionsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          "Couldn't load your chat history. Pull down to retry.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontFamily: 'DMSans', color: Color(0xFF64748B)),
                        ),
                      ),
                    ),
                    data: (sessions) {
                      if (sessions.isEmpty) {
                        return const Center(
                          child: Text(
                            'No past conversations yet.',
                            style: TextStyle(fontFamily: 'DMSans', color: Color(0xFF94A3B8)),
                          ),
                        );
                      }

                      final now = DateTime.now();
                      final today = <Map<String, dynamic>>[];
                      final lastMonth = <Map<String, dynamic>>[];
                      final longTime = <Map<String, dynamic>>[];
                      for (final s in sessions) {
                        final updatedAt = DateTime.tryParse(s['updated_at']?.toString() ?? '') ?? now;
                        final isToday = updatedAt.year == now.year && updatedAt.month == now.month && updatedAt.day == now.day;
                        final isWithin30Days = now.difference(updatedAt).inDays < 30;
                        if (isToday) {
                          today.add(s);
                        } else if (isWithin30Days) {
                          lastMonth.add(s);
                        } else {
                          longTime.add(s);
                        }
                      }

                      Widget buildGroup(String label, List<Map<String, dynamic>> group) {
                        if (group.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSectionHeader(label),
                            for (int i = 0; i < group.length; i++)
                              _buildChatItem(
                                context,
                                ref,
                                title: (group[i]['title'] as String?)?.trim().isNotEmpty == true
                                    ? group[i]['title'] as String
                                    : 'New Chat',
                                meta: _metaFor(
                                  (group[i]['message_count'] as num?)?.toInt() ?? 0,
                                  DateTime.tryParse(group[i]['updated_at']?.toString() ?? '') ?? now,
                                ),
                                sessionId: group[i]['id'].toString(),
                                isLast: i == group.length - 1,
                              ),
                          ],
                        );
                      }

                      return ListView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        children: [
                          buildGroup('Today', today),
                          buildGroup('Last Month', lastMonth),
                          buildGroup('Long Time', longTime),
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
                          const SizedBox(height: 40),
                        ],
                      );
                    },
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
