import 'package:flutter/material.dart';
import 'discipline_components/discipline_gauge_section.dart';
import 'discipline_components/discipline_factors_card.dart';

import 'discipline_components/monthly_investment_section.dart';
import 'discipline_components/sip_discipline_grid.dart';
import 'discipline_components/sip_automation_section.dart';
import 'discipline_components/yearly_investment_section.dart';

class DisciplineTab extends StatefulWidget {
  const DisciplineTab({super.key});

  @override
  State<DisciplineTab> createState() => _DisciplineTabState();
}

class _DisciplineTabState extends State<DisciplineTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final gapHeight = MediaQuery.sizeOf(context).height * 0.04;
    final standardGap = SizedBox(height: gapHeight);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const DisciplineGaugeSection(),
              const DisciplineFactorsCard(),
              const SizedBox(height: 56),
              const MonthlyInvestmentSection(),
              const SizedBox(height: 56),
              const SipDisciplineGrid(),
              const SizedBox(height: 56),
              const SipAutomationSection(),
              const SizedBox(height: 56),
              const YearlyInvestmentSection(),
              const SizedBox(height: 56),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'This information is provided for informational purposes only and does not constitute investment advice, a recommendation, or an offer to buy or sell any securities. It is based on standardized methods and may not reflect your individual financial circumstances or risk profile. Consider consulting a financial advisor before making any investment decisions.',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }
}
