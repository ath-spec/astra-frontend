import 'package:flutter/material.dart';
import '../../mf_collection/mf_theme_collection_screen.dart';

class MfNewTrendingThemes extends StatefulWidget {
  const MfNewTrendingThemes({super.key});

  @override
  State<MfNewTrendingThemes> createState() => _MfNewTrendingThemesState();
}

class _MfNewTrendingThemesState extends State<MfNewTrendingThemes> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.3; // Initial approximate width factor

  final List<Map<String, dynamic>> _renewableFunds = [
    {
      'name': 'Tata Green Energy Fund',
      'category': 'Equity • Thematic',
      'returns': {'1Y': '42.10%', '3Y': '24.50%', '5Y': '19.80%'},
    },
    {
      'name': 'Nippon India Power & Infra',
      'category': 'Equity • Sectoral',
      'returns': {'1Y': '38.40%', '3Y': '21.20%', '5Y': '17.50%'},
    },
  ];

  final List<Map<String, dynamic>> _semiConductorFunds = [
    {
      'name': 'Semi-Conductor',
      'category': 'Equity • Thematic • Global',
      'returns': {'1Y': '54.20%', '3Y': '42.10%', '5Y': '28.50%'},
    },
    {
      'name': 'Global Tech Fund',
      'category': 'Equity • Sectoral',
      'returns': {'1Y': '48.10%', '3Y': '36.50%', '5Y': '25.20%'},
    },
  ];

  final List<Map<String, dynamic>> _aiFunds = [
    {
      'name': 'AI Revolution',
      'category': 'Equity • Sectoral • Technology',
      'returns': {'1Y': '48.50%', '3Y': '34.20%', '5Y': '26.80%'},
    },
    {
      'name': 'Tech & AI Opportunities',
      'category': 'Equity • Thematic',
      'returns': {'1Y': '45.20%', '3Y': '31.50%', '5Y': '24.10%'},
    },
  ];

  final List<Map<String, dynamic>> _indiaMfgFunds = [
    {
      'name': 'India Manufacturing',
      'category': 'Equity • Thematic • Manufacturing',
      'returns': {'1Y': '36.80%', '3Y': '28.40%', '5Y': '22.50%'},
    },
    {
      'name': 'ICICI Pru Manufacturing Fund',
      'category': 'Equity • Thematic',
      'returns': {'1Y': '34.50%', '3Y': '26.80%', '5Y': '21.20%'},
    },
  ];

  final List<Map<String, dynamic>> _evFunds = [
    {
      'name': 'EV Mobility Fund',
      'category': 'Equity • Thematic',
      'returns': {'1Y': '32.40%', '3Y': '25.60%', '5Y': '18.90%'},
    },
    {
      'name': 'Auto & Ancillary Fund',
      'category': 'Equity • Sectoral',
      'returns': {'1Y': '28.90%', '3Y': '22.40%', '5Y': '16.50%'},
    },
  ];

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

  @override
  Widget build(BuildContext context) {

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
                        funds: _renewableFunds,
                        imagePath: 'lib/core/images/renewal.webp',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),

              _buildThemeCard(
                context,
                title: 'Semi\u200Bconductor',
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
                        funds: _semiConductorFunds,
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
                        funds: _aiFunds,
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
                        funds: _indiaMfgFunds,
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
                        funds: _evFunds,
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
    final screenWidth = MediaQuery.of(context).size.width;
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
