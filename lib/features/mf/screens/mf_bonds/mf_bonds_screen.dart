import 'package:flutter/material.dart';

import 'widgets/mf_bonds_banner.dart';
import 'widgets/mf_bonds_list.dart';
import 'widgets/mf_bonds_know_more.dart';
import 'widgets/mf_bonds_faq.dart';

class MfBondsScreen extends StatelessWidget {
  const MfBondsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey/off-white background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB), // Dark header like screenshot
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Bonds',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth;
          
          return Center(
            child: SizedBox(
              width: maxWidth,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    MfBondsBanner(),
                    SizedBox(height: 24),
                    MfBondsList(),
                    SizedBox(height: 24),
                    MfBondsKnowMore(),
                    SizedBox(height: 24),
                    MfBondsFaq(),
                    SizedBox(height: 32),
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
