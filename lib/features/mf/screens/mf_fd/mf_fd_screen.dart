import 'package:flutter/material.dart';

import 'widgets/mf_fd_banner.dart';
import 'widgets/mf_fd_highest_rates.dart';
import 'widgets/mf_fd_plans_list.dart';
import 'widgets/mf_fd_specific_needs.dart';

class MfFdScreen extends StatelessWidget {
  const MfFdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 246, 246), // Dark header
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Fixed Deposit',
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
          // Constrain width for larger screens (tablets/web) to maintain layout proportions
          final double maxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth;
          
          return Center(
            child: SizedBox(
              width: maxWidth,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    MfFdBanner(),
                    SizedBox(height: 32),
                    MfFdHighestRates(),
                    SizedBox(height: 32),
                    MfFdPlansList(),
                    SizedBox(height: 32),
                    MfFdSpecificNeeds(),
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
