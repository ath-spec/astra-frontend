import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/watchlist_provider.dart';
import '../mf_explore/data/mf_mock_fund_data.dart';
import '../fund_profile/mf_fund_profile_screen.dart';

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No items added yet',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);
    
    if (watchlist.isEmpty) {
      return const _PlaceholderScreen(title: 'Watchlist', icon: Icons.bookmark_outline_rounded);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'My Watchlist',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: watchlist.length,
        itemBuilder: (context, index) {
          final fundId = watchlist[index];
          final fundData = MfMockFundData.getFundData(fundId);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () => MfFundProfileScreen.showModal(context, fundId),
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    // Logo Circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Center(
                        child: Text(
                          fundData.logoText.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fundData.name,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fundData.tags,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          fundData.returnPercentage,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: fundData.chartColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fundData.returnDuration,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
