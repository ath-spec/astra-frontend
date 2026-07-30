import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/providers/nav_context_provider.dart';

class MfOrdersHeader extends ConsumerWidget {
  const MfOrdersHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                ref.read(navContextProvider.notifier).state = NavContext.main;
                context.go('/');
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9).withOpacity(0.5), // Very light grey circle from image
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Color(0xFF0F172A),
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Orders',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -1.0,
            ),
          ),
        ],
      ),
    );
  }
}
