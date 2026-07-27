import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profiling_provider.dart';

class ProfilingQuestionsScreen extends ConsumerWidget {
  const ProfilingQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profilingProvider);
    final notifier = ref.read(profilingProvider.notifier);
    final question = state.currentQuestion;
    final canContinue = question.selectedOptionIndex != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () {
                      final handled = notifier.previousQuestion();
                      if (!handled && context.canPop()) {
                        context.pop();
                      } else if (!handled) {
                        context.go('/profiling-intro');
                      }
                    },
                  ),
                  Row(
                    children: [
                      // Simulate offline button for demo/testing
                      IconButton(
                        icon: const Icon(Icons.wifi_off_rounded, color: Color(0xFFEF4444), size: 20),
                        tooltip: 'Simulate No Internet Disconnection',
                        onPressed: () => context.push('/no-internet', extra: '/profiling-questions'),
                      ),
                      const SizedBox(width: 8),
                      // Help pill button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2433),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF2D3748)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFF94A3B8)),
                            SizedBox(width: 6),
                            Text(
                              'Help',
                              style: TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (state.currentQuestionIndex + 1) / 4.0,
                        backgroundColor: const Color(0xFF1E2433),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${state.currentQuestionIndex + 1} of 4',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Animated Question Title & Subtitle & Options
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(question.id),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            question.title,
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.subtitle,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Options Cards
                          ...question.options.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final optionText = entry.value;
                            final isSelected = question.selectedOptionIndex == idx;

                            return GestureDetector(
                              onTap: () => notifier.selectOption(state.currentQuestionIndex, idx),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12.0),
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF132328) : const Color(0xFF1E2433),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF0D9488) : const Color(0xFF2D3748),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        optionText,
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
                                          fontSize: 15,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? const Color(0xFF0D9488) : Colors.transparent,
                                        border: isSelected
                                            ? null
                                            : Border.all(color: const Color(0xFF475569), width: 1.5),
                                      ),
                                      child: isSelected
                                          ? const Center(
                                              child: Icon(Icons.check, size: 16, color: Colors.black),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // CTA Button (strictly disabled until an option is selected)
              GestureDetector(
                onTap: !canContinue
                    ? null
                    : () {
                        final hasMore = notifier.nextQuestion();
                        if (!hasMore) {
                          context.pushReplacement('/profiling-status');
                          notifier.submitProfiling();
                        }
                      },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: canContinue
                          ? const [
                              Color(0xFFFFFFFF),
                              Color(0xFF5BA1F7),
                              Color(0xFF031E6B),
                              Color(0xFF241714),
                            ]
                          : const [
                              Color(0xFFF3F4F6),
                              Color(0xFFD1D5DB),
                              Color(0xFF9CA3AF),
                              Color(0xFF6B7280),
                            ],
                      stops: const [0.0, 0.25, 0.7, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'CONTINUE',
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
              const SizedBox(height: 16),

              // Security footer
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Text(
                    'Your data is 100% safe & secure',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
