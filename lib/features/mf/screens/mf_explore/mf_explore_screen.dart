import 'package:flutter/material.dart';
import 'widgets/mf_explore_header.dart';
import 'widgets/mf_quick_actions.dart';
import 'widgets/mf_explore_grid.dart';
import 'widgets/mf_trending_funds.dart';
import 'widgets/mf_fund_list_card.dart';
import 'widgets/mf_precious_metals_card.dart';
import 'widgets/mf_popular_pills.dart';
import 'widgets/mf_alternative_funds.dart';

class MfExploreScreen extends StatelessWidget {
  const MfExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            floating: true,
            leading: Icon(Icons.chevron_left, color: Colors.black),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(Icons.lock_outline, color: Colors.black),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MfExploreHeader(),
                const MfQuickActions(),
                const SizedBox(height: 48),
                const MfExploreGrid(),
                const SizedBox(height: 48),
                const MfTrendingFunds(),
                const SizedBox(height: 48),
                MfFundListCard(
                  sectionTitle: 'Investment Ideas',
                  cardTitle: 'High Potential Value Funds',
                  cardSubtitle: 'Targeting hidden gems in the stock market',
                  cardGraphic: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF6EE7B7), Color(0xFF10B981)],
                      ),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.pie_chart, color: Colors.white, size: 32),
                  ),
                  funds: const [
                    MfFundItemData(
                      name: 'Quant Value Fund',
                      category: 'Equity • Value',
                      returns: '22.56%',
                      logoIcon: Icons.change_history,
                      logoColor: Colors.purple,
                    ),
                    MfFundItemData(
                      name: 'Axis Value Fund',
                      category: 'Equity • Value',
                      returns: '18.73%',
                      logoIcon: Icons.details,
                      logoColor: Colors.red,
                    ),
                    MfFundItemData(
                      name: 'HSBC Value Fund',
                      category: 'Equity • Value',
                      returns: '18.4%',
                      logoIcon: Icons.account_balance,
                      logoColor: Colors.redAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                MfPreciousMetalsCard(
                  title: 'Diversifying with Gold Funds',
                  subtitle: 'Add Gold to your portfolio with ease with funds that track gold',
                  baseColor: const Color(0xFFFCD34D), // Amber
                  topFundName: 'Edelweiss Gold & Silver ETF FoF',
                  topFundReturns: '37.5%',
                  graphic: Icon(Icons.view_agenda_rounded, size: 100, color: const Color(0xFFFBBF24).withOpacity(0.5)),
                ),
                const SizedBox(height: 48),
                const MfPopularPills(),
                const SizedBox(height: 48),
                const MfAlternativeFunds(),
                const SizedBox(height: 48),
                MfPreciousMetalsCard(
                  title: 'Diversifying with Silver Funds',
                  subtitle: 'Add Silver to your portfolio with ease with funds that track silver',
                  baseColor: const Color(0xFFCBD5E1), // Slate
                  topFundName: 'UTI Silver ETF FoF',
                  topFundReturns: '41.73%',
                  graphic: Icon(Icons.monetization_on_rounded, size: 100, color: const Color(0xFF94A3B8).withOpacity(0.5)),
                ),
                const SizedBox(height: 48),
                MfFundListCard(
                  sectionTitle: 'Ride the Nifty',
                  cardTitle: 'Passive funds that track Nifty 50 for peaceful investments',
                  cardSubtitle: '',
                  cardGraphic: const SizedBox.shrink(), // No graphic for this one
                  funds: const [
                    MfFundItemData(
                      name: 'Motilal Oswal Nifty 50 Index Fund',
                      category: 'Equity • Index Funds',
                      returns: '8.38%',
                      logoIcon: Icons.show_chart,
                      logoColor: Colors.orange,
                    ),
                    MfFundItemData(
                      name: 'Navi Nifty 50 Index Fund',
                      category: 'Equity • Index Funds',
                      returns: '8.36%',
                      logoIcon: Icons.trending_up,
                      logoColor: Colors.green,
                    ),
                    MfFundItemData(
                      name: 'Franklin India Nse Nifty 50 Index Fund',
                      category: 'Equity • Index Funds',
                      returns: '8.34%',
                      logoIcon: Icons.account_balance,
                      logoColor: Colors.blueGrey,
                    ),
                  ],
                ),
                const SizedBox(height: 120), // Bottom padding for nav bar
              ],
            ),
          ),
        ],
      ),
    );
  }
}
