// ============================================================
// FILE: lib/features/analytics/widgets/monthly_spending_level_card.dart
// Horizontal carousel of per-category spend-status mini cards.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/analytics_models.dart';

class MonthlySpendingLevelCard extends StatelessWidget {
  final List<SpendingLevelCategory> categories;
  final VoidCallback? onSeeAll;

  const MonthlySpendingLevelCard({super.key, required this.categories, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly spending level',
                style: TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              GestureDetector(
                onTap: onSeeAll,
                behavior: HitTestBehavior.opaque,
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: categories.length,
            separatorBuilder: (_, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _SpendingLevelTile(category: categories[index]),
          ),
        ),
      ],
    );
  }
}

class _SpendingLevelTile extends StatelessWidget {
  final SpendingLevelCategory category;

  const _SpendingLevelTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(category.status);

    return Container(
      width: 152,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _statusLabel(category.status),
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            category.categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '₹${NumberFormat('#,##0').format(category.amountSpent)}',
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 22,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 450),
              curve: const Cubic(0.23, 1.0, 0.32, 1.0),
              builder: (context, progress, _) {
                return CustomPaint(
                  size: const Size(double.infinity, 22),
                  painter: _SparklinePainter(
                    data: category.sparklineData,
                    color: statusColor,
                    progress: progress,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(SpendingStatus status) {
    switch (status) {
      case SpendingStatus.over:
        return const Color(0xFFF43F5E);
      case SpendingStatus.warning:
        return const Color(0xFFF97316);
      case SpendingStatus.under:
        return const Color(0xFF22C55E);
      case SpendingStatus.normal:
        return const Color(0xFF5BA1F7);
    }
  }

  String _statusLabel(SpendingStatus status) {
    switch (status) {
      case SpendingStatus.over:
        return 'Over budget';
      case SpendingStatus.warning:
        return 'Near limit';
      case SpendingStatus.under:
        return 'Under budget';
      case SpendingStatus.normal:
        return 'On track';
    }
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double progress;

  const _SparklinePainter({
    required this.data,
    required this.color,
    this.progress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final minV = data.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 0.001 ? 1.0 : maxV - minV;

    final fullPath = Path();
    for (var i = 0; i < data.length; i++) {
      final x = size.width * (i / (data.length - 1));
      final y = size.height - ((data[i] - minV) / range) * size.height;
      if (i == 0) {
        fullPath.moveTo(x, y);
      } else {
        fullPath.lineTo(x, y);
      }
    }

    final animatedPath = Path();
    for (final metric in fullPath.computeMetrics()) {
      final extractLen = metric.length * progress.clamp(0.0, 1.0);
      animatedPath.addPath(metric.extractPath(0.0, extractLen), Offset.zero);
    }

    canvas.drawPath(
      animatedPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.color != color ||
      oldDelegate.progress != progress;
}
