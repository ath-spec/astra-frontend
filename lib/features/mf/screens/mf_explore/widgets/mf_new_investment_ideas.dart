import 'package:flutter/material.dart';
import 'mf_fund_list_card.dart';
import '../../mf_collection/mf_collection_screen.dart';

class MfNewInvestmentIdeas extends StatelessWidget {
  const MfNewInvestmentIdeas({super.key});

  @override
  Widget build(BuildContext context) {
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
                width: MediaQuery.of(context).size.width * 0.8,
                child: MfFundListCard(
                  margin: const EdgeInsets.only(left: 16.0, right: 8.0),
                  borderColor: HSLColor.fromColor(Colors.white).withLightness((1.0 - 0.12).clamp(0.0, 1.0)).toColor(),
                  sectionTitle: '', // We use our own header above
                  cardTitle: 'High Growth',
                  cardSubtitle: 'Top ideas with high potential returns.',
                  cardGraphic: SizedBox(
                    width: 90,
                    height: 90,
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
                      name: 'Quant Value Fund',
                      category: 'Equity • Value',
                      returns: '22.56%',
                      logoIcon: Icons.account_balance,
                      logoColor: Colors.deepPurple,
                    ),
                    MfFundItemData(
                      name: 'Axis Value Fund',
                      category: 'Equity • Value',
                      returns: '18.73%',
                      logoIcon: Icons.change_history,
                      logoColor: Colors.red,
                    ),
                    MfFundItemData(
                      name: 'HSBC Value Fund',
                      category: 'Equity • Value',
                      returns: '18.4%',
                      logoIcon: Icons.hdr_strong,
                      logoColor: Colors.redAccent,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: MfFundListCard(
                  margin: const EdgeInsets.only(left: 8.0, right: 16.0),
                  borderColor: HSLColor.fromColor(Colors.white).withLightness((1.0 - 0.12).clamp(0.0, 1.0)).toColor(),
                  sectionTitle: '',
                  cardTitle: 'Safe Investing',
                  cardSubtitle: 'Protect your capital with safer options.',
                  cardGraphic: SizedBox(
                    width: 90,
                    height: 90,
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
                      name: 'HDFC Corporate Bond Fund',
                      category: 'Debt • Corporate Bond',
                      returns: '7.28%',
                      logoIcon: Icons.domain,
                      logoColor: Colors.blue,
                    ),
                    MfFundItemData(
                      name: 'SBI Debt Fund',
                      category: 'Debt • Short Term',
                      returns: '7.10%',
                      logoIcon: Icons.lens,
                      logoColor: Colors.lightBlue,
                    ),
                    MfFundItemData(
                      name: 'ICICI Pru Savings Fund',
                      category: 'Debt • Liquid',
                      returns: '6.75%',
                      logoIcon: Icons.water_drop,
                      logoColor: Colors.deepOrange,
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
