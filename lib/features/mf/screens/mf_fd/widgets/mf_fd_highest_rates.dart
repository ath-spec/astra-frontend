import 'package:flutter/material.dart';

class MfFdHighestRates extends StatefulWidget {
  const MfFdHighestRates({super.key});

  @override
  State<MfFdHighestRates> createState() => _MfFdHighestRatesState();
}

class _MfFdHighestRatesState extends State<MfFdHighestRates> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;
  double _itemWidth = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_itemWidth > 0 && _scrollController.hasClients) {
      int newIndex = (_scrollController.offset / _itemWidth).round();
      if (newIndex < 0) newIndex = 0;
      if (newIndex > 4) newIndex = 4;
      if (newIndex != _currentIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final cardWidth = screenWidth * 0.42; // Adjusted slightly for constrained width
        _itemWidth = cardWidth + 12;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Highest FD rates for you',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1E1E),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRateCard(
                    width: cardWidth,
                    rate: '8.1',
                    bankName: 'Suryoday SF Bank',
                    badgeText: 'Insured up to ₹5L',
                  ),
                  const SizedBox(width: 12),
                  _buildRateCard(
                    width: cardWidth,
                    rate: '7.4',
                    bankName: 'Bajaj Finance Ltd.',
                    badgeText: 'Highest Credit Rating',
                  ),
                  const SizedBox(width: 12),
                  _buildRateCard(
                    width: cardWidth,
                    rate: '7.75',
                    bankName: 'slice SF Bank',
                    badgeText: 'Insured Up to ₹5L',
                  ),
                  const SizedBox(width: 12),
                  _buildRateCard(
                    width: cardWidth,
                    rate: '7.6',
                    bankName: 'Shriram Finance',
                  ),
                  const SizedBox(width: 12),
                  _buildRateCard(
                    width: cardWidth,
                    rate: '7.8',
                    bankName: 'Shivalik SF Bank',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? const Color(0xFF00C75A) : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRateCard({
    required double width,
    required String rate,
    required String bankName,
    String? badgeText,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badgeText != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: const BoxDecoration(
                color: Color(0xFFE5C06A), // Ochre/Golden from the screenshot
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5B4310),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const SizedBox(height: 12), // Spacer if no badge

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badgeText == null) const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      rate,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00C75A), // Bright green
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '% p.a.',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00C75A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  bankName,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    color: Color(0xFF475569), // slate 600
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
