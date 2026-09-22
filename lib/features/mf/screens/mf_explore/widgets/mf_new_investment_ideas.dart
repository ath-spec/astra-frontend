import 'package:flutter/material.dart';
import 'mf_fund_list_card.dart';
import '../../mf_collection/mf_collection_screen.dart';

class MfNewInvestmentIdeas extends StatelessWidget {
  const MfNewInvestmentIdeas({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth * 0.88;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Investment Ideas',
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: cardWidth,
                child: MfFundListCard(
                  margin: const EdgeInsets.only(left: 16.0, right: 8.0),
                  borderColor: const Color(0xFFE2E8F0),
                  sectionTitle: '',
                  cardTitle: 'High Growth',
                  cardSubtitle: 'Top ideas with high potential returns.',
                  cardGraphic: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.asset(
                      'lib/core/images/growth_collections.webp',
                      fit: BoxFit.contain,
                    ),
                  ),
                  onViewCollection: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => const MfCollectionScreen(
                          title: 'High Growth',
                          subtitle: 'Top ideas with high potential returns.',
                          imagePath: 'lib/core/images/growth_collections.webp',
                        ),
                      ),
                    );
                  },
                  funds: const [
                    MfFundItemData(
                      name: 'Axis Small Cap Fund',
                      category: 'Equity • Small Cap',
                      returns: '29.80%',
                      logoIcon: Icons.change_history,
                      logoColor: Colors.red,
                      schemeCode: 'AXIS-SC-G',
                    ),
                    MfFundItemData(
                      name: 'Global Semiconductor Fund',
                      category: 'Equity • Thematic',
                      returns: '42.10%',
                      logoIcon: Icons.memory,
                      logoColor: Colors.deepPurple,
                      schemeCode: 'MIRAE-SEMI-G',
                    ),
                    MfFundItemData(
                      name: 'Parag Parikh Flexi Cap Fund',
                      category: 'Equity • Flexi Cap',
                      returns: '23.80%',
                      logoIcon: Icons.account_balance,
                      logoColor: Colors.teal,
                      schemeCode: 'PARAG-FLX-G',
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: MfFundListCard(
                  margin: const EdgeInsets.only(left: 8.0, right: 16.0),
                  borderColor: const Color(0xFFE2E8F0),
                  sectionTitle: '',
                  cardTitle: 'Safe Investing',
                  cardSubtitle: 'Protect your capital with safer options.',
                  cardGraphic: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.asset(
                      'lib/core/images/safe_investments.webp',
                      fit: BoxFit.contain,
                    ),
                  ),
                  onViewCollection: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => const MfCollectionScreen(
                          title: 'Safe Investing',
                          subtitle: 'Protect your capital with safer options.',
                          imagePath: 'lib/core/images/safe_investments.webp',
                        ),
                      ),
                    );
                  },
                  funds: const [
                    MfFundItemData(
                      name: 'HDFC Corporate Bond Direct Plan',
                      category: 'Debt • Corporate Bond',
                      returns: '7.28%',
                      logoIcon: Icons.domain,
                      logoColor: Colors.blue,
                      schemeCode: 'HDFC-CORPBOND-G',
                    ),
                    MfFundItemData(
                      name: 'SBI Short Term Debt Fund',
                      category: 'Debt • Short Term',
                      returns: '7.10%',
                      logoIcon: Icons.shield_outlined,
                      logoColor: Colors.lightBlue,
                      schemeCode: 'SBI-STD-G',
                    ),
                    MfFundItemData(
                      name: 'ICICI Pru Liquid Fund',
                      category: 'Debt • Liquid',
                      returns: '6.75%',
                      logoIcon: Icons.water_drop,
                      logoColor: Colors.deepOrange,
                      schemeCode: 'ICICI-LIQ-G',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
