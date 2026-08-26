import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/catalog_providers.dart';
import '../../data/catalog_models.dart';
import '../fund_profile/mf_fund_profile_screen.dart';

class MfMutualFundsCollectionScreen extends ConsumerStatefulWidget {
  const MfMutualFundsCollectionScreen({super.key});

  @override
  ConsumerState<MfMutualFundsCollectionScreen> createState() => _MfMutualFundsCollectionScreenState();
}

class _MfMutualFundsCollectionScreenState extends ConsumerState<MfMutualFundsCollectionScreen> {
  String _activeFilter = 'All';
  final _filters = ['All', 'Large Cap', 'Mid Cap', 'Small Cap'];

  final List<Map<String, dynamic>> _mockFunds = [
    {
      'scheme_code': 'INF846K01EW2',
      'name': 'Mirae Asset Large Cap Fund',
      'category': 'Equity • Large Cap',
      'cap': 'Large Cap',
      'returns': {'1Y': '28.40%', '3Y': '16.80%', '5Y': '14.50%'},
      'rating': 5,
    },
    {
      'scheme_code': 'INF209K01157',
      'name': 'HDFC Top 100 Fund',
      'category': 'Equity • Large Cap',
      'cap': 'Large Cap',
      'returns': {'1Y': '26.10%', '3Y': '15.90%', '5Y': '13.80%'},
      'rating': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(allCatalogFundsProvider);

    List<Map<String, dynamic>> fundsList = _mockFunds;
    if (catalogAsync.hasValue && catalogAsync.value != null && catalogAsync.value!.isNotEmpty) {
      fundsList = catalogAsync.value!.map((f) {
        String cap = 'Large Cap';
        if (f.category.toLowerCase().contains('mid')) cap = 'Mid Cap';
        if (f.category.toLowerCase().contains('small')) cap = 'Small Cap';

        return {
          'scheme_code': f.schemeCode,
          'name': f.schemeName,
          'category': f.category,
          'cap': cap,
          'returns': {
            '1Y': '${(f.returns1y ?? 18.0).toStringAsFixed(1)}%',
            '3Y': '${(f.returns3y ?? 21.0).toStringAsFixed(1)}%',
            '5Y': '${(f.returns5y ?? 16.0).toStringAsFixed(1)}%',
          },
          'rating': 5,
        };
      }).toList();
    }

    final filteredFunds = _activeFilter == 'All'
        ? fundsList
        : fundsList.where((f) => f['cap'] == _activeFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Mutual Funds', style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final f = _filters[index];
                final isSelected = _activeFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _activeFilter = f);
                    },
                    selectedColor: const Color(0xFF0F172A),
                    labelStyle: TextStyle(
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredFunds.length,
              itemBuilder: (context, index) {
                final fund = filteredFunds[index];
                final schemeCode = fund['scheme_code']?.toString() ?? '1';
                final returns = fund['returns'] as Map<String, dynamic>? ?? {};

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () => MfFundProfileScreen.showModal(context, schemeCode),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fund['name']?.toString() ?? '',
                                  style: const TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  fund['category']?.toString() ?? '',
                                  style: const TextStyle(fontFamily: 'DMSans', fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                returns['3Y']?.toString() ?? '20.0%',
                                style: const TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                              ),
                              const SizedBox(height: 2),
                              const Text('3Y CAGR', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
