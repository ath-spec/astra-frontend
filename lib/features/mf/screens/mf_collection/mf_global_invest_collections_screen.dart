import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../data/catalog_providers.dart';
import '../../data/catalog_models.dart';
import '../mf_explore/widgets/mf_fund_list_card.dart';
import 'mf_theme_collection_screen.dart';

class MfGlobalInvestCollectionsScreen extends ConsumerStatefulWidget {
  const MfGlobalInvestCollectionsScreen({super.key});

  @override
  ConsumerState<MfGlobalInvestCollectionsScreen> createState() => _MfGlobalInvestCollectionsScreenState();
}

class _MfGlobalInvestCollectionsScreenState extends ConsumerState<MfGlobalInvestCollectionsScreen> {
  String _activeFilter = 'Curated';

  void _openCollection(
    String title,
    String subtitle, {
    String? imagePath,
    IconData? icon,
    Color? iconColor,
    List<CatalogFund>? funds,
  }) {
    final mappedFunds = funds?.map((f) => {
      'scheme_code': f.schemeCode,
      'name': f.schemeName,
      'category': f.category,
      'returns': {
        '1Y': f.returns1y != null ? '${f.returns1y!.toStringAsFixed(1)}%' : '—',
        '3Y': f.returns3y != null ? '${f.returns3y!.toStringAsFixed(1)}%' : '—',
        '5Y': f.returns5y != null ? '${f.returns5y!.toStringAsFixed(1)}%' : '—',
      },
    }).toList();

    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MfThemeCollectionScreen(
          title: title,
          subtitle: subtitle,
          imagePath: imagePath,
          icon: icon,
          iconColor: iconColor,
          funds: mappedFunds,
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

  List<MfFundItemData> _mapFundsToItems(List<CatalogFund> funds, IconData defaultIcon, Color defaultColor) {
    return funds.map((f) {
      final ret = f.returns1y != null
          ? '${f.returns1y!.toStringAsFixed(2)}%'
          : (f.returns3y != null ? '${f.returns3y!.toStringAsFixed(2)}%' : '18.40%');
      return MfFundItemData(
        name: f.schemeName,
        category: f.category,
        returns: ret,
        logoIcon: defaultIcon,
        logoColor: defaultColor,
        schemeCode: f.schemeCode,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(allCatalogFundsProvider);

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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Global Invest',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E1E1E),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Own the world\'s greatest companies through live global funds.',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 80,
                          height: 80,
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

                    // Content
                    if (catalogAsync.isLoading) ...[
                      const AppThemeShimmerCard(height: 140),
                      const SizedBox(height: 16),
                      const AppThemeShimmerCard(height: 140),
                      const SizedBox(height: 16),
                      const AppThemeShimmerCard(height: 140),
                    ] else ...[
                      _buildCardsList(catalogAsync.valueOrNull ?? []),
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

  Widget _buildCardsList(List<CatalogFund> allFunds) {
    // Partition funds dynamically based on categories
    // 'Equity - US Mega Cap' is the dedicated category for the seven actual
    // Magnificent 7 companies (backend migration 000039) — matching on that
    // instead of the broader 'us' substring keeps this card from being
    // dominated by unrelated Global (US) funds like Motilal Oswal Nasdaq 100
    // FOF, which belongs on the "United States" geography card instead.
    final mag7Funds = allFunds.where((f) {
      final cat = f.category.toLowerCase();
      return cat.contains('mega cap');
    }).toList();

    final techFunds = allFunds.where((f) {
      final name = f.schemeName.toLowerCase();
      final cat = f.category.toLowerCase();
      return cat.contains('tech') || name.contains('tech') || name.contains('semi') || name.contains('ai') || name.contains('innovation');
    }).toList();

    final defenseFunds = allFunds.where((f) {
      final name = f.schemeName.toLowerCase();
      final cat = f.category.toLowerCase();
      return name.contains('defense') || name.contains('aerospace') || cat.contains('thematic');
    }).toList();

    final etfFunds = allFunds.where((f) {
      final name = f.schemeName.toLowerCase();
      return name.contains('etf') || name.contains('s&p') || name.contains('index') || name.contains('nifty');
    }).toList();

    final usFunds = allFunds.where((f) {
      final name = f.schemeName.toLowerCase();
      final cat = f.category.toLowerCase();
      return name.contains('us') || cat.contains('us') || name.contains('bluechip');
    }).toList();

    final europeFunds = allFunds.where((f) {
      final name = f.schemeName.toLowerCase();
      final cat = f.category.toLowerCase();
      return name.contains('europe') || cat.contains('europe') || cat.contains('international');
    }).toList();

    final emergingFunds = allFunds.where((f) {
      final name = f.schemeName.toLowerCase();
      final cat = f.category.toLowerCase();
      return name.contains('emerg') || cat.contains('emerg') || cat.contains('small');
    }).toList();

    if (_activeFilter == 'Curated') {
      return Column(
        children: [
          _buildFundCard(
            cardTitle: 'Magnificent 7',
            cardSubtitle: 'Top US Tech & Innovation Leaders',
            icon: Icons.rocket_launch_rounded,
            iconColor: Colors.blue,
            funds: _mapFundsToItems(
              (mag7Funds.isNotEmpty ? mag7Funds : allFunds).take(3).toList(),
              Icons.rocket_launch_rounded,
              Colors.blue,
            ),
            rawFunds: mag7Funds.isNotEmpty ? mag7Funds : allFunds.take(7).toList(),
            imagePath: 'lib/core/images/mag_7.webp',
          ),
          const SizedBox(height: 24),
          _buildFundCard(
            cardTitle: 'AI & Semiconductors',
            cardSubtitle: 'Future of Global Computing',
            icon: Icons.memory_rounded,
            iconColor: Colors.purple,
            funds: _mapFundsToItems(
              (techFunds.isNotEmpty ? techFunds : allFunds).take(3).toList(),
              Icons.memory_rounded,
              Colors.purple,
            ),
            rawFunds: techFunds.isNotEmpty ? techFunds : allFunds.take(6).toList(),
            imagePath: 'lib/core/images/ai_global.webp',
          ),
          const SizedBox(height: 24),
          _buildFundCard(
            cardTitle: 'Defense & Aerospace',
            cardSubtitle: 'Global Infrastructure & Security',
            icon: Icons.security_rounded,
            iconColor: Colors.green,
            funds: _mapFundsToItems(
              (defenseFunds.isNotEmpty ? defenseFunds : allFunds).take(3).toList(),
              Icons.security_rounded,
              Colors.green,
            ),
            rawFunds: defenseFunds.isNotEmpty ? defenseFunds : allFunds.take(6).toList(),
            imagePath: 'lib/core/images/defense.webp',
          ),
          const SizedBox(height: 24),
          _buildFundCard(
            cardTitle: 'Popular Global ETFs',
            cardSubtitle: 'Broad Market Diversification',
            icon: Icons.trending_up_rounded,
            iconColor: Colors.orange,
            funds: _mapFundsToItems(
              (etfFunds.isNotEmpty ? etfFunds : allFunds).take(3).toList(),
              Icons.trending_up_rounded,
              Colors.orange,
            ),
            rawFunds: etfFunds.isNotEmpty ? etfFunds : allFunds.take(6).toList(),
            imagePath: 'lib/core/images/popular.webp',
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildFundCard(
            cardTitle: 'United States',
            cardSubtitle: "World's Largest Capital Market",
            icon: Icons.public_rounded,
            iconColor: Colors.blueAccent,
            funds: _mapFundsToItems(
              (usFunds.isNotEmpty ? usFunds : allFunds).take(3).toList(),
              Icons.public_rounded,
              Colors.blueAccent,
            ),
            rawFunds: usFunds.isNotEmpty ? usFunds : allFunds.take(6).toList(),
            imagePath: 'lib/core/images/usa_flag.webp',
          ),
          const SizedBox(height: 24),
          _buildFundCard(
            cardTitle: 'Europe & Developed Markets',
            cardSubtitle: 'Established Continental Bluechips',
            icon: Icons.account_balance_rounded,
            iconColor: Colors.indigo,
            funds: _mapFundsToItems(
              (europeFunds.isNotEmpty ? europeFunds : allFunds).take(3).toList(),
              Icons.account_balance_rounded,
              Colors.indigo,
            ),
            rawFunds: europeFunds.isNotEmpty ? europeFunds : allFunds.take(6).toList(),
            imagePath: 'lib/core/images/europe.webp',
          ),
          const SizedBox(height: 24),
          _buildFundCard(
            cardTitle: 'Emerging Markets',
            cardSubtitle: 'High Growth Frontier Economies',
            icon: Icons.language_rounded,
            iconColor: Colors.teal,
            funds: _mapFundsToItems(
              (emergingFunds.isNotEmpty ? emergingFunds : allFunds).take(3).toList(),
              Icons.language_rounded,
              Colors.teal,
            ),
            rawFunds: emergingFunds.isNotEmpty ? emergingFunds : allFunds.take(6).toList(),
            imagePath: 'lib/core/images/emerging_market.webp',
          ),
        ],
      );
    }
  }

  Widget _buildFundCard({
    required String cardTitle,
    required String cardSubtitle,
    required IconData icon,
    required Color iconColor,
    required List<MfFundItemData> funds,
    required List<CatalogFund> rawFunds,
    String? imagePath,
  }) {
    return MfFundListCard(
      margin: EdgeInsets.zero,
      borderColor: const Color(0xFFE2E8F0),
      sectionTitle: '',
      cardTitle: cardTitle,
      cardSubtitle: cardSubtitle,
      cardGraphic: imagePath != null
          ? SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            )
          : SizedBox(
              width: 80,
              height: 80,
              child: Icon(icon, color: iconColor, size: 36),
            ),
      funds: funds,
      onViewCollection: () => _openCollection(
        cardTitle,
        cardSubtitle,
        imagePath: imagePath,
        icon: icon,
        iconColor: iconColor,
        funds: rawFunds,
      ),
    );
  }
}
