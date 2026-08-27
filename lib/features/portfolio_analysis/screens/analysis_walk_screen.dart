import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/analysis_walk/analysis_intro_view.dart';
import '../widgets/analysis_walk/analysis_result_view.dart';
import '../models/portfolio_analysis_models.dart';
import '../data/portfolio_analysis_providers.dart';

enum WalkStep {
  disciplineIntro,
  disciplineResult,
  allocationIntro,
  allocationResult,
  performanceIntro,
  performanceResult,
}

class AnalysisWalkScreen extends ConsumerStatefulWidget {
  const AnalysisWalkScreen({super.key});

  @override
  ConsumerState<AnalysisWalkScreen> createState() => _AnalysisWalkScreenState();
}

class _AnalysisWalkScreenState extends ConsumerState<AnalysisWalkScreen> {
  WalkStep _currentStep = WalkStep.disciplineIntro;

  void _nextStep() {
    setState(() {
      switch (_currentStep) {
        case WalkStep.disciplineIntro:
          _currentStep = WalkStep.disciplineResult;
          break;
        case WalkStep.disciplineResult:
          _currentStep = WalkStep.allocationIntro;
          break;
        case WalkStep.allocationIntro:
          _currentStep = WalkStep.allocationResult;
          break;
        case WalkStep.allocationResult:
          _currentStep = WalkStep.performanceIntro;
          break;
        case WalkStep.performanceIntro:
          _currentStep = WalkStep.performanceResult;
          break;
        case WalkStep.performanceResult:
          // Complete! Navigate to portfolio analysis dashboard.
          ref.read(portfolioAnalysisUnlockedProvider.notifier).setUnlocked(true);
          context.pushReplacement('/portfolio-analysis');
          break;
      }
    });
  }

  int get _progressIndex {
    switch (_currentStep) {
      case WalkStep.disciplineIntro:
      case WalkStep.disciplineResult:
        return 0;
      case WalkStep.allocationIntro:
      case WalkStep.allocationResult:
        return 1;
      case WalkStep.performanceIntro:
      case WalkStep.performanceResult:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          // Content (Full screen, no safe area constraints)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _buildCurrentView(),
            ),
          ),
          
          // Top Bar (Overlaid, keeping its own SafeArea for system UI)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        color: Colors.transparent,
                        child: const Icon(Icons.close, color: Colors.black, size: 20),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          height: 2,
                          width: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 2,
                              width: 120 * ((_progressIndex + 1) / 3),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    final disciplineAsync = ref.watch(portfolioDisciplineProvider);
    final allocationAsync = ref.watch(portfolioAllocationProvider);
    final performanceAsync = ref.watch(portfolioPerformanceProvider);

    switch (_currentStep) {
      case WalkStep.disciplineIntro:
        return AnalysisIntroView(
          key: const ValueKey('disciplineIntro'),
          title: 'Discipline',
          description: 'We analyze your contribution patterns to see how consistently you have been investing.',
          icon: Icons.track_changes,
          onNext: _nextStep,
        );
      case WalkStep.disciplineResult:
        final disc = disciplineAsync.value;
        final model = disc != null ? disc.level : DisciplineLevel.good;
        final streak = disc?.currentStreakMonths ?? 4;
        return AnalysisResultView(
          key: const ValueKey('disciplineResult'),
          type: ResultType.discipline,
          mode: model.label,
          scoreText: 'You have a $streak-month disciplined investing streak.',
          description: 'Your monthly contributions and SIP commitments are actively compounding your net worth.',
          gaugeColor: model.color,
          gradientColors: model.gradientColors,
          fillPercentage: model.score,
          onNext: _nextStep,
        );
      case WalkStep.allocationIntro:
        return AnalysisIntroView(
          key: const ValueKey('allocationIntro'),
          title: 'Allocation',
          description: 'We analyze how your money is spread across stocks, gold, and debt to ensure you are not over-exposed.',
          icon: Icons.layers_outlined,
          onNext: _nextStep,
        );
      case WalkStep.allocationResult:
        final alloc = allocationAsync.value;
        final model = alloc != null ? alloc.level : AllocationLevel.balanced;
        final eqPct = alloc?.equityPct ?? 65.0;
        return AnalysisResultView(
          key: const ValueKey('allocationResult'),
          type: ResultType.allocation,
          mode: model.label,
          scoreText: 'Your asset allocation is ${model.label.toLowerCase()}.',
          description: '${eqPct.toStringAsFixed(0)}% equity allocation calibrated against fixed income and liquid reserves.',
          gaugeColor: model.activeColor,
          gradientColors: model.gradientColors,
          fillPercentage: model.activeSegments / 5,
          onNext: _nextStep,
        );
      case WalkStep.performanceIntro:
        return AnalysisIntroView(
          key: const ValueKey('performanceIntro'),
          title: 'Performance',
          description: 'We compare your personal returns against the market index to see how much your money is truly growing.',
          icon: Icons.change_history,
          onNext: _nextStep,
        );
      case WalkStep.performanceResult:
        final perf = performanceAsync.value;
        final model = perf != null ? perf.level : PerformanceLevel.strong;
        final retPct = perf?.totalReturnPct ?? 18.5;
        return AnalysisResultView(
          key: const ValueKey('performanceResult'),
          type: ResultType.performance,
          mode: model.label,
          scoreText: 'Blended return of +${retPct.toStringAsFixed(1)}% across holdings.',
          description: 'Your portfolio performance is actively beating broad fixed deposits and benchmark indices.',
          gaugeColor: model.activeColor,
          gradientColors: model.gradientColors,
          fillPercentage: model.activeSegments / 5,
          onNext: _nextStep,
        );
    }
  }
}
