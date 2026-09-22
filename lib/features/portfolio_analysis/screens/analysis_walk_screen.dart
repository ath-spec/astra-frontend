import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/analysis_walk/analysis_intro_view.dart';
import '../widgets/analysis_walk/analysis_result_view.dart';
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

  /// Renders the intro/"analyzing" view for a walk step. While a result step's
  /// data is still loading it is shown again as a hold state (the thinking orb
  /// reads as "computing") with taps disabled — never a fabricated result.
  Widget _intro(WalkStep step, {bool holding = false}) {
    final onNext = holding ? () {} : _nextStep;
    switch (step) {
      case WalkStep.allocationIntro:
      case WalkStep.allocationResult:
        return AnalysisIntroView(
          key: const ValueKey('allocationIntro'),
          title: 'Allocation',
          description: 'We analyze how your money is spread across stocks, gold, and debt to ensure you are not over-exposed.',
          icon: Icons.layers_outlined,
          onNext: onNext,
        );
      case WalkStep.performanceIntro:
      case WalkStep.performanceResult:
        return AnalysisIntroView(
          key: const ValueKey('performanceIntro'),
          title: 'Performance',
          description: 'We compare your personal returns against the market index to see how much your money is truly growing.',
          icon: Icons.change_history,
          onNext: onNext,
        );
      case WalkStep.disciplineIntro:
      case WalkStep.disciplineResult:
        return AnalysisIntroView(
          key: const ValueKey('disciplineIntro'),
          title: 'Discipline',
          description: 'We analyze your contribution patterns to see how consistently you have been investing.',
          icon: Icons.track_changes,
          onNext: onNext,
        );
    }
  }

  /// Re-fetches all three analyses (used by the error view's "Try again").
  void _retry() {
    ref.invalidate(portfolioDisciplineProvider);
    ref.invalidate(portfolioAllocationProvider);
    ref.invalidate(portfolioPerformanceProvider);
    setState(() {});
  }

  /// Leaves the walk for the Portfolio Analysis screen (which renders its own
  /// skeleton / empty states) without ever showing placeholder numbers here.
  void _continueToAnalysis() {
    ref.read(portfolioAnalysisUnlockedProvider.notifier).setUnlocked(true);
    context.pushReplacement('/portfolio-analysis');
  }

  /// Shown when an analysis fails to load — an explicit, friendly message with
  /// a retry, never a silent skip and never fabricated data.
  Widget _buildError(String section) {
    return Padding(
      key: const ValueKey('walkError'),
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 44, color: Color(0xFF94A3B8)),
          const SizedBox(height: 20),
          Text(
            "We couldn't load your $section analysis",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _retry,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.black,
              ),
              child: const Center(
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _continueToAnalysis,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Continue to portfolio',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
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
        return _intro(WalkStep.disciplineIntro);
      case WalkStep.disciplineResult:
        if (disciplineAsync.hasError) return _buildError('discipline');
        final disc = disciplineAsync.value;
        if (disc == null) return _intro(WalkStep.disciplineResult, holding: true);
        final model = disc.level;
        return AnalysisResultView(
          key: const ValueKey('disciplineResult'),
          type: ResultType.discipline,
          mode: model.label,
          scoreText: 'You have a ${disc.currentStreakMonths}-month disciplined investing streak.',
          description: 'Your monthly contributions and SIP commitments are actively compounding your net worth.',
          gaugeColor: model.color,
          gradientColors: model.gradientColors,
          fillPercentage: model.score,
          onNext: _nextStep,
        );
      case WalkStep.allocationIntro:
        return _intro(WalkStep.allocationIntro);
      case WalkStep.allocationResult:
        if (allocationAsync.hasError) return _buildError('allocation');
        final alloc = allocationAsync.value;
        if (alloc == null) return _intro(WalkStep.allocationResult, holding: true);
        final model = alloc.level;
        return AnalysisResultView(
          key: const ValueKey('allocationResult'),
          type: ResultType.allocation,
          mode: model.label,
          scoreText: 'Your asset allocation is ${model.label.toLowerCase()}.',
          description: '${alloc.equityPct.toStringAsFixed(0)}% equity allocation calibrated against fixed income and liquid reserves.',
          gaugeColor: model.activeColor,
          gradientColors: model.gradientColors,
          fillPercentage: model.activeSegments / 5,
          onNext: _nextStep,
        );
      case WalkStep.performanceIntro:
        return _intro(WalkStep.performanceIntro);
      case WalkStep.performanceResult:
        if (performanceAsync.hasError) return _buildError('performance');
        final perf = performanceAsync.value;
        if (perf == null) return _intro(WalkStep.performanceResult, holding: true);
        final model = perf.level;
        return AnalysisResultView(
          key: const ValueKey('performanceResult'),
          type: ResultType.performance,
          mode: model.label,
          scoreText: 'Blended return of +${perf.totalReturnPct.toStringAsFixed(1)}% across holdings.',
          description: 'Your portfolio performance is actively beating broad fixed deposits and benchmark indices.',
          gaugeColor: model.activeColor,
          gradientColors: model.gradientColors,
          fillPercentage: model.activeSegments / 5,
          onNext: _nextStep,
        );
    }
  }
}
