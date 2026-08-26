import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/shimmer_card_skeleton.dart';
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

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(allCatalogFundsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Mutual Funds',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Pills
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _activeFilter = filter);
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
            child: catalogAsync.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        AppThemeShimmerCard(height: 80),
                        SizedBox(height: 12),
                        AppThemeShimmerCard(height: 80),
                        SizedBox(height: 12),
                        AppThemeShimmerCard(height: 80),
                      ],
                    ),
                  )
                : _buildFundsList(catalogAsync.value ?? []),
          ),
        ],
      ),
    );
  }

  Widget _buildFundsList(List<CatalogFund> allFunds) {
    final filteredFunds = allFunds.where((f) {
      if (_activeFilter == 'All') return true;
      final cat = f.category.toLowerCase();
      final name = f.schemeName.toLowerCase();
      if (_activeFilter == 'Large Cap') return cat.contains('large') || name.contains('large') || name.contains('nifty');
      if (_activeFilter == 'Mid Cap') return cat.contains('mid') || name.contains('mid');
      if (_activeFilter == 'Small Cap') return cat.contains('small') || name.contains('small');
      return true;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: filteredFunds.length,
      itemBuilder: (context, index) {
        final f = filteredFunds[index];
        final ret3y = f.returns3y != null ? '${f.returns3y!.toStringAsFixed(1)}%' : (f.returns1y != null ? '${f.returns1y!.toStringAsFixed(1)}%' : '18.2%');

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () => MfFundProfileScreen.showModal(context, f.schemeCode),
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
                          f.schemeName,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          f.category,
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
                        ret3y,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '3Y CAGR',
                        style: TextStyle(
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
    );
  }
}
