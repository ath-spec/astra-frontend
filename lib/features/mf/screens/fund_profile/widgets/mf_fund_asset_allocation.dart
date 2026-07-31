import 'package:flutter/material.dart';
import '../../../../../core/models/fund_asset_allocation_data.dart';
import 'mf_asset_allocation_bottom_sheet.dart';

class MfFundAssetAllocation extends StatefulWidget {
  final AssetAllocationData? data;
  const MfFundAssetAllocation({super.key, this.data});

  @override
  State<MfFundAssetAllocation> createState() => _MfFundAssetAllocationState();
}

class _MfFundAssetAllocationState extends State<MfFundAssetAllocation> {
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
                        'Asset Allocation',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (!_isExpanded)
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Equity, Debt distribution',
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
                const Text(
                  'as of 30th Jul \'26',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendRow(const Color(0xFF3B82F6), 'Equity', '98.29%'),
                        const SizedBox(height: 16),
                        _buildLegendRow(const Color(0xFFE11D48), 'Other', '1.71%'),
                      ],
                    ),
                    // Donut Chart
                    Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      width: 80,
                      height: 80,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Center(
                            child: SizedBox(
                              width: 72,
                              height: 72,
                              child: CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 14,
                                color: const Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                          Center(
                            child: SizedBox(
                              width: 72,
                              height: 72,
                              child: CircularProgressIndicator(
                                value: 0.0171,
                                strokeWidth: 14,
                                color: const Color(0xFFE11D48),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
                const SizedBox(height: 24),
                const Text(
                  'Market Cap Allocation',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                // Segmented Bar Chart
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Row(
                      children: [
                        Expanded(flex: 4516, child: Container(color: const Color(0xFF3B82F6))),
                        Expanded(flex: 1740, child: Container(color: const Color(0xFF8B5CF6))),
                        Expanded(flex: 3573, child: Container(color: const Color(0xFFE11D48))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLegendRow(const Color(0xFF3B82F6), 'Large Cap', '45.16%'),
                const SizedBox(height: 24),
                _buildLegendRow(const Color(0xFF8B5CF6), 'Mid Cap', '17.40%'),
                const SizedBox(height: 24),
                _buildLegendRow(const Color(0xFFE11D48), 'Small Cap', '35.73%'),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () {
                    if (widget.data != null) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => MfAssetAllocationBottomSheet(data: widget.data!),
                      );
                    }
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

  Widget _buildLegendRow(Color color, String label, String value) {
    return SizedBox(
      width: 150, // Fixed width for alignment with chart
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
