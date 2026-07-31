import 'package:flutter/material.dart';

class MfBondsBanner extends StatefulWidget {
  const MfBondsBanner({super.key});

  @override
  State<MfBondsBanner> createState() => _MfBondsBannerState();
}

class _MfBondsBannerState extends State<MfBondsBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildSlide1(),
                  _buildSlide2(),
                ],
              ),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(0),
                    const SizedBox(width: 8),
                    _buildDot(1),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Benefits',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildBenefit(Icons.trending_up, 'High-Quality\nBonds'),
                  ),
                  Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
                  Expanded(
                    child: _buildBenefit(Icons.security, 'SEBI-\nregulated'),
                  ),
                  Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
                  Expanded(
                    child: _buildBenefit(Icons.lock_open, 'No lock-in.\nSell anytime'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.black : Colors.black.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSlide1() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3EDFC), // Light purple
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 20),
              child: const Icon(Icons.monetization_on, color: Colors.amber, size: 80),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'More returns than FD',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF530582), // Deep purple
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'No lock-ins like FD',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Earn fixed returns up-to',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const Text(
                    '13.5%',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF530582),
                      letterSpacing: -2,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide2() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF333333)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invest in Baskets',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Expert curated basket of bonds for diversified, high yield investing.',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Explore Baskets',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Stack(
              alignment: Alignment.center,
              children: const [
                Icon(Icons.pie_chart, color: Colors.amber, size: 60),
                Positioned(top: 20, right: 10, child: Icon(Icons.show_chart, color: Colors.white54, size: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00C75A), size: 20), // Green icons
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }
}
