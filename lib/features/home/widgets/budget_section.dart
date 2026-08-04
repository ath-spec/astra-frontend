import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/budget_overview_card.dart';
import 'package:astra_frontend/services/service_providers.dart';
import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/category_budget_item.dart';

class BudgetSection extends ConsumerStatefulWidget {
  const BudgetSection({super.key});

  @override
  ConsumerState<BudgetSection> createState() => _BudgetSectionState();
}

class _BudgetSectionState extends ConsumerState<BudgetSection> {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetStateProvider);
    final dash = state.latestDashboard;
    final isBudgetCreated = dash != null;

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Budget',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          if (isBudgetCreated) ...[
            GestureDetector(
              onTap: () => context.push('/budget-control'),
              child: BudgetOverviewCard(
                totalBudget: dash.totalBudget,
                spentAmount: dash.totalSpent,
                percentageUsed: dash.totalBudget > 0 ? (dash.totalSpent / dash.totalBudget).clamp(0.0, 1.0) : 0.0,
                daysRemaining: dash.daysRemainingInMonth,
                isMini: true,
                showIncomeOutcome: false,
                title: '',
                backgroundColor: const Color(0xFFF1F5F9), // Subtle grey matching home theme
                textColor: const Color(0xFF0F172A),
              ),
            ),

          ] else
            _BudgetCard(onTap: () => context.push('/init-budget')),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty-state card – matches Zeyro's _BudgetCard design (cream/yellow bg)
// ---------------------------------------------------------------------------
class _BudgetCard extends StatelessWidget {
  final VoidCallback onTap;
  const _BudgetCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0XFFFFFFFF),
          borderRadius: BorderRadius.circular(4),
          border:Border.all(color:const Color.fromARGB(255, 240, 240, 235),)
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // ── Left image panel ─────────────────────────────────────
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: constraints.maxWidth * 0.4,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'lib/core/images/new_budget.webp',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // ── Right text panel ─────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(
                      left: constraints.maxWidth * 0.4 + 10,
                      right: 18,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Build a budget',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          'AI sets up your budget and helps you track progress all month long',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Text(
                              'create now',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.north_east_rounded,
                                size: 10,
                                color: Color(0xFFFFDF82),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
