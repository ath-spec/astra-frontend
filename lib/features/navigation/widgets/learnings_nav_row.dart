import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../navigation/mainnav.dart';
import '../../../core/providers/nav_context_provider.dart';

class LearningsNavPill extends ConsumerWidget {
  const LearningsNavPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(learningsTabIndexProvider);

    return NavigationPill(
      currentIndex: activeTab,
      onTabTapped: (idx) {
        ref.read(learningsTabIndexProvider.notifier).state = idx;
      },
      isNavVisible: true,
      icons: const [
        Icons.view_module_rounded,
        Icons.play_circle_outline_rounded,
        Icons.local_library_rounded,
      ],
      customIcons: [
        (color) => Icon(Icons.view_module_rounded, color: color, size: 16),
        (color) => Icon(Icons.play_circle_outline_rounded, color: color, size: 16),
        (color) => Icon(Icons.local_library_rounded, color: color, size: 16),
      ],
      labels: const ['Modules', 'Videos', 'Library'],
    );
  }
}
