import 'package:flutter/material.dart';

/// AppThemeShimmerCard: Sleek card matching the current app theme (clean white card,
/// delicate border, subtle shadow) with smooth pulsating greyish skeleton bars inside.
class AppThemeShimmerCard extends StatefulWidget {
  final double? height;
  final double width;
  final BorderRadius borderRadius;
  final List<double>? barWidths;

  const AppThemeShimmerCard({
    super.key,
    this.height,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.barWidths,
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(24),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top small label bar
              _buildShimmerBar(width: widget.barWidths != null && widget.barWidths!.isNotEmpty ? widget.barWidths![0] : 80, height: 12),
              const SizedBox(height: 14),
              // Main large title / value bar
              _buildShimmerBar(width: widget.barWidths != null && widget.barWidths!.length > 1 ? widget.barWidths![1] : 180, height: 28),
              const SizedBox(height: 18),
              // Bottom metrics / sub-info row
              Row(
                children: [
                  _buildShimmerBar(width: widget.barWidths != null && widget.barWidths!.length > 2 ? widget.barWidths![2] : 90, height: 14),
                  const SizedBox(width: 24),
                  _buildShimmerBar(width: widget.barWidths != null && widget.barWidths!.length > 3 ? widget.barWidths![3] : 110, height: 14),
                ],
              ),
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
          // Main performance skeleton card (White card with greyish pulsing shimmer bars)
          AppThemeShimmerCard(
            height: 160,
            barWidths: [90, 200, 100, 110],
          ),
          SizedBox(height: 16),

          // Details skeleton card
          AppThemeShimmerCard(
            height: 110,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            barWidths: [70, 140, 80, 90],
          ),
          SizedBox(height: 24),

          // Holding profile skeleton card
          AppThemeShimmerCard(
            height: 140,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            barWidths: [110, 220, 120, 100],
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}
