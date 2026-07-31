import 'package:flutter/material.dart';

class MfFdSpecificNeeds extends StatefulWidget {
  const MfFdSpecificNeeds({super.key});

  @override
  State<MfFdSpecificNeeds> createState() => _MfFdSpecificNeedsState();
}

class _MfFdSpecificNeedsState extends State<MfFdSpecificNeeds> {
  int _expandedIndex = 0; // First item expanded by default

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF3EDFC), // Light purple background
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Different FD for your specific needs',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1E1E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildAccordionItem(
            index: 0,
            title: 'Insured FDs',
            icon: Icons.shield,
            iconColor: Colors.blue,
            iconBgColor: Colors.blue.withOpacity(0.1),
            description: 'Invest with confidence knowing your FD is insured up to ₹5 lakh by DICGC, RBI\'s subsidiary.',
            cards: [
              _buildFDCard('Suryoday SF Bank', 'Instant withdrawal', '8.1', '2Y 6M', Colors.deepOrange),
              _buildFDCard('slice SF Bank', '3 hour withdrawal', '7.75', '1Y 5M 26D', Colors.purpleAccent),
            ],
          ),
          const SizedBox(height: 12),
          _buildAccordionItem(
            index: 1,
            title: 'FDs with SIP',
            icon: Icons.savings,
            iconColor: Colors.deepOrange,
            iconBgColor: Colors.deepOrange.withOpacity(0.1),
            description: 'Invest regularly with SIP and watch your savings grow steadily with assured returns.',
            cards: [
              _buildFDCard('Suryoday SF Bank', 'Upto ₹5L insured', '8.1', '2Y 6M', Colors.deepOrange),
              _buildFDCard('Shivalik SF Bank', 'Upto ₹5L insured', '7.8', '1Y 10M', Colors.teal),
            ],
          ),
          const SizedBox(height: 12),
          _buildAccordionItem(
            index: 2,
            title: 'Recurring Deposits (RDs)',
            icon: Icons.calendar_month,
            iconColor: Colors.green,
            iconBgColor: Colors.green.withOpacity(0.1),
            description: 'Build wealth monthly with guaranteed, locked-in returns through RDs.',
            cards: [
              _buildFDCard('Shivalik SF Bank', 'Upto ₹5L insured', '7.8', '1Y 10M', Colors.teal),
              _buildFDCard('Suryoday SF Bank', 'Upto ₹5L insured', '8.1', '2Y 6M', Colors.deepOrange),
            ],
          ),
          const SizedBox(height: 12),
          _buildAccordionItem(
            index: 3,
            title: 'Tax Saving Fixed Deposits',
            icon: Icons.percent,
            iconColor: Colors.teal,
            iconBgColor: Colors.teal.withOpacity(0.1),
            description: 'Claim deductions upto ₹1.5L under Section 80C while earning assured returns.',
            cards: [
              _buildFDCard('Suryoday SF Bank', 'Upto ₹5L insured', '8.0', '5Y', Colors.deepOrange),
              _buildFDCard('Shivalik SF Bank', 'Upto ₹5L insured', '6.5', '5Y', Colors.teal),
            ],
          ),
          const SizedBox(height: 12),
          _buildAccordionItem(
            index: 4,
            title: 'Quick Withdrawal FDs',
            icon: Icons.hourglass_bottom,
            iconColor: Colors.orange,
            iconBgColor: Colors.orange.withOpacity(0.1),
            description: 'Access your savings instantly with our FD partners - whenever you need it.',
            cards: [
              _buildFDCard('Suryoday SF Bank', 'Instant withdrawal', '8.1', '2Y 6M', Colors.deepOrange),
              _buildFDCard('slice SF Bank', '3 hour withdrawal', '7.75', '1Y 5M 26D', Colors.purpleAccent),
            ],
          ),
          const SizedBox(height: 12),
          _buildAccordionItem(
            index: 5,
            title: 'High Credit Rated FDs',
            icon: Icons.workspace_premium,
            iconColor: Colors.blueAccent,
            iconBgColor: Colors.blueAccent.withOpacity(0.1),
            description: 'Invest in high-rated NBFC FDs (ICRA/CRISIL) for stable, worry-free returns.',
            cards: [
              _buildFDCard('Bajaj Finance Ltd.', 'AAA+ Rated', '7.4', '2Y 7M', Colors.blue[800]!),
              _buildFDCard('Shriram Finance', 'AA+ Rated', '7.6', '3Y', Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccordionItem({
    required int index,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String description,
    required List<Widget> cards,
  }) {
    final isExpanded = _expandedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (_expandedIndex == index) {
                  _expandedIndex = -1; // Collapse if already expanded
                } else {
                  _expandedIndex = index;
                }
              });
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 14, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < cards.length; i++) ...[
                          cards[i],
                          if (i < cards.length - 1) const SizedBox(width: 12),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeOut,
          ),
        ],
      ),
    );
  }

  Widget _buildFDCard(String bankName, String badgeText, String rate, String tenure, Color logoColor) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: logoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(Icons.account_balance, color: logoColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            bankName,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              color: Color(0xFF1E1E1E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE5C06A), // Ochre/Golden
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B4310),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                rate,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E1E1E), // Black text for this rate
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                '% p.a.',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            tenure,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          _InvestNowButton(),
        ],
      ),
    );
  }
}

class _InvestNowButton extends StatefulWidget {
  @override
  State<_InvestNowButton> createState() => _InvestNowButtonState();
}

class _InvestNowButtonState extends State<_InvestNowButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {},
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF00C75A), // Bright green
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Invest now',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
