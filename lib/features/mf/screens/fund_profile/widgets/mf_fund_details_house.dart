import 'package:flutter/material.dart';

class MfFundDetailsHouse extends StatefulWidget {
  final String? amcName;
  final double? aum;
  final String? fundManager;

  const MfFundDetailsHouse({
    super.key,
    this.amcName,
    this.aum,
    this.fundManager,
  });

  @override
  State<MfFundDetailsHouse> createState() => _MfFundDetailsHouseState();
}

class _MfFundDetailsHouseState extends State<MfFundDetailsHouse> {
  bool _isMainExpanded = false;
  bool _isCardExpanded = false;

  @override
  Widget build(BuildContext context) {
    final amc = widget.amcName ?? 'Asset Management Company';
    final aumStr = widget.aum != null ? '₹ ${(widget.aum! / 1000).toStringAsFixed(1)}K Cr' : '₹ 1,36,788 Cr';
    final manager = widget.fundManager ?? 'Senior Fund Manager';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isMainExpanded = !_isMainExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fund details & fund house',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Icon(
                    _isMainExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
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
                    _buildStatRow('Fund Manager', manager),
                    const Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
                    _buildFundHouseSection(amc, aumStr),
                  ],
                ),
              ),
            ),
            crossFadeState: _isMainExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          const Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundHouseSection(String amc, String aumStr) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                amc,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _isCardExpanded = !_isCardExpanded;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      _isCardExpanded ? 'Show less' : 'Show more',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Icon(
                      _isCardExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 16,
                      color: const Color(0xFF0F172A),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Total AUM: $aumStr',
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
