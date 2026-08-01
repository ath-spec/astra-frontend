import 'package:flutter/material.dart';
import 'widgets/mf_sip_empty_state.dart';

class SipScreen extends StatelessWidget {
  const SipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual state check when data is connected
    final bool isEmpty = true;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 24),
              child: Text(
                'SIPs',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  letterSpacing: -1.0,
                ),
              ),
            ),
            Expanded(
              child: isEmpty ? _buildEmptyState() : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const MfSipEmptyState();
  }

  Widget _buildContent() {
    return const Center(
      child: Text('SIP Content Goes Here'),
    );
  }
}
