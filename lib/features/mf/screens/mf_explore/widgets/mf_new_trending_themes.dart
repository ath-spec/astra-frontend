import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/catalog_providers.dart';
import '../../../data/catalog_models.dart';
import '../../mf_collection/mf_theme_collection_screen.dart';

class MfNewTrendingThemes extends ConsumerStatefulWidget {
  const MfNewTrendingThemes({super.key});

  @override
  ConsumerState<MfNewTrendingThemes> createState() => _MfNewTrendingThemesState();
}

class _MfNewTrendingThemesState extends ConsumerState<MfNewTrendingThemes> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.3; // Initial approximate width factor

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final viewport = _scrollController.position.viewportDimension;
      if (maxScroll > 0) {
        final progress = ((_scrollController.offset + viewport) / (maxScroll + viewport)).clamp(0.0, 1.0);
        if (progress != _scrollProgress) {
          setState(() {
            _scrollProgress = progress;
          });
        }
      }
    }
  }

  List<Map<String, dynamic>> _mapFunds(List<CatalogFund> funds) {
    return funds
        .map((f) => {
              'scheme_code': f.schemeCode,
              'name': f.schemeName,
              'category': f.category,
              'returns': {
                '1Y': '${(f.returns1y ?? 28.0).toStringAsFixed(1)}%',
                '3Y': '${(f.returns3y ?? 24.5).toStringAsFixed(1)}%',
                '5Y': '${(f.returns5y ?? 19.8).toStringAsFixed(1)}%',
              },
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(allCatalogFundsProvider);
    final catalogFunds = catalogAsync.valueOrNull ?? <CatalogFund>[];

    final renewableFunds = _mapFunds(catalogFunds
        .where((f) =>
            f.schemeName.toLowerCase().contains('green') ||
            f.schemeName.toLowerCase().contains('energy') ||
            f.schemeName.toLowerCase().contains('infra') ||
            f.schemeName.toLowerCase().contains('power'))
        .take(6)
        .toList());

    final semiConductorFunds = _mapFunds(catalogFunds
        .where((f) =>
            f.schemeName.toLowerCase().contains('semi') ||
            f.schemeName.toLowerCase().contains('chip') ||
            f.schemeName.toLowerCase().contains('nasdaq') ||
            f.schemeName.toLowerCase().contains('global tech'))
        .take(6)
        .toList());

    final aiFunds = _mapFunds(catalogFunds
        .where((f) =>
            f.schemeName.toLowerCase().contains('ai') ||
            f.schemeName.toLowerCase().contains('technology') ||
            f.category.toLowerCase().contains('technology'))
        .take(6)
        .toList());

    final indiaMfgFunds = _mapFunds(catalogFunds
        .where((f) =>
            f.schemeName.toLowerCase().contains('manufactur') ||
            f.category.toLowerCase().contains('manufactur'))
        .take(6)
        .toList());

    final evFunds = _mapFunds(catalogFunds
        .where((f) =>
            f.schemeName.toLowerCase().contains(' ev') ||
            f.schemeName.toLowerCase().contains('auto') ||
            f.schemeName.toLowerCase().contains('mobility'))
        .take(6)
        .toList());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Trending Themes',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _scrollProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          controller: _scrollController,
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
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => MfThemeCollectionScreen(
                        title: 'Renewable Energy',
                        subtitle: 'Powering the future of energy.',
                        funds: renewableFunds,
                        imagePath: 'lib/core/images/renewal.webp',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildThemeCard(
                context,
                title: 'Semi​conductor',
                subtitle: 'Powering the digital future.',
                imageAsset: 'lib/core/images/semi.webp',
                bgColor: const Color.fromARGB(255, 255, 255, 255),
                imageScaleFraction: 0.8,
                imageRightFraction: 0.0,
                imageBottomFraction: -0.1,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => MfThemeCollectionScreen(
                        title: 'Semiconductor',
                        subtitle: 'Powering the digital future.',
                        funds: semiConductorFunds,
                        imagePath: 'lib/core/images/semi.webp',
                      ),
                    ),
                  );
                },
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
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => MfThemeCollectionScreen(
                        title: 'AI Revolution',
                        subtitle: 'Invest in companies building AI.',
                        funds: aiFunds,
                        imagePath: 'lib/core/images/ai.webp',
                      ),
                    ),
                  );
                },
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
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => MfThemeCollectionScreen(
                        title: 'India Manufacturing',
                        subtitle: "Back India's next growth engine.",
                        funds: indiaMfgFunds,
                        imagePath: 'lib/core/images/manu.webp',
                      ),
                    ),
                  );
                },
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
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => MfThemeCollectionScreen(
                        title: 'EV Mobility',
                        subtitle: 'The future of electric mobility.',
                        funds: evFunds,
                        imagePath: 'lib/core/images/ev.webp',
                      ),
                    ),
                  );
                },
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
    VoidCallback? onTap,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth * 0.35;

    // Fixed sizes for consistency across all screen sizes (industry standard)
    final titleFontSize = 14.0;
    final subtitleFontSize = 10.0;
    final padding = 14.0;
    final iconSize = 16.0;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
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
                  color: Colors.black.withValues(alpha: 0.03),
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
                    top: padding,
                    left: padding,
                    right: padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: padding * 0.5),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
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
                    bottom: padding * 0.5,
                    left: padding,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: padding * 0.5,
                        vertical: padding * 0.125,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: iconSize,
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
      ),
    );
  }
}
