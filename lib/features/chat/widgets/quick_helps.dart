import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/dashed_line.dart';
import '../providers/chat_provider.dart';

class QuickHelps extends ConsumerWidget {
  const QuickHelps({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'TRY ASKING',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildHelpItem(
            context,
            ref,
            category: 'PORTFOLIO',
            question: 'optimize my portfolio?',
            isLast: false,
          ),
          _buildHelpItem(
            context,
            ref,
            category: 'TAXES',
            question: 'how to save on taxes?',
            isLast: false,
          ),
          _buildHelpItem(
            context,
            ref,
            category: 'FUNDS',
            question: 'best mutual funds?',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context, WidgetRef ref, {required String category, required String question, required bool isLast}) {
    return GestureDetector(
      onTap: () {
        ref.read(chatNotifierProvider.notifier).sendMessage(question);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B82F6), // Blue color from the design
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
}
