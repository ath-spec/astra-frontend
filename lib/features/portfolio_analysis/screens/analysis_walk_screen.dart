import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../widgets/analysis_walk/analysis_intro_view.dart';
import '../widgets/analysis_walk/analysis_result_view.dart';
import '../../home/widgets/home_portfolio_analysis.dart';
import '../models/portfolio_analysis_models.dart';

enum WalkStep {
  disciplineIntro,
  disciplineResult,
  allocationIntro,
  allocationResult,
  performanceIntro,
  performanceResult,
}

class AnalysisWalkScreen extends StatefulWidget {
  const AnalysisWalkScreen({super.key});

  @override
  State<AnalysisWalkScreen> createState() => _AnalysisWalkScreenState();
}

class _AnalysisWalkScreenState extends State<AnalysisWalkScreen> {
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
          hasSeenAnalysisWalkthrough.value = true;
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Stack(
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
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
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
                    const SizedBox(width: 40), // Balance the close button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    ),
  );
}

  Widget _buildCurrentView() {
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
        final model = DisciplineLevel.moderate;
        return AnalysisResultView(
          key: const ValueKey('disciplineResult'),
          type: ResultType.discipline,
          mode: model.label,
          scoreText: 'You\'re building good habits.',
          description: 'Your monthly contributions are becoming more consistent, though there\'s room to strengthen your SIP adherence.',
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
        final model = AllocationLevel.veryAggressive;
        return AnalysisResultView(
          key: const ValueKey('allocationResult'),
          type: ResultType.allocation,
          mode: model.label,
          scoreText: 'Your portfolio is highly aggressive.',
          description: 'Heavy concentration in high-risk equity and multiplier assets positions you for sharp swings and high rewards.',
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
        final model = PerformanceLevel.veryStrong;
        return AnalysisResultView(
          key: const ValueKey('performanceResult'),
          type: ResultType.performance,
          mode: model.label,
          scoreText: 'Your portfolio is outperforming the market.',
          description: 'Your XIRR is significantly ahead of the benchmark. Excellent fund quality and smart choices are paying off.',
          gaugeColor: model.activeColor,
          gradientColors: model.gradientColors,
          fillPercentage: model.activeSegments / 5,
          onNext: _nextStep,
        );
    }
  }
}
