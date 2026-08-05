import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class HomeWealthFeed extends StatefulWidget {
  const HomeWealthFeed({super.key});

  @override
  State<HomeWealthFeed> createState() => _HomeWealthFeedState();
}

class _HomeWealthFeedState extends State<HomeWealthFeed> {
  late Timer _timer;
  String _currentTimeIst = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    // Current time in UTC + 5:30 for IST
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    setState(() {
      _currentTimeIst = DateFormat('hh:mm a').format(now);
    });
  }

  final List<Map<String, dynamic>> _newsItems = [
    {
      'image': 'lib/core/images/budget_analysis.webp',
      'tags': ['Top News', '• Trending'],
      'title': 'Income Tax Department\'s NUDGE drive leads to 1.25 crore updated ITRs',
      'description': 'The CBDT\'s technology-driven NUDGE campaign prompted 1.25 crore taxpayers to revise or update their ITRs over FY25.',
      'source': 'LiveMint',
    },
    {
      'image': 'lib/core/images/growth_card.webp',
      'tags': ['News from our experts'],
      'title': 'A 3 year investment break turned ₹17 crore into ₹12.1 crore',
      'description': 'Two investors start with ₹1 crore each, both compounding at 12% for 25 years. The first stays uninterrupted and ends with ₹17 crore.',
      'source': 'Economic Times',
    },
    {
      'image': 'lib/core/images/ai.webp',
      'tags': ['Tech', '• Hot'],
      'title': 'AI Stocks Rally: Are we in a bubble or a new era?',
      'description': 'Global tech funds see massive inflows as semiconductor and AI software companies post record-breaking quarterly guidance.',
      'source': 'MoneyControl',
    },
    {
      'image': 'lib/core/images/safe_investments.webp',
      'tags': ['Bonds', 'Alert'],
      'title': 'RBI holds repo rate steady at 6.5%',
      'description': 'The Monetary Policy Committee has decided to keep the repo rate unchanged for the sixth consecutive meeting, focusing on inflation.',
      'source': 'Bloomberg Quint',
    },
    {
      'image': 'lib/core/images/mag_7.webp',
      'tags': ['Global Investing'],
      'title': 'Magnificent 7 stocks drive 80% of S&P 500 returns',
      'description': 'Tech giants continue their dominant run, leaving traditional value stocks trailing behind in the first half of the year.',
      'source': 'CNBC TV18',
    },
    {
      'image': 'lib/core/images/realestate.webp',
      'tags': ['Real Estate'],
      'title': 'Commercial real estate sees 15% bump in tier 2 cities',
      'description': 'As companies push for hybrid models, tier 2 cities are emerging as the new hotspots for commercial real estate investments.',
      'source': 'LiveMint',
    },
    {
      'image': 'lib/core/images/gold.webp',
      'tags': ['Commodities', '• Trending'],
      'title': 'Gold hits new all-time high amid geopolitical tensions',
      'description': 'Safe-haven demand surges as investors seek shelter from market volatility, pushing gold prices to unprecedented levels.',
      'source': 'Reuters',
    },
    {
      'image': 'lib/core/images/silver.webp',
      'tags': ['Commodities'],
      'title': 'Silver follows gold\'s rally, breaks key resistance',
      'description': 'Industrial demand coupled with precious metal momentum creates a perfect storm for silver prices this quarter.',
      'source': 'ET Markets',
    },
    {
      'image': 'lib/core/images/invits.webp',
      'tags': ['Infrastructure'],
      'title': 'New INVIT guidelines to boost retail participation',
      'description': 'SEBI\'s latest circular reduces minimum investment limits, making Infrastructure Investment Trusts more accessible.',
      'source': 'Business Standard',
    },
    {
      'image': 'lib/core/images/new_budget.webp',
      'tags': ['Taxation', 'Update'],
      'title': 'New tax regime sees 60% adoption among millennials',
      'description': 'Simplified tax structures and reduced surcharge rates make the new tax regime the preferred choice for young earners.',
      'source': 'Financial Express',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your wealth feed',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E), // Green
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last updated: Today, $_currentTimeIst',
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Feed
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: _newsItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            final item = _newsItems[index];
            return _WealthFeedCard(
              imagePath: item['image'],
              tags: List<String>.from(item['tags']),
              title: item['title'],
              description: item['description'],
              source: item['source'],
            );
          },
        ),
      ],
    );
  }
}

class _WealthFeedCard extends StatefulWidget {
  final String imagePath;
  final List<String> tags;
  final String title;
  final String description;
  final String source;

  const _WealthFeedCard({
    required this.imagePath,
    required this.tags,
    required this.title,
    required this.description,
    required this.source,
  });

  @override
  State<_WealthFeedCard> createState() => _WealthFeedCardState();
}

class _WealthFeedCardState extends State<_WealthFeedCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: const Cubic(0.23, 1, 0.32, 1), // Strong ease-out (Emil)
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4), // As specifically requested by user
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Content Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags
                    Row(
                      children: widget.tags.map((tag) {
                        final isTrending = tag.toLowerCase().contains('trending') || tag.toLowerCase().contains('hot');
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isTrending) ...[
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444), // Red
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  tag.replaceAll('•', '').trim(),
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isTrending ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      widget.description,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    
                    // Source
                    Text(
                      'Source: ${widget.source}',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Read More Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Read summary',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: Color(0xFF0F172A),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
