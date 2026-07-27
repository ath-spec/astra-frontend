import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../models/dashboard_stats_model.dart';
import '../providers/home_provider.dart';

/// Scoped ConsumerWidget displaying dashboard metrics grid.
/// Prevents full dashboard re-render when stats update.
class StatsSummaryWidget extends ConsumerWidget {
  const StatsSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      loading: () => const SizedBox(
        height: 180,
        child: LoadingView(message: 'Loading telemetry...'),
      ),
      error: (err, stack) => ErrorView(
        message: err.toString(),
        onRetry: () => ref.invalidate(dashboardStatsProvider),
      ),
      data: (stats) => _buildStatsGrid(context, stats),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardStats stats) {
    final theme = Theme.of(context);
    final items = [
      _StatItem(
        title: 'Active Revenue',
        value: '\$${stats.activeRevenue.toStringAsFixed(2)}',
        icon: Icons.payments_outlined,
        color: const Color(0xFF10B981), // Emerald
      ),
      _StatItem(
        title: 'Total Users',
        value: '${stats.totalUsers}',
        icon: Icons.people_outline_rounded,
        color: const Color(0xFF6366F1), // Indigo
      ),
      _StatItem(
        title: 'Pending Orders',
        value: '${stats.pendingOrders}',
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFFF59E0B), // Amber
      ),
      _StatItem(
        title: 'System Health',
        value: '${stats.systemHealth}%',
        icon: Icons.monitor_heart_outlined,
        color: const Color(0xFF3B82F6), // Blue
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 116,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(item.icon, color: item.color, size: 20),
                    ],
                  ),
                  Text(
                    item.value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}
