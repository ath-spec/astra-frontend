import 'dart:ui' show lerpDouble, ImageFilter;
import 'package:flutter/material.dart';
import 'widgets/mf_holdings_empty_state.dart';
import 'widgets/mf_holdings_header.dart';

class HoldingsScreen extends StatefulWidget {
  const HoldingsScreen({super.key});

  @override
  State<HoldingsScreen> createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends State<HoldingsScreen> {
  bool _hasImportedPortfolio = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: HoldingsHeaderDelegate(
              safeAreaTop: MediaQuery.of(context).padding.top,
              screenHeight: MediaQuery.of(context).size.height,
              hasImportedPortfolio: _hasImportedPortfolio,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                children: [
                  MfHoldingsEmptyState(
                    title: "Your AI Investment Guide",
                    subtitle: "Discover investments tailored to your goals, risk profile, and financial journey.",
                    ctaText: "Explore Investments",
                    imagePath: 'lib/core/images/new_holding.webp',
                    onCtaTapped: () {
                      setState(() {
                        _hasImportedPortfolio = false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  MfHoldingsEmptyState(
                    title: "Unlock Portfolio Intelligence",
                    subtitle: "Import your holdings to unlock personalized insights, risk analysis, and smarter recommendations.",
                    ctaText: "Import Portfolio",
                    imagePath: 'lib/core/images/holdingsnewstocks.webp',
                    onCtaTapped: () {
                      setState(() {
                        _hasImportedPortfolio = true;
                      });
                    },
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


