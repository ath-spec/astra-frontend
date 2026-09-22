import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../data/catalog_providers.dart';
import '../../data/catalog_models.dart';
import '../fund_profile/mf_fund_profile_screen.dart';

class MfInvitsCollectionScreen extends ConsumerStatefulWidget {
  const MfInvitsCollectionScreen({super.key});

  @override
  ConsumerState<MfInvitsCollectionScreen> createState() => _MfInvitsCollectionScreenState();
}

class _MfInvitsCollectionScreenState extends ConsumerState<MfInvitsCollectionScreen> {
  static const _category = 'Other - InvIT';

  String _activeFilter = 'All';
  final _filters = ['All', 'Power', 'Roads'];
  String _returnPeriod = '1Y';

  List<CatalogFund> _filteredFunds(List<CatalogFund> allFunds) {
    if (_activeFilter == 'All') return allFunds;
    return allFunds.where((f) {
      final text = '${f.category} ${f.schemeName}'.toLowerCase();
      switch (_activeFilter) {
        case 'Power':
          return text.contains('power') || text.contains('grid') || text.contains('energy');
        case 'Roads':
          return text.contains('road') || text.contains('highway') || text.contains('infra');
        default:
          return true;
      }
    }).toList();
  }

  String _returnFor(CatalogFund f) {
    final value = switch (_returnPeriod) {
      '3Y' => f.returns3y,
      '5Y' => f.returns5y,
      _ => f.returns1y,
    };
    return value != null ? '${value.toStringAsFixed(2)}%' : '—';
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogFundsByCategoryProvider(_category));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(4),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1E1E1E)),
              ),
            ),
          ),
        ),
        title: const Text(
          'INVITs Collection',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_returnPeriod == '1Y') {
                    _returnPeriod = '3Y';
                  } else if (_returnPeriod == '3Y') {
                    _returnPeriod = '5Y';
                  } else {
                    _returnPeriod = '1Y';
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_returnPeriod Returns',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isActive = _activeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeFilter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Divider
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          Expanded(
            child: catalogAsync.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        AppThemeShimmerCard(height: 140),
                        SizedBox(height: 12),
                        AppThemeShimmerCard(height: 140),
                        SizedBox(height: 12),
                        AppThemeShimmerCard(height: 140),
                      ],
                    ),
                  )
                : catalogAsync.hasError
                    ? const Center(
                        child: Text(
                          "Couldn't load InVITs.",
                          style: TextStyle(fontFamily: 'DMSans', color: Color(0xFF64748B)),
                        ),
                      )
                    : _buildFundsList(_filteredFunds(catalogAsync.valueOrNull ?? [])),
          ),
        ],
      ),
    );
  }

  Widget _buildFundsList(List<CatalogFund> funds) {
    if (funds.isEmpty) {
      return const Center(
        child: Text(
          'No InVITs available yet.',
          style: TextStyle(fontFamily: 'DMSans', color: Color(0xFF64748B)),
        ),
      );
    }
    return Column(
      children: [
        // Fund count hint
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            children: [
              Text(
                '${funds.length} trusts',
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: funds.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF8F9FA)),
            itemBuilder: (context, index) {
              final fund = funds[index];
              return _buildFundRow(fund);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFundRow(CatalogFund fund) {
    return Column(
      children: [
        InkWell(
          onTap: () => MfFundProfileScreen.showModal(context, fund.schemeCode),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                // Logo
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Center(
                        child: Text(
                          fund.schemeName.isNotEmpty ? fund.schemeName.substring(0, 1) : '?',
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars, color: Colors.deepOrange, size: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fund.schemeName,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          color: Color(0xFF1E1E1E),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fund.category,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Returns
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _returnFor(fund),
                    key: ValueKey<String>('${fund.schemeCode}_$_returnPeriod'),
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00C75A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 1,
          color: const Color(0xFFF8F9FA),
        ),
      ],
    );
  }
}
