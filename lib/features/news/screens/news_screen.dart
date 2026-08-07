import 'package:flutter/material.dart';
import '../../home/widgets/home_wealth_feed.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isSecondCardStacked = ValueNotifier(false);

  @override
  void dispose() {
    _scrollController.dispose();
    _isSecondCardStacked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: const Text(
          'News & Insights',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            color: Color(0xFF0F172A),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.7), // Allow last card to scroll to top
              child: HomeWealthFeed(
                scrollController: _scrollController,
                isSecondCardStacked: _isSecondCardStacked,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
