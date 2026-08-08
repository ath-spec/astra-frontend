import 'package:flutter/material.dart';
import '../fund_profile/mf_fund_profile_screen.dart';

class MfInvitsCollectionScreen extends StatefulWidget {
  const MfInvitsCollectionScreen({super.key});

  @override
  State<MfInvitsCollectionScreen> createState() => _MfInvitsCollectionScreenState();
}

class _MfInvitsCollectionScreenState extends State<MfInvitsCollectionScreen> {
  String _activeFilter = 'All';

  final _filters = ['All', 'Power', 'Roads'];

  final List<Map<String, dynamic>> _allFunds = [
    {
      'name': 'PowerGrid InvIT',
      'category': 'Infrastructure • Power',
      'cap': 'Power',
      'returns': {'1Y': '12.40%', '3Y': '10.80%', '5Y': '9.50%'},
      'rating': 5,
    },
    {
      'name': 'IRB InvIT Fund',
      'category': 'Infrastructure • Roads',
      'cap': 'Roads',
      'returns': {'1Y': '14.10%', '3Y': '11.40%', '5Y': '10.10%'},
      'rating': 4,
    },
    {
      'name': 'India Grid Trust',
      'category': 'Infrastructure • Power',
      'cap': 'Power',
      'returns': {'1Y': '11.60%', '3Y': '9.80%', '5Y': '8.20%'},
      'rating': 4,
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
                  } else if (_returnPeriod == '3Y') _returnPeriod = '5Y';
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
