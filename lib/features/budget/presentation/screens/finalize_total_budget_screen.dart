import 'package:go_router/go_router.dart';
import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/services/service_providers.dart';
import 'package:astra_frontend/services/finance_repository.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/core/instrumentation/funnel_tracker.dart';
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';
import 'package:astra_frontend/features/budget/presentation/screens/budget_category_analyzing_screen.dart';
import 'package:astra_frontend/features/budget/presentation/screens/budget_control_screen.dart';
import 'package:astra_frontend/features/budget/presentation/screens/set_budget_category_screen.dart';
import 'package:astra_frontend/services/analytics_service.dart';

class FinalizeBudgetScreen extends ConsumerStatefulWidget {
  final double totalBudget;
  final bool isManual;
  final bool isRolloverModify;
  
  const FinalizeBudgetScreen({
    super.key,
    required this.totalBudget,
    this.isManual = false,
    this.isRolloverModify = false,
  });

  @override
  ConsumerState<FinalizeBudgetScreen> createState() =>
      _FinalizeBudgetScreenState();
}

class _FinalizeBudgetScreenState extends ConsumerState<FinalizeBudgetScreen> {
  // Configured logic
  double _currentBudget = 0;
  double _income = 0;
  double _typicalSpend = 0;
  double _suggestedBudget = 0;
  final currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  late final TextEditingController _budgetController;
  bool _isLoading = false;
  BudgetConflictException? _conflictError;
  bool _hasNoData = false;

  String _formatCompact(double value) {
    if (value.abs() >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}Cr';
    } else if (value.abs() >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}L';
    } else if (value.abs() >= 10000) {
      return '₹${(value / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
    } else {
      return currencyFormat.format(value);
    }
  }

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('finalize_total_budget_screen');
    FunnelTracker.instance.logStep('budget_creation', stepNumber: 6, stepName: 'finalize_total');
    
    _currentBudget = widget.totalBudget;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = ref.read(budgetStateProvider);
      
      if (widget.isRolloverModify && state.currentDiagnosis == null) {
        setState(() => _isLoading = true);
        try {
          await state.fetchDiagnosis();
        } catch (e) {
          debugPrint('Failed to fetch diagnosis for rollover modify: $e');
        }
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }

      if (!mounted) return;
      final diag = state.currentDiagnosis;
      setState(() {
        _hasNoData = widget.isRolloverModify ? false : (diag?.historicalSpending.isEmpty ?? true);
        
        _suggestedBudget = diag?.suggestedTotalBudget ?? _currentBudget;

        // If the slider is currently stuck at 0 (e.g. new user), and there IS a valid suggested budget from the backend, snap to it.
        // If the backend also returned 0 (or no ML call was made), it will just stay at 0 and force the user to type it in.
        if (_currentBudget <= 0 && _suggestedBudget > 0) {
          _currentBudget = _suggestedBudget;
          _budgetController.text = _currentBudget.toStringAsFixed(0);
        }

        _income = diag?.averageIncome ?? (_currentBudget * 1.06);
        _typicalSpend = diag?.averageExpenses ?? (_currentBudget * 1.05);
      });
    });

    _budgetController = TextEditingController(
      text: _currentBudget.toStringAsFixed(0),
    );
    // Initial dummy values until frame callback
    _income = _currentBudget * 1.06;
    _typicalSpend = _currentBudget * 1.05;
    _suggestedBudget = _currentBudget;
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  // Return the styling based on the budget value
  Color _getCardColor() {
    if (_currentBudget > _income) {
      return BudgetColors.errorBg; // Light Red
    } else if (_currentBudget < _typicalSpend) {
      return const Color(0xFFEFEEE2); // Olive/Khaki
    } else {
      return BudgetColors.successBg; // Light Green
    }
  }

  Color _getTextColor() {
    if (_currentBudget > _income) {
      return const Color(0xFFB71C1C); // Dark Red
    } else if (_currentBudget < _typicalSpend) {
      return const Color(0xFF5A5734); // Dark Olive
    } else {
      return BudgetColors.darkGreen; // Dark Green
    }
  }

  Widget _buildSavingsText() {
    final double diff = _income - _currentBudget;
    final double yearly = diff * 12;
    final String yearlyStr = _formatCompact(yearly);

    final spendDiff = _typicalSpend - _currentBudget;
    final String spendStr = spendDiff >= 0 ? "less" : "more";
    final double absSpendDiff = spendDiff.abs();

    if (_currentBudget > _income) {
      // Deficit Red
      final deficit = _currentBudget - _income;
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: "Your budget exceeds income by "),
            TextSpan(
              text: "${_formatCompact(deficit)}/month",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: ", meaning you'll dip into savings or incur debt.\n",
            ),
            TextSpan(text: "You'd be spending "),
            TextSpan(
              text: _formatCompact(absSpendDiff),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: " $spendStr than your typical "),
            TextSpan(
              text: _formatCompact(_typicalSpend),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: " spend. consider cutting back to save more."),
          ],
        ),
        textAlign: TextAlign.left,
        style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
          fontSize: 12,
          color: _getTextColor(),
          height: 1.5,
        ),
      );
    } else if (_currentBudget < _typicalSpend) {
      // Ambitious Olive
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: "Saving "),
            TextSpan(
              text: "${_formatCompact(diff)}/month ($yearlyStr/yr)",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: " is an ambitious goal.\n"),
            TextSpan(text: "Your budget is "),
            TextSpan(
              text: _formatCompact(absSpendDiff),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: " $spendStr than your typical "),
            TextSpan(
              text: _formatCompact(_typicalSpend),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: " spend."),
          ],
        ),
        textAlign: TextAlign.left,
        style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
          fontSize: 12,
          color: _getTextColor(),
          height: 1.5,
        ),
      );
    } else {
      // Ideal Green
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: "You're set to save "),
            TextSpan(
              text: "${_formatCompact(diff)}/month ($yearlyStr/yr)",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: ".\n"),
            TextSpan(text: "Your budget is "),
            TextSpan(
              text: _formatCompact(absSpendDiff),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: " $spendStr than your typical "),
            TextSpan(
              text: _formatCompact(_typicalSpend),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: " spend."),
          ],
        ),
        textAlign: TextAlign.left,
        style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
          fontSize: 12,
          color: _getTextColor(),
          height: 1.5,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFfaf5ea),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SizedBox.expand(
            child: Stack(
            children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: getProportionateScreenHeight(180),
                  ), // Space for floating button
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top header
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                          child: ZeyroIconButton(
                            eventName: 'finalize_total_budget_screen_back_tapped',
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: BudgetColors.black,
                              size: 20,
                            ),
                            onPressed: () { Navigator.of(context).pop(); },
                          ),
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(12)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(24),
                          ),
                          child: Text("Finalize your budget",
                            style: TextStyle(fontFamily: 'DMSans', 
                              fontSize: getProportionateScreenWidth(26),
                              fontWeight: FontWeight.w600,
                              color: BudgetColors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(12)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(24),
                          ),
                          child: Text(
                            _hasNoData
                                ? "Since we dont have any data on you we would suggest using the standard 50-30-20 rule."
                                : "Based on your ${_formatCompact(_income)} income, here's your ideal spending range.",
                            style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
                              fontSize: 12,
                              color: BudgetColors.grey7,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),

                      SizedBox(height: getProportionateScreenHeight(20)),

                      // Big Budget Box
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(24),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 40,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0XFFffdf80),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text("Monthly budget",
                                style: TextStyle(fontFamily: 'DMSans', 
                                  fontSize: 14,
                                  color: BudgetColors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Custom bold budget display with edit capability
                              Container(
                                width: 250,
                                padding: const EdgeInsets.only(bottom: 4),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: BudgetColors.black,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  controller: _budgetController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                    LengthLimitingTextInputFormatter(8),
                                  ],
                                  style: TextStyle(fontFamily: 'DMSans', 
                                    fontSize: 44,
                                    fontWeight: FontWeight.w600,
                                    color: BudgetColors.black,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    prefixText: '₹',
                                    prefixStyle: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600,
                                      color: BudgetColors.black,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    final double? parsed = double.tryParse(val);
                                    setState(() {
                                      _currentBudget = parsed ?? 0;
                                      _conflictError = null;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Custom Dial Scroll
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: _BudgetDial(
                                  value: _currentBudget,
                                  minValue: 0,
                                  maxValue: 99999999.0,
                                  stepCount: 99999,
                                  onChanged: (val) {
                                    setState(() {
                                      _currentBudget = val;
                                      _conflictError =
                                          null; // Clear error on edit
                                      final newText = val.toStringAsFixed(0);
                                      if (_budgetController.text != newText) {
                                        _budgetController.text = newText;
                                        _budgetController.selection =
                                            TextSelection.fromPosition(
                                              TextPosition(
                                                offset: newText.length,
                                              ),
                                            );
                                      }
                                    });
                                  },
                                ),
                              ),

                              if (!_hasNoData) ...[
                                const SizedBox(height: 40),
                                Text("Stay within ${_formatCompact(_suggestedBudget * 0.9)} - ${_formatCompact(_suggestedBudget * 1.1)} to stay on track.",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
                                    fontSize: 12,
                                    color: BudgetColors.grey7,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      if (!_hasNoData) ...[
                        SizedBox(height: getProportionateScreenHeight(30)),

                        // Reactive Savings Card (Now part of the main column)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_conflictError != null) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: BudgetColors.errorBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFB71C1C),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.warning_amber_rounded,
                                            color: Color(0xFFB71C1C),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text("Budget conflict",
                                            style: TextStyle(fontFamily: 'DMSans', 
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1,
                                              color: const Color(0xFFB71C1C),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _conflictError!.type == 'scalable_floor_exceeded'
                                            ? "Your new budget covers your protected bills, but doesn't leave enough room for your other categories. you are short by ₹${_conflictError!.amount.toStringAsFixed(0)}."
                                            : "You have a conflict in your budget allocation.",
                                        style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
                                          fontSize: 13,
                                          color: const Color(0xFFB71C1C),
                                          height: 1.5,
                                        ),
                                      ),
                                      if (_conflictError!.conflicts.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          _conflictError!.type == 'scalable_floor_exceeded'
                                            ? (_conflictError!.conflicts.length > 1
                                                ? "Flexible categories: " + _conflictError!.conflicts.map((c) => c.replaceAll('_', ' ').toLowerCase()).join(', ')
                                                : "Flexible category: " + _conflictError!.conflicts.first.replaceAll('_', ' ').toLowerCase())
                                            : (_conflictError!.conflicts.length > 1
                                                ? "Fixed categories: " + _conflictError!.conflicts.map((c) => c.replaceAll('_', ' ').toLowerCase()).join(', ')
                                                : "Fixed category: " + _conflictError!.conflicts.first.replaceAll('_', ' ').toLowerCase()),
                                          style: TextStyle(fontFamily: 'DMSans', 
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFB71C1C),
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: getProportionateScreenHeight(20),
                                ),
                              ],
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: _getCardColor(),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Your potential savings".toLowerCase(),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontFamily: 'DMSans', 
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                        color: _getTextColor(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSavingsText(),
                                  ],
                                ),
                              ), // closes if (_conflictError != null) ...[
                            ], // closes children of Column
                          ),
                        ),
                      ], // closes if (!_hasNoData) ...[
                    ], // closes children of main Column
                  ),
                ),
              ),
            ),

            // Floating Continue Button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: getProportionateScreenWidth(32),
                    right: getProportionateScreenWidth(32),
                    bottom: getProportionateScreenHeight(16),
                  ),
                  child: ZeyroButton(
                    eventName:
                        'finalize_total_budget_screen_review_categories_tapped',
                    onPressed: _isLoading
                        ? null
                        : () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            if (_currentBudget <= 0) {
                              ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
        const SnackBar(behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 1500), 
                                  content: Text("Budget cannot be zero"),
                                  backgroundColor: Color(0xFFB71C1C),
                                ),
                              );
                              return;
                            }
                            
                            AnalyticsService.instance.logEvent('budget_finalized', properties: {
                              'suggested_budget_amount': _suggestedBudget,
                              'final_budget_amount': _currentBudget,
                              'was_changed': _currentBudget != _suggestedBudget,
                              'is_manual': widget.isManual,
                              'is_rollover_modify': widget.isRolloverModify,
                            });
                            
                            setState(() => _isLoading = true);
                            try {
                              final budgetState = ref.read(budgetStateProvider);

                              // If we don't have a session yet (e.g. user had no data), create one
                              if (budgetState.currentSessionId == null ||
                                  budgetState.currentSessionId!.isEmpty) {
                                final now = DateTime.now();
                                final month =
                                    '${now.year}-${now.month.toString().padLeft(2, '0')}';
                                await budgetState.createSession(
                                  _currentBudget,
                                  month: month,
                                );
                              }

                              final sessionId = budgetState.currentSessionId;
                              if (sessionId != null && sessionId.isNotEmpty) {
                                await FinanceRepository(
                                  dioApiClient,
                                ).updateBudgetSession(
                                  sessionId: sessionId,
                                  totalBudget: _currentBudget,
                                );

                                if (widget.isManual) {
                                  await budgetState.finalizeSession(
                                    totalBudget: _currentBudget,
                                    allocations: [],
                                  );
                                  await budgetState.fetchLatestDashboard();
                                }
                              }
                            } catch (e) {
                              debugPrint(
                                'session update/create failed (non-fatal): $e',
                              );
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }

                            if (mounted) {
                                if (widget.isManual) {
                                  // Manual flow: go directly to budget screen
                                  context.go('/');
                                  context.push('/budget-control');
                                } else if (widget.isRolloverModify && _currentBudget == widget.totalBudget) {
                                  // Modify flow, but total budget was NOT changed:
                                  // Skip ML suggestion and go directly to category adjustment screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SetBudgetCategoryScreen(
                                        totalBudget: _currentBudget,
                                      ),
                                    ),
                                  );
                                } else {
                                  // Normal flow (or modify flow with changed total): analyze categories via ML
                                  final diag = ref
                                      .read(budgetStateProvider)
                                      .currentDiagnosis;
                                  if (!widget.isRolloverModify && (diag?.historicalSpending.isEmpty ?? true)) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SetBudgetCategoryScreen(
                                              totalBudget: _currentBudget,
                                            ),
                                      ),
                                    );
                                  } else {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BudgetCategoryAnalyzingScreen(
                                              totalBudget: _currentBudget,
                                            ),
                                      ),
                                    );

                                    if (mounted &&
                                        result is BudgetConflictException) {
                                      AnalyticsService.instance.logEvent('budget_ml_conflict_detected', properties: {
                                        'conflict_type': result.type,
                                        'conflict_amount': result.amount,
                                        'conflicting_categories': result.conflicts.join(','),
                                      });
                                      setState(() {
                                        _conflictError = result;
                                      });
                                    }
                                  }
                                }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BudgetColors.black,
                      foregroundColor: BudgetColors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      shadowColor: BudgetColors.black.withOpacity(0.3),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: BudgetColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text("Continue",
                            style: TextStyle(fontFamily: 'DMSans', 
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}

// Custom DMSansactive dial mapped exactly to standard slider API
class _BudgetDial extends StatefulWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final int stepCount;
  final ValueChanged<double> onChanged;

  const _BudgetDial({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.stepCount,
    required this.onChanged,
  });

  @override
  State<_BudgetDial> createState() => _BudgetDialState();
}

class _BudgetDialState extends State<_BudgetDial> {
  late final ScrollController _scrollController;
  final double _tickWidth = 14.0; // Distance between ticks

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: _valueToOffset(widget.value),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _BudgetDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value ||
        widget.maxValue != oldWidget.maxValue ||
        widget.minValue != oldWidget.minValue ||
        widget.stepCount != oldWidget.stepCount) {
      if (_scrollController.hasClients) {
        final expectedOffset = _valueToOffset(widget.value);
        if ((_scrollController.offset - expectedOffset).abs() > 1.0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scrollController.hasClients) {
              _jumpToValue(widget.value);
            }
          });
        }
      }
    }
  }

  double get _valueRange => widget.maxValue - widget.minValue;

  double _offsetToValue(double offset) {
    double valuePerTick = _valueRange.isInfinite
        ? 10.0
        : (_valueRange / widget.stepCount);
    double rawValue = widget.minValue + (offset / _tickWidth) * valuePerTick;
    return rawValue.clamp(widget.minValue, widget.maxValue);
  }

  double _valueToOffset(double val) {
    double valuePerTick = _valueRange.isInfinite
        ? 10.0
        : (_valueRange / widget.stepCount);
    return ((val - widget.minValue) / valuePerTick) * _tickWidth;
  }

  void _jumpToValue(double val) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_valueToOffset(val));
    }
  }

  void _step(int stepSign) {
    // For manual buttons on a large range, stepping 1 division (₹10) feels too slow, let's step by ₹100
    double newTarget = (widget.value + (stepSign * 100))
        .clamp(widget.minValue, widget.maxValue)
        // round cleanly to nearest 100
        .roundToDouble();

    // Snap cleanly
    widget.onChanged(newTarget);
    _jumpToValue(newTarget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: BudgetColors.white, // Match background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: BudgetColors.black12), // Subtle border
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // padding required to center the first/last elements
          final paddingAmount = constraints.maxWidth / 2;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Scroll Area
              NotificationListener<ScrollNotification>(
                onNotification: (notif) {
                  if (notif is ScrollUpdateNotification) {
                    final newValue = _offsetToValue(_scrollController.offset);
                    widget.onChanged(newValue);
                  }
                  return true;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: paddingAmount),
                  itemExtent: _tickWidth,
                  // If infinite, itemCount is null for infinite scrolling
                  itemCount: widget.maxValue.isInfinite
                      ? null
                      : widget.stepCount + 1, // inclusive of 0th to last
                  itemBuilder: (context, index) {
                    // Make every 10th line taller
                    bool isMajorTick = index % 10 == 0;
                    return Container(
                      width: _tickWidth,
                      alignment: Alignment.center,
                      child: Container(
                        width: isMajorTick ? 2.0 : 1.0,
                        height: isMajorTick ? 30.0 : 15.0,
                        decoration: BoxDecoration(
                          color: isMajorTick ? BudgetColors.black : Colors.black26,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Shadow overlays for the edges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      gradient: LinearGradient(
                        colors: [BudgetColors.white, BudgetColors.white.withOpacity(0.0)],
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      gradient: LinearGradient(
                        colors: [BudgetColors.white.withOpacity(0.0), BudgetColors.white],
                      ),
                    ),
                  ),
                ],
              ),

              // Fixed Center Selector Line & Chevron Buttons overtop
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ZeyroIconButton(
                    eventName:
                        'finalize_total_budget_screen_quick_edit_clear_tapped',
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: BudgetColors.grey7,
                      size: 28,
                    ),
                    onPressed: widget.value > widget.minValue
                        ? () => _step(-1)
                        : null,
                  ),
                  // Center Selector
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: BudgetColors.black,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: BudgetColors.black.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  ZeyroIconButton(
                    eventName:
                        'finalize_total_budget_screen_quick_edit_save_tapped',
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: BudgetColors.grey7,
                      size: 28,
                    ),
                    onPressed: widget.value < widget.maxValue
                        ? () => _step(1)
                        : null,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

