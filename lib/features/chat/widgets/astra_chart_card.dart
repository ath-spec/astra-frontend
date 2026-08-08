import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class AstraChartCard extends StatefulWidget {
  final String? title;
  final String chartType; // "pie", "doughnut", or "bar"
  final Map<String, dynamic> data;

  const AstraChartCard({
    super.key,
    this.title,
    required this.chartType,
    required this.data,
  });

  @override
  State<AstraChartCard> createState() => _AstraChartCardState();
}

class _AstraChartCardState extends State<AstraChartCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // _progressAnim drives the actual slice values: 0 → 1
  // Each section value = realValue * _progressAnim.value
  // This means slices literally grow from nothing to full on every frame.
  late Animation<double> _progressAnim;

  // Entrance: fade + translate up
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  final List<Color> _colors = [
    const Color(0xFF3B82F6),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFF6366F1),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Entrance: fade in during first 20% of the animation
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
    );

    // Data growth: starts at 8%, ends at 100%
    // Gives fade a head start before slices begin growing
    _progressAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.08, 1.0, curve: Curves.easeOutCubic),
    );

    _slideAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Cubic(0.23, 1, 0.32, 1)),
      ),
    );

    // Start on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder rebuilds on every animation frame,
    // passing the current progress value directly to chart builders.
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, 10 * _slideAnim.value),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.title != null && widget.title!.isNotEmpty) ...[
                    Text(
                      widget.title!,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  SizedBox(
                    height: 200,
                    child: widget.chartType == 'bar'
                        ? _buildBarChart(_progressAnim.value)
                        : _buildPieChart(_progressAnim.value),
                  ),
                  const SizedBox(height: 16),
                  _buildLegend(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPieChart(double progress) {
    final isDoughnut = widget.chartType == 'doughnut';
    int colorIdx = 0;

    final sections = widget.data.entries.map((e) {
      final realVal = (e.value as num).toDouble();
      final animatedVal = realVal * progress;
      final color = _colors[colorIdx % _colors.length];
      colorIdx++;

      return PieChartSectionData(
        color: color,
        // Use a tiny floor so fl_chart doesn't divide by zero when progress≈0
        value: animatedVal < 0.01 ? 0.01 : animatedVal,
        // Show labels once slices are 70% of the way drawn
        title: progress > 0.70 ? '${realVal.toInt()}%' : '',
        radius: isDoughnut ? 42 : 84,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontFamily: 'DMSans',
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: isDoughnut ? 38 : 0,
        sections: sections,
        pieTouchData: PieTouchData(enabled: false),
      ),
      // Disable fl_chart's internal swap — we're driving values directly
      swapAnimationDuration: Duration.zero,
    );
  }

  Widget _buildBarChart(double progress) {
    int x = 0;
    int colorIdx = 0;
    double maxY = 0;

    // Pre-compute maxY from real values for stable axis
    for (final e in widget.data.entries) {
      final v = (e.value as num).toDouble();
      if (v > maxY) maxY = v;
    }

    final barGroups = widget.data.entries.map((e) {
      final realVal = (e.value as num).toDouble();
      final animatedVal = realVal * progress;
      final color = _colors[colorIdx % _colors.length];
      colorIdx++;

      final group = BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: animatedVal,
            color: color,
            width: 28,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          )
        ],
      );
      x++;
      return group;
    }).toList();

    final keys = widget.data.keys.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= keys.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    keys[value.toInt()],
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                      fontFamily: 'DMSans',
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFFE2E8F0),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
      // Drive directly — no internal swap needed
      swapAnimationDuration: Duration.zero,
    );
  }

  Widget _buildLegend() {
    // Stagger legend items per Emil — don't let everything appear at once
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: widget.data.entries.toList().asMap().entries.map((entry) {
        final color = _colors[entry.key % _colors.length];
        // Each legend item fades in with a 50ms stagger
        // Use Interval.transform directly — safe inside build, avoids CurvedAnimation object leak
        final staggerStart = (entry.key * 0.08).clamp(0.0, 0.8);
        final staggerEnd = (staggerStart + 0.2).clamp(0.0, 1.0);
        final interval = Interval(staggerStart, staggerEnd, curve: Curves.easeOut);
        final legendOpacity = interval.transform(_controller.value);

        return Opacity(
          opacity: legendOpacity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                entry.value.key,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
