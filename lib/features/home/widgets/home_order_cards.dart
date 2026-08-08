import 'package:flutter/material.dart';

class PortfolioCardData {
  final String fundName;
  final String currentValue;
  final String returnsString;
  final bool isPositive;

  const PortfolioCardData({
    required this.fundName,
    required this.currentValue,
    required this.returnsString,
    required this.isPositive,
  });
}

class HomePortfolioCards extends StatefulWidget {
  final List<PortfolioCardData> cards;

  const HomePortfolioCards({
    super.key,
    this.cards = const [
      PortfolioCardData(
        fundName: 'Canara Robeco Large Cap Fund',
        currentValue: '₹2,34,851',
        returnsString: '₹2,465.97 (1.06%)',
        isPositive: true,
      ),
      PortfolioCardData(
        fundName: 'HDFC Silver ETF FoF',
        currentValue: '₹184',
        returnsString: '₹0.56 (0.3%)',
        isPositive: true,
      ),
      PortfolioCardData(
        fundName: 'Quant Value Fund',
        currentValue: '₹95,200',
        returnsString: '₹1,200.50 (1.2%)',
        isPositive: true,
      ),
    ],
  });

  @override
  State<HomePortfolioCards> createState() => _HomePortfolioCardsState();
}

class _HomePortfolioCardsState extends State<HomePortfolioCards> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none, // Allow shadow to bleed
        itemCount: widget.cards.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return _PortfolioCard(data: widget.cards[index]);
        },
      ),
    );
  }
}

class _PortfolioCard extends StatefulWidget {
  final PortfolioCardData data;

  const _PortfolioCard({required this.data});

  @override
  State<_PortfolioCard> createState() => _PortfolioCardState();
}

class _PortfolioCardState extends State<_PortfolioCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        // Handle tap
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data.fundName,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B), // Slate 500
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                widget.data.currentValue,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    widget.data.isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 14,
                    color: widget.data.isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    widget.data.returnsString,
                    style: TextStyle(
                      fontFamily: 'DMMono',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.data.isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
