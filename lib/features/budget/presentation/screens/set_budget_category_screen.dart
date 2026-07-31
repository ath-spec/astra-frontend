import 'package:astra_frontend/features/budget/theme/budget_colors.dart';

import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/services/service_providers.dart';
import 'package:astra_frontend/features/budget/presentation/screens/budget_control_screen.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/category_item_model.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/ai_set_all_bottom_sheet.dart';
import 'package:astra_frontend/core/routes/app_routes.dart';
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';
import 'package:astra_frontend/features/budget/presentation/screens/budget_generate_screen.dart';
import 'package:astra_frontend/services/finance_repository.dart';
import 'package:astra_frontend/services/analytics_service.dart';


class SetBudgetCategoryScreen extends ConsumerStatefulWidget {
  final double totalBudget;

  const SetBudgetCategoryScreen({super.key, required this.totalBudget});

  @override
  ConsumerState<SetBudgetCategoryScreen> createState() =>
      _SetBudgetCategoryScreenState();
}

class _SetBudgetCategoryScreenState extends ConsumerState<SetBudgetCategoryScreen> {
  final currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  List<CategoryItem> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('set_budget_category_screen');
    _initializeCategories();
  }

  void _initializeCategories() {
    final suggestions = ref.read(budgetStateProvider).suggestedCategories;
    setState(() {
      _categories = suggestions.map((s) {
        // Map category ID to Icon and Color (simplified for now)
        IconData icon = Icons.category_rounded;
        Color color = BudgetColors.midGrey;
        
        String name = s.categoryName;
        if (name.isEmpty) {
          // If name is empty, try to use bits of the ID as a last resort
          if (s.categoryId.isNotEmpty) {
            name = s.categoryId;
          } else {
            name = 'unknown category';
          }
        }
        
        switch (name.toLowerCase()) {
          case 'utilities':
          case 'household':
          case 'bills':
            icon = Icons.home_rounded;
            color = const Color(0xFF2196F3);
            break;
          case 'shopping':
          case 'ecommerce':
            icon = Icons.shopping_bag_rounded;
            color = const Color(0xFFE91E63);
            break;
          case 'drinks & dining':
          case 'dining':
          case 'food':
          case 'food & dining':
          case 'restaurants':
            icon = Icons.local_dining_rounded;
            color = const Color(0xFFFF9800);
            break;
          case 'groceries':
          case 'market':
            icon = Icons.shopping_basket_rounded;
            color = BudgetColors.successText;
            break;
          case 'travel':
          case 'transport':
          case 'commute':
            icon = Icons.flight_takeoff_rounded;
            color = const Color(0xFF3F51B5);
            break;
          case 'entertainment':
          case 'fun':
            icon = Icons.movie_rounded;
            color = BudgetColors.lightPurple;
            break;
        }

        return CategoryItem(
          categoryId: s.categoryId,
          title: name,
          icon: icon,
          iconColor: color,
          suggestedAmount: s.suggestedAmount,
          isSet: true, // Default to true if suggested
        );
      }).toList();
      
      if (_categories.isEmpty) {
         // Fallback to minimal default if API returned nothing
         _categories = [
            CategoryItem(
              categoryId: "other",
              title: "Other",
              icon: Icons.category_rounded,
              iconColor: Colors.blueGrey,
              suggestedAmount: widget.totalBudget,
              isSet: true,
            ),
         ];
      }
    });
  }

  bool get _anyCategorySet => _categories.any((c) => c.isSet);

  void _toggleCategorySet(CategoryItem category) {
    setState(() {
      category.isSet = !category.isSet;
    });
  }


  @override
  Widget build(BuildContext context) {
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
                    child: ZeyroIconButton(eventName: 'set_budget_category_screen_back_tapped', 
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: BudgetColors.black,
                        size: 20,
                      ),
                      onPressed: () { Navigator.of(context).pop(); },
                    ),
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(8)),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(24),
                  ),
                  child: Text(
                    "set up category budgets",
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
                    "we've set up a few budgets to get you started. you can change these at any time.",
                    style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: BudgetColors.grey7),
                    textAlign: TextAlign.left,
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
                        bottom: getProportionateScreenHeight(160),
                      ), // Space for floating buttons
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => Divider(
                        color: BudgetColors.black.withOpacity(0.05),
                        height: 32,
                      ),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        return InkWell(
                          onTap: () => _toggleCategorySet(cat),
                          highlightColor: Colors.transparent,
                          splashColor: BudgetColors.black.withOpacity(0.02),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cat.iconColor.withOpacity(0.1),
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
              onVerticalDragUpdate: (_) {}, // Absorbs swipe down to prevent accidental button taps
              child: Container(
                color: const Color(0xFFfaf5ea),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: getProportionateScreenWidth(32),
                    right: getProportionateScreenWidth(32),
                    bottom: getProportionateScreenHeight(8), // Pushed down
                    top: getProportionateScreenHeight(12),   // Reduced height
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                children: [
                  ZeyroButton(eventName: 'set_budget_category_screen_confirm_tapped', 
                    onPressed: (_anyCategorySet && !_isLoading)
                        ? () {
                            const validCategorySlugs = {
                              'food_dining', 'transportation', 'entertainment',
                              'utilities', 'savings', 'healthcare', 'education',
                              'shopping', 'travel', 'insurance',
                            };

                            final selectedCategories = _categories
                                .where((c) => c.isSet)
                                .toList();

                            final allocations = selectedCategories
                                .map((c) => CategoryAllocation(
                                      categoryId: c.categoryId ?? c.title.toLowerCase(),
                                      amount: c.suggestedAmount,
                                      isTracking: true,
                                    ))
                                .where((a) => validCategorySlugs.contains(a.categoryId))
                                .toList();
                          
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BudgetGenerateScreen(
                                  totalBudget: widget.totalBudget,
                                  allocations: allocations,
                                  categoryList: selectedCategories,
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BudgetColors.black,
                      foregroundColor: BudgetColors.white,
                      disabledBackgroundColor: Colors.black12,
                      disabledForegroundColor: Colors.black38,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: _anyCategorySet ? 4 : 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: BudgetColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "set category budgets",
                            style: TextStyle(fontFamily: 'DMSans', 
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(8)), // Reduced gap
                  OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            const validCategorySlugs = {
                              'food_dining', 'transportation', 'entertainment',
                              'utilities', 'savings', 'healthcare', 'education',
                              'shopping', 'travel', 'insurance',
                            };

                            // Map all ML-suggested categories but mark them hidden
                            final allocations = _categories
                                .map((c) => CategoryAllocation(
                                      categoryId: c.categoryId ?? c.title.toLowerCase(),
                                      amount: c.suggestedAmount,
                                      isTracking: true,
                                      isHidden: true,
                                    ))
                                .where((a) => validCategorySlugs.contains(a.categoryId))
                                .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BudgetGenerateScreen(
                                  totalBudget: widget.totalBudget,
                                  allocations: allocations,
                                  categoryList: _categories, // Pass original categories so state is right
                                ),
                              ),
                            );
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BudgetColors.black,
                      side: BorderSide.none,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "not now",
                      style: TextStyle(fontFamily: 'DMSans', 
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: BudgetColors.foreground,
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
