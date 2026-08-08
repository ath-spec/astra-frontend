import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              height: MediaQuery.sizeOf(context).height,
              child: const _AnimatedGradientBackground(),
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
                        bottom: MediaQuery.viewInsetsOf(context).bottom > 0
                            ? MediaQuery.viewInsetsOf(context).bottom
                            : MediaQuery.paddingOf(context).bottom,
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

class _AnimatedGradientBackground extends StatefulWidget {
  const _AnimatedGradientBackground();

  @override
  State<_AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
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
        // Smoothly shift the gradient alignments to create a flowing effect
        final alignTop = AlignmentTween(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ).evaluate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
        );

        final alignBottom = AlignmentTween(
          begin: Alignment.bottomRight,
          end: Alignment.bottomLeft,
        ).evaluate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   begin: alignTop,
            //   end: alignBottom,
            //   colors: const [
            //     Color(0xFF97AFD4), 
            //     Color(0xFF7493D5),
            //     Color(0xFFC5D2DE),
            //     Color(0xFFE7F5FF), 
            //   ],
            //   stops: const [0.0, 0.25, 0.45, 1.0],
            // ),
            color: Color.fromARGB(255, 231, 243, 254),
          ),
        );
      },
    );
  }
}
