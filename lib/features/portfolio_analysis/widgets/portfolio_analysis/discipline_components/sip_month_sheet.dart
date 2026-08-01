import 'package:flutter/material.dart';

class SipMonthSheet extends StatefulWidget {
  final String initialMonth;

  const SipMonthSheet({super.key, required this.initialMonth});

  @override
  State<SipMonthSheet> createState() => _SipMonthSheetState();
}

class _SipMonthSheetState extends State<SipMonthSheet> {
  static const List<String> _months = [
    'SEP', 'OCT', 'NOV', 'DEC', 'JAN', 'FEB', 
    'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG'
  ];
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = _months.indexOf(widget.initialMonth);
    if (_currentIndex == -1) _currentIndex = 11; // fallback to AUG
  }

  void _previousMonth() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _nextMonth() {
    if (_currentIndex < _months.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final month = _months[_currentIndex];
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == _months.length - 1;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // 75% height
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SIP IN ${month == 'AUG' ? 'AUGUST' : month}', 
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: isFirst ? null : _previousMonth,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.chevron_left, 
                            size: 14, 
                            color: isFirst ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${month[0].toUpperCase()}${month.substring(1).toLowerCase()} \'2026',
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: isLast ? null : _nextMonth,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.chevron_right, 
                            size: 14, 
                            color: isLast ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // SIPs Paid Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                  ),
                  child: const Icon(Icons.check, size: 14, color: Color(0xFFCBD5E1)),
                ),
                const SizedBox(width: 12),
                const Text(
                  '0',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'SIPs paid',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Speech Bubble Tip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Streak will close once the current month ends',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                Positioned(
                  top: -4,
                  left: 16,
                  child: Transform.rotate(
                    angle: 3.14159 / 4,
                    child: Container(
                      width: 10,
                      height: 10,
                      color: const Color(0xFFF1F5F9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 1),
          const SizedBox(height: 16),
          
          // Total amount paid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'TOTAL AMOUNT PAID:',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  '₹0',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 1),
          
          // Empty State
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Custom Document / Magnifying glass icon
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Base document shape (rotated)
                          Transform.rotate(
                            angle: -0.2,
                            child: Container(
                              width: 48,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF0F172A),
                                    offset: Offset(-2, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  Container(margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), height: 4, width: 24, color: const Color(0xFFE2E8F0)),
                                  Container(margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), height: 4, width: 16, color: const Color(0xFFE2E8F0)),
                                ],
                              ),
                            ),
                          ),
                          // Magnifying glass with X
                          Positioned(
                            right: 4,
                            bottom: 8,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Handle
                                Positioned(
                                  left: -8,
                                  bottom: -8,
                                  child: Transform.rotate(
                                    angle: 0.78, // 45 deg
                                    child: Container(width: 8, height: 20, color: Colors.white, child: Container(decoration: BoxDecoration(border: Border.all(color: const Color(0xFF0F172A), width: 1.5)))),
                                  ),
                                ),
                                // Lens
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF0F172A),
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE53E3E), // Red cross background
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'No transactions found',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'we couldn\'t find any transactions related to your filters. try tweaking your filters to get better results.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 48), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
