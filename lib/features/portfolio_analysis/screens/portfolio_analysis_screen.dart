import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PortfolioAnalysisScreen extends StatelessWidget {
  const PortfolioAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'ANALYSIS',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Color(0xFF64748B),
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Portfolio Analysis Dashboard Coming Soon...'),
      ),
    );
  }
}
