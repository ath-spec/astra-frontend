import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecurringPaymentsCard extends StatelessWidget {
  final double totalUpcoming;
  final String currentMonth;
  final List<Map<String, dynamic>> bills;

  const RecurringPaymentsCard({
    super.key,
    this.totalUpcoming = 2100.0,
    this.currentMonth = 'October',
    this.bills = const [
      {
        'title': 'Jio Fiber',
        'subtitle': 'Broadband',
        'amount': 1000.0,
        'date': 'Oct 23',
        'icon': Icons.wifi,
      },
      {
        'title': 'Netflix',
        'subtitle': 'Entertainment',
        'amount': 650.0,
        'date': 'Oct 25',
        'icon': Icons.movie,
      },
      {
        'title': 'Spotify',
        'subtitle': 'Music',
        'amount': 120.0,
        'date': 'Oct 28',
        'icon': Icons.music_note,
      },
      {
        'title': 'Gym Membership',
        'subtitle': 'Health',
        'amount': 330.0,
        'date': 'Oct 30',
        'icon': Icons.fitness_center,
      }
    ],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/recurring-intro');
      },
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recurring',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.more_horiz,
                color: Colors.white.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹\${totalUpcoming.toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Upcoming in $currentMonth',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...bills.map((bill) => _buildBillItem(bill)),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'View all',
                style: TextStyle(
                  color: Colors.blue.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildBillItem(Map<String, dynamic> bill) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              bill['icon'] as IconData,
              color: Colors.white.withOpacity(0.7),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill['title'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bill['subtitle'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹\${(bill['amount'] as double).toInt()}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bill['date'] as String,
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
