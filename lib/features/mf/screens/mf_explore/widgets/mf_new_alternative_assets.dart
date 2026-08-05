import 'package:flutter/material.dart';
import '../../mf_collection/mf_reits_collection_screen.dart';
import '../../mf_collection/mf_gold_collection_screen.dart';
import '../../mf_collection/mf_invits_collection_screen.dart';
import '../../mf_collection/mf_theme_collection_screen.dart';

class MfNewAlternativeAssets extends StatelessWidget {
  const MfNewAlternativeAssets({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Alternative Assets',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Explore alternative investment options.',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _AnimatedAssetCard(
                      title: 'REITs',
                      subtitle: 'Investment in\nincome generating\nreal estate.',
                      imageAsset: 'lib/core/images/realestate.webp',
                      backgroundColor: const Color(0xFFE4F0FF),
                      imageScaleFraction: 0.8,
                      imageRightFraction: 0.03,
                      imageBottomFraction: 0.03,
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (_) => const MfReitsCollectionScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AnimatedAssetCard(
                      title: 'Gold Funds',
                      subtitle: 'Diversify with\ngold investments.',
                      imageAsset: 'lib/core/images/gold.webp',
                      backgroundColor: const Color(0xFFFDF0D5),
                      imageScaleFraction: 1.35,
                      imageRightFraction: 0.35,
                      imageBottomFraction: 0.35,
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (_) => const MfGoldCollectionScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _AnimatedAssetCard(
                      title: 'Silver Funds',
                      subtitle: 'Add silver to\nyour portfolio.',
                      imageAsset: 'lib/core/images/silver.webp',
                      backgroundColor: const Color(0xFFF2F4F7),
                      imageScaleFraction: 1.35,
                      imageRightFraction: 0.35,
                      imageBottomFraction: 0.35,
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (_) => const MfThemeCollectionScreen(
                            title: 'Silver Funds',
                            subtitle: 'Add silver to your portfolio.',
                            imagePath: 'lib/core/images/silver.webp',
                          )),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AnimatedAssetCard(
                      title: 'INVITs',
                      subtitle: "Infrastructre investment\nfor steady returns.",
                      imageAsset: 'lib/core/images/invits.webp',
                      backgroundColor: const Color(0xFFE5F1EB),
                      imageScaleFraction: 0.8,
                      imageRightFraction: 0.1,
                      imageBottomFraction: 0.14,
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (_) => const MfInvitsCollectionScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedAssetCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imageAsset;
  final Color backgroundColor;
  final double imageScaleFraction;
  final double imageRightFraction;
  final double imageBottomFraction;
  final VoidCallback onTap;

  const _AnimatedAssetCard({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.backgroundColor,
    required this.onTap,
    this.imageScaleFraction = 0.9,
    this.imageRightFraction = 0.1,
    this.imageBottomFraction = 0.3,
  });

  @override
  State<_AnimatedAssetCard> createState() => _AnimatedAssetCardState();
}

class _AnimatedAssetCardState extends State<_AnimatedAssetCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: const Cubic(0.23, 1, 0.32, 1), // Strong ease-out
        child: AspectRatio(
          aspectRatio: 1.45, // Responsive rectangular ratio (scales height perfectly with width)
          child: Container(
            decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: HSLColor.fromColor(widget.backgroundColor).withLightness(
                (HSLColor.fromColor(widget.backgroundColor).lightness - 0.12).clamp(0.0, 1.0)
              ).toColor(),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3), // clip inner slightly smaller to avoid border bleeding
            child: Stack(
              children: [
                // Base Image Layer (Responsive)
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      final size = w * widget.imageScaleFraction;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            right: -(w * widget.imageRightFraction),
                            bottom: -(h * widget.imageBottomFraction),
                            width: size,
                            height: size,
                            child: Image.asset(
                              widget.imageAsset,
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomRight,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Gradient Shade Overlay to blend the image perfectly
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.backgroundColor,
                          widget.backgroundColor,
                          widget.backgroundColor.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.2, 1.0], // Covers the left edge completely, smoothly fades out
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 14, bottom: 14, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8), // Reduced spacing to fit smaller height
                      Expanded(
                        child: Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
