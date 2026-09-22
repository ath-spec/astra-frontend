// ============================================================
// FILE: lib/features/analytics/screens/category_spends_screen.dart
// Full list of category spend, reached from the allocation card
// or the monthly-spending-level carousel's "see all".
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/responsive/context_responsive.dart';
import '../../../core/widgets/responsive_body.dart';
import '../data/analytics_repository.dart';
import '../models/analytics_models.dart';

class CategorySpendsScreen extends StatefulWidget {
  const CategorySpendsScreen({super.key});

  @override
  State<CategorySpendsScreen> createState() => _CategorySpendsScreenState();
}

class _CategorySpendsScreenState extends State<CategorySpendsScreen> {
  List<CategoryAllocation>? _allocations;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final summary = await AnalyticsRepository.instance.getSummary();
    if (!mounted) return;
    setState(() => _allocations = summary.categoryAllocations);
  }

  @override
  Widget build(BuildContext context) {
    final allocations = _allocations;
    final total = allocations?.fold<double>(0, (s, c) => s + c.actualSpent) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Category spends',
          style: TextStyle(fontFamily: 'DMSans', fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        ),
      ),
      body: allocations == null
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) {
                final hPad = context.pageHorizontalPadding;
                return ResponsiveBody(
                  child: ListView(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: const Color(0xFF0F172A),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total spent this month',
                        style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Colors.white70),
                      ),
                      Text(
                        '₹${NumberFormat('#,##0').format(total)}',
                        style: const TextStyle(fontFamily: 'DMSans', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (final allocation in allocations) _CategoryBudgetRow(allocation: allocation),
              ],
                  ),
                );
              },
            ),
    );
  }
}

class _CategoryBudgetRow extends StatelessWidget {
  final CategoryAllocation allocation;

  const _CategoryBudgetRow({required this.allocation});

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(allocation.colorHex);
    final progress = allocation.budgetedAmount == 0
        ? 0.0
        : (allocation.actualSpent / allocation.budgetedAmount).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  allocation.categoryName,
                  style: const TextStyle(fontFamily: 'DMSans', fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
              ),
              Text(
                '₹${NumberFormat('#,##0').format(allocation.actualSpent)} / ₹${NumberFormat('#,##0').format(allocation.budgetedAmount)}',
                style: const TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 500),
            curve: const Cubic(0.23, 1.0, 0.32, 1.0),
            builder: (context, animatedValue, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: animatedValue,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
