import 'package:flutter/material.dart';
import '../fund_profile/mf_fund_profile_screen.dart';

class MfStocksCollectionScreen extends StatefulWidget {
  const MfStocksCollectionScreen({super.key});

  @override
  State<MfStocksCollectionScreen> createState() => _MfStocksCollectionScreenState();
}

class _MfStocksCollectionScreenState extends State<MfStocksCollectionScreen> {
  String _activeFilter = 'All';

  final _filters = ['All', 'Large Cap', 'Mid Cap', 'Small Cap'];

  final List<Map<String, dynamic>> _allFunds = [
    // Large Cap
    {
      'name': 'Reliance Industries',
      'category': 'Equity • Large Cap',
      'cap': 'Large Cap',
      'returns': {'1Y': '22.40%', '3Y': '18.80%', '5Y': '16.50%'},
      'rating': 5,
    },
    {
      'name': 'TCS',
      'category': 'Equity • Large Cap',
      'cap': 'Large Cap',
      'returns': {'1Y': '15.10%', '3Y': '12.90%', '5Y': '14.80%'},
      'rating': 4,
    },
    {
      'name': 'HDFC Bank',
      'category': 'Equity • Large Cap',
      'cap': 'Large Cap',
      'returns': {'1Y': '12.60%', '3Y': '11.20%', '5Y': '15.20%'},
      'rating': 5,
    },
    // Mid Cap
    {
      'name': 'Trent Ltd',
      'category': 'Equity • Mid Cap',
      'cap': 'Mid Cap',
      'returns': {'1Y': '62.10%', '3Y': '45.40%', '5Y': '38.50%'},
      'rating': 5,
    },
    {
      'name': 'TVS Motor',
      'category': 'Equity • Mid Cap',
      'cap': 'Mid Cap',
      'returns': {'1Y': '46.80%', '3Y': '38.60%', '5Y': '25.20%'},
      'rating': 4,
    },
    // Small Cap
    {
      'name': 'Suzlon Energy',
      'category': 'Equity • Small Cap',
      'cap': 'Small Cap',
      'returns': {'1Y': '165.20%', '3Y': '82.10%', '5Y': '42.80%'},
      'rating': 5,
    },
    {
      'name': 'BSE Ltd',
      'category': 'Equity • Small Cap',
      'cap': 'Small Cap',
      'returns': {'1Y': '158.40%', '3Y': '68.60%', '5Y': '49.50%'},
      'rating': 5,
    },
  ];

  String _returnPeriod = '1Y';

  List<Map<String, dynamic>> get _filteredFunds {
    if (_activeFilter == 'All') return _allFunds;
    return _allFunds.where((f) => f['cap'] == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final funds = _filteredFunds;

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
          'Stocks Collection',
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
                  if (_returnPeriod == '1Y') _returnPeriod = '3Y';
                  else if (_returnPeriod == '3Y') _returnPeriod = '5Y';
                  else _returnPeriod = '1Y';
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
          // Fund count hint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              children: [
                Text(
                  '${funds.length} stocks',
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
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF8F9FA)),
              itemBuilder: (context, index) {
                final fund = funds[index];
                return _buildFundRow(fund);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundRow(Map<String, dynamic> fund) {
    return Column(
      children: [
        InkWell(
          onTap: () => MfFundProfileScreen.showModal(context, fund['name'] as String),
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
                          (fund['name'] as String).substring(0, 1),
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
                        fund['name'] as String,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1E1E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fund['category'] as String,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                // Returns
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    (fund['returns'] as Map<String, dynamic>)[_returnPeriod] as String,
                    key: ValueKey<String>('${fund['name']}_$_returnPeriod'),
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
