import 'package:flutter/material.dart';

class MfNewTrendingThemes extends StatelessWidget {
  const MfNewTrendingThemes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Trending Themes',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildThemeCard(
                context,
                title: 'Renewable Energy',
                subtitle: 'Powering the future of energy.',
                imageAsset: 'lib/core/images/renewal.webp',
                bgColor: const Color.fromARGB(255, 255, 255, 255),
                imageScaleFraction: 0.8,
                imageRightFraction: -0.05,
                imageBottomFraction: -0.1,
              ),
              const SizedBox(width: 12),

              _buildThemeCard(
                context,
                title: 'Semiconductor',
                subtitle: 'Powering the digital future.',
                imageAsset: 'lib/core/images/semi.webp',
                bgColor: const Color.fromARGB(255, 255, 255, 255),
                imageScaleFraction: 0.8,
                imageRightFraction: 0.0,
                imageBottomFraction: -0.1,
              ),
              const SizedBox(width: 12),
              _buildThemeCard(
                context,
                title: 'AI Revolution',
                subtitle: 'Invest in companies building AI.',
                imageAsset: 'lib/core/images/ai.webp',
                bgColor: const Color.fromARGB(255, 255, 255, 255),
                imageScaleFraction: 1,
                imageRightFraction: -0.05,
                imageBottomFraction: -0.05,
              ),
              const SizedBox(width: 12),
              _buildThemeCard(
                context,
                title: 'India Manufacturing',
                subtitle: "Back India's next growth engine.",
                imageAsset: 'lib/core/images/manu.webp',
                bgColor: const Color.fromARGB(255, 255, 255, 255),
                imageScaleFraction: 1,
                imageRightFraction: 0.0,
                imageBottomFraction: -0.05,
              ),
              const SizedBox(width: 12),
              _buildThemeCard(
                context,
                title: 'EV Mobility',
                subtitle: 'The future of electric mobility.',
                imageAsset: 'lib/core/images/ev.webp',
                bgColor: const Color.fromARGB(255, 255, 255, 255),
                imageScaleFraction: 0.8,
                imageRightFraction: 0.0,
                imageBottomFraction: -0.1,
              ), 
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imageAsset,
    required Color bgColor,
    required double imageScaleFraction,
    required double imageRightFraction,
    required double imageBottomFraction,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.35;

    return SizedBox(
      width: cardWidth,
      child: AspectRatio(
        aspectRatio: 0.72,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: HSLColor.fromColor(bgColor)
                  .withLightness(
                    (HSLColor.fromColor(bgColor).lightness - 0.12).clamp(
                      0.0,
                      1.0,
                    ),
                  )
                  .toColor(),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Image Background (Responsive)
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      final size = w * imageScaleFraction;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            right: -(w * imageRightFraction),
                            bottom: -(h * imageBottomFraction),
                            width: size,
                            height: size,
                            child: Image.asset(imageAsset, fit: BoxFit.contain),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Text Content
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Explore Button
                Positioned(
                  bottom: 8,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
