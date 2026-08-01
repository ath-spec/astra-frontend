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
            ],
          ),
        ),
      ],
    );
  }
}
