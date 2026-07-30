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
              fontWeight: FontWeight.w700,
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
                title: 'AI Revolution',
                subtitle: 'Invest in companies\nbuilding AI.',
                imageAsset: 'lib/core/images/india_ai.webp',
                imageScaleFraction: 0.9,
                imageRightFraction: 0.0,
                imageBottomFraction: 0.0,
              ),
              const SizedBox(width: 12),
              _buildThemeCard(
                context,
                title: 'India Mfg',
                subtitle: "Back India's next\ngrowth engine.",
                imageAsset: 'lib/core/images/india_manufacturing.webp',
                imageScaleFraction: 0.9,
                imageRightFraction: 0.0,
                imageBottomFraction: 0.0,
              ),
              const SizedBox(width: 12),
              _buildThemeCard(
                context,
                title: 'Semi-Conductor',
                subtitle: 'Powering the\ndigital future.',
                imageAsset: 'lib/core/images/semiconductor.webp',
                imageScaleFraction: 0.9,
                imageRightFraction: 0.0,
                imageBottomFraction: 0.0,
              ),
              const SizedBox(width: 12),
              _buildThemeCard(
                context,
                title: 'EV Mobility',
                subtitle: 'The future of\nelectric mobility.',
                imageAsset: 'lib/core/images/ev.webp',
                imageScaleFraction: 0.9,
                imageRightFraction: 0.0,
                imageBottomFraction: 0.0,
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
    required double imageScaleFraction,
    required double imageRightFraction,
    required double imageBottomFraction,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.42;
    const bgColor = Color(0xFFF8FAFC); // Default uniform background color

    return SizedBox(
      width: cardWidth,
      child: AspectRatio(
        aspectRatio: 0.72,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: HSLColor.fromColor(bgColor).withLightness(
                (HSLColor.fromColor(bgColor).lightness - 0.12).clamp(0.0, 1.0)
              ).toColor(),
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
            borderRadius: BorderRadius.circular(15),
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
                // Gradient Overlay to ensure text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          bgColor,
                          bgColor.withOpacity(0.8),
                          bgColor.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                // Text Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
                      const Spacer(),
                      // Explore Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Explore',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
                          ],
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
    );
  }
}
