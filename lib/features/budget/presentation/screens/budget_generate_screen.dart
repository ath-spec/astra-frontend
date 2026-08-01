import 'package:go_router/go_router.dart';
import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/services/service_providers.dart';
import 'package:astra_frontend/features/budget/data/budget_mock_providers.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/category_item_model.dart';

class BudgetGenerateScreen extends ConsumerStatefulWidget {
  final double totalBudget;
  final List<CategoryAllocation> allocations;
  final List<CategoryItem> categoryList;

  const BudgetGenerateScreen({
    super.key,
    required this.totalBudget,
    required this.allocations,
    required this.categoryList,
  });

  @override
  ConsumerState<BudgetGenerateScreen> createState() =>
      _BudgetGenerateScreenState();
}

class _BudgetGenerateScreenState extends ConsumerState<BudgetGenerateScreen> {
  int _textIndex = 0;
  final List<String> _loadingTexts = [
    "Saving your preferences...",
    "Generating final budget plan...",
    "Setting up budget control center for you...",
  ];

  Timer? _textTimer;
  bool _hasError = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGeneration();
    });

    _textTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_hasError) return;
      if (_textIndex < _loadingTexts.length - 1) {
        setState(() {
          _textIndex++;
        });
      }
    });
  }

  Future<void> _startGeneration({bool isRetry = false}) async {
    if (!mounted || _isAnalyzing) return;
    _isAnalyzing = true;

    if (!isRetry) {
      setState(() {
        _hasError = false;
        _loadingTexts.removeWhere((text) =>
            text.contains("Retrying...") ||
            text.contains("Reconnect...") ||
            text.contains("Went wrong") ||
            text.contains("Server error"));
        if (_textIndex >= _loadingTexts.length) {
          _textIndex = _loadingTexts.length - 1;
        }
      });
    }

    final budgetState = ref.read(budgetStateProvider);
    try {
      await budgetState.generateBudget(
        totalBudget: widget.totalBudget,
        allocations: widget.allocations,
        categoryList: widget.categoryList,
      );

      if (mounted) {
        // Delay one microtask so notifyListeners() propagates fully
        // before the home BudgetSection rebuilds (avoids stale-state flash)
        Future.microtask(() {
          if (mounted) {
            context.go('/');
            context.push('/budget-control');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        if (!isRetry) {
          setState(() {
            _hasError = true;
            String errMsg = "Something went wrong. Retrying...";
            if (!_loadingTexts.contains(errMsg)) {
              _loadingTexts.add(errMsg);
            }
            _textIndex = _loadingTexts.indexOf(errMsg);
          });
        }

        _isAnalyzing = false;
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && _hasError) {
            _startGeneration(isRetry: true);
          }
        });
      }
    }
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
                    'lib/core/images/budget_loading.webp',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Loading Text with Fade
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _loadingTexts[_textIndex],
                  key: ValueKey<int>(_textIndex),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DMSans',
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
