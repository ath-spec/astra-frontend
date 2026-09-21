// ============================================================
// FILE: lib/features/analytics/widgets/actionable_insights_card.dart
// Horizontal carousel of actionable-insight cards, revealed after
// the user engages with the top AI insight.
// ============================================================

import 'package:flutter/material.dart';
import '../models/analytics_models.dart';

const _iconMap = <String, IconData>{
  'restaurant': Icons.restaurant_rounded,
  'receipt_long': Icons.receipt_long_rounded,
  'savings': Icons.savings_rounded,
  'insights': Icons.insights_rounded,
};

class ActionableInsightsCard extends StatelessWidget {
  final List<ActionableInsight> insights;
  final ValueChanged<ActionableInsight>? onTapInsight;

  const ActionableInsightsCard({super.key, required this.insights, this.onTapInsight});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Actionable insights',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.0,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: insights.length,
            separatorBuilder: (_, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _InsightPod(
              insight: insights[index],
              staggerIndex: index,
              onTap: () => onTapInsight?.call(insights[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightPod extends StatefulWidget {
  final ActionableInsight insight;
  final int staggerIndex;
  final VoidCallback? onTap;

  const _InsightPod({required this.insight, required this.staggerIndex, this.onTap});

  @override
  State<_InsightPod> createState() => _InsightPodState();
}

class _InsightPodState extends State<_InsightPod> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _entrance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
    _entrance = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    Future.delayed(Duration(milliseconds: 40 * widget.staggerIndex), () {
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
    final color = _hexToColor(widget.insight.colorHex);

    return FadeTransition(
      opacity: _entrance,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(_entrance),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
                      child: Icon(_iconMap[widget.insight.iconName] ?? Icons.insights_rounded, size: 16, color: color),
                    ),
                    const Spacer(),
                    if (widget.insight.tag != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          widget.insight.tag!,
                          style: TextStyle(fontFamily: 'DMSans', fontSize: 9.5, fontWeight: FontWeight.w700, color: color),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.insight.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'DMSans', fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), height: 1.25),
                ),
                const Spacer(),
                if (widget.insight.progress != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.insight.progress!.clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  widget.insight.ctaText,
                  style: TextStyle(fontFamily: 'DMSans', fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
