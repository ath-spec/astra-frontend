import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/catalog_providers.dart';
import '../../data/catalog_models.dart';
import '../fund_profile/mf_fund_profile_screen.dart';

class MfCollectionScreen extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final String? imagePath;

  const MfCollectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath,
  });

  @override
  ConsumerState<MfCollectionScreen> createState() => _MfCollectionScreenState();
}

class _MfCollectionScreenState extends ConsumerState<MfCollectionScreen> {
  String _returnPeriod = '3Y'; // '1Y', '3Y', '5Y'

  final List<Map<String, dynamic>> _mockFunds = [
    {
      'scheme_code': 'INF846K01EW2',
      'name': 'Quant Value Fund',
      'category': 'Equity • Value',
      'returns': {'1Y': '45.12%', '3Y': '22.56%', '5Y': '18.42%'},
    },
    {
      'scheme_code': 'INF209K01157',
      'name': 'Axis Value Fund',
      'category': 'Equity • Value',
      'returns': {'1Y': '38.54%', '3Y': '18.73%', '5Y': '15.20%'},
    },
  ];

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(allCatalogFundsProvider);

    List<Map<String, dynamic>> displayFunds = _mockFunds;
    if (catalogAsync.hasValue && catalogAsync.value != null && catalogAsync.value!.isNotEmpty) {
      displayFunds = catalogAsync.value!.map((f) {
        return {
          'scheme_code': f.schemeCode,
          'name': f.schemeName,
          'category': f.category,
          'returns': {
            '1Y': '${(f.returns1y ?? 18.0).toStringAsFixed(1)}%',
            '3Y': '${(f.returns3y ?? 21.0).toStringAsFixed(1)}%',
            '5Y': '${(f.returns5y ?? 16.0).toStringAsFixed(1)}%',
          },
        };
      }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: displayFunds.length,
        itemBuilder: (context, index) {
          final f = displayFunds[index];
          final schemeCode = f['scheme_code']?.toString() ?? '1';
          final returnsMap = f['returns'] as Map<String, dynamic>? ?? {};
          final returnVal = returnsMap[_returnPeriod] ?? '20.0%';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () => MfFundProfileScreen.showModal(context, schemeCode),
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f['name']?.toString() ?? 'Fund Name',
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            f['category']?.toString() ?? 'Equity',
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          returnVal,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_returnPeriod CAGR',
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
