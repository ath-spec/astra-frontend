import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/nav_context_provider.dart';
import 'modules/modules_tab.dart';
import 'videos/videos_tab.dart';
import 'library/library_tab.dart';

class LearningsScreen extends ConsumerWidget {
  const LearningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(learningsTabIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Learnings',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Bite-sized financial wisdom, curated for you.',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Tab Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _buildCurrentTab(activeTab),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const ModulesTab(key: ValueKey('modules_tab'));
      case 1:
        return const VideosTab(key: ValueKey('videos_tab'));
      case 2:
        return const LibraryTab(key: ValueKey('library_tab'));
      default:
        return const ModulesTab(key: ValueKey('modules_tab'));
    }
  }
}

