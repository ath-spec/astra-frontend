import 'package:flutter/material.dart';

import '../../mf_collection/mf_mutual_funds_collection_screen.dart';
import '../../mf_collection/mf_stocks_collection_screen.dart';
import '../../mf_collection/mf_etfs_collection_screen.dart';
import '../../mf_collection/mf_gold_collection_screen.dart';
import '../../mf_collection/mf_reits_collection_screen.dart';
import '../../mf_collection/mf_invits_collection_screen.dart';
import '../../mf_collection/mf_global_funds_collection_screen.dart';
import '../../mf_collection/mf_fds_collection_screen.dart';
import '../../mf_collection/mf_bonds_collection_screen.dart';
class MfExploreAssets extends StatelessWidget {
  const MfExploreAssets({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'Mutual\nFunds', 'icon': Icons.pie_chart_rounded, 'color': const Color.fromARGB(255, 0, 0, 0)},
      {'title': 'Stocks', 'icon': Icons.trending_up_rounded, 'color': const Color.fromARGB(255, 0, 0, 0)},
      {'title': 'ETFs', 'icon': Icons.widgets_rounded, 'color': const Color.fromARGB(255, 0, 0, 0)},
      {'title': 'Gold', 'icon': Icons.inventory_2_rounded, 'color': const Color.fromARGB(255, 0, 0, 0)},
      {'title': 'Bonds', 'icon': Icons.security_rounded, 'color': const Color.fromARGB(255, 0, 0, 0)},
      {'title': 'REITs', 'icon': Icons.location_city_rounded, 'color': const Color.fromARGB(255, 0, 0, 0)},
      {'title': 'INVITs', 'icon': Icons.account_tree_rounded, 'color': const Color.fromARGB(255, 0, 0, 0)},
      {'title': 'FDs', 'icon': Icons.lock_rounded, 'color': const Color.fromARGB(255, 0, 0, 0)},
      {'title': 'Global\nFunds', 'icon': Icons.public_rounded, 'color': const Color.fromARGB(255, 0, 0, 0)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Explore Assets',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              Row(
                children: const [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF0F172A),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () {
                  if (item['title'] == 'Mutual\nFunds') {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const MfMutualFundsCollectionScreen()),
                    );
                  } else if (item['title'] == 'FDs') {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const MfFdsCollectionScreen()),
                    );
                  } else if (item['title'] == 'Bonds') {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const MfBondsCollectionScreen()),
                    );
                  } else if (item['title'] == 'Stocks') {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const MfStocksCollectionScreen()),
                    );
                  } else if (item['title'] == 'ETFs') {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const MfEtfsCollectionScreen()),
                    );
                  } else if (item['title'] == 'Gold') {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const MfGoldCollectionScreen()),
                    );
                  } else if (item['title'] == 'REITs') {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const MfReitsCollectionScreen()),
                    );
                  } else if (item['title'] == 'INVITs') {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const MfInvitsCollectionScreen()),
                    );
                  } else if (item['title'] == 'Global\nFunds') {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const MfGlobalFundsCollectionScreen()),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color.fromARGB(255, 220, 220, 221)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
