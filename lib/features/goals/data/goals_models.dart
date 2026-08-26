// Typed models for the `/api/v1/goals` backend endpoints.

class GoalItem {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double progressPct;
  final int daysLeft;
  final String status;
  final String? deadline;

  const GoalItem({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.progressPct,
    required this.daysLeft,
    required this.status,
    this.deadline,
  });

  factory GoalItem.fromJson(Map<String, dynamic> json) {
    return GoalItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0.0,
      progressPct: (json['progress_pct'] as num?)?.toDouble() ?? 0.0,
      daysLeft: (json['days_left'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'ACTIVE',
      deadline: json['deadline']?.toString(),
    );
  }
}

class GoalsSummary {
  final double totalTarget;
  final double totalCurrent;
  final double overallProgressPct;
  final int activeCount;
  final int completedCount;

  const GoalsSummary({
    required this.totalTarget,
    required this.totalCurrent,
    required this.overallProgressPct,
    required this.activeCount,
    required this.completedCount,
  });

  static const empty = GoalsSummary(
    totalTarget: 0,
    totalCurrent: 0,
    overallProgressPct: 0,
    activeCount: 0,
    completedCount: 0,
  );

  factory GoalsSummary.fromJson(Map<String, dynamic> json) {
    return GoalsSummary(
      totalTarget: (json['total_target'] as num?)?.toDouble() ?? 0.0,
      totalCurrent: (json['total_current'] as num?)?.toDouble() ?? 0.0,
      overallProgressPct:
          (json['overall_progress_pct'] as num?)?.toDouble() ?? 0.0,
      activeCount: (json['active_count'] as num?)?.toInt() ?? 0,
      completedCount: (json['completed_count'] as num?)?.toInt() ?? 0,
    );
  }
}
