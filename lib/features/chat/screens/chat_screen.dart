import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/chat_app_bar.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add GestureDetector at the top level to dismiss keyboard on tap outside
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Inherits glass background
        extendBody: true,
        resizeToAvoidBottomInset: false, // Handled manually by padding
        body: Stack(
          children: [
            // Background Gradient: matching new dark navy to light reference
            // Use fixed height instead of Positioned.fill to prevent gradient squishing when keyboard opens
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1C3059),
                      Color(0xFF233A5F),
                      Color(0xFFD0D3DA),
                      Color(0xFFF9FDFF),
                    ],
                    stops: [0.0, 0.35, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            // Center everything else for responsiveness
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SizedBox.expand(
                  child: Stack(
                    children: [
                      // Main Content Area with unified scroll view
                      const Positioned.fill(
                        child: ChatMessageList(),
                      ),

                      // Top floating App Bar
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: ChatAppBar(),
                      ),

                      // Bottom Input Field (floating above everything, responds to keyboard and nav bar)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: MediaQuery.of(context).viewInsets.bottom > 0
                            ? MediaQuery.of(context).viewInsets.bottom
                            : MediaQuery.of(context).padding.bottom,
                        child: const ChatInputField(),
                      ),
                    ],
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
