import 'package:flutter/material.dart';
import '../mf_explore/widgets/mf_fund_list_card.dart';
import 'mf_theme_collection_screen.dart';

class MfGlobalInvestCollectionsScreen extends StatefulWidget {
  const MfGlobalInvestCollectionsScreen({super.key});

  @override
  State<MfGlobalInvestCollectionsScreen> createState() => _MfGlobalInvestCollectionsScreenState();
}

class _MfGlobalInvestCollectionsScreenState extends State<MfGlobalInvestCollectionsScreen> {
  String _activeFilter = 'Curated';

  void _openCollection(
    String title,
    String subtitle, {
    String? imagePath,
    IconData? icon,
    Color? iconColor,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MfThemeCollectionScreen(
          title: title,
          subtitle: subtitle,
          imagePath: imagePath,
          icon: icon,
          iconColor: iconColor,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Cubic(0.23, 1, 0.32, 1);
          var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(4),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1E1E1E)),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth;
          return Center(
            child: SizedBox(
              width: maxWidth,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Header Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Global Invest',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E1E1E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Own the world\'s greatest companies.',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                color: Color(0xFF64748B), // Slate 500
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Graphic
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.asset(
                          'lib/core/images/global_invest.webp',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Curated', 'Geographies'].map((filter) {
                        final isActive = _activeFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () => setState(() => _activeFilter = filter),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? Colors.white : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Cards List
                  if (_activeFilter == 'Curated') ...[
                    _buildFundCard(
                      cardTitle: 'Magnificent 7',
                      cardSubtitle: 'Top US Tech',
                      icon: Icons.rocket_launch_rounded,
                      iconColor: Colors.blue,
                      funds: _mockMag7,
                      imagePath: 'lib/core/images/mag_7.webp',
                    ),
                    const SizedBox(height: 24),
                    _buildFundCard(
                      cardTitle: 'AI & Semiconductors',
                      cardSubtitle: 'Future of Tech',
                      icon: Icons.memory_rounded,
                      iconColor: Colors.purple,
                      funds: _mockAiSemi,
                      imagePath: 'lib/core/images/ai_global.webp',
                    ),
                    const SizedBox(height: 24),
                    _buildFundCard(
                      cardTitle: 'Defense',
                      cardSubtitle: 'Global Defense',
                      icon: Icons.security_rounded,
                      iconColor: Colors.green,
                      funds: _mockDefense,
                      imagePath: 'lib/core/images/defense.webp',
                    ),
                    const SizedBox(height: 24),
                    _buildFundCard(
                      cardTitle: 'Popular ETFs',
                      cardSubtitle: 'Broad Market',
                      icon: Icons.trending_up_rounded,
                      iconColor: Colors.orange,
                      funds: _mockPopularEtfs,
                      imagePath: 'lib/core/images/popular.webp',
                    ),
                  ] else ...[
                    _buildFundCard(
                      cardTitle: 'US',
                      cardSubtitle: 'United States',
                      icon: Icons.public_rounded,
                      iconColor: Colors.blueAccent,
                      funds: _mockUS,
                      imagePath: 'lib/core/images/usa_flag.webp',
                    ),
                    const SizedBox(height: 24),
                    _buildFundCard(
                      cardTitle: 'Europe',
                      cardSubtitle: 'European Union',
                      icon: Icons.account_balance_rounded,
                      iconColor: Colors.indigo,
                      funds: _mockEurope,
                      imagePath: 'lib/core/images/europe.webp',
                    ),
                    const SizedBox(height: 24),
                    _buildFundCard(
                      cardTitle: 'Emerging Markets',
                      cardSubtitle: 'High Growth Economies',
                      icon: Icons.language_rounded,
                      iconColor: Colors.teal,
                      funds: _mockEmerging,
                      imagePath: 'lib/core/images/emerging_market.webp',
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildFundCard({
    required String cardTitle,
    required String cardSubtitle,
    required IconData icon,
    required Color iconColor,
    required List<MfFundItemData> funds,
    String? imagePath,
  }) {
    return MfFundListCard(
      margin: EdgeInsets.zero, // Match High Growth card tight layout
      borderColor: const Color(0xFFE2E8F0),
      sectionTitle: '',
      cardTitle: cardTitle,
      cardSubtitle: cardSubtitle,
      cardGraphic: imagePath != null
          ? SizedBox(
              width: 90,
              height: 90,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            )
          : SizedBox(
              width: 90,
              height: 90,
              child: Icon(icon, color: iconColor, size: 40),
            ),
      funds: funds,
      onViewCollection: () => _openCollection(
        cardTitle,
        cardSubtitle,
        imagePath: imagePath,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  // --- MOCK DATA ---

  final List<MfFundItemData> _mockMag7 = [
    const MfFundItemData(
      name: 'Motilal Oswal Nasdaq 100 FOF',
      category: 'Equity • Global',
      returns: '26.80%',
      logoIcon: Icons.apple,
      logoColor: Colors.black,
    ),
    const MfFundItemData(
      name: 'Mirae Asset NYSE FANG+ ETF',
      category: 'Equity • Global Tech',
      returns: '31.20%',
      logoIcon: Icons.computer,
      logoColor: Colors.blue,
    ),
  ];

  final List<MfFundItemData> _mockAiSemi = [
    const MfFundItemData(
      name: 'Edelweiss US Technology Equity FOF',
      category: 'Equity • Global Tech',
      returns: '24.50%',
      logoIcon: Icons.memory,
      logoColor: Colors.purple,
    ),
    const MfFundItemData(
      name: 'DSP Global Innovation FOF',
      category: 'Equity • Global Tech',
      returns: '22.10%',
      logoIcon: Icons.precision_manufacturing,
      logoColor: Colors.deepPurple,
    ),
  ];

  final List<MfFundItemData> _mockDefense = [
    const MfFundItemData(
      name: 'DSP Global Aerospace & Defense FOF',
      category: 'Equity • Global Sectoral',
      returns: '28.20%',
      logoIcon: Icons.security,
      logoColor: Colors.green,
    ),
    const MfFundItemData(
      name: 'Edelweiss International Defense Equity',
      category: 'Equity • Global Sectoral',
      returns: '25.10%',
      logoIcon: Icons.shield,
      logoColor: Colors.teal,
    ),
  ];

  final List<MfFundItemData> _mockPopularEtfs = [
    const MfFundItemData(
      name: 'Motilal Oswal S&P 500 ETF',
      category: 'Equity • Global Large Cap',
      returns: '22.80%',
      logoIcon: Icons.trending_up,
      logoColor: Colors.blueAccent,
    ),
    const MfFundItemData(
      name: 'Nippon India ETF Hang Seng BeES',
      category: 'Equity • Global Emerging',
      returns: '15.75%',
      logoIcon: Icons.show_chart,
      logoColor: Colors.redAccent,
    ),
  ];

  final List<MfFundItemData> _mockUS = [
    const MfFundItemData(
      name: 'ICICI Prudential US Bluechip Equity',
      category: 'Equity • Global',
      returns: '18.40%',
      logoIcon: Icons.business,
      logoColor: Colors.orange,
    ),
    const MfFundItemData(
      name: 'PGIM India Global Equity',
      category: 'Equity • Global',
      returns: '16.90%',
      logoIcon: Icons.public,
      logoColor: Colors.blue,
    ),
  ];

  final List<MfFundItemData> _mockEurope = [
    const MfFundItemData(
      name: 'Invesco Pan European Equity',
      category: 'Equity • Global',
      returns: '8.20%',
      logoIcon: Icons.euro,
      logoColor: Colors.indigo,
    ),
    const MfFundItemData(
      name: 'Nippon India Europe Dynamic',
      category: 'Equity • Global',
      returns: '7.50%',
      logoIcon: Icons.account_balance,
      logoColor: Colors.red,
    ),
  ];

  final List<MfFundItemData> _mockEmerging = [
    const MfFundItemData(
      name: 'Kotak Global Emerging Market',
      category: 'Equity • Global',
      returns: '12.40%',
      logoIcon: Icons.landscape,
      logoColor: Colors.teal,
    ),
    const MfFundItemData(
      name: 'Aditya Birla Sun Life Emerging',
      category: 'Equity • Global',
      returns: '11.80%',
      logoIcon: Icons.explore,
      logoColor: Colors.brown,
    ),
  ];
}
