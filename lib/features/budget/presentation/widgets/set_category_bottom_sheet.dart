import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/category_item_model.dart';
import 'package:astra_frontend/features/budget/presentation/screens/budget_generate_screen.dart';
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/services/finance_repository.dart';
import 'package:astra_frontend/services/service_providers.dart';

class SetCategoryBottomSheet extends ConsumerStatefulWidget {
  final double totalBudget;
  final double? oldBudgetLimit;

  const SetCategoryBottomSheet({
    super.key,
    required this.totalBudget,
    this.oldBudgetLimit,
  });

  @override
  ConsumerState<SetCategoryBottomSheet> createState() => _SetCategoryBottomSheetState();
}

class _SetCategoryBottomSheetState extends ConsumerState<SetCategoryBottomSheet> {
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
    _initializeCategories();
  }

  void _initializeCategories() {
    final suggestions = ref.read(budgetStateProvider).suggestedCategories;
    setState(() {
      _categories = suggestions.map((s) {
        // Use the display name exactly as the backend sends it.
        // Fall back to the slug only when the display name is truly blank.
        final displayName = s.categoryName.isNotEmpty
            ? s.categoryName
            : s.categoryId.replaceAll('_', ' ');

        // Pick icon + accent colour by matching on the stable categoryId slug,
        // not on the localised display name.
        final IconData icon;
        final Color color;
        switch (s.categoryId.toLowerCase()) {
          case 'utilities':
          case 'bills':
          case 'household':
            icon = Icons.home_rounded;
            color = const Color(0xFF2196F3);
            break;
          case 'shopping':
          case 'ecommerce':
            icon = Icons.shopping_bag_rounded;
            color = const Color(0xFFE91E63);
            break;
          case 'food_dining':
          case 'food':
          case 'dining':
          case 'restaurants':
          case 'groceries':
            icon = Icons.local_dining_rounded;
            color = const Color(0xFFFF9800);
            break;
          case 'transportation':
          case 'travel':
          case 'transport':
          case 'commute':
            icon = Icons.directions_car_rounded;
            color = const Color(0xFF3F51B5);
            break;
          case 'entertainment':
            icon = Icons.movie_rounded;
            color = BudgetColors.lightPurple;
            break;
          case 'healthcare':
          case 'health':
            icon = Icons.favorite_rounded;
            color = const Color(0xFFE53935);
            break;
          case 'education':
            icon = Icons.school_rounded;
            color = const Color(0xFF00897B);
            break;
          case 'savings':
          case 'investments':
            icon = Icons.savings_rounded;
            color = const Color(0xFF43A047);
            break;
          case 'insurance':
            icon = Icons.shield_rounded;
            color = const Color(0xFF546E7A);
            break;
          default:
            icon = Icons.category_rounded;
            color = BudgetColors.midGrey;
        }

        return CategoryItem(
          categoryId: s.categoryId,
          title: displayName,
          icon: icon,
          iconColor: color,
          suggestedAmount: s.suggestedAmount,
          isSet: true,
        );
      }).toList();

      if (_categories.isEmpty) {
        _categories = [
          CategoryItem(
            categoryId: 'other',
            title: 'other',
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
    final mq = MediaQuery.of(context);
    return Container(
      height: mq.size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFfaf5ea),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: BudgetColors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(24)),
            child: Text(
              "set up category budgets",
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: getProportionateScreenWidth(22),
                fontWeight: FontWeight.w600,
                color: BudgetColors.black,
              ),
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(8)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(24)),
            child: Text(
              "we've set up a few budgets based on your new limit. you can change these at any time.",
              style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: BudgetColors.grey7),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(16)),

          // Categories List
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(24)),
              child: ListView.separated(
                padding: EdgeInsets.only(bottom: getProportionateScreenHeight(20)),
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
                          child: Icon(cat.icon, color: cat.iconColor, size: 24),
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
                                  const Icon(Icons.auto_awesome, size: 12, color: BudgetColors.grey7),
                                  const SizedBox(width: 4),
                                  Text(
                                    "suggested: ${currencyFormat.format(cat.suggestedAmount)}/mo",
                                    style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: BudgetColors.grey7),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          cat.isSet ? Icons.check_circle_rounded : Icons.add_rounded,
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

          // Action Buttons
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: getProportionateScreenWidth(24),
                right: getProportionateScreenWidth(24),
                bottom: getProportionateScreenHeight(16),
                top: getProportionateScreenHeight(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ZeyroButton(eventName: 'set_category_bottom_sheet_save_tapped',
                    onPressed: (_anyCategorySet && !_isLoading)
                        ? () {
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
                            
                            // Close bottom sheet, passing 'saved' so we don't revert
                            Navigator.pop(context, 'saved');
                            
                            // Go to Generate Screen
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: _anyCategorySet ? 4 : 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: BudgetColors.white, strokeWidth: 2))
                        : Text("set category budgets", style: TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(height: getProportionateScreenHeight(16)),
                  OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (widget.oldBudgetLimit != null) {
                              setState(() => _isLoading = true);
                              try {
                                await FinanceRepository().updateBudgetSettings(
                                  spendingLimit: widget.oldBudgetLimit!,
                                );
                                final budgetState = ref.read(budgetStateProvider);
                                if (budgetState.currentSessionId != null && budgetState.currentSessionId!.isNotEmpty) {
                                  await FinanceRepository().updateBudgetSession(
                                    sessionId: budgetState.currentSessionId!,
                                    totalBudget: widget.oldBudgetLimit!,
                                  );
                                }
                                if (mounted) {
                                  Navigator.pop(context, 'reverted');
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 1500), content: Text('Failed to revert: $e', style: TextStyle(fontFamily: 'DMSans', ))),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            } else {
                               Navigator.pop(context);
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BudgetColors.black,
                      side: BorderSide.none,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      "i've changed my mind",
                      style: TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w600, color: BudgetColors.foreground),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
