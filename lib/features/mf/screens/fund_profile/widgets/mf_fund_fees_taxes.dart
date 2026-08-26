import 'package:flutter/material.dart';
import 'mf_fees_taxes_bottom_sheet.dart';

class MfFundFeesTaxes extends StatefulWidget {
  final double? expenseRatio;
  final String? exitLoad;

  const MfFundFeesTaxes({
    super.key,
    this.expenseRatio,
    this.exitLoad,
  });

  @override
  State<MfFundFeesTaxes> createState() => _MfFundFeesTaxesState();
}

class _MfFundFeesTaxesState extends State<MfFundFeesTaxes> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final expRatioStr = widget.expenseRatio != null
        ? '${widget.expenseRatio!.toStringAsFixed(2)}%'
        : '0.65%';
    final exitLoadStr = widget.exitLoad ?? '1% if redeemed within 365 days; Nil thereafter';

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
                        'Fees & Taxes on investment',
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
                            'Expense ratio, exit load',
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
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildStatRow('Expense ratio', expRatioStr),
                    const Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
                    _buildStatRow('Exit load', exitLoadStr, isMultiline: true),
                    const Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
                    _buildStatRow('Stamp duty', '0.005% (from July 1st 2020)'),
                    const Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
                    _buildTaxImplicationRow(context),
                  ],
                ),
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          const Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxImplicationRow(BuildContext context) {
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const MfFeesTaxesBottomSheet(),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tax implication',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
            Row(
              children: [
                Text(
                  'Know more',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 14, color: Color(0xFF0F172A)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
