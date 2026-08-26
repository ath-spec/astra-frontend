import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/catalog_providers.dart';
import '../../data/catalog_models.dart';
import '../fund_profile/mf_fund_profile_screen.dart';

class MfEtfsCollectionScreen extends ConsumerStatefulWidget {
  const MfEtfsCollectionScreen({super.key});

  @override
  ConsumerState<MfEtfsCollectionScreen> createState() => _MfEtfsCollectionScreenState();
}

class _MfEtfsCollectionScreenState extends ConsumerState<MfEtfsCollectionScreen> {
  String _activeFilter = 'All';
  final _filters = ['All', 'Equity', 'Debt', 'Gold'];

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(allCatalogFundsProvider);

    List<CatalogFund> funds = [];
    if (catalogAsync.hasValue && catalogAsync.value != null) {
      funds = catalogAsync.value!.where((f) {
        if (_activeFilter == 'All') return true;
        return f.category.toLowerCase().contains(_activeFilter.toLowerCase());
      }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('ETFs & Index Funds', style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600)),
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
              itemCount: funds.length,
              itemBuilder: (context, index) {
                final fund = funds[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () => MfFundProfileScreen.showModal(context, fund.schemeCode),
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
                                  fund.schemeName,
                                  style: const TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  fund.category,
                                  style: const TextStyle(fontFamily: 'DMSans', fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${(fund.returns3y ?? 16.5).toStringAsFixed(1)}%',
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
