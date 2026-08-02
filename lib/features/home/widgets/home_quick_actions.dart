import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/nav_context_provider.dart';

class HomeQuickActions extends ConsumerWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick actions',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 16,
            children: [
              _buildAction(Icons.bar_chart_rounded, 'SIP\'s', onTap: () {
                ref.read(navContextProvider.notifier).state = NavContext.mf;
                ref.read(mfTabIndexProvider.notifier).state = 2;
                context.go('/mf');
              }),
              _buildAction(Icons.receipt_long_outlined, 'Orders', onTap: () {
                ref.read(navContextProvider.notifier).state = NavContext.mf;
                ref.read(mfTabIndexProvider.notifier).state = 3;
                context.go('/mf');
              }),
              _buildAction(Icons.bookmark_outline_rounded, 'Watchlist', onTap: () {
                ref.read(navContextProvider.notifier).state = NavContext.mf;
                ref.read(mfTabIndexProvider.notifier).state = 4;
                context.go('/mf');
              }),
              _buildAction(Icons.shopping_cart_outlined, 'Cart'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAction(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFE2E8F0), // Slate 200
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFF334155), // Slate 700
              size: 24,
            ),
          ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        ],
      ),
    );
  }
}
