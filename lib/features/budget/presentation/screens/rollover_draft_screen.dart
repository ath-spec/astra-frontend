import 'package:astra_frontend/features/budget/theme/budget_colors.dart';

import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/services/service_providers.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/category_item_model.dart';
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';

import 'package:astra_frontend/features/budget/presentation/screens/finalize_total_budget_screen.dart';
import 'package:astra_frontend/features/budget/presentation/screens/budget_generate_screen.dart';
import 'package:astra_frontend/features/budget/data/models/budget_models.dart' hide CategoryAllocation;
import 'package:astra_frontend/services/analytics_repository.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:astra_frontend/services/analytics_service.dart';

class RolloverDraftScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final bool isFallback;

  const RolloverDraftScreen({
    super.key,
    required this.sessionId,
    required this.isFallback,
  });

  @override
  ConsumerState<RolloverDraftScreen> createState() => _RolloverDraftScreenState();
}

class _RolloverDraftScreenState extends ConsumerState<RolloverDraftScreen> {
  final currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  BudgetSetupSession? _session;
  List<CategoryItem> _categories = [];
  bool _isLoading = true;
  bool _isFinalizing = false;

  bool _hasError = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('rollover_draft_screen');
    _loadSession();
    
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          if (_hasError || (_session == null && !_isLoading)) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
            _loadSession();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadSession() async {
    final repo = ref.read(analyticsRepositoryProvider);
    final session = await repo.getBudgetSetupSession(widget.sessionId);
    if (mounted) {
      if (session != null) {
        _session = session;
        _categories = session.categoryAllocations.map((s) {
          String name = s.categoryName ?? s.categoryId;
          if (name.isEmpty) {
            name = 'unknown category';
          }

          IconData icon = _getIconForName(name);
          Color color = _parseColor(s.categoryColor ?? '', fallback: BudgetColors.successBg);

          return CategoryItem(
            categoryId: s.categoryId,
            title: name,
            icon: icon,
            iconColor: color,
            suggestedAmount: s.amount,
            isSet: true, // Default to true
          );
        }).toList();

        if (_categories.isEmpty) {
          _categories = [
            CategoryItem(
              categoryId: "other",
              title: "Other",
              icon: Icons.category_rounded,
              iconColor: Colors.blueGrey,
              suggestedAmount: session.totalBudget,
              isSet: true,
            ),
          ];
        }

        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  bool get _anyCategorySet => _categories.any((c) => c.isSet);

  void _toggleCategorySet(CategoryItem category) {
    setState(() {
      category.isSet = !category.isSet;
    });
  }

  Future<void> _handleAccept() async {
    if (_session == null) return;
    setState(() => _isFinalizing = true);

    const validCategorySlugs = {
      'food_dining', 'transportation', 'entertainment',
      'utilities', 'savings', 'healthcare', 'education',
      'shopping', 'travel', 'insurance',
    };

    final selectedCategories = _categories.where((c) => c.isSet).toList();

    final allocations = selectedCategories
        .map((c) => CategoryAllocation(
              categoryId: c.categoryId ?? c.title.toLowerCase(),
              amount: c.suggestedAmount,
              isTracking: true,
            ))
        .where((a) => validCategorySlugs.contains(a.categoryId))
        .toList();

    final budgetState = ref.read(budgetStateProvider);
    budgetState.currentSessionId = _session!.id;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetGenerateScreen(
          totalBudget: _session!.totalBudget,
          allocations: allocations,
          categoryList: selectedCategories,
        ),
      ),
    );
  }

  Future<void> _handleModify() async {
    if (_session == null) return;
    setState(() => _isFinalizing = true);

    // Send the user to the total budget slider screen (FinalizeBudgetScreen).
    // The backend already generated category allocations for the rollover draft.
    // We load them into the global budgetState so SetBudgetCategoryScreen can display them.
    final budgetState = ref.read(budgetStateProvider);
    budgetState.currentSessionId = _session!.id;
    budgetState.suggestedCategories = _session!.categoryAllocations.map((a) {
      return CategorySuggestion(
        categoryId: a.categoryId,
        categoryName: a.categoryName ?? 'Category',
        suggestedAmount: a.amount,
        confidenceScore: 1.0,
        adjustmentBounds: AdjustmentBounds(
          minRecommended: a.amount * 0.5,
          maxRecommended: a.amount * 1.5,
        ),
      );
    }).toList();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinalizeBudgetScreen(
          totalBudget: _session!.totalBudget,
          isManual: false,
          isRolloverModify: true,
        ),
      ),
    );

    if (mounted) {
      setState(() => _isFinalizing = false);
    }
  }


  Future<void> _handleNotNow() async {
    final repo = ref.read(analyticsRepositoryProvider);
    await repo.rejectBudgetSetupSession(widget.sessionId);
    if (mounted) {
      ref.read(budgetStateProvider).clearPendingRollover();
      Navigator.of(context).pop(true); // Return true to trigger dashboard refresh
    }
  }

  Color _parseColor(String hexColor, {required Color fallback}) {
    if (hexColor.isEmpty) return fallback;
    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  IconData _getIconForName(String name) {
    final n = name.toLowerCase();
    if (n.contains('grocer') || n.contains('food')) return Icons.shopping_basket_rounded;
    if (n.contains('trans') || n.contains('travel') || n.contains('cab')) return Icons.directions_car_rounded;
    if (n.contains('utilit') || n.contains('bill')) return Icons.bolt_rounded;
    if (n.contains('house') || n.contains('rent')) return Icons.home_rounded;
    if (n.contains('shop')) return Icons.shopping_bag_rounded;
    if (n.contains('health') || n.contains('medic')) return Icons.medical_services_rounded;
    if (n.contains('dine') || n.contains('restaurant') || n.contains('dining')) return Icons.restaurant_rounded;
    return Icons.category_rounded;
  }

  String _currentMonthName() {
    final now = DateTime.now();
    final monthNames = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december'
    ];
    return monthNames[now.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFfaf5ea),
        body: Center(child: CircularProgressIndicator(color: BudgetColors.black)),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFFfaf5ea),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Unable to load budget draft',
                  style: TextStyle(fontFamily: 'DMSans', color: BudgetColors.black)),
              const SizedBox(height: 16),
              ZeyroButton(eventName: 'rollover_draft_screen_retry_tapped',
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _loadSession();
                },
                style: ElevatedButton.styleFrom(backgroundColor: BudgetColors.black),
                child: const Text('Retry', style: TextStyle(color: BudgetColors.white)),
              ),
              const SizedBox(height: 8),
              TextButton(
                  onPressed: () { AnalyticsService.instance.logEvent('back_button_tapped', properties: {'screen': 'rollover_draft_screen'}); Navigator.of(context).pop(); },
                  child: const Text('Close', style: TextStyle(color: BudgetColors.black))),
            ],
          ),
        ),
      );
    }

    if (_session == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFfaf5ea),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Draft expired or unavailable',
                  style: TextStyle(fontFamily: 'DMSans', color: BudgetColors.black)),
              const SizedBox(height: 16),
              TextButton(
                  onPressed: () { AnalyticsService.instance.logEvent('back_button_tapped', properties: {'screen': 'rollover_draft_screen'}); Navigator.of(context).pop(); },
                  child: const Text('Close', style: TextStyle(color: BudgetColors.black))),
            ],
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFfaf5ea),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                      child: ZeyroIconButton(
                        eventName: 'rollover_draft_screen_back_tapped',
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: BudgetColors.black,
                          size: 20,
                        ),
                        onPressed: () { AnalyticsService.instance.logEvent('back_button_tapped', properties: {'screen': 'rollover_draft_screen'}); Navigator.of(context).pop(); },
                      ),
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(8)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(24),
                    ),
                    child: Text(
                      "${_currentMonthName()}'s budget",
                      style: TextStyle(fontFamily: 'DMSans', 
                        fontSize: getProportionateScreenWidth(26),
                        fontWeight: FontWeight.w600,
                        color: BudgetColors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(12)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(24),
                    ),
                    child: Text(
                      widget.isFallback
                          ? "we've prepared a baseline budget for you. review and adjust as needed."
                          : "we've drafted the perfect budget for ${_session!.month} to help you hit your goals.",
                      style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: BudgetColors.grey7),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(24)),
                  // Total Budget Display
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(24),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: BudgetColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: BudgetColors.black.withValues(alpha: 0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: BudgetColors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Budget',
                              style: TextStyle(fontFamily: 'DMSans', 
                                  color: BudgetColors.grey7, fontSize: 16)),
                          Text(
                              currencyFormat.format(_session!.totalBudget),
                              style: TextStyle(fontFamily: 'DMSans', 
                                  color: BudgetColors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(24)),
                  // Categories List
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(32),
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.only(
                          bottom: getProportionateScreenHeight(220),
                        ), // Space for floating buttons
                        itemCount: _categories.length,
                        separatorBuilder: (context, index) => Divider(
                          color: BudgetColors.black.withValues(alpha: 0.05),
                          height: 32,
                        ),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          return InkWell(
                            onTap: () => _toggleCategorySet(cat),
                            highlightColor: Colors.transparent,
                            splashColor: BudgetColors.black.withValues(alpha: 0.02),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cat.iconColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    cat.icon,
                                    color: cat.iconColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cat.title,
                                        style: TextStyle(fontFamily: 'DMSans', 
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: BudgetColors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.auto_awesome,
                                            size: 12,
                                            color: BudgetColors.grey7,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "suggested: ${currencyFormat.format(cat.suggestedAmount)}/mo",
                                            style: TextStyle(fontFamily: 'DMSans', 
                                              fontSize: 12,
                                              color: BudgetColors.grey7,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  cat.isSet
                                      ? Icons.check_circle_rounded
                                      : Icons.add_rounded,
                                  color: cat.isSet ? BudgetColors.successText : Colors.black45,
                                  size: 28,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating Bottom Actions
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (_) {},
                child: Container(
                  color: const Color(0xFFfaf5ea),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: getProportionateScreenWidth(32),
                        right: getProportionateScreenWidth(32),
                        bottom: getProportionateScreenHeight(8),
                        top: getProportionateScreenHeight(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ZeyroButton(
                            eventName: 'rollover_accept_tapped',
                            onPressed: (_anyCategorySet && !_isFinalizing)
                                ? _handleAccept
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BudgetColors.black,
                              foregroundColor: BudgetColors.white,
                              disabledBackgroundColor: BudgetColors.black12,
                              disabledForegroundColor: Colors.black38,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: _anyCategorySet ? 4 : 0,
                            ),
                            child: _isFinalizing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: BudgetColors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "accept & apply",
                                    style: TextStyle(fontFamily: 'DMSans', 
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          SizedBox(height: getProportionateScreenHeight(8)),
                          OutlinedButton(
                            onPressed: _isFinalizing ? null : _handleModify,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: BudgetColors.black,
                              side: const BorderSide(color: BudgetColors.black12, width: 1.5),
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "modify",
                              style: TextStyle(fontFamily: 'DMSans', 
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: BudgetColors.foreground,
                              ),
                            ),
                          ),
                          SizedBox(height: getProportionateScreenHeight(4)),
                          TextButton(
                            onPressed: _isFinalizing ? null : _handleNotNow,
                            style: TextButton.styleFrom(
                              foregroundColor: BudgetColors.grey7,
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: Text(
                              "not now",
                              style: TextStyle(fontFamily: 'DMSans', 
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
