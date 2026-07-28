import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Explore',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: const Center(
        child: Text(
          'Explore opportunities coming soon',
          style: TextStyle(
            fontFamily: 'DMSans',
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
