import 'package:flutter/material.dart';
import 'discipline_components/discipline_gauge_section.dart';
import 'discipline_components/discipline_factors_card.dart';

import 'discipline_components/monthly_investment_section.dart';
import 'discipline_components/sip_discipline_grid.dart';
import 'discipline_components/sip_automation_section.dart';
import 'discipline_components/yearly_investment_section.dart';

class DisciplineTab extends StatelessWidget {
  const DisciplineTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: const [
              DisciplineGaugeSection(),
              DisciplineFactorsCard(),
              SizedBox(height: 48),
              MonthlyInvestmentSection(),
              SipDisciplineGrid(),
              SizedBox(height: 48),
              SipAutomationSection(),
              SizedBox(height: 48),
              YearlyInvestmentSection(),
              SizedBox(height: 48),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'This information is provided for informational purposes only and does not constitute investment advice, a recommendation, or an offer to buy or sell any securities. It is based on standardized methods and may not reflect your individual financial circumstances or risk profile. Consider consulting a financial advisor before making any investment decisions.',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }
}
