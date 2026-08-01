import 'package:flutter/material.dart';
import '../../fund_profile/mf_fund_profile_screen.dart';

class MfBondsList extends StatefulWidget {
  const MfBondsList({super.key});

  @override
  State<MfBondsList> createState() => _MfBondsListState();
}

class _MfBondsListState extends State<MfBondsList> {
  String _selectedFilter = 'All';

  final List<Map<String, String>> _allBonds = [
    {'name': 'Adani Airport', 'rating': 'IND AA-', 'rate': '8.5%', 'tenure': '30 Months'},
    {'name': 'Akme Fintrade', 'rating': 'A- (Low Credit Rating)', 'rate': '12.0%', 'tenure': '31 Months'},
    {'name': 'Monedo Oct\' 27', 'rating': 'IND BBB-', 'rate': '13.5%', 'tenure': '14 Months'},
    {'name': 'DAR Credit', 'rating': 'CARE BBB-', 'rate': '13.5%', 'tenure': '28 Months'},
    {'name': 'Capri Global', 'rating': 'ACUITE AA+', 'rate': '9.0%', 'tenure': '26 Months'},
    {'name': 'Navi Finserv Ltd', 'rating': 'CRISIL A', 'rate': '10.85%', 'tenure': '22 Months'},
  ];

  List<Map<String, String>> get _filteredBonds {
    if (_selectedFilter == 'High returns') {
      return _allBonds.where((b) {
        final rate = double.tryParse(b['rate']!.replaceAll('%', '')) ?? 0.0;
        return rate > 10.0;
      }).toList();
    } else if (_selectedFilter == '✨ High ratings') {
      return _allBonds.where((b) {
        return b['rating']!.contains('AA') || b['rating']!.contains('AAA');
      }).toList();
    }
    return _allBonds;
  }

  @override
  Widget build(BuildContext context) {
    final bonds = _filteredBonds;
    List<Widget> bondRows = [];
    for (int i = 0; i < bonds.length; i += 2) {
      bondRows.add(
        Row(
          children: [
            Expanded(
              child: _buildBondCard(
                name: bonds[i]['name']!,
                rating: bonds[i]['rating']!,
                rate: bonds[i]['rate']!,
                tenure: bonds[i]['tenure']!,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: i + 1 < bonds.length
                  ? _buildBondCard(
                      name: bonds[i + 1]['name']!,
                      rating: bonds[i + 1]['rating']!,
                      rate: bonds[i + 1]['rate']!,
                      tenure: bonds[i + 1]['tenure']!,
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      );
      if (i + 2 < bonds.length) {
        bondRows.add(const SizedBox(height: 12));
      }
    }

    return Container(
      color: const Color(0xFFF8F9FA), // match background
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore top rated bonds on ET Money',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', isSelected: _selectedFilter == 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('High returns', isSelected: _selectedFilter == 'High returns'),
                const SizedBox(width: 8),
                _buildFilterChip('✨ High ratings', isSelected: _selectedFilter == '✨ High ratings'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...bondRows,
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED), // Very light orange background
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.error_outline, color: Color(0xFFF97316), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bonds rated A- & lower carry risks and should have limited allocation in your portfolio.',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      color: Color(0xFFC2410C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF00C75A) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? const Color(0xFF1E1E1E) : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildBondCard({
    required String name,
    required String rating,
    required String rate,
    required String tenure,
  }) {
    return InkWell(
      onTap: () => MfFundProfileScreen.showModal(context, name),
      borderRadius: BorderRadius.circular(4.0),
      child: Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E1E1E),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                rating,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  color: Color(0xFF475569),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rate,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00C75A), // Green
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tenure,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF00C75A),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

