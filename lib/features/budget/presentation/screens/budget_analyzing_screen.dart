import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/services/service_providers.dart';
import 'package:astra_frontend/features/budget/presentation/screens/budget_intro_diagnosis_screen.dart';


class BudgetAnalyzingScreen extends ConsumerStatefulWidget {
  final double totalBudget;
  const BudgetAnalyzingScreen({super.key, this.totalBudget = 0.0});

  @override
  ConsumerState<BudgetAnalyzingScreen> createState() =>
      _BudgetAnalyzingScreenState();
}

class _BudgetAnalyzingScreenState extends ConsumerState<BudgetAnalyzingScreen> {
  int _textIndex = 0;
  final List<String> _loadingTexts = [
    "Agent is analyzing your cash flow...",
    "Agent is reviewing your spending habits...",
    "Agent is generating a plan...",
  ];

  Timer? _textTimer;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnalysis();
    });

    _textTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_hasError) return; // Stop cycling texts if there's an error

      if (_textIndex < _loadingTexts.length - 1) {
        setState(() {
          _textIndex++;
        });
      } else {
        // We finished the initial texts. Now wait for the diagnosis to be ready.
        final state = ref.read(budgetStateProvider);
        if (!state.isLoadingDiagnosis && state.currentDiagnosis != null) {
          timer.cancel();
          _navigateToNext();
        } else {
          // If still loading, maybe add a final "hanging" text or just wait
          if (!_loadingTexts.contains("Finalizing your plan...")) {
            setState(() {
              _loadingTexts.add("Finalizing your plan...");
              _textIndex = _loadingTexts.length - 1;
            });
          }
        }
      }
    });
  }

  bool _isAnalyzing = false;

  Future<void> _startAnalysis({bool isRetry = false}) async {
    if (!mounted || _isAnalyzing) return;
    _isAnalyzing = true;

    if (!isRetry) {
      setState(() {
        _hasError = false;
        // Reset text if we were showing an error
        if (_loadingTexts.contains(
          "No internet connection. waiting to reconnect...",
        )) {
          _loadingTexts.remove(
            "No internet connection. waiting to reconnect...",
          );
          if (_textIndex >= _loadingTexts.length) {
            _textIndex = _loadingTexts.length - 1;
          }
        }
      });
    }


    try {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted && _hasError) setState(() => _hasError = false);
    } catch (e) {
      if (mounted) {
        _isAnalyzing = false;
      }
    }
  }

  void _navigateToNext() {
    if (!mounted) return;
    final diagnosis = ref.read(budgetStateProvider).currentDiagnosis;
    final suggestedBudget = diagnosis?.suggestedTotalBudget ?? 0.0;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BudgetIntroDiagnosisScreen(totalBudget: suggestedBudget),
      ),
    );
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xffece9ea),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Static Image Center
              SizedBox(
                width: 280,
                height: 280,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'lib/core/images/budget_analysis.webp',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // const SizedBox(height: 20),
              // Loading Text with Fade
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _loadingTexts[_textIndex],
                  key: ValueKey<int>(_textIndex),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'DMSans', 
                    color: BudgetColors.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
