// ============================================================
// FILE: lib/features/analytics/widgets/analytics_skeleton_card.dart
// Premium white shimmer skeleton card for the Analytics screen,
// replacing the generic circular spinner with synchronized,
// cohesive layout placeholders following Emil Kowalski's principles.
// ============================================================

import 'package:flutter/material.dart';

class AnalyticsSkeletonView extends StatelessWidget {
  const AnalyticsSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyticsChartSkeletonCard(),
        SizedBox(height: 32),
        AnalyticsRecentSpendsSkeletonCard(),
      ],
    );
  }
}

/// Main white shimmer card simulating the Focus Level Chart and spend metrics.
class AnalyticsChartSkeletonCard extends StatefulWidget {
  const AnalyticsChartSkeletonCard({super.key});

  @override
  State<AnalyticsChartSkeletonCard> createState() => _AnalyticsChartSkeletonCardState();
}

class _AnalyticsChartSkeletonCardState extends State<AnalyticsChartSkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double borderRadius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(_shimmerAnim.value - 1, 0),
          end: Alignment(_shimmerAnim.value + 1, 0),
          colors: const [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
            Color(0xFFE2E8F0),
            Color(0xFFF1F5F9),
            Color(0xFFF8FAFC),
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(width: 130, height: 18, borderRadius: 4),
                      const SizedBox(height: 6),
                      _shimmerBox(width: 85, height: 11, borderRadius: 3),
                    ],
                  ),
                  _shimmerBox(width: 72, height: 26, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 28),

              // Simulated Chart Area (7 bars with varied heights)
              SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    _BarSkeleton(height: 52),
                    _BarSkeleton(height: 78),
                    _BarSkeleton(height: 42),
                    _BarSkeleton(height: 104),
                    _BarSkeleton(height: 68),
                    _BarSkeleton(height: 92),
                    _BarSkeleton(height: 48),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Baseline bar
              Container(
                height: 1.2,
                color: const Color(0xFFF1F5F9),
              ),
              const SizedBox(height: 8),

              // Day labels placeholder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  7,
                  (_) => _shimmerBox(width: 22, height: 8, borderRadius: 2),
                ),
              ),
              const SizedBox(height: 20),

              // Footer Metrics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(width: 60, height: 9, borderRadius: 2),
                      const SizedBox(height: 5),
                      _shimmerBox(width: 90, height: 15, borderRadius: 3),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _shimmerBox(width: 50, height: 9, borderRadius: 2),
                      const SizedBox(height: 5),
                      _shimmerBox(width: 75, height: 15, borderRadius: 3),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BarSkeleton extends StatelessWidget {
  final double height;

  const _BarSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}

/// White shimmer card simulating Recent Spends transaction rows.
class AnalyticsRecentSpendsSkeletonCard extends StatefulWidget {
  const AnalyticsRecentSpendsSkeletonCard({super.key});

  @override
  State<AnalyticsRecentSpendsSkeletonCard> createState() =>
      _AnalyticsRecentSpendsSkeletonCardState();
}

class _AnalyticsRecentSpendsSkeletonCardState
    extends State<AnalyticsRecentSpendsSkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double borderRadius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(_shimmerAnim.value - 1, 0),
          end: Alignment(_shimmerAnim.value + 1, 0),
          colors: const [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
            Color(0xFFE2E8F0),
            Color(0xFFF1F5F9),
            Color(0xFFF8FAFC),
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _shimmerBox(width: 120, height: 16, borderRadius: 4),
                  _shimmerBox(width: 48, height: 12, borderRadius: 3),
                ],
              ),
              const SizedBox(height: 18),

              // 3 Transaction Skeleton Rows
              _buildRow(),
              const Divider(height: 20, thickness: 0.6, color: Color(0xFFF8FAFC)),
              _buildRow(),
              const Divider(height: 20, thickness: 0.6, color: Color(0xFFF8FAFC)),
              _buildRow(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow() {
    return Row(
      children: [
        _shimmerBox(width: 38, height: 38, borderRadius: 4),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBox(width: 110, height: 13, borderRadius: 3),
              const SizedBox(height: 5),
              _shimmerBox(width: 70, height: 10, borderRadius: 3),
            ],
          ),
        ),
        _shimmerBox(width: 55, height: 14, borderRadius: 3),
      ],
    );
  }
}
