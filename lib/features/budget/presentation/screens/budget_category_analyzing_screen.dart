import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/features/budget/presentation/screens/set_budget_category_screen.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:astra_frontend/services/service_providers.dart';
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';
import 'package:dio/dio.dart';
import 'package:astra_frontend/services/analytics_service.dart';

class BudgetCategoryAnalyzingScreen extends ConsumerStatefulWidget {
  final double totalBudget;
  const BudgetCategoryAnalyzingScreen({super.key, required this.totalBudget});

  @override
  ConsumerState<BudgetCategoryAnalyzingScreen> createState() =>
      _BudgetCategoryAnalyzingScreenState();
}

class _BudgetCategoryAnalyzingScreenState
    extends ConsumerState<BudgetCategoryAnalyzingScreen> {
  int _textIndex = 0;
  final List<String> _loadingTexts = [
    "Reviewing your spending habits...",
    "Generating a budget plan...",
    "Generating category budgets...",
  ];

  Timer? _textTimer;
  bool _hasError = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('budget_category_analyzing_screen');

    // Start API call
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnalysis();
    });

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none) && _hasError) {
        // Small delay to let network settle before retrying
        Future.delayed(const Duration(milliseconds: 500), () {
          _startAnalysis();
        });
      }
    });


    // Text cycler
    _textTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_hasError) return; // Stop cycling texts if there's an error

      if (_textIndex < _loadingTexts.length - 1) {
        setState(() {
          _textIndex++;
        });
      } else {
        // We do NOT cancel the timer here anymore because if there's a slow connection,
        // it might get stuck on the last text instead of error. 
        // We'll let the API call handle the navigation.
      }
    });
  }

  bool _isAnalyzing = false;
  Object? _lastException;

  Future<void> _startAnalysis({bool isRetry = false}) async {
    if (!mounted || _isAnalyzing) return;
    _isAnalyzing = true;

    if (!isRetry) {
      setState(() {
        _hasError = false;
        _loadingTexts.removeWhere((text) => text.contains("Retrying...") || text.contains("reconnect...") || text.contains("went wrong") || text.contains("server error"));
        if (_textIndex >= _loadingTexts.length) {
          _textIndex = _loadingTexts.length - 1;
        }
      });
    }

    final budgetState = ref.read(budgetStateProvider);
    try {
      if (budgetState.currentSessionId == null) {
        await budgetState.createSession(widget.totalBudget);
      }
      
      budgetState.suggestedCategories = [];
      await budgetState.fetchCategorySuggestions(widget.totalBudget);
      
      if (mounted) {
        // Clear error state so the screen shows loading texts again
        if (_hasError) {
          setState(() {
            _hasError = false;
            _loadingTexts.removeWhere((text) => text.contains("Retrying...") || text.contains("reconnect...") || text.contains("went wrong") || text.contains("server error"));
            if (_textIndex >= _loadingTexts.length) {
              _textIndex = _loadingTexts.length - 1;
            }
          });
        }
        // If API is fast, still wait a bit for the animation feel
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SetBudgetCategoryScreen(totalBudget: widget.totalBudget),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (e is BudgetConflictException) {
        if (mounted) {
          Navigator.pop(context, e);
        }
        return;
      }
      
      if (mounted) {
        if (!isRetry) {
          setState(() {
            _hasError = true;
            _lastException = e;
            _loadingTexts.removeWhere((text) => text.contains("Retrying...") || text.contains("reconnect...") || text.contains("went wrong") || text.contains("server error"));
            _loadingTexts.add("No internet connection. Please check network.");
            _textIndex = _loadingTexts.length - 1;
          });
        }
        
        _isAnalyzing = false;
        
        bool shouldAutoRetry = true;
        if (_hasError && _lastException is DioException) {
          final dioErr = _lastException as DioException;
          if (dioErr.response != null && 
              dioErr.response!.statusCode != null && 
              dioErr.response!.statusCode! >= 400 && 
              dioErr.response!.statusCode! < 500) {
            // Check if it's a captive portal
            final isCaptivePortal = dioErr.response!.statusCode == 403 &&
                (dioErr.response?.data?.toString() ?? '').contains('<html');
            if (!isCaptivePortal) {
              shouldAutoRetry = false; // Do not auto-retry 4xx client errors
            }
          }
        }

        if (shouldAutoRetry) {
          // Auto-retry every 5 seconds silently so captive portals login seamlessly resolves
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted && _hasError) {
              _startAnalysis(isRetry: true);
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
              width: getProportionateScreenWidth(280),
              height: getProportionateScreenWidth(280),
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
