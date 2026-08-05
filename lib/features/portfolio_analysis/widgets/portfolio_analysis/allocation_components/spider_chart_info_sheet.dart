import 'package:flutter/material.dart';
import '../../../../../core/responsive/size_config.dart';

class SpiderChartInfoSheet extends StatelessWidget {
  const SpiderChartInfoSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SpiderChartInfoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(getProportionateScreenWidth(24)),
          topRight: Radius.circular(getProportionateScreenWidth(24)),
        ),
      ),
      padding: EdgeInsets.only(
        top: getProportionateScreenHeight(24),
        left: getProportionateScreenWidth(24),
        right: getProportionateScreenWidth(24),
        bottom: MediaQuery.of(context).padding.bottom + getProportionateScreenHeight(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Genome Dimensions',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: getProportionateScreenWidth(14),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: getProportionateScreenHeight(24)),
          _buildInfoItem('Growth', 'The potential for the investment to significantly increase in value over time.'),
          _buildInfoItem('Income', 'The ability to generate regular cash flow, such as dividends or interest payments.'),
          _buildInfoItem('Capital Preservation', 'How well the investment protects your initial money from market downturns.'),
          _buildInfoItem('Inflation Defense', 'The ability of the investment to outpace or keep up with rising consumer prices over time.'),
          _buildInfoItem('Liquidity', 'How easily and quickly the asset can be converted back into cash without a major price drop.'),
          _buildInfoItem('Sustainability', 'Adherence to Environmental, Social, and Governance (ESG) criteria and ethical business practices.'),
          _buildInfoItem('Real Assets', 'Exposure to tangible, physical assets like real estate, gold, infrastructure, or commodities.'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: getProportionateScreenWidth(12),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(4)),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: getProportionateScreenWidth(10),
              height: 1.4,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
