import 'package:flutter/material.dart';

class MfFundDetailsHouse extends StatefulWidget {
  const MfFundDetailsHouse({super.key});

  @override
  State<MfFundDetailsHouse> createState() => _MfFundDetailsHouseState();
}

class _MfFundDetailsHouseState extends State<MfFundDetailsHouse> {
  bool _isMainExpanded = false;
  bool _isCardExpanded = false;

  @override
  Widget build(BuildContext context) {
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
                // Fund House Card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'HSBC Mutual Fund',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Fund house • Since 13 years 6 months',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'HSBC',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatRow('Rank (total assets)', '17 in India'),
                      _buildDivider(),
                      _buildStatRow('Total AUM', '₹1,36,788 Cr'),
                      
                      AnimatedCrossFade(
                        firstChild: const SizedBox(width: double.infinity, height: 0),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDivider(),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Address:',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 10,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '16, V N Road, Fort, Mumbai 400 001',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 10,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Phone:',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 10,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '022-66145000',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 10,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        crossFadeState: _isCardExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isCardExpanded = !_isCardExpanded;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isCardExpanded ? 'Show less' : 'Show more',
                                  style: const TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _isCardExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  size: 14,
                                  color: const Color(0xFF0F172A),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Investment Objective
                const Text(
                  'Investment Objective',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'To generate long-term capital appreciation from diversified portfolio of predominantly equity and equity related securities, in the Indian markets with higher focus on undervalued securities. The Scheme could also additionally invest in Foreign Securities in international markets.There is no assurance that the investment objective of the scheme will be realized.',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                
                // List Tiles
                _buildListTile(Icons.description_outlined, 'Scheme Document'),
                const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
                _buildListTile(Icons.person_outline, 'Fund managers'),
                
                const SizedBox(height: 16),
              ],
            ),
            crossFadeState: _isMainExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              color: Color(0xFF64748B),
            ),
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

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1), // subtly dashed look originally, solid for now
    );
  }

  Widget _buildListTile(IconData icon, String title) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF0F172A)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF0F172A)),
          ],
        ),
      ),
    );
  }
}
