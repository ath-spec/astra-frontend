import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_stats_model.dart';

/// Auto-dispose FutureProvider fetching dashboard analytics.
/// Demonstrates async data fetching with simulated latency.
final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  await Future.delayed(const Duration(milliseconds: 700));
  return const DashboardStats(
    totalUsers: 14280,
    activeRevenue: 84520.50,
    pendingOrders: 34,
    systemHealth: 99.8,
    recentActivity: [
      'New user registration: @sarah_c',
      'Order #4920 completed successfully',
      'System backup finished at 04:00 UTC',
      'API latency improved by 12ms',
    ],
  );
});
