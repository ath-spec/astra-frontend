import 'package:flutter/material.dart';

class MfBondsList extends StatelessWidget {
  const MfBondsList({super.key});

  @override
  Widget build(BuildContext context) {
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
                _buildFilterChip('All', isSelected: true),
                const SizedBox(width: 8),
                _buildFilterChip('High returns'),
                const SizedBox(width: 8),
                _buildFilterChip('✨ High ratings'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildBondCard(
                  name: 'Adani Airport',
                  rating: 'IND AA-',
                  rate: '8.5%',
                  tenure: '30 Months',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBondCard(
                  name: 'Akme Fintrade',
                  rating: 'A- (Low Credit Rating)',
                  rate: '12.0%',
                  tenure: '31 Months',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildBondCard(
                  name: 'Monedo Oct\' 27',
                  rating: 'IND BBB-',
                  rate: '13.5%',
                  tenure: '14 Months',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBondCard(
                  name: 'DAR Credit',
                  rating: 'CARE BBB-',
                  rate: '13.5%',
                  tenure: '28 Months',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildBondCard(
                  name: 'Capri Global',
                  rating: 'ACUITE AA+',
                  rate: '9.0%',
                  tenure: '26 Months',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBondCard(
                  name: 'Navi Finserv Ltd',
                  rating: 'CRISIL A',
                  rate: '10.85%',
                  tenure: '22 Months',
                ),
              ),
            ],
          ),
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
    return Container(
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
    );
  }

  Widget _buildBondCard({
    required String name,
    required String rating,
    required String rate,
    required String tenure,
  }) {
    return Container(
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
    );
  }
}
