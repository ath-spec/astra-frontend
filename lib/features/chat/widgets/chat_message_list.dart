import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import 'chat_initial_view.dart'; // Contains ChatHeader

class ChatMessageList extends ConsumerStatefulWidget {
  const ChatMessageList({super.key});

  @override
  ConsumerState<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends ConsumerState<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatNotifierProvider);
    
    // Auto-scroll to bottom only when messages are added, not on every build
    ref.listen(chatNotifierProvider, (previous, next) {
      if (previous != null && next.length > previous.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && next.isNotEmpty) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (messages.isEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.zero,
              child: ChatHeader(),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: const [
                Expanded(flex: 2, child: SizedBox(height: 32)),
                SizedBox(height: 120),
              ],
            ),
          ),
        ] else ...[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 80,
              20,
              100,
            ),
            sliver: SliverList.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _ChatBubble(message: message);
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
            bottomLeft: !message.isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          // No border for system messages
          border: null,
          boxShadow: message.isUser
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            height: 1.4,
            // Increase contrast of system text against the gradient
            color: message.isUser ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}
