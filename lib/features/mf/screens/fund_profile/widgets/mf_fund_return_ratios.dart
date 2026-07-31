import 'package:flutter/material.dart';
import 'mf_return_ratios_bottom_sheet.dart';

class MfFundReturnRatios extends StatefulWidget {
  const MfFundReturnRatios({super.key});

  @override
  State<MfFundReturnRatios> createState() => _MfFundReturnRatiosState();
}

class _MfFundReturnRatiosState extends State<MfFundReturnRatios> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Return & risk ratios',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (!_isExpanded)
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Alpha, Sharpe, Beta',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF0F172A),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Table Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Ratios',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Fund',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Cat. Avg',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildRatioRow('Alpha', '6.76', true, '2.34'),
                const SizedBox(height: 24),
                _buildRatioRow('Beta', '1.03', false, '0.98'),
                const SizedBox(height: 24),
                _buildRatioRow('Sharpe', '0.83', true, '0.54'),
                const SizedBox(height: 24),
                _buildRatioRow('Standard Deviation', '16.48', false, '15.84'),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const MfReturnRatiosBottomSheet(),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Know more',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 14, color: Color(0xFF0F172A)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildRatioRow(String title, String fundVal, bool isPositive, String avgVal) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            fundVal,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isPositive ? const Color(0xFF00C75A) : const Color(0xFFEF4444), // Green or Red
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            avgVal,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
