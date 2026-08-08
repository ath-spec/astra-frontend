import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:astra_frontend/core/instrumentation/funnel_tracker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/budget_overview_card.dart';
import 'package:astra_frontend/features/budget/presentation/screens/category_budget_screen.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/category_budget_summary_card.dart';
import 'package:astra_frontend/features/budget/presentation/screens/budget_settings_screen.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/category_item_model.dart';

import 'package:astra_frontend/core/routes/app_routes.dart';

import 'package:astra_frontend/features/budget/data/models/budget_models.dart';
import 'package:astra_frontend/services/service_providers.dart';
import 'package:astra_frontend/core/events/data_events.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:astra_frontend/services/analytics_service.dart';

class BudgetControlScreen extends ConsumerStatefulWidget {
  final double totalBudget;
  final List<CategoryItem>? categoryList;
  final String? targetCategoryName;
  const BudgetControlScreen({
    super.key,
    this.totalBudget = 0.0,
    this.categoryList,
    this.targetCategoryName,
  });

  @override
  ConsumerState<BudgetControlScreen> createState() =>
      _BudgetControlScreenState();
}

class _BudgetControlScreenState extends ConsumerState<BudgetControlScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {};

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('budget_control_screen');
    FunnelTracker.instance.logStep(
      'budget_creation',
      stepNumber: 7,
      stepName: 'control_center',
    );
    FunnelTracker.instance.endFunnel('budget_creation', success: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetStateProvider).fetchLatestDashboard();
    });

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (!results.contains(ConnectivityResult.none)) {
        ref.read(budgetStateProvider).fetchLatestDashboard();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final state = ref.watch(budgetStateProvider);
    final dash = state.latestDashboard;
    final totalBudget = dash?.totalBudget ?? widget.totalBudget;
    final spentAmount = dash?.totalSpent ?? state.sessionTotalSpent;

    // Removed auto-scroll logic that caused a jarring jump on load

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: ZeyroIconButton(
                            eventName: 'budget_control_screen_back_tapped',
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFF0F172A),
                              size: 20,
                            ),
                            onPressed: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              } else {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
                              }
                            },
                          ),
                        ),
                      ),
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Budget",
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: getProportionateScreenHeight(24)),

                    // Main Overview Card
                    BudgetOverviewCard(
                      totalBudget: totalBudget,
                      spentAmount: spentAmount,
                      percentageUsed: totalBudget != 0
                          ? spentAmount / totalBudget
                          : 0.0,
                      daysRemaining: (dash?.daysRemainingInMonth ?? 0) > 0
                          ? dash!.daysRemainingInMonth
                          : (DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month + 1,
                                  0,
                                ).day -
                                DateTime.now().day),
                      projectedSpend: dash?.projectedSpend ?? 0,
                      incomeAmount: dash?.incomeAmount ?? 0,
                      budgetPeriodStart: dash?.budgetPeriodStart,
                      budgetPeriodEnd: dash?.budgetPeriodEnd,
                      backgroundColor: _getHealthColor(dash?.status),
                      textColor: _getHealthTextColor(dash?.status),
                      onTopIconTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BudgetSettingsScreen(),
                            settings: const RouteSettings(
                              name: '/budget/settings',
                            ),
                          ),
                        );
                        if (!mounted) return;
                        ref.read(budgetStateProvider).fetchLatestDashboard();
                        DataEvents.triggerDashboardRefresh();
                      },
                    ),
                    SizedBox(height: getProportionateScreenHeight(32)),
                    if (dash != null &&
                        dash.budgets.where((b) => !b.isHidden).isNotEmpty) ...[
                      // Category Budgets Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Category budgets",
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: getProportionateScreenHeight(16)),
                      _buildCategoriesSection(context, dash),
                    ],
                    SizedBox(height: getProportionateScreenHeight(100)),
                  ],
                ),
              ),
            ),
        )],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, dash) {
    if (dash == null || dash.budgets.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text("No budgets set"),
        ),
      );
    }

    final allBudgets = dash.budgets
        .where((b) => b != null && !b.isHidden)
        .toList();

    // Show all categories sent by the backend
    List<BudgetCategoryDetail> budgets = List<BudgetCategoryDetail>.from(
      allBudgets,
    );
    if (widget.targetCategoryName != null) {
      final targetIdx = budgets.indexWhere(
        (b) => b.categoryName == widget.targetCategoryName,
      );
      if (targetIdx == -1) {
        final target = allBudgets.firstWhere(
          (b) => b.categoryName == widget.targetCategoryName,
          orElse: () => allBudgets.first,
        );
        if (target.categoryName == widget.targetCategoryName) {
          budgets.insert(0, target);
        }
      } else if (targetIdx >= 5) {
        final target = budgets.removeAt(targetIdx);
        budgets.insert(0, target);
      }
    }

    final bool hasMoreCategories = budgets.length > 4;
    if (budgets.length > 4) {
      budgets = budgets.take(4).toList();
    }
    final int daysRemaining = (dash.daysRemainingInMonth) > 0
        ? dash.daysRemainingInMonth
        : (DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day -
              DateTime.now().day);

    return Column(
      children: [
        for (int i = 0; i < budgets.length; i += 2) ...[
          Row(
            children: [
              Expanded(
                child: KeyedSubtree(
                  key: _categoryKeys.putIfAbsent(
                    "${budgets[i].categoryId}_$i",
                    () => GlobalKey(),
                  ),
                  child: _buildCategoryCard(context, budgets[i], daysRemaining),
                ),
              ),
              const SizedBox(width: 16),
              if (i + 1 < budgets.length)
                Expanded(
                  child: KeyedSubtree(
                    key: _categoryKeys.putIfAbsent(
                      "${budgets[i + 1].categoryId}_${i + 1}",
                      () => GlobalKey(),
                    ),
                    child: _buildCategoryCard(
                      context,
                      budgets[i + 1],
                      daysRemaining,
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 16),
        if (hasMoreCategories)
          Center(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryBudgetScreen(dash: dash),
                    settings: const RouteSettings(name: '/budget/categories'),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(16),
                  vertical: getProportionateScreenHeight(8),
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "View all categories",
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: getProportionateScreenWidth(12),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF0F172A),
                      size: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    dynamic budget,
    int daysRemaining,
  ) {
    return CategoryBudgetSummaryCard(
      categoryName: budget.categoryName,
      budgetedAmount: budget.budgetedAmount,
      spentAmount: budget.spentAmount,
      percentageUsed: budget.percentageUsed,
      daysRemaining: daysRemaining,
      icon: _getIconForName(budget.categoryName),
      isMini: true,
      backgroundColor: _parseColor(budget.categoryColor, fallback: _getCategoryColor(budget.status)).withValues(alpha: 0.15),
      textColor: _parseColor(budget.categoryTextColor, fallback: _getCategoryTextColor(budget.status)),
      borderColor: const Color(0xFFE2E8F0),
    );
  }

  Color _getHealthColor(String? status) {
    switch (status) {
      case 'warning':
        return const Color(0xFFFEF3C7);
      case 'critical':
        return const Color(0xFFFEE2E2);
      default:
        return const Color.fromARGB(255, 5, 134, 91).withValues(alpha: 0.1);
    }
  }

  Color _getHealthTextColor(String? status) {
    switch (status) {
      case 'warning':
        return const Color(0xFFB45309);
      case 'critical':
        return const Color(0xFF991B1B);
      default:
        return const Color(0xFF0F172A);
    }
  }

  Color _getCategoryColor(String status) {
    switch (status) {
      case 'warning':
        return const Color(0xFFFEF3C7);
      case 'critical':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFECFDF5);
    }
  }

  Color _getCategoryTextColor(String status) {
    switch (status) {
      case 'warning':
        return const Color(0xFFB45309);
      case 'critical':
        return const Color(0xFF991B1B);
      default:
        return const Color.fromARGB(255, 5, 134, 91);
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
    if (n.contains('grocer') || n.contains('food')) {
      return Icons.shopping_basket_rounded;
    }
    if (n.contains('trans') || n.contains('travel') || n.contains('cab')) {
      return Icons.directions_car_rounded;
    }
    if (n.contains('utilit') || n.contains('bill')) return Icons.bolt_rounded;
    if (n.contains('house') || n.contains('rent')) return Icons.home_rounded;
    if (n.contains('shop')) return Icons.shopping_bag_rounded;
    if (n.contains('health') || n.contains('medic')) {
      return Icons.medical_services_rounded;
    }
    if (n.contains('dine') || n.contains('restaurant') || n.contains('dining')) {
      return Icons.restaurant_rounded;
    }
    return Icons.category_rounded;
  }
}
