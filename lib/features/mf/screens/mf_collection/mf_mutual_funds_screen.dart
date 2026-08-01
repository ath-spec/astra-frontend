import 'package:flutter/material.dart';
import '../fund_profile/mf_fund_profile_screen.dart';

class MfMutualFundsScreen extends StatefulWidget {
  const MfMutualFundsScreen({super.key});

  @override
  State<MfMutualFundsScreen> createState() => _MfMutualFundsScreenState();
}

class _MfMutualFundsScreenState extends State<MfMutualFundsScreen> {
  String _activeFilter = 'All';

  final _filters = ['All', 'Large Cap', 'Mid Cap', 'Small Cap'];

  final List<Map<String, dynamic>> _allFunds = [
    // Large Cap
    {
      'name': 'Mirae Asset Large Cap Fund',
      'category': 'Equity • Large Cap',
      'cap': 'Large Cap',
      'returns': {'1Y': '28.40%', '3Y': '16.80%', '5Y': '14.50%'},
      'rating': 5,
    },
    {
      'name': 'HDFC Top 100 Fund',
      'category': 'Equity • Large Cap',
      'cap': 'Large Cap',
      'returns': {'1Y': '26.10%', '3Y': '15.90%', '5Y': '13.80%'},
      'rating': 4,
    },
    {
      'name': 'ICICI Pru Bluechip Fund',
      'category': 'Equity • Large Cap',
      'cap': 'Large Cap',
      'returns': {'1Y': '25.60%', '3Y': '15.20%', '5Y': '13.20%'},
      'rating': 5,
    },
    {
      'name': 'SBI Bluechip Fund',
      'category': 'Equity • Large Cap',
      'cap': 'Large Cap',
      'returns': {'1Y': '23.80%', '3Y': '14.70%', '5Y': '12.90%'},
      'rating': 4,
    },
    {
      'name': 'Axis Bluechip Fund',
      'category': 'Equity • Large Cap',
      'cap': 'Large Cap',
      'returns': {'1Y': '21.40%', '3Y': '13.50%', '5Y': '11.80%'},
      'rating': 3,
    },
    // Mid Cap
    {
      'name': 'Quant Mid Cap Fund',
      'category': 'Equity • Mid Cap',
      'cap': 'Mid Cap',
      'returns': {'1Y': '52.10%', '3Y': '32.40%', '5Y': '24.50%'},
      'rating': 5,
    },
    {
      'name': 'Nippon India Growth Fund',
      'category': 'Equity • Mid Cap',
      'cap': 'Mid Cap',
      'returns': {'1Y': '46.80%', '3Y': '28.60%', '5Y': '21.20%'},
      'rating': 4,
    },
    {
      'name': 'HDFC Mid-Cap Opportunities',
      'category': 'Equity • Mid Cap',
      'cap': 'Mid Cap',
      'returns': {'1Y': '43.20%', '3Y': '26.90%', '5Y': '20.10%'},
      'rating': 5,
    },
    {
      'name': 'Motilal Oswal Midcap Fund',
      'category': 'Equity • Mid Cap',
      'cap': 'Mid Cap',
      'returns': {'1Y': '41.50%', '3Y': '25.30%', '5Y': '19.40%'},
      'rating': 4,
    },
    {
      'name': 'Edelweiss Mid Cap Fund',
      'category': 'Equity • Mid Cap',
      'cap': 'Mid Cap',
      'returns': {'1Y': '38.90%', '3Y': '23.80%', '5Y': '18.60%'},
      'rating': 3,
    },
    // Small Cap
    {
      'name': 'Quant Small Cap Fund',
      'category': 'Equity • Small Cap',
      'cap': 'Small Cap',
      'returns': {'1Y': '65.20%', '3Y': '42.10%', '5Y': '32.80%'},
      'rating': 5,
    },
    {
      'name': 'Nippon India Small Cap Fund',
      'category': 'Equity • Small Cap',
      'cap': 'Small Cap',
      'returns': {'1Y': '58.40%', '3Y': '38.60%', '5Y': '29.50%'},
      'rating': 5,
    },
    {
      'name': 'SBI Small Cap Fund',
      'category': 'Equity • Small Cap',
      'cap': 'Small Cap',
      'returns': {'1Y': '52.80%', '3Y': '34.20%', '5Y': '26.80%'},
      'rating': 4,
    },
    {
      'name': 'Axis Small Cap Fund',
      'category': 'Equity • Small Cap',
      'cap': 'Small Cap',
      'returns': {'1Y': '46.10%', '3Y': '29.80%', '5Y': '23.40%'},
      'rating': 4,
    },
    {
      'name': 'DSP Small Cap Fund',
      'category': 'Equity • Small Cap',
      'cap': 'Small Cap',
      'returns': {'1Y': '42.30%', '3Y': '27.50%', '5Y': '21.90%'},
      'rating': 3,
    },
  ];

  String _returnPeriod = '3Y';

  List<Map<String, dynamic>> get _filteredFunds {
    if (_activeFilter == 'All') return _allFunds;
    return _allFunds.where((f) => f['cap'] == _activeFilter).toList();
  }

  Color _capColor(String cap) {
    switch (cap) {
      case 'Large Cap': return const Color(0xFF3B82F6);
      case 'Mid Cap': return const Color(0xFF8B5CF6);
      case 'Small Cap': return const Color(0xFF10B981);
      default: return const Color(0xFF64748B);
    }
  }

  Color _capBgColor(String cap) {
    switch (cap) {
      case 'Large Cap': return const Color(0xFFEFF6FF);
      case 'Mid Cap': return const Color(0xFFF5F3FF);
      case 'Small Cap': return const Color(0xFFECFDF5);
      default: return const Color(0xFFF1F5F9);
    }
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
          'Mutual Funds',
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
          // Divider
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          // Fund count hint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              children: [
                Text(
                  '${funds.length} funds',
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
                // Logo — same style as MfCollectionScreen
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


