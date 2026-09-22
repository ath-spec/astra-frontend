
import 'package:flutter/material.dart';

class ShimmerBar extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBar({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  State<ShimmerBar> createState() => _ShimmerBarState();
}

class _ShimmerBarState extends State<ShimmerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnim;

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_shimmerAnim.value - 1, 0),
              end: Alignment(_shimmerAnim.value + 1, 0),
              colors: const [
                Color(0xFFF1F5F9),
                Color(0xFFE2E8F0),
                Color(0xFFCBD5E1),
                Color(0xFFE2E8F0),
                Color(0xFFF1F5F9),
              ],
              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// AppThemeShimmerCard: Sleek card matching the current app theme (clean white card,
/// delicate border, subtle shadow) with smooth pulsating greyish skeleton bars inside.
class AppThemeShimmerCard extends StatefulWidget {
  final double? height;
  final double width;
  final BorderRadius borderRadius;
  final List<double>? barWidths;
  final EdgeInsetsGeometry padding;

  const AppThemeShimmerCard({
    super.key,
    this.height,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.barWidths,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  @override
  State<AppThemeShimmerCard> createState() => _AppThemeShimmerCardState();
}

class _AppThemeShimmerCardState extends State<AppThemeShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnim;

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

  // Fixed content heights the full 3-row layout below needs (label bar +
  // gap + title bar + gap + metrics row), independent of barWidths.
  static const double _fullContentHeight = 10 + 10 + 22 + 12 + 12;
  static const double _compactContentHeight = 10 + 10 + 22;
  static const double _borderWidth = 1.2;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // A caller may pass a fixed `height` (e.g. compact 72px row
        // skeletons on the transactions screen) that's too short for the
        // full 3-row layout once padding is subtracted. Rather than
        // overflow, degrade to a shorter layout that actually fits —
        // computed from the real constraint instead of assuming callers
        // always size the card for the full content.
        final resolvedPadding = widget.padding.resolve(TextDirection.ltr);
        // BoxDecoration.border adds its own implicit padding (Container
        // merges decoration.padding with the explicit padding), so the
        // border's thickness must be subtracted too or this still overflows
        // by exactly 2x the border width.
        final availableContent = widget.height == null
            ? null
            : widget.height! - resolvedPadding.vertical - (_borderWidth * 2);
        final showMetricsRow =
            availableContent == null || availableContent >= _fullContentHeight;
        final showTitleBar =
            availableContent == null || availableContent >= _compactContentHeight;

        return Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1.2,
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top small label bar
              _buildShimmerBar(
                width: widget.barWidths != null && widget.barWidths!.isNotEmpty
                    ? widget.barWidths![0]
                    : 80,
                height: 10,
              ),
              if (showTitleBar) ...[
                const SizedBox(height: 10),
                // Main large title / value bar
                _buildShimmerBar(
                  width: widget.barWidths != null && widget.barWidths!.length > 1
                      ? widget.barWidths![1]
                      : 180,
                  height: 22,
                ),
              ],
              if (showMetricsRow) ...[
                const SizedBox(height: 12),
                // Bottom metrics / sub-info row
                Row(
                  children: [
                    _buildShimmerBar(
                      width: widget.barWidths != null && widget.barWidths!.length > 2
                          ? widget.barWidths![2]
                          : 80,
                      height: 12,
                    ),
                    const SizedBox(width: 16),
                    _buildShimmerBar(
                      width: widget.barWidths != null && widget.barWidths!.length > 3
                          ? widget.barWidths![3]
                          : 100,
                      height: 12,
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        gradient: LinearGradient(
          begin: Alignment(_shimmerAnim.value - 1, 0),
          end: Alignment(_shimmerAnim.value + 1, 0),
          colors: const [
            Color(0xFFF1F5F9),
            Color(0xFFE2E8F0),
            Color(0xFFCBD5E1),
            Color(0xFFE2E8F0),
            Color(0xFFF1F5F9),
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ),
      ),
    );
  }
}

class FundProfileSkeletonLoading extends StatelessWidget {
  const FundProfileSkeletonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppThemeShimmerCard(
            height: 150,
            barWidths: [90, 200, 100, 110],
          ),
          SizedBox(height: 16),
          AppThemeShimmerCard(
            height: 130,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            barWidths: [70, 140, 80, 90],
          ),
          SizedBox(height: 20),
          AppThemeShimmerCard(
            height: 150,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            barWidths: [110, 220, 120, 100],
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}


class HoldingsSkeletonLoading extends StatefulWidget {
  const HoldingsSkeletonLoading({super.key});

  @override
  State<HoldingsSkeletonLoading> createState() => _HoldingsSkeletonLoadingState();
}

class _HoldingsSkeletonLoadingState extends State<HoldingsSkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnim;

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

  Widget _buildShimmerBox({
    required double width,
    required double height,
    double borderRadius = 4,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(_shimmerAnim.value - 1, 0),
          end: Alignment(_shimmerAnim.value + 1, 0),
          colors: const [
            Color(0xFFF1F5F9),
            Color(0xFFE2E8F0),
            Color(0xFFCBD5E1),
            Color(0xFFE2E8F0),
            Color(0xFFF1F5F9),
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaTop = MediaQuery.paddingOf(context).top;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: safeAreaTop + 24),
                // Top Header Pill / Value Section
                Center(
                  child: Column(
                    children: [
                      _buildShimmerBox(width: 100, height: 12, borderRadius: 6),
                      const SizedBox(height: 12),
                      _buildShimmerBox(width: 200, height: 32, borderRadius: 8),
                      const SizedBox(height: 10),
                      _buildShimmerBox(width: 130, height: 14, borderRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Holding Items List Skeletons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: List.generate(5, (index) => _buildHoldingItemSkeleton()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHoldingItemSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          _buildShimmerBox(width: 36, height: 36, shape: BoxShape.circle),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(width: 140, height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                _buildShimmerBox(width: 90, height: 10, borderRadius: 3),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildShimmerBox(width: 70, height: 14, borderRadius: 4),
              const SizedBox(height: 8),
              _buildShimmerBox(width: 50, height: 10, borderRadius: 3),
            ],
          ),
        ],
      ),
    );
  }
}
